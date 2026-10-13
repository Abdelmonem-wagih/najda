/**
 * A deliberately tiny test runner — avoids pulling in jest/mocha/vitest as a
 * new dependency just for this. `@firebase/rules-unit-testing`'s
 * assertSucceeds/assertFails already throw on failure, which is all a runner
 * needs to hook into.
 */
type TestFn = () => Promise<void> | void;

const tests: { name: string; fn: TestFn }[] = [];

export function test(name: string, fn: TestFn): void {
  tests.push({ name, fn });
}

export async function runTests(): Promise<void> {
  let passed = 0;
  let failed = 0;

  for (const t of tests) {
    try {
      await t.fn();
      console.log(`  ✅ ${t.name}`);
      passed++;
    } catch (err: any) {
      console.error(`  ❌ ${t.name}`);
      console.error(`     ${err?.message ?? err}`);
      failed++;
    }
  }

  console.log(`\n${passed} passed, ${failed} failed (${tests.length} total)`);
  if (failed > 0) process.exitCode = 1;
}
