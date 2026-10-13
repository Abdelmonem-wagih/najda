#!/usr/bin/env node
/**
 * Fails (exit 1) if the collection names or status enums declared in the
 * three mirrored contract files have drifted apart:
 *   - najda_functions/src/contract.ts
 *   - lib/core/constants/firestore_contract.dart
 *   - ../najda-dashboard/src/lib/contract.js  (override with DASHBOARD_CONTRACT env var)
 *
 * Each file must contain matching `// CONTRACT:<BLOCK>:START` / `:END`
 * marker comments (works across Dart/TS/JS since all three use `//`).
 * Within each marked block, every single- or double-quoted string literal
 * is extracted and the resulting *set* of values is compared across files.
 * This deliberately ignores key names/ordering/language syntax — only the
 * actual collection-name/status-value strings have to match.
 */
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = join(__dirname, '..');

const DASHBOARD_CONTRACT =
  process.env.DASHBOARD_CONTRACT || join(repoRoot, '..', 'najda-dashboard', 'src', 'lib', 'contract.js');

const FILES = [
  { label: 'functions (contract.ts)', path: join(repoRoot, 'najda_functions', 'src', 'contract.ts') },
  { label: 'flutter (firestore_contract.dart)', path: join(repoRoot, 'lib', 'core', 'constants', 'firestore_contract.dart') },
  { label: 'dashboard (contract.js)', path: DASHBOARD_CONTRACT, optional: true },
];

const BLOCKS = ['COLLECTIONS', 'INCIDENT_STATUS', 'AMBULANCE_STATUS'];

function extractBlock(source, blockName, fileLabel) {
  const startMarker = `CONTRACT:${blockName}:START`;
  const endMarker = `CONTRACT:${blockName}:END`;
  const startIdx = source.indexOf(startMarker);
  const endIdx = source.indexOf(endMarker);
  if (startIdx === -1 || endIdx === -1 || endIdx < startIdx) {
    throw new Error(`[${fileLabel}] missing or malformed ${blockName} markers`);
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
    if (f.optional) {
      console.warn(`⚠️  skipping ${f.label}: ${f.path} not found (dashboard repo not alongside this one?)`);
      continue;
    }
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
  const extracted = loaded.map(f => {
    try {
      return { label: f.label, values: extractStringLiterals(extractBlock(f.source, blockName, f.label)) };
    } catch (err) {
      console.error(`❌ ${err.message}`);
      failed = true;
      return null;
    }
  }).filter(Boolean);

  if (extracted.length < 2) continue;

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
