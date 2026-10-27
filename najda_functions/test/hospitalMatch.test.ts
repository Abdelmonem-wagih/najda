/**
 * Pure unit tests for pickNearestHospital — no emulator needed, run directly:
 *   npx tsx test/hospitalMatch.test.ts
 */
import * as assert from 'node:assert/strict';
import { test, runTests } from './testHarness';
import { pickNearestHospital, type HospitalCandidate } from '../src/lib/hospitalMatch';

// Cairo-ish coordinates; "near" and "far" are both roughly east of the point.
const POINT = { lat: 30.0, lng: 31.0 };

const NEAR_WITH_ER: HospitalCandidate = { id: 'near-er', name: 'Near ER', latitude: 30.01, longitude: 31.01, hasER: true, bedsAvailable: 2 };
const FAR_WITH_ER: HospitalCandidate = { id: 'far-er', name: 'Far ER', latitude: 30.5, longitude: 31.5, hasER: true, bedsAvailable: 20 };
const NEAR_NO_ER: HospitalCandidate = { id: 'near-no-er', name: 'Near No ER', latitude: 30.001, longitude: 31.001, hasER: false, bedsAvailable: 50 };
const NO_COORDS: HospitalCandidate = { id: 'no-coords', name: 'No Coords', hasER: true };

test('picks the nearest hospital that has an ER', () => {
  const result = pickNearestHospital(POINT.lat, POINT.lng, [FAR_WITH_ER, NEAR_WITH_ER]);
  assert.equal(result?.hospitalId, 'near-er');
});

test('excludes hospitals without an ER even if closer', () => {
  const result = pickNearestHospital(POINT.lat, POINT.lng, [NEAR_NO_ER, FAR_WITH_ER]);
  assert.equal(result?.hospitalId, 'far-er');
});

test('excludes hospitals missing coordinates', () => {
  const result = pickNearestHospital(POINT.lat, POINT.lng, [NO_COORDS, FAR_WITH_ER]);
  assert.equal(result?.hospitalId, 'far-er');
});

test('returns null when no eligible hospital exists', () => {
  const result = pickNearestHospital(POINT.lat, POINT.lng, [NEAR_NO_ER, NO_COORDS]);
  assert.equal(result, null);
});

test('ties on distance break by more beds available', () => {
  const sameDistanceA: HospitalCandidate = { id: 'a', latitude: 30.02, longitude: 31.0, hasER: true, bedsAvailable: 1 };
  const sameDistanceB: HospitalCandidate = { id: 'b', latitude: 29.98, longitude: 31.0, hasER: true, bedsAvailable: 9 };
  const result = pickNearestHospital(POINT.lat, POINT.lng, [sameDistanceA, sameDistanceB]);
  assert.equal(result?.hospitalId, 'b');
});

runTests();
