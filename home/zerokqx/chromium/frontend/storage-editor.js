import * as CodeMirror from '../third_party/codemirror.next/codemirror.next.js';
import {CodeHighlighter, codeHighlighterStyles} from '../ui/components/code_highlighter/code_highlighter.js';
import {Config} from '../ui/components/text_editor/text_editor.js';
import {ThemeChangeEvent, ThemeSupport} from '../ui/legacy/theme_support/theme_support.js';

// Limit work done by automatic detection and prevent deep, compact JSON from
// expanding into a much larger value on a single formatting action.
const MAX_FORMAT_LENGTH = 1024 * 1024;

const template = document.createElement('template');
template.innerHTML = `
  <dialog class="znix-dialog znix-storage-editor" aria-labelledby="znix-storage-editor-title">
    <form autocomplete="off">
      <header>
        <h2 id="znix-storage-editor-title">Edit storage entry</h2>
        <p class="znix-storage-kind"></p>
      </header>
      <div class="znix-dialog-content">
        <label class="znix-field">
          <span>Key</span>
          <textarea name="key" rows="1" spellcheck="false" placeholder=" "></textarea>
        </label>
        <div class="znix-storage-tools">
          <label class="znix-field">
            <span>Value format</span>
            <select name="mode">
              <option value="text">String</option>
              <option value="json">JSON</option>
            </select>
          </label>
          <button class="znix-button text" type="button" data-action="format">Format JSON</button>
        </div>
        <div class="znix-storage-value"></div>
        <div class="znix-storage-error" role="alert" hidden></div>
      </div>
      <footer>
        <button class="znix-button text" type="button" data-action="cancel">Cancel</button>
        <button class="znix-button text" type="button" data-action="save">Save</button>
      </footer>
    </form>
  </dialog>`;

function validateJson(text) {
  try {
    JSON.parse(text);
  } catch (error) {
    throw new Error(`Invalid JSON: ${error.message}`);
  }
}

function formatJson(text) {
  if (text.length > MAX_FORMAT_LENGTH) {
    throw new Error('This value is too large to format. You can still edit it.');
  }
  // Keep raw tokens intact. Round-tripping through JSON.stringify would round
  // large numbers, reorder some keys, and discard repeated object members.
  const tokens = text.match(/"(?:\\[\s\S]|[^"\\])*"|[{}\[\],:]|[^\s{}\[\],:"]+/g);
  let depth = 0;
  const newline = () => '\n' + '  '.repeat(depth);
  function formatToken(token, index) {
    if (token === '{' || token === '[') {
      ++depth;
      const closer = token === '{' ? '}' : ']';
      return token + (tokens[index + 1] === closer ? '' : newline());
    }
    if (token === '}' || token === ']') {
      --depth;
      const opener = token === '}' ? '{' : '[';
      return (tokens[index - 1] === opener ? '' : newline()) + token;
    }
    if (token === ',') {
      return ',' + newline();
    }
    return token === ':' ? ': ' : token;
  }
  const formatted = [];
  let length = 0;
  for (const [index, token] of tokens.entries()) {
    const part = formatToken(token, index);
    length += part.length;
    if (length > MAX_FORMAT_LENGTH) {
      throw new Error('Formatted JSON would be too large. You can still edit the original.');
    }
    formatted.push(part);
  }
  return formatted.join('');
}

function checkResponse(response, message) {
  const error = response.getError();
  if (error) {
    throw new Error(`${message} ${error}`);
  }
}

function draftToPersist(draft, displayedValue, originalValue, explicitFormat) {
  return !explicitFormat && draft === displayedValue ? originalValue : draft;
}

async function saveEntry(storage, originalKey, originalValue, key, value) {
  const agent = storage.model.agent;
  const storageId = storage.id;
  const readEntries = async () => {
    const response = await agent.invoke_getDOMStorageItems({storageId});
    checkResponse(response, 'Could not read the current storage.');
    return new Map(response.entries);
  };

  const items = await readEntries();
  if (items.get(originalKey) !== originalValue) {
    throw new Error('The original entry changed or was deleted. Reopen it to work with the latest value.');
  }
  if (key === originalKey && value === originalValue) {
    return;
  }
  if (key !== originalKey && items.has(key)) {
    throw new Error('That key already exists. Choose a different key.');
  }

  const write = await agent.invoke_setDOMStorageItem({storageId, key, value});
  checkResponse(write, 'Could not save the entry.');
  if (key === originalKey) {
    return;
  }

  // A rename is two protocol operations. Retain the original unless the new
  // entry was written and both entries still match our observations.
  try {
    const afterWrite = await readEntries();
    if (afterWrite.get(originalKey) !== originalValue || afterWrite.get(key) !== value) {
      throw new Error('Storage changed while saving.');
    }
    const remove = await agent.invoke_removeDOMStorageItem({storageId, key: originalKey});
    checkResponse(remove, 'Could not remove the original key.');
  } catch (error) {
    throw new Error(`${error.message} Check both keys before retrying the rename.`);
  }
}

