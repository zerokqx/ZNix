// DataGridElement forwards real row clicks to their light-DOM config rows.
export function installStorageEditor(view) {
  let selectedRow;
  let opening = false;
  const content = view.contentElement;
  const storageRow = 'tr[data-key][data-value]';

  async function open(row) {
    if (opening || !row?.isConnected) {
      return;
    }
    const storage = view.domStorage;
    const {key, value} = row.dataset;
    opening = true;
    try {
      const {editStorageEntry} = await import('./storage-editor.js');
      if (view.isShowing() && view.domStorage === storage) {
        await editStorageEntry(storage, key, value, row.closest('devtools-data-grid'));
      }
    } catch (error) {
      console.error('Unable to open the storage editor', error);
      content.ownerDocument.defaultView.alert('Could not open the storage editor.');
    } finally {
      opening = false;
    }
  }

  content.addEventListener('click', event => {
    const row = event.target.closest?.(storageRow);
    if (row?.closest('devtools-data-grid')) {
      void open(row);
    }
  });
  content.addEventListener('select', event => {
    if (event.target.matches?.(storageRow)) {
      selectedRow = event.target;
    }
  }, true);
  content.addEventListener('deselect', event => {
    if (event.target.matches?.('devtools-data-grid')) {
      selectedRow = undefined;
    }
  }, true);
  content.addEventListener('keydown', event => {
    if (event.key !== 'Enter' || event.repeat || event.isComposing || event.defaultPrevented ||
        event.composedPath().some(node => node.matches?.('input, textarea, [contenteditable=true]'))) {
      return;
    }
    const grid = event.composedPath().find(node => node.matches?.('devtools-data-grid'));
    const row = grid?.querySelector(storageRow + '[selected]') ??
      (selectedRow?.closest('devtools-data-grid') === grid ? selectedRow : null);
    if (row?.isConnected) {
      event.preventDefault();
      event.stopPropagation();
      void open(row);
    }
  }, true);
}
