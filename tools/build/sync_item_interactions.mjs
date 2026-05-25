import fs from 'node:fs';
import path from 'node:path';

const defaultSourcePath = 'code/modules/interaction_menu/item_interactions.dm';
const sourcePath = process.argv[2] ?? defaultSourcePath;
const rewrittenDmPath = process.argv[3] ?? defaultSourcePath;
const outputPath = process.argv[4] ?? 'config/interactions/item_interactions.master.json';

const CONSTANTS = new Map([
  ['TRUE', true],
  ['FALSE', false],
  ['INTERACTION_SELF', 'self'],
  ['INTERACTION_OTHER', 'other'],
  ['INTERACTION_REQUIRE_SELF_HAND', 'self_hand'],
  ['INTERACTION_REQUIRE_TARGET_HAND', 'target_hand'],
  ['INTERACTION_REQUIRE_SELF_MOUTH', 'self_mouth'],
  ['INTERACTION_REQUIRE_TARGET_MOUTH', 'target_mouth'],
  ['INTERACTION_REQUIRE_SELF_TK', 'self_tk'],
]);

const ROOT_TEMPLATE_PATHS = new Set([
  '/datum/interaction/howling_item',
  '/datum/interaction/howling_item_inserted',
]);

function normalizePath(filePath) {
  return filePath.replaceAll('\\', '/');
}

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

function splitTopLevel(text) {
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
    if (char === ',' && depth === 0) {
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

function parseDmString(text) {
  const quote = text[0];
  let result = '';
  let escaped = false;

  for (let index = 1; index < text.length - 1; index += 1) {
    const char = text[index];
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

function parseDmLiteral(rawValue) {
  const value = rawValue.trim();
  if (CONSTANTS.has(value)) {
    return CONSTANTS.get(value);
  }
  if (/^-?\d+$/.test(value)) {
    return Number.parseInt(value, 10);
  }
  if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
    return parseDmString(value);
  }
  if (value.startsWith('list(') && value.endsWith(')')) {
    const inner = value.slice(5, -1).trim();
    if (!inner.length) {
      return [];
    }
    return splitTopLevel(inner).map(parseDmLiteral);
  }
  if (value.startsWith('/')) {
    return value;
  }
  return value;
}

function directParentPath(typePath) {
  const lastSlash = typePath.lastIndexOf('/');
  if (lastSlash <= 0) {
    return null;
  }
  return typePath.slice(0, lastSlash);
}

function parseBlocks(fileContents) {
  const lines = fileContents.replaceAll('\r\n', '\n').split('\n');
  const blocks = [];
  let currentBlock = null;

  const flushBlock = () => {
    if (!currentBlock) {
      return;
    }
    while (
      currentBlock.lines.length > 0 &&
      currentBlock.lines[currentBlock.lines.length - 1].trim().length === 0
    ) {
      currentBlock.lines.pop();
    }
    blocks.push(currentBlock);
    currentBlock = null;
  };

  for (const line of lines) {
    if (/^\/datum\/interaction\/[^\s(]*\s*$/.test(line)) {
      flushBlock();
      currentBlock = {
        path: line.trim(),
        lines: [line],
        properties: new Map(),
        parentType: null,
      };
      continue;
    }

    if (!currentBlock) {
      continue;
    }

    currentBlock.lines.push(line);
  }

  flushBlock();

  for (const block of blocks) {
    let currentProperty = null;
    let currentValue = '';
    let parenDepth = 0;

    const commitProperty = () => {
      if (!currentProperty) {
        return;
      }
      block.properties.set(currentProperty, currentValue.trim());
      if (currentProperty === 'parent_type') {
        block.parentType = currentValue.trim();
      }
      currentProperty = null;
      currentValue = '';
      parenDepth = 0;
    };

    for (const line of block.lines.slice(1)) {
      const propertyMatch = line.match(/^\t([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)$/);
      if (currentProperty && !propertyMatch) {
        currentValue += `\n${line.trim()}`;
        parenDepth += countParenDelta(line);
        if (parenDepth <= 0) {
          commitProperty();
        }
        continue;
      }

      if (propertyMatch) {
        if (currentProperty) {
          commitProperty();
        }
        currentProperty = propertyMatch[1];
        currentValue = propertyMatch[2];
        parenDepth = countParenDelta(propertyMatch[2]);
        if (parenDepth <= 0) {
          commitProperty();
        }
      }
    }

    commitProperty();
  }

  return blocks;
}

function formatTemplateBlock(block) {
  const lines = [...block.lines];
  if (ROOT_TEMPLATE_PATHS.has(block.path) && !lines.some((line) => line.includes('register_in_menu = FALSE'))) {
    lines.splice(1, 0, '\tregister_in_menu = FALSE');
  }
  return `${lines.join('\n')}\n`;
}

function main() {
  const fileContents = fs.readFileSync(sourcePath, 'utf8');
  const blocks = parseBlocks(fileContents);
  const blockByPath = new Map(blocks.map((block) => [block.path, block]));
  const childCounts = new Map();

  const addChild = (parentPath) => {
    if (!parentPath) {
      return;
    }
    childCounts.set(parentPath, (childCounts.get(parentPath) ?? 0) + 1);
  };

  for (const block of blocks) {
    addChild(block.parentType ?? directParentPath(block.path));
  }

  const keptBlocks = [];
  const leafBlocks = [];

  for (const block of blocks) {
    const looksLikeTemplate =
      !block.properties.has('name') &&
      !block.properties.has('description') &&
      !block.properties.has('message');

    if ((childCounts.get(block.path) ?? 0) > 0 || looksLikeTemplate) {
      keptBlocks.push(block);
      continue;
    }
    leafBlocks.push(block);
  }

  const registry = {};

  for (const block of leafBlocks) {
    const templateType = block.parentType ?? directParentPath(block.path);
    if (!templateType) {
      throw new Error(`Unable to determine template type for ${block.path}`);
    }

    const entry = {
      interaction_id: block.path,
      template_type: templateType,
    };

    for (const [property, rawValue] of block.properties.entries()) {
      if (property === 'parent_type') {
        continue;
      }
      entry[property] = parseDmLiteral(rawValue);
    }

    registry[block.path] = entry;
  }

  if (leafBlocks.length === 0) {
    throw new Error(
      `No leaf item interactions were found in ${normalizePath(sourcePath)}. Pass an unmigrated source snapshot as the first argument.`,
    );
  }

  const nextDmContents = `${keptBlocks.map(formatTemplateBlock).join('\n').trimEnd()}\n`;

  fs.mkdirSync(path.dirname(outputPath), { recursive: true });
  fs.mkdirSync(path.dirname(rewrittenDmPath), { recursive: true });
  fs.writeFileSync(rewrittenDmPath, nextDmContents);
  fs.writeFileSync(outputPath, `${JSON.stringify(registry, null, 2)}\n`);

  const keptCount = keptBlocks.length;
  const leafCount = leafBlocks.length;
  console.log(
    `Synced item interaction registry: kept ${keptCount} DM templates, exported ${leafCount} leaf interactions to ${normalizePath(outputPath)}`,
  );

  const missingTemplates = leafBlocks.filter((block) => {
    const templateType = block.parentType ?? directParentPath(block.path);
    return templateType && !blockByPath.has(templateType);
  });
  if (missingTemplates.length > 0) {
    console.warn(
      `Warning: ${missingTemplates.length} interactions inherit from template types outside ${normalizePath(sourcePath)}.`,
    );
  }
}

main();
