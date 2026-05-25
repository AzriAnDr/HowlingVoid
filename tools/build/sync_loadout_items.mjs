import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';

const REPO_ROOT = process.cwd();
const SEARCH_ROOTS = ['code'];
const DEFAULT_OUTPUT = 'config/content/loadout_items.json';

function normalizePath(filePath) {
  return filePath.replaceAll('\\', '/');
}

function parseCliArgs(argv) {
  const options = {
    outputPath: DEFAULT_OUTPUT,
    manifestOnly: false,
    fromGitHead: false,
  };
  const positional = [];

  for (const arg of argv) {
    switch (arg) {
      case '--manifest-only':
        options.manifestOnly = true;
        break;
      case '--from-git-head':
        options.fromGitHead = true;
        break;
      default:
        positional.push(arg);
        break;
    }
  }

  if (positional[0]) {
    options.outputPath = normalizePath(positional[0]);
  }

  if (options.fromGitHead && !options.manifestOnly) {
    throw new Error('--from-git-head requires --manifest-only.');
  }

  return options;
}

const CLI_OPTIONS = parseCliArgs(process.argv.slice(2));
let cachedGitHeadTrackedFiles = null;

function getGitHeadTrackedFiles() {
  if (cachedGitHeadTrackedFiles) {
    return cachedGitHeadTrackedFiles;
  }

  const tracked = execFileSync(
    'git',
    ['ls-files', ...SEARCH_ROOTS],
    { cwd: REPO_ROOT, encoding: 'utf8' },
  )
    .split(/\r?\n/)
    .map((line) => normalizePath(line.trim()))
    .filter(Boolean);

  cachedGitHeadTrackedFiles = new Set(tracked);
  return cachedGitHeadTrackedFiles;
}

