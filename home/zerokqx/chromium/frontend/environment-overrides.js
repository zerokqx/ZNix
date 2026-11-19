// Walk CSS tokens so parentheses, commas, comments, and strings in fallbacks
// do not affect which calls are replaced. The same code runs for inline CSS.
function* tokenizeCss(css) {
  const pattern = /\/\*[\s\S]*?(?:\*\/|$)|"(?:\\(?:\r\n|[\s\S])|[^"\\\r\n\f])*"?|'(?:\\(?:\r\n|[\s\S])|[^'\\\r\n\f])*'?|(?:\\(?:[a-f\d]{1,6}(?:\r\n|[ \t\r\n\f])?|[^\r\n\f])|[\w\u0080-\uffff-])+|[^\t\n\f\r ]/gi;
  const urlStart = /\([ \t\n\r\f]*(?!['" \t\n\r\f])/y;
  const urlEnd = /(?:\\(?:\r\n|[\s\S])|[^\\)])*(?:\)|$)/y;
  let match;
  while ((match = pattern.exec(css))) {
    const index = match.index;
    const token = match[0];
    const next = pattern.lastIndex;
    if (css[next] === '(' && decodeIdentifier(token).toLowerCase() === 'url') {
      urlStart.lastIndex = next;
      if (urlStart.test(css)) {
        // Unquoted URL contents are a single token, including comment-like
        // sequences in a path. Quoted URLs use ordinary string tokens.
        urlEnd.lastIndex = next + 1;
        const end = urlEnd.test(css) ? urlEnd.lastIndex : css.length;
        pattern.lastIndex = end;
        yield {token: css.slice(index, end), index, url: true};
        continue;
      }
    }
    yield {token, index, url: false};
  }
}

function decodeIdentifier(identifier) {
  return identifier.replace(/\\(?:([a-f\d]{1,6})(?:\r\n|[ \t\n\r\f])?|([^\r\n\f]))/gi, (_, hex, character) => {
    if (!hex) {
      return character;
    }
    const codePoint = Number.parseInt(hex, 16);
    return codePoint > 0 && codePoint <= 0x10ffff && !(codePoint >= 0xd800 && codePoint <= 0xdfff) ?
      String.fromCodePoint(codePoint) : '\ufffd';
  });
}

export function normalizeEnvKey(input) {
  const parts = [...tokenizeCss(input)].filter(({token}) => !token.startsWith('/*'));
  const name = parts.shift()?.token;
  // An identifier followed by zero or more nonnegative integer indices.
  const isIdentifier = /^(?:--|-?(?:[_a-z\u0080-\uffff]|\\(?:[a-f\d]{1,6}(?:\r\n|[ \t\n\r\f])?|[^\r\n\f])))(?:[\w\u0080-\uffff-]|\\(?:[a-f\d]{1,6}(?:\r\n|[ \t\n\r\f])?|[^\r\n\f]))*$/i;
  if (!name || !isIdentifier.test(name)) {
    throw new Error('Enter a CSS environment name, optionally followed by nonnegative indices.');
  }
  // Re-escape characters that would make the decoded name ambiguous with
  // an indexed key (e.g. "segment\ 0" and "segment 0" are different).
  const identifier = decodeIdentifier(name).replace(/^\d|(?<=^-)\d|^-$|[^\w\u0080-\uffff-]/g, character => '\\' + character.codePointAt(0).toString(16) + ' ');
  const normalizedIndices = [];
  for (let i = 0; i < parts.length; ++i) {
    const {token, index} = parts[i];
    const digits = token === '+' && parts[i + 1]?.index === index + 1 ? parts[++i].token : token;
    if (!/^\d+$/.test(digits)) {
      throw new Error('Enter a CSS environment name, optionally followed by nonnegative indices.');
    }
    normalizedIndices.push(digits.replace(/^0+(?=\d)/, ''));
  }
  return [identifier, ...normalizedIndices].join(' ');
}

