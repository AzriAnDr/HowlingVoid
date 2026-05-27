import fs from 'node:fs';
import path from 'node:path';

const REPO_ROOT = process.cwd();
const SEARCH_ROOTS = ['code'];
const DEFAULT_OUTPUT = 'tmp/build/content-validate.json';
const TYPE_HEADER_PATTERN = /^\s*(\/[^\s(]+)\s*(?:(?=\/\/)\/\/.*)?$/gm;

const MANIFESTS = [
  {
    kind: 'loadout_items',
    file: 'config/content/loadout_items.json',
    requiredFields: ['id', 'template_type', 'name', 'item_path'],
    pathFields: {
      template_type: '/datum/loadout_item',
      item_path: '/obj/item',
      reskin_datum: '/datum/atom_skin',
    },
    assocPathKeyFields: {
      job_greyscale_palettes: '/datum',
    },
    uniqueFields: ['id', 'item_path'],
  },
];

function normalizePath(filePath) {
  return filePath.replaceAll('\\', '/');
}

function walkFiles(root, extension = '.dm') {
  const normalizedRoot = normalizePath(root);
  if (!fs.existsSync(normalizedRoot)) {
    return [];
  }

  const files = [];
  const stack = [normalizedRoot];
  while (stack.length > 0) {
    const current = stack.pop();
    if (!current) {
      continue;
    }

    for (const entry of fs.readdirSync(current, { withFileTypes: true })) {
      const entryPath = normalizePath(path.join(current, entry.name));
      if (entry.isDirectory()) {
        stack.push(entryPath);
        continue;
      }
      if (entry.name.endsWith(extension)) {
        files.push(entryPath);
      }
    }
  }

  files.sort();
  return files;
}

function collectDeclaredTypes() {
  const declaredTypes = new Set();
  for (const root of SEARCH_ROOTS) {
    for (const filePath of walkFiles(root)) {
      const contents = fs.readFileSync(filePath, 'utf8');
      for (const match of contents.matchAll(TYPE_HEADER_PATTERN)) {
        const typePath = match[1];
        declaredTypes.add(typePath);

        const segments = typePath.split('/').filter(Boolean);
        for (let index = 1; index < segments.length; index += 1) {
          declaredTypes.add(`/${segments.slice(0, index).join('/')}`);
        }
      }
    }
  }
  return declaredTypes;
}

function normalizeTypePathString(value) {
  if (typeof value !== 'string') {
    return value;
  }

  const commentIndex = value.indexOf('//');
  if (commentIndex >= 0) {
    return value.slice(0, commentIndex).trim();
  }
  return value.trim();
}

function validatePathRef(errors, declaredTypes, manifestKind, entryId, fieldName, value, expectedRoot) {
  if (value === null || value === undefined) {
    return;
  }
  const normalizedValue = normalizeTypePathString(value);
  if (typeof normalizedValue !== 'string' || !normalizedValue.startsWith('/')) {
    errors.push(`${manifestKind}:${entryId}:${fieldName} must be a DM typepath string.`);
    return;
  }
  if (!(normalizedValue === expectedRoot || normalizedValue.startsWith(`${expectedRoot}/`))) {
    errors.push(`${manifestKind}:${entryId}:${fieldName} must be under ${expectedRoot}, got ${normalizedValue}.`);
  }
  if (!declaredTypes.has(normalizedValue)) {
    errors.push(`${manifestKind}:${entryId}:${fieldName} points to missing type ${normalizedValue}.`);
  }
}

function validateAssocPathKeys(errors, declaredTypes, manifestKind, entryId, fieldName, value, expectedRoot) {
  if (value === null || value === undefined) {
    return;
  }
  if (Array.isArray(value) || typeof value !== 'object') {
    errors.push(`${manifestKind}:${entryId}:${fieldName} must be an object with DM typepath keys.`);
    return;
  }

  for (const rawKey of Object.keys(value)) {
    validatePathRef(errors, declaredTypes, manifestKind, entryId, `${fieldName} key`, rawKey, expectedRoot);
  }
}

function validateManifest(manifest, declaredTypes, errors, warnings) {
  const absolutePath = path.join(REPO_ROOT, manifest.file);
  if (!fs.existsSync(absolutePath)) {
    warnings.push(`${manifest.kind}: skipped, manifest file is missing (${manifest.file}).`);
    return {
      kind: manifest.kind,
      file: manifest.file,
      entries: 0,
      skipped: true,
    };
  }

  let decoded;
  try {
    decoded = JSON.parse(fs.readFileSync(absolutePath, 'utf8'));
  } catch (error) {
    errors.push(`${manifest.kind}: failed to parse ${manifest.file}: ${error instanceof Error ? error.message : error}`);
    return {
      kind: manifest.kind,
      file: manifest.file,
      entries: 0,
      skipped: false,
    };
  }

  if (Array.isArray(decoded) || typeof decoded !== 'object' || decoded === null) {
    errors.push(`${manifest.kind}: ${manifest.file} must decode to an object keyed by entry id.`);
    return {
      kind: manifest.kind,
      file: manifest.file,
      entries: 0,
      skipped: false,
    };
  }

  const uniqueTrackers = new Map(
    manifest.uniqueFields.map((fieldName) => [fieldName, new Map()]),
  );

  let entries = 0;
  for (const [entryKey, entryValue] of Object.entries(decoded)) {
    entries += 1;
    if (Array.isArray(entryValue) || typeof entryValue !== 'object' || entryValue === null) {
      errors.push(`${manifest.kind}:${entryKey} must be an object.`);
      continue;
    }

    const entry = entryValue;
    const entryId = typeof entry.id === 'string' && entry.id.length > 0 ? entry.id : entryKey;

    for (const requiredField of manifest.requiredFields) {
      const value = entry[requiredField];
      if (value === null || value === undefined || value === '') {
        errors.push(`${manifest.kind}:${entryId} is missing required field ${requiredField}.`);
      }
    }

    for (const uniqueField of manifest.uniqueFields) {
      const tracker = uniqueTrackers.get(uniqueField);
      if (!tracker) {
        continue;
      }
      const value = entry[uniqueField];
      if (value === null || value === undefined || value === '') {
        continue;
      }
      const normalizedValue = typeof value === 'string' ? normalizeTypePathString(value) : JSON.stringify(value);
      const previous = tracker.get(normalizedValue);
      if (previous) {
        const message = `${manifest.kind}:${entryId} duplicates ${uniqueField}=${normalizedValue} already used by ${previous}.`;
        if (manifest.warningUniqueFields?.includes(uniqueField)) {
          warnings.push(message);
        } else {
          errors.push(message);
        }
      } else {
        tracker.set(normalizedValue, entryId);
      }
    }

    for (const [fieldName, expectedRoot] of Object.entries(manifest.pathFields)) {
      if (!(fieldName in entry)) {
        continue;
      }
      validatePathRef(errors, declaredTypes, manifest.kind, entryId, fieldName, entry[fieldName], expectedRoot);
    }

    for (const [fieldName, expectedRoot] of Object.entries(manifest.assocPathKeyFields)) {
      if (!(fieldName in entry)) {
        continue;
      }
      validateAssocPathKeys(errors, declaredTypes, manifest.kind, entryId, fieldName, entry[fieldName], expectedRoot);
    }

  }

  return {
    kind: manifest.kind,
    file: manifest.file,
    entries,
    skipped: false,
  };
}

function main() {
  const outputPath = normalizePath(process.argv[2] ?? DEFAULT_OUTPUT);
  const declaredTypes = collectDeclaredTypes();
  const errors = [];
  const warnings = [];
  const manifests = MANIFESTS.map((manifest) =>
    validateManifest(manifest, declaredTypes, errors, warnings),
  );

  const report = {
    generatedAt: new Date().toISOString(),
    declaredTypeCount: declaredTypes.size,
    errors,
    warnings,
    manifests,
  };

  fs.mkdirSync(path.dirname(path.join(REPO_ROOT, outputPath)), { recursive: true });
  fs.writeFileSync(path.join(REPO_ROOT, outputPath), `${JSON.stringify(report, null, 2)}\n`);

  for (const warning of warnings) {
    console.warn(`warning: ${warning}`);
  }
  if (errors.length > 0) {
    for (const error of errors) {
      console.error(`error: ${error}`);
    }
    process.exitCode = 1;
    return;
  }

  const summary = manifests
    .map((manifest) => `${manifest.kind}=${manifest.entries}${manifest.skipped ? ' (skipped)' : ''}`)
    .join(', ');
  console.log(`Validated content manifests: ${summary}`);
}

main();