function readSourceFile(filePath) {
  const normalizedPath = normalizePath(filePath);
  if (CLI_OPTIONS.fromGitHead && getGitHeadTrackedFiles().has(normalizedPath)) {
    return execFileSync(
      'git',
      ['show', `HEAD:${normalizedPath}`],
      { cwd: REPO_ROOT, encoding: 'utf8' },
    );
  }

  return fs.readFileSync(normalizedPath, 'utf8');
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

function loadDefineMap() {
  const defineFiles = SEARCH_ROOTS
    .flatMap((root) => walkFiles(root))
    .filter((filePath) => filePath.includes('/__DEFINES/'));

  const rawDefines = new Map();
  for (const filePath of defineFiles) {
    const lines = readSourceFile(filePath).replaceAll('\r\n', '\n').split('\n');
    for (const line of lines) {
      const match = line.match(/^#define\s+([A-Z0-9_]+)\s+(.+)$/);
      if (!match) {
        continue;
      }
      if (match[1].includes('(')) {
        continue;
      }
      rawDefines.set(match[1], match[2].trim());
    }
  }

  const cache = new Map([
    ['TRUE', true],
    ['FALSE', false],
    ['NULL', null],
    ['NONE', 0],
  ]);

  const evaluating = new Set();

  const evaluate = (name) => {
    if (cache.has(name)) {
      return cache.get(name);
    }
    if (evaluating.has(name)) {
      throw new Error(`Circular define dependency while evaluating ${name}`);
    }

    const raw = rawDefines.get(name);
    if (!raw) {
      throw new Error(`Unknown define ${name}`);
    }

    evaluating.add(name);
    try {
      const value = evaluateExpression(raw);
      cache.set(name, value);
      return value;
    } finally {
      evaluating.delete(name);
    }
  };

  const evaluateExpression = (expression) => {
    if (/^".*"$/.test(expression) || /^'.*'$/.test(expression)) {
      return expression.slice(1, -1);
    }
    if (/^-?\d+(\.\d+)?$/.test(expression)) {
      return Number(expression);
    }
    if (/^null$/i.test(expression)) {
      return null;
    }

    let transformed = expression;
    transformed = transformed.replace(/\bTRUE\b/g, 'true');
    transformed = transformed.replace(/\bFALSE\b/g, 'false');
    transformed = transformed.replace(/\bNULL\b/gi, 'null');

    transformed = transformed.replace(/\b([A-Z][A-Z0-9_]+)\b/g, (full, token) => {
      if (token === 'TRUE' || token === 'FALSE' || token === 'NULL') {
        return full;
      }
      if (!rawDefines.has(token) && !cache.has(token)) {
        return full;
      }
      const value = evaluate(token);
      return JSON.stringify(value);
    });

    if (/[A-Z][A-Z0-9_]+/.test(transformed)) {
      throw new Error(`Unsupported identifier in expression: ${expression}`);
    }

    return Function(`"use strict"; return (${transformed});`)();
  };

  return {
    has(name) {
      return rawDefines.has(name) || cache.has(name);
    },
    get(name) {
      return evaluate(name);
    },
    evaluateExpression,
  };
}

const DEFINE_MAP = loadDefineMap();

function countParenDelta(text) {
  let depth = 0;
  let quote = null;
  let escaped = false;

  for (const char of text) {
    if (escaped) {
      escaped = false;
      continue;
    }
    if (char === '\\') {
      escaped = true;
      continue;
    }
    if (quote) {
      if (char === quote) {
        quote = null;
      }
      continue;
    }
    if (char === '"' || char === "'") {
      quote = char;
      continue;
    }
    if (char === '(') {
      depth += 1;
      continue;
    }
    if (char === ')') {
      depth -= 1;
    }
  }

  return depth;
}

function splitTopLevel(text, separator = ',') {
  const parts = [];
  let current = '';
  let depth = 0;
  let quote = null;
  let escaped = false;

  for (const char of text) {
    if (escaped) {
      current += char;
      escaped = false;
      continue;
    }
    if (char === '\\') {
      current += char;
      escaped = true;
      continue;
    }
    if (quote) {
      current += char;
      if (char === quote) {
        quote = null;
      }
      continue;
    }
    if (char === '"' || char === "'") {
      current += char;
      quote = char;
      continue;
    }
    if (char === '(') {
      current += char;
      depth += 1;
      continue;
    }
    if (char === ')') {
      current += char;
      depth -= 1;
      continue;
    }
    if (char === separator && depth === 0) {
      if (current.trim().length > 0) {
        parts.push(current.trim());
      }
      current = '';
      continue;
    }
    current += char;
  }

  if (current.trim().length > 0) {
    parts.push(current.trim());
  }

  return parts;
}

function parseDmString(value) {
  const quote = value[0];
  let result = '';
  let escaped = false;

  for (let index = 1; index < value.length - 1; index += 1) {
    const char = value[index];
    if (escaped) {
      result += char;
      escaped = false;
      continue;
    }
    if (char === '\\') {
      escaped = true;
      continue;
    }
    if (char === quote) {
      continue;
    }
    result += char;
  }

  return result;
}

function findTopLevelEquals(text) {
  let depth = 0;
  let quote = null;
  let escaped = false;

  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    if (escaped) {
      escaped = false;
      continue;
    }
    if (char === '\\') {
      escaped = true;
      continue;
    }
    if (quote) {
      if (char === quote) {
        quote = null;
      }
      continue;
    }
    if (char === '"' || char === "'") {
      quote = char;
      continue;
    }
    if (char === '(') {
      depth += 1;
      continue;
    }
    if (char === ')') {
      depth -= 1;
      continue;
    }
    if (char === '=' && depth === 0) {
      return index;
    }
  }

  return -1;
}

function parseDmValue(rawValue) {
  let value = rawValue.trim();
  if (value.startsWith('/')) {
    value = value.replace(/\s*\/\/.*$/, '').trim();
  }
  if (!value.length) {
    return null;
  }
  if (/^-?\d+(\.\d+)?$/.test(value)) {
    return Number(value);
  }
  if (/^null$/i.test(value)) {
    return null;
  }
  if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
    return parseDmString(value);
  }
  if (value.startsWith('/')) {
    return value;
  }
  if (value.startsWith('list(') && value.endsWith(')')) {
    const inner = value.slice(5, -1).trim();
    if (!inner.length) {
      return [];
    }
    const parts = splitTopLevel(inner);
    const hasAssocEntries = parts.some((part) => findTopLevelEquals(part) >= 0);
    if (!hasAssocEntries) {
      return parts.map(parseDmValue);
    }

    const objectValue = {};
    for (const part of parts) {
      const equalsIndex = findTopLevelEquals(part);
      if (equalsIndex < 0) {
        throw new Error(`Mixed list styles are not supported: ${value}`);
      }
      const key = parseDmValue(part.slice(0, equalsIndex));
      const mappedValue = parseDmValue(part.slice(equalsIndex + 1));
      objectValue[String(key)] = mappedValue;
    }
    return objectValue;
  }
  if (DEFINE_MAP.has(value)) {
    return DEFINE_MAP.get(value);
  }
  return DEFINE_MAP.evaluateExpression(value);
}

function directParentPath(typePath) {
  const lastSlash = typePath.lastIndexOf('/');
  if (lastSlash <= 0) {
    return null;
  }
  return typePath.slice(0, lastSlash);
}

function ownerPathForProc(procPath) {
  let trimmed = procPath.trim();
  if (trimmed.includes('(')) {
    trimmed = trimmed.slice(0, trimmed.indexOf('('));
  }
  if (trimmed.includes('/proc/')) {
    return trimmed.slice(0, trimmed.indexOf('/proc/'));
  }
  return directParentPath(trimmed);
}