export function validateEnvValue(input) {
  const value = input.replace(/^[ \t\n\r\f]+|[ \t\n\r\f]+$/g, '');
  const closing = [];
  let hasValue = false;
  for (const {token, url} of tokenizeCss(value)) {
    if (token.startsWith('/*')) {
      if (!token.endsWith('*/') || token.length < 4) {
        throw new Error('Close the CSS comment before saving.');
      }
      continue;
    }
    hasValue = true;
    if (url) {
      if (!/(?<!\\)(?:\\\\)*\)$/.test(token)) {
        throw new Error('Close the CSS URL before saving.');
      }
      continue;
    }
    if ((token.startsWith('"') && !/^"(?:\\(?:\r\n|[\s\S])|[^"\\\r\n\f])*"$/.test(token)) ||
        (token.startsWith("'") && !/^'(?:\\(?:\r\n|[\s\S])|[^'\\\r\n\f])*'$/.test(token))) {
      throw new Error('Close the CSS string before saving.');
    }
    if (token === '(' || token === '[' || (token === '{' && closing.length)) {
      closing.push({'(': ')', '[': ']', '{': '}'}[token]);
    } else if ((')]}'.includes(token) && closing.pop() !== token) ||
               (!closing.length && '{;!'.includes(token)) || token === '\\') {
      throw new Error('Enter a CSS value without declaration delimiters.');
    }
  }
  if (!hasValue || closing.length || (globalThis.CSS && !CSS.supports('--znix-env-value', value))) {
    throw new Error('Enter a valid CSS value.');
  }
  return value;
}

