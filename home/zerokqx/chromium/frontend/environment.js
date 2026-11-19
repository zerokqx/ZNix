import * as UI from '../ui/legacy/legacy.js';
import {EnvironmentOverrides, normalizeEnvKey, validateEnvValue} from './environment-overrides.js';

export class EnvironmentPanel extends UI.Panel.Panel {
  static #instance;
  #engine = new EnvironmentOverrides();
  #entries = new Map();
  #body;
  #status;
  #empty;
  #busy = false;
  #dialog;

  static instance() {
    return this.#instance ||= new EnvironmentPanel();
  }

  constructor() {
    super('znix-css-environment');
    this.element.classList.add('znix-environment');
    this.contentElement.innerHTML = `
      <main class="znix-environment__content" aria-labelledby="znix-environment-title">
        <header class="znix-environment__header">
          <div>
            <h1 id="znix-environment-title">CSS Environment</h1>
            <p>Override values used by <code>env()</code> on the inspected page.</p>
          </div>
          <button class="znix-button filled" type="button" data-action="add">Add variable</button>
        </header>
        <div class="znix-environment__toolbar" role="group" aria-label="Override actions">
          <p class="znix-environment__count"></p>
          <button class="znix-button text" type="button" data-action="reapply">Reapply</button>
          <button class="znix-button text" type="button" data-action="reset">Remove all overrides</button>
        </div>
        <div class="znix-environment__table-container">
          <table class="znix-environment__table" aria-label="CSS environment overrides">
            <thead><tr><th scope="col">Key</th><th scope="col">Value</th></tr></thead>
            <tbody></tbody>
          </table>
          <div class="znix-environment__empty">
            <h2>No overrides</h2>
            <p>Add a CSS environment variable, then select its row to edit its key or value.</p>
            <code>safe-area-inset-top → 59px</code>
            <code>viewport-segment-width 0 0 → 390px</code>
            <code>app-header-height → 72px</code>
          </div>
        </div>
        <p class="znix-environment__status" role="status" aria-live="polite"></p>
        <p class="znix-environment__hint">Substitutes matching <code>env()</code> calls in page CSS. Use Reapply after reload or dynamic style changes. Removing an override restores untouched source styles.</p>
      </main>`;
    this.#body = this.contentElement.querySelector('tbody');
    this.#status = this.contentElement.querySelector('.znix-environment__status');
    this.#empty = this.contentElement.querySelector('.znix-environment__empty');
    this.contentElement.querySelector('[data-action=add]').addEventListener('click', () => this.#edit());
    this.contentElement.querySelector('[data-action=reapply]').addEventListener('click', () => {
      void this.#apply(new Map(this.#entries)).catch(error => this.#showStatus(error.message, true));
    });
    this.contentElement.querySelector('[data-action=reset]').addEventListener('click', () => {
      void this.#apply(new Map()).catch(error => this.#showStatus(error.message, true));
    });
    this.#renderRows();
  }

  #renderRows() {
    this.#body.replaceChildren();
    for (const [key, value] of this.#entries) {
      const row = document.createElement('tr');
      const keyCell = row.appendChild(document.createElement('td'));
      const button = keyCell.appendChild(document.createElement('button'));
      button.type = 'button';
      button.className = 'znix-environment__key';
      button.textContent = key;
      button.setAttribute('aria-label', `Edit ${key}`);
      row.appendChild(document.createElement('td')).textContent = value;
      row.addEventListener('click', () => this.#edit(key));
      this.#body.append(row);
    }
    this.#empty.hidden = this.#entries.size > 0;
    this.contentElement.querySelector('.znix-environment__count').textContent =
      `${this.#entries.size} ${this.#entries.size === 1 ? 'override' : 'overrides'}`;
    this.#setBusy(this.#busy);
  }

  #setBusy(busy) {
    this.#busy = busy;
    for (const button of this.contentElement.querySelectorAll('button')) {
      button.disabled = busy || (this.#entries.size === 0 && ['reset', 'reapply'].includes(button.dataset.action));
    }
    this.contentElement.setAttribute('aria-busy', String(busy));
  }

  #showStatus(message, error = false) {
    this.#status.textContent = message;
    this.#status.classList.toggle('error', error);
  }

