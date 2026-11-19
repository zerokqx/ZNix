import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';

const path = process.argv[2] ??
  new URL('../home/zerokqx/chromium/frontend/environment-overrides.js', import.meta.url);
const { normalizeEnvKey, rewriteCss, validateEnvValue } = await import(
  'data:text/javascript;base64,' + readFileSync(path).toString('base64')
);

test('rewrites arbitrary and indexed env values inside CSS expressions', () => {
  const source = String.raw`padding: calc(1px + ENV(my-\76 alue, clamp(0px, 1px, 2px)));
margin: env(viewport-segment-width /**/ 00 +01, 10px);
color: env(theme-color, red);`;
  const entries = new Map([
    ['my-value', '2rem'],
    ['viewport-segment-width 0 1', '20px'],
    ['theme-color', 'oklch(60% .2 30)'],
  ]);
  assert.equal(rewriteCss(source, entries), `padding: calc(1px + /**/2rem/**/);
margin: /**/20px/**/;
color: /**/oklch(60% .2 30)/**/;`);
});

test('leaves literals and similarly named functions unchanged', () => {
  const source = `/* env(name) */
content: "env(name)";
background: url(a/*env(name));
color: env-other(name);
color: env(Name);`;
  const entries = new Map([['name', 'red']]);
  assert.equal(rewriteCss(source, entries), source);
  assert.equal(rewriteCss(source + '\ncolor: env(name);', entries), source + '\ncolor: /**/red/**/;');
});

test('substitutes nested fallbacks only if their outer call is preserved', () => {
  const source = 'a:env(x,env(y));b:env(z,env(y));c:env(x,env(z,env(y)))';
  assert.equal(
    rewriteCss(source, new Map([['x', '7px'], ['y', '9px']])),
    'a:/**/7px/**/;b:env(z,/**/9px/**/);c:/**/7px/**/'
  );
});

test('preserves the boundary between the replacement and surrounding tokens', () => {
  assert.equal(rewriteCss('width:env(x)px', new Map([['x', '10']])), 'width:/**/10/**/px');
});

test('normalizes CSS identifier escapes and nonnegative indices', () => {
  assert.equal(normalizeEnvKey(String.raw` \76 iewport-segment-width 000 +01`), 'viewport-segment-width 0 1');
  assert.notEqual(normalizeEnvKey(String.raw`segment\ 0`), normalizeEnvKey('segment 0'));
  for (const invalid of ['env(x)', 'x -1', 'x 1.5', 'x + 1', 'x, y', 'x y']) {
    assert.throws(() => normalizeEnvKey(invalid), /CSS environment name/);
  }
});

test('accepts CSS values while rejecting text that could close the declaration', () => {
  for (const valid of ['1px', 'var(--x, calc(1px + 2%))', "'{};!'", 'url(data:image/png;base64,ABCD)']) {
    assert.equal(validateEnvValue(' ' + valid + ' '), valid);
  }
  for (const invalid of [
    '', '/* comment */', '/* open', '1px; color: red', '1px !important',
    '1px} p {color: red', 'calc(1px', ')', '"unclosed', String.raw`"escaped\"`, String.raw`url(test\)`,
  ]) {
    assert.throws(() => validateEnvValue(invalid));
  }
});
