#!/usr/bin/env node
/**
 * Fails (exit 1) if any shared schema block declared in the mirrored contract
 * files has drifted apart:
 *   - najda_functions/src/contract.ts
 *   - lib/core/constants/firestore_contract.dart
 *   - ../najda-dashboard/src/lib/contract.js  (override with DASHBOARD_CONTRACT env var)
 *
 * Each file marks its blocks with matching `// CONTRACT:<BLOCK>:START` / `:END`
 * comments (works across Dart/TS/JS since all three use `//`). Within each
 * marked block, every single- or double-quoted string literal is extracted
 * and the resulting *set* of values is compared across every file that
 * declares that block — a file is free to not declare a block that doesn't
 * apply to it (e.g. the Flutter app has no use for dashboard-only blocks),
 * but any two files that BOTH declare a block must agree on its values.
 */
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, '..');

const DASHBOARD_CONTRACT =
  process.env.DASHBOARD_CONTRACT || 'E:\\najda-dashboard\\src\\lib\\contract.js';

const FILES = [
  { label: 'functions (contract.ts)', path: join(repoRoot, 'najda_functions', 'src', 'contract.ts') },
  { label: 'flutter (firestore_contract.dart)', path: join(repoRoot, 'lib', 'core', 'constants', 'firestore_contract.dart') },
  { label: 'dashboard (contract.js)', path: DASHBOARD_CONTRACT },
];

// Every file that DOES declare a block must agree on its values. A file that
// doesn't declare a block at all (no markers) is simply left out of that
// block's comparison — see extractBlock(). Only a malformed marker pair
// (start without end, or vice versa) is an error.
const BLOCKS = [
  'COLLECTIONS',
  'INCIDENT_STATUS',
  'AMBULANCE_STATUS',
  'INCIDENT_FIELDS',
  'AMBULANCE_FIELDS',
  'AMBULANCE_PRIVATE_FIELDS',
  'TRACKING_FIELDS',
  'CITIZEN_FIELDS',
  'NOTIFICATION_FIELDS',
  'AMBULANCE_HISTORY_FIELDS',
  'HOSPITAL_FIELDS',
  'DASHBOARD_ROLES',
  'DASHBOARD_USER_FIELDS',
];

/** Returns the text between a block's markers, or null if the file doesn't declare that block at all. */
function extractBlock(source, blockName) {
  const startMarker = `CONTRACT:${blockName}:START`;
  const endMarker = `CONTRACT:${blockName}:END`;
  const startIdx = source.indexOf(startMarker);
  const endIdx = source.indexOf(endMarker);
  if (startIdx === -1 && endIdx === -1) return null;
  if (startIdx === -1 || endIdx === -1 || endIdx < startIdx) {
    throw new Error(`malformed ${blockName} markers`);
  }
  return source.slice(startIdx + startMarker.length, endIdx);
}

function extractStringLiterals(blockText) {
  const re = /'([^'\\]*(?:\\.[^'\\]*)*)'|"([^"\\]*(?:\\.[^"\\]*)*)"/g;
  const values = new Set();
  let m;
  while ((m = re.exec(blockText)) !== null) {
    values.add(m[1] !== undefined ? m[1] : m[2]);
  }
  return values;
}

function setsEqual(a, b) {
  if (a.size !== b.size) return false;
  for (const v of a) if (!b.has(v)) return false;
  return true;
}

function diff(a, b) {
  const onlyInA = [...a].filter(v => !b.has(v));
  const onlyInB = [...b].filter(v => !a.has(v));
  return { onlyInA, onlyInB };
}

let failed = false;
const loaded = [];

for (const f of FILES) {
  if (!existsSync(f.path)) {
    console.error(`❌ required contract file missing: ${f.path}`);
    failed = true;
    continue;
  }
  loaded.push({ ...f, source: readFileSync(f.path, 'utf8') });
}

if (loaded.length < 2) {
  console.error('❌ need at least 2 contract files to compare, found', loaded.length);
  process.exit(1);
}

for (const blockName of BLOCKS) {
  const extracted = [];
  for (const f of loaded) {
    try {
      const block = extractBlock(f.source, blockName);
      if (block !== null) extracted.push({ label: f.label, values: extractStringLiterals(block) });
    } catch (err) {
      console.error(`❌ [${f.label}] ${err.message}`);
      failed = true;
    }
  }

  if (extracted.length < 2) {
    if (extracted.length === 1) {
      console.log(`ℹ️  ${blockName}: only declared by ${extracted[0].label}, nothing to compare`);
    }
    continue;
  }

  const [first, ...rest] = extracted;
  for (const other of rest) {
    if (!setsEqual(first.values, other.values)) {
      const { onlyInA, onlyInB } = diff(first.values, other.values);
      console.error(`❌ ${blockName} mismatch between "${first.label}" and "${other.label}"`);
      if (onlyInA.length) console.error(`   only in ${first.label}: ${onlyInA.join(', ')}`);
      if (onlyInB.length) console.error(`   only in ${other.label}: ${onlyInB.join(', ')}`);
      failed = true;
    } else {
      console.log(`✅ ${blockName}: ${first.label} ⇔ ${other.label} match (${first.values.size} values)`);
    }
  }
}

if (failed) {
  console.error('\nContract check FAILED.');
  process.exit(1);
}
console.log('\nContract check passed — all mirrored files agree.');