function parseTopLevelBlocks(fileContents) {
  const lines = fileContents.replaceAll('\r\n', '\n').split('\n');
  const blocks = [];
  let current = { kind: 'raw', lines: [] };

  const flush = () => {
    if (!current || current.lines.length === 0) {
      return;
    }
    blocks.push(current);
  };

  const typeHeaderPattern = /^\/datum\/loadout_item\/[^\s(]*\s*(?:(?=\/\/)\/\/.*)?$/;
  const procHeaderPattern = /^\/datum\/loadout_item\/[^\s]*\s*\(.*\)\s*(?:(?=\/\/)\/\/.*)?$/;

  for (const line of lines) {
    const trimmedLine = line.trim();
    const normalizedHeader = trimmedLine.replace(/\s*\/\/.*$/, '').trim();

    if (typeHeaderPattern.test(trimmedLine)) {
      flush();
      current = {
        kind: 'type',
        path: normalizedHeader,
        lines: [line],
      };
      continue;
    }
    if (procHeaderPattern.test(trimmedLine)) {
      flush();
      current = {
        kind: 'proc',
        path: normalizedHeader,
        ownerPath: ownerPathForProc(normalizedHeader),
        lines: [line],
      };
      continue;
    }

    current.lines.push(line);
  }

  flush();
  return blocks;
}

function parseProperties(typeBlock) {
  const properties = new Map();
  let currentProperty = null;
  let currentValue = '';
  let parenDepth = 0;

  const commit = () => {
    if (!currentProperty) {
      return;
    }
    properties.set(currentProperty, currentValue.trim());
    currentProperty = null;
    currentValue = '';
    parenDepth = 0;
  };

  for (const line of typeBlock.lines.slice(1)) {
    const propertyMatch = line.match(/^\t([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/);
    if (currentProperty && !propertyMatch) {
      currentValue += `\n${line.trim()}`;
      parenDepth += countParenDelta(line);
      if (parenDepth <= 0) {
        commit();
      }
      continue;
    }

    if (propertyMatch) {
      if (currentProperty) {
        commit();
      }
      currentProperty = propertyMatch[1];
      currentValue = propertyMatch[2];
      parenDepth = countParenDelta(propertyMatch[2]);
      if (parenDepth <= 0) {
        commit();
      }
    }
  }

  commit();
  return properties;
}

function rewriteLoadoutFile(filePath) {
  const original = readSourceFile(filePath);
  const blocks = parseTopLevelBlocks(original);
  const childCounts = new Map();
  const procOwners = new Set();

  for (const block of blocks) {
    if (block.kind === 'type') {
      const parentPath = directParentPath(block.path);
      if (parentPath) {
        childCounts.set(parentPath, (childCounts.get(parentPath) ?? 0) + 1);
      }
      continue;
    }
    if (block.kind === 'proc' && block.ownerPath) {
      procOwners.add(block.ownerPath);
    }
  }

  const manifestEntries = {};
  const keptBlocks = [];
  let exportedCount = 0;

  for (const block of blocks) {
    if (block.kind !== 'type') {
      keptBlocks.push(block);
      continue;
    }

    const hasChildren = (childCounts.get(block.path) ?? 0) > 0;
    const hasBehavior = procOwners.has(block.path);

    let properties;
    try {
      properties = parseProperties(block);
    } catch {
      keptBlocks.push(block);
      continue;
    }

    if (!properties.has('item_path')) {
      keptBlocks.push(block);
      continue;
    }

    const templateType = directParentPath(block.path);
    if (!templateType) {
      keptBlocks.push(block);
      continue;
    }

    try {
      const entry = {
        id: block.path,
        template_type: templateType,
      };

      for (const [property, rawValue] of properties.entries()) {
        entry[property] = parseDmValue(rawValue);
      }

      manifestEntries[block.path] = entry;
      exportedCount += 1;
    } catch {
      keptBlocks.push(block);
      continue;
    }

    // Keep non-leaf or behaviorful definitions in DM so child template types and procs remain intact.
    if (hasChildren || hasBehavior) {
      keptBlocks.push(block);
    }
  }

  if (!exportedCount) {
    return { changed: false, manifestEntries: {}, exportedCount: 0 };
  }

  const nextContents = keptBlocks.map((block) => block.lines.join('\n')).join('\n');
  const normalizedNextContents = `${nextContents.replace(/\n{3,}/g, '\n\n').trimEnd()}\n`;
  if (!CLI_OPTIONS.manifestOnly) {
    fs.writeFileSync(filePath, normalizedNextContents);
  }

  return {
    changed: normalizedNextContents !== original,
    manifestEntries,
    exportedCount,
  };
}

function main() {
  const outputPath = CLI_OPTIONS.outputPath;
  const dmFiles = SEARCH_ROOTS.flatMap((root) => walkFiles(root));

  let touchedFiles = 0;
  let exportedEntries = 0;
  const manifestEntries = {};

  for (const filePath of dmFiles) {
    const result = rewriteLoadoutFile(filePath);
    if (result.exportedCount > 0) {
      touchedFiles += 1;
      exportedEntries += result.exportedCount;
      Object.assign(manifestEntries, result.manifestEntries);
    }
  }

  fs.mkdirSync(path.dirname(path.join(REPO_ROOT, outputPath)), { recursive: true });
  fs.writeFileSync(path.join(REPO_ROOT, outputPath), `${JSON.stringify(manifestEntries, null, 2)}\n`);

  console.log(
    `Synced loadout manifest: exported ${exportedEntries} leaf entries from ${touchedFiles} files to ${outputPath}`,
  );
}

main();