export function rewriteCss(css, entries) {
  if (!entries.size || !/env\(|\\/i.test(css)) {
    return css;
  }
  const groups = [];
  const edits = [];
  let end = 0;
  let previousToken = '';
  for (const {token, index} of tokenizeCss(css)) {
    const previous = previousToken;
    const adjacent = index === end;
    end = index + token.length;
    previousToken = token;
    if (token === '(' || token === '[' || token === '{') {
      const name = adjacent ? decodeIdentifier(previous).toLowerCase() : '';
      const start = index - previous.length;
      const isEnv = token === '(' && name === 'env' && css[start - 1] !== '@' && css[start - 1] !== '#';
      groups.push({
        close: {'(': ')', '[': ']', '{': '}'}[token],
        start: isEnv ? start : null,
        argumentStart: end,
        argumentEnd: null,
        editCount: edits.length,
      });
    } else if (token === ',' && groups.at(-1)?.argumentEnd === null) {
      groups.at(-1).argumentEnd = index;
    } else if (token === groups.at(-1)?.close) {
      const group = groups.pop();
      if (group.start === null) {
        continue;
      }
      let key;
      try {
        key = normalizeEnvKey(css.slice(group.argumentStart, group.argumentEnd ?? index));
      } catch {
        continue;
      }
      if (entries.has(key)) {
        // An overridden outer env() discards its entire fallback, including
        // any nested matches already found in that fallback.
        edits.length = group.editCount;
        edits.push({start: group.start, end, value: entries.get(key)});
      }
    }
  }
  if (!edits.length) {
    return css;
  }
  const result = [];
  let offset = 0;
  for (const edit of edits) {
    // Keep the substituted token list separate from its neighbors.
    // For example, env(length)px must not become the dimension 10px.
    result.push(css.slice(offset, edit.start), '/**/', edit.value, '/**/');
    offset = edit.end;
  }
  result.push(css.slice(offset));
  return result.join('');
}

// This function and the CSS tokenizer run in an isolated world. Keeping the
// inline snapshots there preserves node identity without holding remote IDs.
function rewriteInlineStyles(pairs) {
  const entries = new Map(pairs);
  const snapshots = globalThis.znixEnvironmentSnapshots ??= new Map();
  const elements = new Set(snapshots.keys());
  if (entries.size) {
    const roots = [document];
    for (const root of roots) {
      for (const element of root.querySelectorAll('*')) {
        if (element.hasAttribute('style')) {
          elements.add(element);
        }
        if (element.shadowRoot) {
          roots.push(element.shadowRoot);
        }
      }
    }
  }

  const mutations = [];
  const detached = [];
  let conflicts = 0;
  try {
    for (const element of elements) {
      const current = element.getAttribute('style');
      const previous = snapshots.get(element);
      const inDocument = element.ownerDocument === document;
      const connected = inDocument && element.isConnected;
      if (!connected) {
        detached.push(element);
      }
      if (!inDocument || (previous && current !== previous.applied && current !== previous.original)) {
        ++conflicts;
        continue;
      }
      const original = previous?.original ?? current;
      const applied = connected ? rewriteCss(original, entries) : original;
      if (applied !== current) {
        mutations.push({element, original, applied, current});
        element.setAttribute('style', applied);
      } else if (current === original) {
        snapshots.delete(element);
      }
    }
    for (const {element, original, applied} of mutations) {
      if (applied === original || !element.isConnected) {
        snapshots.delete(element);
      } else {
        snapshots.set(element, {original, applied});
      }
    }
    for (const element of detached) {
      snapshots.delete(element);
    }
  } catch (error) {
    for (const {element, applied, current} of mutations.reverse()) {
      if (element.getAttribute('style') === applied) {
        element.setAttribute('style', current);
      }
    }
    throw error;
  }
  return {changed: mutations.length, conflicts};
}

const inlineRewrite = 'function(entries) {\n' + [
  tokenizeCss, decodeIdentifier, normalizeEnvKey, rewriteCss, rewriteInlineStyles,
].join('\n') + '\nreturn rewriteInlineStyles(entries);\n}';

function assertResponse(response) {
  const error = response.getError();
  if (error || response.exceptionDetails) {
    throw new Error(error || response.exceptionDetails.exception?.description || response.exceptionDetails.text);
  }
  return response;
}

export class EnvironmentOverrides {
  #sheets = new WeakMap();
  #pending = Promise.resolve();

  apply(entries) {
    const normalized = new Map(Array.from(entries, ([name, value]) => [normalizeEnvKey(name), validateEnvValue(value)]));
    const operation = this.#pending.then(() => this.#apply(normalized));
    this.#pending = operation.catch(() => {});
    return operation;
  }

  reset() {
    return this.apply(new Map());
  }

  async #apply(entries) {
    const {CSSModel, ResourceTreeModel, TargetManager} = await import('../core/sdk/sdk.js');
    const manager = TargetManager.TargetManager.instance();
    const target = manager.primaryPageTarget();
    const resourceTree = target?.model(ResourceTreeModel.ResourceTreeModel);
    const cssModel = target?.model(CSSModel.CSSModel);
    const frame = resourceTree?.mainFrame;
    if (!frame || !cssModel?.isEnabled()) {
      throw new Error('Open a web page and wait for it to load before applying CSS overrides.');
    }
    const {id: frameId, loaderId} = frame;
    const checkPage = () => {
      if (manager.primaryPageTarget() !== target || resourceTree.mainFrame?.loaderId !== loaderId) {
        throw new Error('The inspected page changed. Reapply overrides to the new page.');
      }
    };
    const context = assertResponse(await target.pageAgent().invoke_createIsolatedWorld({
      frameId,
      worldName: 'ZNix CSS Environment',
    }));
    const headers = cssModel.styleSheetHeaders().filter(header =>
      header.origin === 'regular' && (entries.size || this.#sheets.has(header)));
    const live = header => cssModel.styleSheetHeaderForId(header.id) === header;
    const read = async header => {
      const reply = await cssModel.agent.invoke_getStyleSheetText({styleSheetId: header.id});
      return live(header) ? assertResponse(reply).text : null;
    };
    const write = async (header, text) => {
      assertResponse(await cssModel.agent.invoke_setStyleSheetText({styleSheetId: header.id, text}));
      cssModel.fireStyleSheetChanged(header.id);
    };

    const journal = [];
    let conflicts = 0;
    try {
      // Batch reads without sending a burst of every stylesheet to the renderer.
      for (let start = 0; start < headers.length; start += 8) {
        checkPage();
        const batch = headers.slice(start, start + 8);
        const contents = await Promise.all(batch.map(read));
        for (const [index, header] of batch.entries()) {
          const current = contents[index];
          if (current === null) {
            continue;
          }
          const previous = this.#sheets.get(header);
          if (previous && current !== previous.applied && current !== previous.original) {
            ++conflicts;
            continue;
          }
          const original = previous?.original ?? current;
          const applied = rewriteCss(original, entries);
          if (applied === current) {
            if (current === original) {
              this.#sheets.delete(header);
            }
            continue;
          }
          await cssModel.originalStyleSheetText(header);
          checkPage();
          const latest = await read(header);
          if (latest !== current) {
            conflicts += latest === null ? 0 : 1;
            continue;
          }
          checkPage();
          journal.push({header, original, applied, current});
          await write(header, applied);
        }
      }

      checkPage();
      const inline = assertResponse(await target.runtimeAgent().invoke_callFunctionOn({
        executionContextId: context.executionContextId,
        functionDeclaration: inlineRewrite,
        arguments: [{value: [...entries]}],
        returnByValue: true,
        silent: true,
      })).result.value;
      for (const {header, original, applied} of journal) {
        if (original === applied) {
          this.#sheets.delete(header);
        } else {
          this.#sheets.set(header, {original, applied});
        }
      }
      return {changed: journal.length + inline.changed, conflicts: conflicts + inline.conflicts};
    } catch (error) {
      let incomplete = false;
      for (const {header, original, current, applied} of journal.reverse()) {
        try {
          const latest = await read(header);
          if (latest === applied) {
            await write(header, current);
          } else if (latest !== null && latest !== current) {
            incomplete = true;
          }
        } catch {
          // Keep the snapshot available for a retry even if rollback failed.
          this.#sheets.set(header, {original, applied});
          incomplete = true;
        }
      }
      if (incomplete) {
        throw new Error(error.message + ' Some CSS could not be restored. Reload the page to clear these changes.');
      }
      throw error;
    }
  }
}