export async function editStorageEntry(storage, originalKey, originalValue, grid) {
  const dialog = template.content.firstElementChild.cloneNode(true);
  const form = dialog.querySelector('form');
  const key = dialog.querySelector('[name=key]');
  const mode = dialog.querySelector('[name=mode]');
  const format = dialog.querySelector('[data-action=format]');
  const cancel = dialog.querySelector('[data-action=cancel]');
  const save = dialog.querySelector('[data-action=save]');
  const error = dialog.querySelector('.znix-storage-error');

  dialog.querySelector('.znix-storage-kind').textContent =
    storage.isLocalStorage ? 'Local Storage' : 'Session Storage';
  key.value = originalKey;
  // Textarea normalizes CRLF. Keep the real key if the draft was not edited.
  const displayedKey = key.value;
  let initialDraft = originalValue;
  let initialWarning = '';
  let json = false;
  if (originalValue.length <= MAX_FORMAT_LENGTH) {
    try {
      JSON.parse(originalValue);
      json = true;
    } catch {
      // Treat arbitrary storage strings as plain text.
    }
  }
  if (json) {
    try {
      initialDraft = formatJson(originalValue);
    } catch (error) {
      initialWarning = error.message;
    }
  }
  mode.value = json ? 'json' : 'text';
  const syntax = new CodeMirror.Compartment();
  const readOnly = new CodeMirror.Compartment();
  const jsonLanguage = await CodeHighlighter.languageFromMIME('application/json');
  const jsonExtensions = [jsonLanguage, CodeMirror.foldGutter(), CodeMirror.keymap.of(CodeMirror.foldKeymap)];
  const state = CodeMirror.EditorState.create({
    doc: initialDraft,
    extensions: [
      Config.baseConfiguration(originalValue),
      CodeMirror.lineNumbers(),
      CodeMirror.bracketMatching(),
      CodeMirror.EditorView.contentAttributes.of({'aria-label': 'Value', spellcheck: 'false'}),
      syntax.of(json ? jsonExtensions : []),
      readOnly.of([]),
    ],
  });
  const editorHost = dialog.querySelector('.znix-storage-value').appendChild(document.createElement('div'));
  editorHost.className = 'znix-storage-code';
  const editorRoot = editorHost.attachShadow({mode: 'open'});
  editorRoot.appendChild(document.createElement('style')).textContent = codeHighlighterStyles;
  const displayedValue = state.sliceDoc();
  let editor;
  let saving = false;
  let explicitFormat = false;

  const showError = message => {
    error.textContent = message;
    error.hidden = !message;
  };
  showError(initialWarning);
  const setSaving = busy => {
    saving = busy;
    key.disabled = mode.disabled = cancel.disabled = save.disabled = busy;
    format.disabled = busy || mode.value !== 'json';
    save.textContent = busy ? 'Saving…' : 'Save';
    editor.dispatch({effects: readOnly.reconfigure([CodeMirror.EditorState.readOnly.of(busy), CodeMirror.EditorView.editable.of(!busy)])});
  };

  mode.addEventListener('change', () => {
    showError('');
    editor.dispatch({effects: syntax.reconfigure(mode.value === 'json' ? jsonExtensions : [])});
    format.disabled = mode.value !== 'json';
  });
  format.disabled = !json;
  format.addEventListener('click', () => {
    try {
      const draft = editor.state.sliceDoc();
      validateJson(draft);
      const formatted = formatJson(draft);
      if (formatted !== draft) {
        editor.dispatch({changes: {from: 0, to: editor.state.doc.length, insert: formatted}});
      }
      explicitFormat = true;
      showError('');
      editor.focus();
    } catch (failure) {
      showError(failure.message);
    }
  });
  cancel.addEventListener('click', () => dialog.close());
  dialog.addEventListener('cancel', event => {
    if (saving) {
      event.preventDefault();
    }
  });
  form.addEventListener('submit', event => event.preventDefault());
  save.addEventListener('click', async () => {
    if (saving) {
      return;
    }
    showError('');
    const draft = editor.state.sliceDoc();
    const value = draftToPersist(draft, displayedValue, originalValue, explicitFormat);
    const newKey = key.value === displayedKey ? originalKey : key.value;
    try {
      if (mode.value === 'json') {
        validateJson(value);
      }
      setSaving(true);
      await saveEntry(storage, originalKey, originalValue, newKey, value);
      dialog.close();
    } catch (failure) {
      setSaving(false);
      showError(failure.message);
      save.focus();
    }
  });

  const lifetime = new AbortController();
  document.addEventListener('keydown', event => {
    if (dialog.open && event.key === 'Escape' && !event.isComposing) {
      // DevTools also binds Escape to the drawer on the document.
      event.preventDefault();
      event.stopImmediatePropagation();
      if (!saving) {
        dialog.close();
      }
    }
  }, {capture: true, signal: lifetime.signal});
  document.body.append(dialog);
  try {
    editor = new CodeMirror.EditorView({state, parent: editorRoot, root: editorRoot});
    const theme = ThemeSupport.instance();
    theme.addEventListener(ThemeChangeEvent.eventName, () => {
      editor.dispatch({
        effects: Config.themeSelection.reconfigure(theme.themeName() === 'dark' ? Config.dummyDarkTheme : []),
      });
    }, {signal: lifetime.signal});
    dialog.showModal();
    editor.focus();
    await new Promise(resolve => dialog.addEventListener('close', resolve, {once: true}));
  } finally {
    lifetime.abort();
    editor?.destroy();
    dialog.remove();
  }
  if (grid?.isConnected) {
    grid.focus();
  }
}