  async #apply(entries) {
    if (this.#busy) throw new Error('Wait for the current update to finish.');
    this.#setBusy(true);
    this.#showStatus('Updating page styles…');
    try {
      const result = entries.size ? await this.#engine.apply(entries) : await this.#engine.reset();
      this.#entries = entries;
      this.#renderRows();
      this.#showStatus(result.conflicts
        ? `Updated ${result.changed} sources. Preserved ${result.conflicts} sources changed by the page. Reload to clear remaining substitutions.`
        : entries.size
          ? `Updated ${result.changed} CSS sources. ${entries.size} overrides configured.`
          : 'Overrides removed. Original styles restored.', Boolean(result.conflicts));
    } finally {
      this.#setBusy(false);
    }
  }

  #edit(originalKey) {
    if (this.#busy || this.#dialog) return;
    const editing = originalKey !== undefined;
    const dialog = document.createElement('dialog');
    this.#dialog = dialog;
    dialog.className = 'znix-dialog znix-environment-editor';
    dialog.setAttribute('aria-labelledby', 'znix-environment-editor-title');
    dialog.innerHTML = `
      <form novalidate autocomplete="off">
        <header><h2 id="znix-environment-editor-title">${editing ? 'Edit variable' : 'Add variable'}</h2></header>
        <div class="znix-dialog-content znix-environment-editor__fields">
          <label class="znix-field"><span>Key</span><input name="key" placeholder=" " spellcheck="false" autofocus aria-describedby="znix-environment-key-help"></label>
          <p id="znix-environment-key-help">Name inside env(), including indices when needed.</p>
          <label class="znix-field"><span>Value</span><textarea name="value" placeholder=" " rows="3" spellcheck="false" aria-describedby="znix-environment-value-help"></textarea></label>
          <p id="znix-environment-value-help">CSS value with units, for example 59px or calc(100vh - 24px).</p>
          <p class="znix-environment-editor__preview"><code></code></p>
          <p class="znix-environment-editor__error" role="alert" hidden></p>
        </div>
        <footer>
          ${editing ? '<button class="znix-button text" type="button" data-action="delete">Remove</button>' : ''}
          <button class="znix-button text" type="button" data-action="cancel">Cancel</button>
          <button class="znix-button text" type="submit">Save</button>
        </footer>
      </form>`;
    const form = dialog.querySelector('form');
    const key = form.elements.namedItem('key');
    const value = form.elements.namedItem('value');
    const error = dialog.querySelector('.znix-environment-editor__error');
    key.value = originalKey ?? '';
    value.value = this.#entries.get(originalKey) ?? '';
    let saving = false;
    const preview = () => {
      dialog.querySelector('code').textContent = `env(${key.value || 'variable-name'}) → ${value.value || 'CSS value'}`;
    };
    form.addEventListener('input', () => {
      error.hidden = true;
      key.removeAttribute('aria-invalid');
      value.removeAttribute('aria-invalid');
      preview();
    });
    preview();
    const save = async remove => {
      if (saving) return;
      error.hidden = true;
      try {
        const entries = new Map(this.#entries);
        if (editing) entries.delete(originalKey);
        if (!remove) {
          let name;
          let cssValue;
          try {
            name = normalizeEnvKey(key.value);
            if (entries.has(name)) throw new Error('This key already exists. Choose another name.');
          } catch (failure) {
            key.setAttribute('aria-invalid', 'true');
            key.focus();
            throw failure;
          }
          try {
            cssValue = validateEnvValue(value.value);
          } catch (failure) {
            value.setAttribute('aria-invalid', 'true');
            value.focus();
            throw failure;
          }
          entries.set(name, cssValue);
        }
        saving = true;
        for (const control of form.elements) control.disabled = true;
        dialog.closedBy = 'none';
        await this.#apply(entries);
        dialog.close();
      } catch (failure) {
        this.#showStatus('Could not update page styles.', true);
        error.textContent = failure.message;
        error.hidden = false;
      } finally {
        saving = false;
        for (const control of form.elements) control.disabled = false;
        dialog.closedBy = 'closerequest';
      }
    };
    form.addEventListener('submit', event => { event.preventDefault(); void save(false); });
    dialog.querySelector('[data-action=delete]')?.addEventListener('click', () => void save(true));
    dialog.querySelector('[data-action=cancel]').addEventListener('click', () => dialog.close());
    dialog.addEventListener('cancel', event => { if (saving) event.preventDefault(); });
    const lifetime = new AbortController();
    // DevTools consumes Escape for its drawer before the dialog default action.
    document.addEventListener('keydown', event => {
      if (event.key === 'Escape' && !event.isComposing && dialog.open) {
        event.preventDefault();
        event.stopImmediatePropagation();
        if (!saving) dialog.close();
      }
    }, {capture: true, signal: lifetime.signal});
    dialog.addEventListener('close', () => {
      lifetime.abort();
      dialog.remove();
      this.#dialog = undefined;
      const button = [...this.#body.querySelectorAll('button')].find(button => button.textContent === key.value);
      (button ?? this.contentElement.querySelector('[data-action=add]')).focus();
    }, {once: true});
    document.body.append(dialog);
    dialog.showModal();
  }
}
