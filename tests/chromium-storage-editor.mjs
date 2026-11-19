import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

// Load the same functions as the browser without importing Chromium's UI
// modules. Only the inert template is initialized at module load time.
const path = process.argv[2] ??
  new URL('../home/zerokqx/chromium/frontend/storage-editor.js', import.meta.url);
const source = readFileSync(path, 'utf8')
  .replace(/^import .*;\n/gm, '')
  .replace(/^export (async function editStorageEntry)/m, '$1');
const { formatJson, validateJson, draftToPersist, saveEntry } = vm.runInNewContext(
  source + '\n({ formatJson, validateJson, draftToPersist, saveEntry })',
  { document: { createElement: () => ({}) } },
  { filename: 'storage-editor.js' },
);

test('JSON formatting preserves number lexemes, duplicate keys, and escapes', () => {
  const json = String.raw`{"n":9007199254740993,"n":1e+60,"text":"\\\"","x":[]}`;
  validateJson(json);
  assert.equal(formatJson(json), [
    '{',
    '  "n": 9007199254740993,',
    '  "n": 1e+60,',
    String.raw`  "text": "\\\"",`,
    '  "x": []',
    '}',
  ].join('\n'));
  assert.throws(() => validateJson('{"n":]}'), /Invalid JSON/);
});

test('JSON formatting stops before producing a large result', () => {
  assert.throws(() => formatJson('"' + 'a'.repeat(1024 * 1024) + '"'), /too large/);
  const depth = 1024;
  const json = '['.repeat(depth) + '0' + ']'.repeat(depth);
  validateJson(json);
  assert.throws(() => formatJson(json), /Formatted JSON would be too large/);
});

test('only an explicit Format action saves otherwise unchanged pretty JSON', () => {
  const original = '{"n":9007199254740993}';
  const pretty = formatJson(original);
  assert.equal(draftToPersist(pretty, pretty, original, false), original);
  assert.equal(draftToPersist(pretty, pretty, original, true), pretty);
  assert.equal(draftToPersist('edited', pretty, original, false), 'edited');
});

function fixture(options = {}) {
  const items = new Map([['', ' unmodified\r\n'], ['existing', 'saved']]);
  const operations = [];
  const storageId = { storageKey: 'fixture', isLocalStorage: true };
  const response = getError => ({ getError: () => getError });
  const agent = {
    async invoke_getDOMStorageItems({ storageId: id }) {
      assert.equal(id, storageId);
      return { entries: [...items], ...response() };
    },
    async invoke_setDOMStorageItem({ storageId: id, key, value }) {
      assert.equal(id, storageId);
      operations.push(['set', key, value]);
      if (options.setError) return response(options.setError);
      items.set(key, value);
      options.afterWrite?.(items);
      return response();
    },
    async invoke_removeDOMStorageItem({ storageId: id, key }) {
      assert.equal(id, storageId);
      operations.push(['remove', key]);
      if (options.removeError) return response(options.removeError);
      items.delete(key);
      return response();
    },
  };
  const save = (key, value = ' unmodified\r\n') =>
    saveEntry({ id: storageId, model: { agent } }, '', ' unmodified\r\n', key, value);
  return { items, operations, save };
}

test('renaming an empty key preserves its original bytes and writes before deleting', async () => {
  const { items, operations, save } = fixture();
  await save('');
  assert.deepEqual(operations, []);
  await save('renamed');
  assert.deepEqual(operations, [['set', 'renamed', ' unmodified\r\n'], ['remove', '']]);
  assert.equal(items.get('renamed'), ' unmodified\r\n');
  assert.equal(items.has(''), false);
});

test('colliding, stale, and deleted originals cause no mutation', async () => {
  const { items, operations, save } = fixture();
  await assert.rejects(save('existing'), /already exists/);
  items.set('', 'external change');
  await assert.rejects(save('renamed'), /changed or was deleted/);
  items.delete('');
  await assert.rejects(save('renamed'), /changed or was deleted/);
  assert.deepEqual(operations, []);
});

test('rename preserves the original on a protocol write failure', async () => {
  const { items, operations, save } = fixture({ setError: 'Quota exceeded' });
  await assert.rejects(save('renamed'), /Quota exceeded/);
  assert.deepEqual(operations, [['set', 'renamed', ' unmodified\r\n']]);
  assert.equal(items.get(''), ' unmodified\r\n');
  assert.equal(items.has('renamed'), false);
});

test('rename preserves both entries on a protocol remove failure', async () => {
  const { items, save } = fixture({ removeError: 'Disconnected' });
  await assert.rejects(save('renamed'), /Check both keys/);
  assert.equal(items.get(''), ' unmodified\r\n');
  assert.equal(items.get('renamed'), ' unmodified\r\n');
});

test('rename checks both entries again before removing the original', async () => {
  for (const changedKey of ['', 'renamed']) {
    const { items, operations, save } = fixture({
      afterWrite(entries) {
        entries.set(changedKey, 'external change');
      },
    });
    await assert.rejects(save('renamed'), /Storage changed while saving/);
    assert.deepEqual(operations, [['set', 'renamed', ' unmodified\r\n']]);
    assert.equal(items.get(changedKey), 'external change');
  }
});
