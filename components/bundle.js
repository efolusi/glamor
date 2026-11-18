/* @ds-bundle: {"format":4,"namespace":"Komando","components":[{"name":"AppLogo"},{"name":"SFSymbol"},{"name":"IconTile"},{"name":"StatusDot"},{"name":"Pill"},{"name":"DashedDivider"},{"name":"Button"},{"name":"LinkButton"},{"name":"Chip"},{"name":"TextField"},{"name":"SearchBar"},{"name":"CommandBar"},{"name":"ToggleCard"},{"name":"UnderlineTabs"},{"name":"SectionTitle"},{"name":"Card"},{"name":"CardList"},{"name":"AttentionCard"},{"name":"RunningCard"},{"name":"TargetCard"},{"name":"ActivityRow"},{"name":"TerminalPane"},{"name":"FormHeader"},{"name":"Banner"},{"name":"EmptyState"},{"name":"SidebarItem"},{"name":"GroupRow"},{"name":"TabButton"},{"name":"PanelHeader"},{"name":"MenuRow"},{"name":"CommandPalette"},{"name":"ProfileCard"},{"name":"AppShell"},{"name":"Terminal"},{"name":"StatusBar"},{"name":"Segmented"},{"name":"DataTable"},{"name":"AgentMessage"},{"name":"ToolCall"},{"name":"ApprovalCard"},{"name":"AgentComposer"},{"name":"Checkbox"},{"name":"Switch"},{"name":"PopupButton"},{"name":"ProgressBar"},{"name":"Skeleton"},{"name":"Popover"},{"name":"Sheet"},{"name":"AlertDialog"}]} */
(function () {
  var React = window.React;
  var h = React.createElement;

  function cx() {
    var out = [];
    for (var i = 0; i < arguments.length; i++) if (arguments[i]) out.push(arguments[i]);
    return out.join(' ');
  }
  function v(name) { return 'var(--' + name + ')'; }
  function assign(a, b) { var o = {}, k; for (k in a) o[k] = a[k]; for (k in b) o[k] = b[k]; return o; }
  // A stable id for tying a label, a help line or a dialog title to what it names.
  var idSeq = 0;
  function useUid(prefix) {
    var r = React.useRef(null);
    if (r.current == null) r.current = 'k-' + prefix + '-' + (++idSeq);
    return r.current;
  }
  // An icon-only control is named by its tooltip without the shortcut: "Ask the agent (⌘J)" reads "Ask the agent".
  function nameOf(help) { return help ? String(help).replace(/\s*\([^)]*\)\s*$/, '') : undefined; }

  // Stand-in glyphs keyed by SF Symbol name (16-unit box). The app draws the real SF Symbols.
  var G = {
    'magnifyingglass': '<circle cx="7" cy="7" r="4.75"/><path d="M10.5 10.5 14 14"/>',
    'chevron.right': '<path d="M6 3.5 10.5 8 6 12.5"/>',
    'plus': '<path d="M8 3v10M3 8h10"/>',
    'xmark': '<path d="M4 4l8 8M12 4l-8 8"/>',
    'checkmark': '<path d="M3.5 8.3 6.5 11.2 12.5 5"/>',
    'xmark.circle.fill': '<circle class="f" cx="8" cy="8" r="7"/><path class="k" d="M5.6 5.6l4.8 4.8M10.4 5.6l-4.8 4.8"/>',
    'checkmark.circle.fill': '<circle class="f" cx="8" cy="8" r="7"/><path class="k" d="M5 8.2 7.1 10.3 11 6"/>',
    'exclamationmark.circle.fill': '<circle class="f" cx="8" cy="8" r="7"/><path class="k" d="M8 4.6v4.1M8 11.3v.1"/>',
    'exclamationmark.triangle.fill': '<path class="f" d="M6.8 2.4a1.4 1.4 0 0 1 2.4 0l5.7 9.9a1.4 1.4 0 0 1-1.2 2.1H2.3a1.4 1.4 0 0 1-1.2-2.1z"/><path class="k" d="M8 6v3.4M8 11.8v.1"/>',
    'arrow.up.circle.fill': '<circle class="f" cx="8" cy="8" r="7.5"/><path class="k" d="M8 11.6V4.8M5.2 7.5 8 4.7l2.8 2.8"/>',
    'arrow.clockwise': '<path d="M12.5 5.9A5.2 5.2 0 1 1 8 3.3"/><path d="M6 1.3 8.2 3.3 6 5.3"/>',
    'ellipsis': '<circle class="f" cx="3.5" cy="8" r="1.2"/><circle class="f" cx="8" cy="8" r="1.2"/><circle class="f" cx="12.5" cy="8" r="1.2"/>',
    'chevron.up.chevron.down': '<path d="M5 6 8 3l3 3M5 10l3 3 3-3"/>',
    'square.grid.2x2': '<rect x="2" y="2" width="5" height="5" rx="1.2"/><rect x="9" y="2" width="5" height="5" rx="1.2"/><rect x="2" y="9" width="5" height="5" rx="1.2"/><rect x="9" y="9" width="5" height="5" rx="1.2"/>',
    'server.rack': '<rect x="2" y="2.5" width="12" height="4.5" rx="1.2"/><rect x="2" y="9" width="12" height="4.5" rx="1.2"/><path d="M4.6 4.75h.01M4.6 11.25h.01"/>',
    'cylinder.split.1x2': '<ellipse cx="8" cy="3.8" rx="5.5" ry="2"/><path d="M2.5 3.8v8.4c0 1.1 2.5 2 5.5 2s5.5-.9 5.5-2V3.8M2.5 8c0 1.1 2.5 2 5.5 2s5.5-.9 5.5-2"/>',
    // Caches were a bolt before they became memorychip; only the Icon audit's "today" column still draws it.
    'bolt.horizontal': '<path d="M1.5 8.6 7.2 4.2v2.6h7.3L8.8 11.8V9.2H1.5z"/>',
    'archivebox': '<rect x="1.8" y="2.5" width="12.4" height="3.5" rx="1"/><path d="M2.8 6v6.2c0 .7.5 1.3 1.2 1.3h8c.7 0 1.2-.6 1.2-1.3V6M6.5 8.6h3"/>',
    'circle.hexagongrid': '<circle class="f" cx="8" cy="8" r="1.5"/><circle class="f" cx="3.8" cy="8" r="1.5"/><circle class="f" cx="12.2" cy="8" r="1.5"/><circle class="f" cx="5.9" cy="4.3" r="1.5"/><circle class="f" cx="10.1" cy="4.3" r="1.5"/><circle class="f" cx="5.9" cy="11.7" r="1.5"/><circle class="f" cx="10.1" cy="11.7" r="1.5"/>',
    'tray.full': '<path d="M2 9.5 3.6 3.2h8.8L14 9.5v3.3H2z"/><path d="M2 9.5h3.2l1 1.8h3.6l1-1.8H14"/><path d="M5.6 5.4h4.8M5.1 7.4h5.8"/>',
    'shippingbox': '<path d="M8 1.8 14 4.8v6.4L8 14.2 2 11.2V4.8z"/><path d="M2 4.8 8 7.8l6-3M8 7.8v6.4M5 3.3l6 3"/>',
    'network.badge.shield.half.filled': '<circle cx="7" cy="7" r="5.2"/><path d="M1.8 7h10.4M7 1.8c1.6 1.5 2.2 3.3 2.2 5.2S8.6 10.7 7 12.2C5.4 10.7 4.8 8.9 4.8 7S5.4 3.3 7 1.8"/><path class="f" d="M11.8 8.6 15 9.8v1.9c0 1.6-1.4 2.8-3.2 3.4-1.8-.6-3.2-1.8-3.2-3.4V9.8z"/>',
    'arrow.left.arrow.right': '<path d="M2.5 5.5h10.5M10.5 3 13 5.5 10.5 8M13.5 10.5H3M5.5 8 3 10.5 5.5 13"/>',
    'gearshape': '<circle cx="8" cy="8" r="2.3"/><path d="M8 1.8v1.8M8 12.4v1.8M1.8 8h1.8M12.4 8h1.8M3.6 3.6l1.3 1.3M11.1 11.1l1.3 1.3M3.6 12.4l1.3-1.3M11.1 4.9l1.3-1.3"/>',
    'gearshape.2': '<circle cx="6.5" cy="9" r="2"/><path d="M6.5 4.6v1.3M6.5 12.1v1.3M2.1 9h1.3M9.6 9h1.3M3.4 5.9l.9.9M8.7 11.2l.9.9M3.4 12.1l.9-.9M8.7 6.8l.9-.9"/><circle cx="12.2" cy="3.8" r="1.6"/>',
    'curlybraces': '<path d="M5.5 2.5c-1.5 0-2 .6-2 1.8v1.6c0 1-.5 1.6-1.5 2.1 1 .5 1.5 1.1 1.5 2.1v1.6c0 1.2.5 1.8 2 1.8M10.5 2.5c1.5 0 2 .6 2 1.8v1.6c0 1 .5 1.6 1.5 2.1-1 .5-1.5 1.1-1.5 2.1v1.6c0 1.2-.5 1.8-2 1.8"/>',
    'key': '<circle cx="5" cy="8" r="3"/><path d="M8 8h6.5M12 8v2.3M14.3 8v1.6"/>',
    'clock.arrow.circlepath': '<path d="M2.7 8.6A5.4 5.4 0 1 0 4.3 4.2"/><path d="M1.8 2.5v2.6h2.6M8.2 5.2V8l2 1.3"/>',
    'terminal': '<rect x="1.5" y="2.5" width="13" height="11" rx="2"/><path d="M4.5 6.2 6.8 8 4.5 9.8M8.5 10h3"/>',
    'stethoscope': '<path d="M3.5 2v4a3 3 0 0 0 6 0V2"/><path d="M6.5 9v1.8a3 3 0 0 0 6 0V9.5"/><circle cx="12.5" cy="8" r="1.5"/>',
    'questionmark.circle': '<circle cx="8" cy="8" r="6.5"/><path d="M6.2 6.2a1.9 1.9 0 1 1 2.6 1.8c-.5.2-.8.6-.8 1.1v.4M8 11.6v.1"/>',
    'lock.fill': '<rect class="f" x="3" y="7" width="10" height="7.5" rx="1.6"/><path d="M5.2 7V5a2.8 2.8 0 0 1 5.6 0v2"/>',
    'lock': '<rect x="3" y="7" width="10" height="7.5" rx="1.6"/><path d="M5.2 7V5a2.8 2.8 0 0 1 5.6 0v2"/>',
    'link': '<path d="M6.8 9.2a2.6 2.6 0 0 0 3.7 0l2.2-2.2a2.6 2.6 0 0 0-3.7-3.7l-.8.8M9.2 6.8a2.6 2.6 0 0 0-3.7 0L3.3 9a2.6 2.6 0 0 0 3.7 3.7l.8-.8"/>',
    'checkmark.seal': '<path d="M8 1.5l1.6 1.2 2-.1.6 1.9 1.6 1.2-.6 1.9.6 1.9-1.6 1.2-.6 1.9-2-.1L8 14.5l-1.6-1.2-2 .1-.6-1.9-1.6-1.2.6-1.9-.6-1.9 1.6-1.2.6-1.9 2 .1z"/><path d="M5.6 8.1 7.2 9.7 10.4 6.4"/>',
    'text.bubble': '<path d="M3.6 2.3h8.8c.9 0 1.6.7 1.6 1.6v5.8c0 .9-.7 1.6-1.6 1.6H7.4l-3 2.5v-2.5h-.8c-.9 0-1.6-.7-1.6-1.6V3.9c0-.9.7-1.6 1.6-1.6z"/><path d="M5 5.6h6M5 8.2h4"/>',
    'folder': '<path d="M1.8 4.2c0-.8.6-1.4 1.4-1.4h3l1.4 1.6h5.2c.8 0 1.4.6 1.4 1.4v6.4c0 .8-.6 1.4-1.4 1.4H3.2c-.8 0-1.4-.6-1.4-1.4z"/>',
    'folder.fill': '<path class="f" d="M1.8 4.2c0-.8.6-1.4 1.4-1.4h3l1.4 1.6h5.2c.8 0 1.4.6 1.4 1.4v6.4c0 .8-.6 1.4-1.4 1.4H3.2c-.8 0-1.4-.6-1.4-1.4z"/>',
    'doc': '<path d="M4 1.8h5l3.2 3.2v8.2c0 .6-.5 1-1 1H4c-.6 0-1-.4-1-1V2.8c0-.6.4-1 1-1z"/><path d="M9 1.8V5h3.2"/>',
    'doc.text': '<path d="M4 1.8h5l3.2 3.2v8.2c0 .6-.5 1-1 1H4c-.6 0-1-.4-1-1V2.8c0-.6.4-1 1-1z"/><path d="M9 1.8V5h3.2M5.5 8h5M5.5 10.5h5"/>',
    'arrow.down': '<path d="M8 2.5v11M3.8 9.3 8 13.5l4.2-4.2"/>',
    'arrow.up': '<path d="M8 13.5v-11M3.8 6.7 8 2.5l4.2 4.2"/>',
    'square.split.1x2': '<rect x="1.8" y="2.5" width="12.4" height="11" rx="2"/><path d="M1.8 8h12.4"/>',
    'rectangle.split.2x1': '<rect x="1.8" y="2.5" width="12.4" height="11" rx="2"/><path d="M8 2.5v11"/>',
    'rectangle.split.1x2': '<rect x="1.8" y="2.5" width="12.4" height="11" rx="2"/><path d="M1.8 8h12.4"/>',
    'square.split.2x1': '<rect x="1.8" y="2.5" width="12.4" height="11" rx="2"/><path d="M8 2.5v11"/>',
    'play.fill': '<path class="f" d="M4.5 2.6v10.8c0 .5.5.8 1 .5l8.3-5.4c.4-.3.4-.8 0-1.1L5.5 2.1c-.5-.3-1 0-1 .5z"/>',
    'stop.fill': '<rect class="f" x="3.5" y="3.5" width="9" height="9" rx="1.5"/>',
    'chevron.down': '<path d="M3.5 6 8 10.5 12.5 6"/>',
    'tablecells': '<rect x="1.8" y="2.5" width="12.4" height="11" rx="1.6"/><path d="M1.8 6.2h12.4M1.8 9.8h12.4M6 6.2v7.3M10 6.2v7.3"/>',
    'at': '<circle cx="8" cy="8" r="2.6"/><path d="M10.6 8v1c0 1.2 1 2 2 1.6.9-.4 1.4-1.5 1.4-2.6A6 6 0 1 0 10.4 13.5"/>',
    'paperclip': '<path d="M12.5 7.3 7.6 12.2a3 3 0 0 1-4.2-4.2l5.2-5.2a2 2 0 0 1 2.8 2.8L6.2 10.8a1 1 0 0 1-1.4-1.4l4.6-4.6"/>',
    'hammer': '<path d="M9.2 2.5 13.5 6.8l-1.6 1.6L7.6 4.1z"/><path d="M8.4 5.6 2.5 11.5a1.1 1.1 0 0 0 1.6 1.6L10 7.2"/>',
    'line.3.horizontal.decrease': '<path d="M2.5 4.5h11M4.5 8h7M6.5 11.5h3"/>',
    'trash': '<path d="M2.8 4.3h10.4M6.2 4.3V2.8h3.6v1.5M4 4.3l.7 8.9c0 .6.5 1 1 1h4.6c.5 0 1-.4 1-1l.7-8.9"/>',
    'pencil': '<path d="M10.8 2.4l2.8 2.8-7.8 7.8-3.4.6.6-3.4z"/>',
    'eye': '<path d="M1.5 8S4 3.5 8 3.5 14.5 8 14.5 8 12 12.5 8 12.5 1.5 8 1.5 8z"/><circle cx="8" cy="8" r="2"/>',
    'cpu': '<rect x="3.5" y="3.5" width="9" height="9" rx="1.5"/><rect x="6" y="6" width="4" height="4" rx=".6"/><path d="M6 1.5v2M10 1.5v2M6 12.5v2M10 12.5v2M1.5 6h2M1.5 10h2M12.5 6h2M12.5 10h2"/>',
    'memorychip': '<rect x="1.8" y="4" width="12.4" height="7" rx="1.2"/><path d="M4.5 6.5v2M7 6.5v2M9.5 6.5v2M12 6.5v2M4 11v2M8 11v2M12 11v2"/>',
    'externaldrive': '<rect x="1.8" y="5" width="12.4" height="6.5" rx="1.6"/><path d="M11.5 8.25h.01M3.2 5 4.6 2.5h6.8L12.8 5"/>',
    'list.bullet': '<path d="M6 4h8M6 8h8M6 12h8M2.6 4h.01M2.6 8h.01M2.6 12h.01"/>',
    'square.on.square': '<rect x="5" y="5" width="9" height="9" rx="1.6"/><path d="M11 5V3.4c0-.9-.7-1.6-1.6-1.6H3.4c-.9 0-1.6.7-1.6 1.6v6c0 .9.7 1.6 1.6 1.6H5"/>',
    'power': '<path d="M8 1.8v6M4.4 4.2a5.2 5.2 0 1 0 7.2 0"/>',
    'globe': '<circle cx="8" cy="8" r="6.2"/><path d="M1.8 8h12.4M8 1.8c1.8 1.7 2.6 3.8 2.6 6.2S9.8 12.5 8 14.2C6.2 12.5 5.4 10.4 5.4 8S6.2 3.5 8 1.8"/>',
    'arrow.triangle.2.circlepath': '<path d="M2.5 7.5A5.5 5.5 0 0 1 12.6 4.6"/><path d="M13.2 1.8v3h-3"/><path d="M13.5 8.5A5.5 5.5 0 0 1 3.4 11.4"/><path d="M2.8 14.2v-3h3"/>',
    'touchid': '<path d="M4.2 3.4A5.5 5.5 0 0 1 13.5 7.5v1.2"/><path d="M2.6 6a5.6 5.6 0 0 0-.1 1.5v3"/><path d="M5 13.8V7.6a3 3 0 0 1 6 0v3.2"/><path d="M8 7.6v6.6"/><path d="M11 12.8v1.4"/>',
    'faceid': '<path d="M1.5 5V3.5a2 2 0 0 1 2-2H5M11 1.5h1.5a2 2 0 0 1 2 2V5M14.5 11v1.5a2 2 0 0 1-2 2H11M5 14.5H3.5a2 2 0 0 1-2-2V11"/><path d="M5.5 5.8v1M10.5 5.8v1M8 5.8v3.4h-.8M5.6 11a3.4 3.4 0 0 0 4.8 0"/>',
    'arrow.up.circle': '<circle cx="8" cy="8" r="6.2"/><path d="M8 11.2V4.9M5.3 7.5 8 4.8l2.7 2.7"/>',
    'person.2': '<circle cx="6" cy="5.5" r="2.3"/><path d="M1.8 13.5c.4-2.3 2.1-3.8 4.2-3.8s3.8 1.5 4.2 3.8"/><path d="M10.5 3.4a2.3 2.3 0 0 1 0 4.4M12 9.9c1.2.5 2 1.9 2.2 3.6"/>',
    'clock': '<circle cx="8" cy="8" r="6.2"/><path d="M8 4.5V8l2.3 1.5"/>',
    'bell': '<path d="M4 11.5V7.2a4 4 0 0 1 8 0v4.3l1.2 1.3H2.8z"/><path d="M6.6 14.2h2.8"/>',
    'checkmark.shield': '<path d="M8 1.8 13 3.6v4c0 3.2-2.2 5.6-5 6.6-2.8-1-5-3.4-5-6.6v-4z"/><path d="M5.6 8.1 7.3 9.7l3.1-3.3"/>',
    'arrow.triangle.branch': '<circle cx="4" cy="3.5" r="1.5"/><circle cx="4" cy="12.5" r="1.5"/><circle cx="12" cy="5.5" r="1.5"/><path d="M4 5v6M12 7c0 2.6-2.4 3.3-8 4"/>',
    'arrow.up.arrow.down': '<path d="M5 13V3M2.5 5.5 5 3l2.5 2.5M11 3v10M8.5 10.5 11 13l2.5-2.5"/>',
    'antenna.radiowaves.left.and.right': '<circle cx="8" cy="7" r="1.2"/><path d="M8 8.2v6M5.2 4.4a4 4 0 0 0 0 5.2M10.8 4.4a4 4 0 0 1 0 5.2M3 2.6a6.6 6.6 0 0 0 0 8.8M13 2.6a6.6 6.6 0 0 1 0 8.8"/>',
    'square.stack.3d.up': '<path d="M8 1.8 14 4.8 8 7.8 2 4.8z"/><path d="M2 8l6 3 6-3M2 11.2l6 3 6-3"/>',
    'play.square.stack': '<rect x="2.5" y="5" width="11" height="9.5" rx="2"/><path d="M4.5 2.5h7"/><path class="f" d="M6.8 7.6v4.3c0 .3.3.5.6.3l3.3-2.1c.3-.2.3-.5 0-.7L7.4 7.3c-.3-.2-.6 0-.6.3z"/>',
    'waveform.path.ecg': '<path d="M1.5 8.5h2.7l1.6-4 2.6 8 1.9-6 1.2 2h3"/>',
    'xmark.octagon.fill': '<path class="f" d="M5.3 1.5h5.4l3.8 3.8v5.4l-3.8 3.8H5.3l-3.8-3.8V5.3z"/><path class="k" d="M5.6 5.6l4.8 4.8M10.4 5.6l-4.8 4.8"/>',
    'sidebar.left': '<rect x="2" y="3" width="12" height="10" rx="1.8"/><path d="M6.5 3v10"/>',
    'house': '<path d="M2.3 7.6 8 2.6l5.7 5"/><path d="M3.8 6.4v6.8c0 .5.4.8.8.8h2.4v-3.6h2V14h2.4c.4 0 .8-.3.8-.8V6.4"/>',
    'chevron.down.small': '<path d="M4.5 6.5 8 10l3.5-3.5"/>',
    'chevron.up': '<path d="M3.5 10 8 5.5 12.5 10"/>',
    'terminal.fill': '<rect class="f" x="1.5" y="2.5" width="13" height="11" rx="2"/><path class="k" d="M4.5 6.2 6.8 8 4.5 9.8M8.5 10h3"/>',
    'square.and.arrow.down': '<path d="M5.6 5.5H4.3c-.8 0-1.5.7-1.5 1.5v5.5c0 .8.7 1.5 1.5 1.5h7.4c.8 0 1.5-.7 1.5-1.5V7c0-.8-.7-1.5-1.5-1.5h-1.3"/><path d="M8 1.8v7.7M5.3 6.9 8 9.6l2.7-2.7"/>',
    'heart.text.square': '<rect x="1.8" y="1.8" width="12.4" height="12.4" rx="2.6"/><path d="M8 9.2C6.7 8.4 5.3 7.5 5.3 6.2c0-1.1 1.5-1.6 2.7-.5 1.2-1.1 2.7-.6 2.7.5 0 1.3-1.4 2.2-2.7 3z"/><path d="M5.5 11.6h5"/>',
    'plus.rectangle.on.rectangle': '<path d="M4.6 2.3h7.6c.9 0 1.5.7 1.5 1.5v6.6"/><rect x="2.3" y="4.6" width="9.4" height="9.1" rx="1.6"/><path d="M7 7v4.2M4.9 9.1h4.2"/>',
    'menubar.rectangle': '<rect x="1.8" y="2.5" width="12.4" height="11" rx="2"/><path d="M1.8 6h12.4M4.3 4.25h.01M6.3 4.25h.01"/>',
    'command': '<path d="M6 6h4v4H6zM6 6V4.5A1.5 1.5 0 1 0 4.5 6H6M10 6V4.5A1.5 1.5 0 1 1 11.5 6H10M6 10v1.5A1.5 1.5 0 1 1 4.5 10H6M10 10v1.5a1.5 1.5 0 1 0 1.5-1.5H10"/>',
    'iphone': '<rect x="4" y="1.5" width="8" height="13" rx="2"/><path d="M7 3.6h2"/>',
    'chevron.left': '<path d="M10 3.5 5.5 8 10 12.5"/>',
    'arrow.right': '<path d="M2.5 8h11M9.3 3.8 13.5 8l-4.2 4.2"/>',
    'arrow.left': '<path d="M13.5 8h-11M6.7 3.8 2.5 8l4.2 4.2"/>',
    'arrow.turn.left.up': '<path d="M13 13.5H8.5a3 3 0 0 1-3-3V3"/><path d="M2.5 6 5.5 3l3 3"/>',
    'arrow.left.arrow.right.circle': '<circle cx="8" cy="8" r="6.5"/><path d="M4.8 6.6h6.4M9.6 5l1.6 1.6-1.6 1.6M11.2 9.4H4.8M6.4 7.8 4.8 9.4 6.4 11"/>',
    'eye.slash': '<path d="M1.5 8S4 3.5 8 3.5 14.5 8 14.5 8 12 12.5 8 12.5 1.5 8 1.5 8z"/><circle cx="8" cy="8" r="2"/><path d="M2.5 2.5l11 11"/>',
    'square.and.arrow.up': '<path d="M5.6 6H4.3c-.8 0-1.5.7-1.5 1.5v5c0 .8.7 1.5 1.5 1.5h7.4c.8 0 1.5-.7 1.5-1.5v-5c0-.8-.7-1.5-1.5-1.5h-1.3"/><path d="M8 9.5V1.8M5.3 4.4 8 1.7l2.7 2.7"/>',
    'folder.badge.plus': '<path d="M8.5 13.2H3.2c-.8 0-1.4-.6-1.4-1.4V4.2c0-.8.6-1.4 1.4-1.4h3l1.4 1.6h5.2c.8 0 1.4.6 1.4 1.4v2.4"/><path d="M12.2 9.4v4.4M10 11.6h4.4"/>',
    'info.circle': '<circle cx="8" cy="8" r="6.5"/><path d="M8 7.2v4.3M8 4.7v.1"/>',
    'circle.dashed': '<circle cx="8" cy="8" r="6" stroke-dasharray="2 2.1"/>'
  };
  var WEIGHT = { light: 1, regular: 1.5, medium: 1.6, semibold: 1.8, bold: 2 };

  function SFSymbol(p) {
    var size = p.size || 16;
    var body = G[p.name] || G['circle.dashed'];
    var sw = WEIGHT[p.weight || 'regular'] || 1.5;
    return h('span', {
      className: cx('k-sym', p.className),
      style: assign({ width: size + 'px', height: size + 'px', color: p.color ? v(p.color) : undefined }, p.style || {}),
      'aria-hidden': 'true',
      'data-symbol': p.name,
      dangerouslySetInnerHTML: { __html: '<svg viewBox="0 0 16 16" style="stroke-width:' + sw + '">' + body + '</svg>' }
    });
  }

  // Foundations
  var logoSeq = 0;
  function AppLogo(p) {
    // K-caret: a K whose stem is the cursor, on a graphite square (corner 25%). 32 and below use the heavier small drawing.
    var size = p.size || 28, id = 'k-logo-' + (++logoSeq), small = size <= 32;
    return h('svg', { className: 'k-logo', viewBox: '0 0 100 100', width: size, height: size, role: 'img', 'aria-label': 'Komando' },
      h('defs', null,
        h('linearGradient', { id: id + '-bg', x1: 0, y1: 0, x2: 0, y2: 1 },
          h('stop', { offset: 0, style: { stopColor: 'var(--logo-ground-top)' } }),
          h('stop', { offset: 1, style: { stopColor: 'var(--logo-ground-bottom)' } }))),
      h('rect', { width: 100, height: 100, rx: 25, fill: 'url(#' + id + '-bg)' }),
      small
        ? h('rect', { x: 25, y: 24.5, width: 14, height: 51, rx: 7, style: { fill: 'var(--logo-cursor)' } })
        : h('rect', { x: 27.5, y: 24, width: 12, height: 52, rx: 6, style: { fill: 'var(--logo-cursor)' } }),
      h('path', { d: small ? 'M70.5 31 51.5 50 70.5 69' : 'M69.5 29.5 50.5 50 69.5 70.5', fill: 'none', strokeWidth: small ? 12 : 10, strokeLinecap: 'round', strokeLinejoin: 'round', style: { stroke: 'var(--logo-ink)' } }));
  }

  function IconTile(p) {
    var size = p.size || 32;
    var glyph = { 20: 12, 28: 16, 32: 16, 40: 20, 48: 24 }[size] || Math.round(size / 2);
    return h('span', {
      className: 'k-tile',
      style: { width: size + 'px', height: size + 'px', '--t': v(p.tint || 'accent') }
    }, h(SFSymbol, { name: p.symbol, size: glyph, weight: 'medium', style: { '--sym-knock': v('panel') } }));
  }
  function StatusDot(p) {
    var size = p.size || 8;
    return h('span', { className: 'k-dot', style: { width: size + 'px', height: size + 'px', '--c': v(p.tone || 'ok') } });
  }
  function Pill(p) {
    return h('span', { className: 'k-pill', style: { '--c': v(p.tone || 'text2') } }, p.children);
  }
  function DashedDivider() { return h('div', { className: 'k-dashed', role: 'separator' }); }

  // Actions
  function Button(p) {
    var variant = p.variant || 'secondary';
    var kids = [];
    var iconOnly = p.children == null;
    if (p.symbol) kids.push(h(SFSymbol, { key: 's', name: p.symbol, size: iconOnly && p.size !== 'xs' ? 16 : 12, weight: variant === 'primary' ? 'semibold' : 'medium' }));
    if (!iconOnly) kids.push(h('span', { key: 'l' }, p.children));
    if (p.shortcut && variant === 'primary') kids.push(h('span', { key: 'k', className: 'k-kbd-in' }, p.shortcut));
    return h('button', {
      type: 'button', className: cx('k-btn', 'k-btn-' + variant, p.size === 'sm' && 'sm', p.size === 'xs' && 'xs', iconOnly && 'icon', p.wide && 'k-btn-wide', p.className),
      disabled: p.disabled, onClick: p.onClick, title: p.help,
      'aria-label': p.label || (iconOnly ? nameOf(p.help) : undefined), 'aria-pressed': p.pressed != null ? !!p.pressed : undefined
    }, kids);
  }
  function LinkButton(p) {
    return h('button', { type: 'button', className: 'k-link', onClick: p.onClick }, h('span', null, p.children), h(SFSymbol, { name: 'chevron.right', size: 8, weight: 'bold' }));
  }
  function Chip(p) {
    return h('button', { type: 'button', className: cx('k-chip', p.selected && 'k-chip-on', p.className), onClick: p.onClick }, p.children);
  }

  // Inputs
  // The visible label is a real <label>. Component children (TextField, PopupButton, Switch, Segmented) are told its id, so their
  // control is named by it and described by the help line; other children are grouped under it.
  function FormField(p) {
    var lid = useUid('label'), hid = useUid('help');
    var labelId = p.labelId || lid, helpId = p.helpId || hid;
    var kids = React.Children.map(p.children, function (c) {
      return c && typeof c.type === 'function' ? React.cloneElement(c, { labelId: labelId, helpId: p.help ? helpId : undefined }) : c;
    });
    var grouped = !p.inputId && React.Children.toArray(p.children).some(function (c) { return !c || typeof c.type !== 'function'; });
    return h('div', { className: 'k-formfield', role: grouped ? 'group' : undefined, 'aria-labelledby': grouped ? labelId : undefined },
      h('label', { className: 'k-formfield-label', id: labelId, htmlFor: p.inputId }, p.label),
      kids,
      p.help ? h('span', { className: 'k-formfield-help', id: helpId }, p.help) : null);
  }
  function TextField(p) {
    var lid = useUid('label'), hid = useUid('help'), iid = useUid('input');
    var labelId = p.label ? lid : p.labelId, helpId = p.label ? (p.help ? hid : undefined) : p.helpId;
    var a11y = { id: iid, 'aria-labelledby': labelId, 'aria-describedby': helpId, 'aria-label': labelId ? undefined : (p.ariaLabel || p.placeholder) };
    var field = h('label', { className: cx('k-field', p.focused && 'is-focused', p.multiline && 'multi') },
      p.multiline
        ? h('textarea', assign({ className: cx('k-input k-textarea', p.mono && 'k-input-mono'), rows: p.rows || 3, placeholder: p.placeholder, defaultValue: p.value, spellCheck: false }, a11y))
        : h('input', assign({ className: cx('k-input', p.mono && 'k-input-mono'), type: p.secure ? 'password' : 'text', placeholder: p.placeholder, defaultValue: p.value, spellCheck: false }, a11y)));
    return p.label ? h(FormField, { label: p.label, help: p.help, labelId: lid, helpId: hid, inputId: iid }, field) : field;
  }
  function SearchBar(p) {
    return h('label', { className: cx('k-search', p.focused && 'is-focused') },
      h(SFSymbol, { name: 'magnifyingglass', size: 16, color: 'text3' }),
      h('input', { className: 'k-input', 'aria-label': p.label || 'Search', placeholder: p.placeholder, defaultValue: p.value, spellCheck: false }),
      p.value ? h(SFSymbol, { name: 'xmark.circle.fill', size: 16, color: 'text3', style: { '--sym-knock': v('field') } }) : null,
      p.actionTitle ? h(Button, { variant: 'secondary', size: 'sm', disabled: !p.value }, p.actionTitle) : h('span', { style: { width: '8px' } }));
  }
  // A real checkbox, visually hidden behind the drawn box, so it is focused, read and toggled like any checkbox.
  function Check(p) {
    return h('label', { className: 'k-check' },
      h('input', { type: 'checkbox', className: 'k-vh', checked: !!p.on, readOnly: true, onChange: p.onChange, 'aria-label': p.label ? undefined : p.ariaLabel }),
      h('span', { className: cx('k-check-box', p.on && 'on'), 'aria-hidden': 'true' }, p.on ? h(SFSymbol, { name: 'checkmark', size: 12, weight: 'bold' }) : null),
      p.label);
  }
  function CommandBar(p) {
    var empty = !(p.value || '').trim();
    var trailing = p.running
      ? [h('span', { key: 'sp', className: 'k-spinner', role: 'status', 'aria-label': 'Running' }), h(Button, { key: 'st', variant: 'ghost', size: 'sm' }, 'Stop')]
      : [h('button', { key: 'run', type: 'button', className: cx('k-send', !empty && 'on'), title: 'Run (↩)', 'aria-label': 'Run', disabled: empty }, h(SFSymbol, { name: 'arrow.up', size: 12, weight: 'semibold' }))];
    return h('div', { className: 'k-cmdbar' },
      h('label', { className: cx('k-cmdbar-line', p.focused && 'is-focused') },
        h(SFSymbol, { name: 'chevron.right', size: 12, weight: 'bold', color: 'accent' }),
        h('input', { className: 'k-input k-input-mono', 'aria-label': p.label || 'Command', placeholder: p.placeholder, defaultValue: p.value, spellCheck: false }),
        trailing),
      (p.options && p.options.length) || p.accessory ? h('div', { className: 'k-cmdbar-opts' }, (p.options || []).map(function (o, i) { return h(Check, { key: i, label: o.label, on: o.on }); }), p.accessory || null) : null);
  }
  function ToggleCard(p) {
    var tid = useUid('title'), did = useUid('help');
    return h('div', { className: 'k-card k-togglecard' },
      h('div', { className: 'k-row', style: { gap: 'var(--space-12)' } },
        h('div', { className: 'k-twoline' },
          h('span', { className: 'k-rowtitle', id: tid }, p.title),
          h('span', { className: 'k-sub', id: did }, p.help)),
        h(Switch, { on: p.on, onClick: p.onToggle, labelledBy: tid, describedBy: p.help ? did : undefined })),
      p.on ? p.children : null);
  }
  function UnderlineTabs(p) {
    return h('div', { className: 'k-tabs', role: 'tablist' }, (p.items || []).map(function (t) {
      var on = t === p.selected;
      return h('button', { key: t, type: 'button', role: 'tab', 'aria-selected': on, tabIndex: on ? 0 : -1, className: cx('k-tabs-item', on && 'on') }, t);
    }));
  }

  // Content
  function SectionTitle(p) {
    return h('div', { className: 'k-sectiontitle' },
      h('div', { className: 'k-sectiontitle-top' },
        h('span', { className: 'k-sectiontitle-title' }, p.title),
        p.detail ? h('span', { className: 'k-sectiontitle-detail' }, p.detail) : null),
      p.subtitle ? h('span', { className: 'k-sectiontitle-sub' }, p.subtitle) : null);
  }
  function Card(p) {
    return h('div', { className: cx('k-card', p.className), style: p.padding != null ? { padding: p.padding + 'px' } : undefined }, p.children);
  }
  function HoverCard(p) {
    return h('button', { type: 'button', className: cx('k-hovercard', p.hover && 'is-hover'), onClick: p.onClick }, p.children);
  }
  function Surface(p) {
    return h('div', { className: 'k-surface', style: p.padding != null ? { padding: p.padding + 'px' } : undefined }, p.children);
  }
  function InfoRow(p) {
    return h('div', { className: 'k-inforow' },
      h('span', { className: 'k-inforow-label' }, p.label),
      h('span', { className: cx('k-inforow-value', p.mono && 'k-mono') }, p.value));
  }
  function CardList(p) {
    var items = React.Children.toArray(p.children);
    var out = [];
    items.forEach(function (c, i) {
      out.push(c);
      if (i < items.length - 1) out.push(h('div', { key: 'sep' + i, className: 'k-cardlist-sep' }));
    });
    return h('div', { className: 'k-card k-cardlist' }, out);
  }
  function AttentionCard(p) {
    var tone = p.tone || 'warn';
    // Severity by shape as well as color: a problem is a circle, a warning a triangle, each with its word for VoiceOver.
    var problem = tone === 'danger';
    return h('div', { className: 'k-attention', style: { '--c': v(tone) } },
      h('span', { className: 'k-attention-mark', role: 'img', 'aria-label': problem ? 'Problem' : 'Warning', title: problem ? 'Problem' : 'Warning' },
        h(SFSymbol, { name: problem ? 'exclamationmark.circle.fill' : 'exclamationmark.triangle.fill', size: 16, color: tone, style: { '--sym-knock': v('card') } })),
      h('div', { className: 'k-attention-text' },
        h('div', { className: 'k-attention-top' },
          h('span', { className: 'k-attention-subject k-trunc' }, p.subject),
          p.category ? h('span', { className: 'k-attention-cat' }, p.category) : null),
        h('span', { className: 'k-attention-msg' }, p.message)),
      p.actionTitle ? h(Button, { variant: 'secondary', size: 'sm' }, p.actionTitle) : null);
  }
  function RunningCard(p) {
    var chipTone = p.chipTone || 'ok';
    return h(HoverCard, { hover: p.hover },
      h('div', { className: 'k-running' },
        h('div', { className: 'k-running-top' },
          h(IconTile, { symbol: p.symbol, tint: p.tint, size: 28 }),
          h('span', { className: 'k-rowtitle k-trunc' }, p.title)),
        h('span', { className: 'k-mono k-t2 k-trunc', style: { display: 'block' } }, p.line),
        h('div', { className: 'k-row' },
          h(Pill, { tone: chipTone }, p.chip),
          p.meta ? h('span', { className: 'k-sub k-t3' }, p.meta) : null)));
  }
  function TargetCard(p) {
    return h(HoverCard, { hover: p.hover },
      h('div', { className: 'k-target' },
        h(IconTile, { symbol: p.symbol, tint: p.tint, size: 40 }),
        h('div', { className: 'k-twoline' },
          h('span', { className: 'k-rowtitle k-trunc' }, p.name),
          h('span', { className: 'k-sub k-trunc' }, p.subtitle)),
        p['protected'] ? h(SFSymbol, { name: 'lock.fill', size: 12, color: 'warn' }) : null));
  }
  function ActivityRow(p) {
    return h('div', { className: 'k-activity' },
      h(IconTile, { symbol: p.symbol, tint: p.tint, size: 32 }),
      h('div', { className: 'k-twoline' },
        h('span', { className: 'k-rowtitle' }, p.title),
        p.detail ? h('span', { className: 'k-mono k-t2 k-trunc' }, p.detail) : null,
        h('span', { className: 'k-meta' }, (p.meta || []).filter(Boolean).join(' · '))),
      h('button', { type: 'button', className: 'k-more', title: 'More', 'aria-label': 'More' }, h(SFSymbol, { name: 'ellipsis', size: 16 })));
  }
  function OutputText(p) {
    return h('div', { className: 'k-surface k-mono k-output', style: p.tone ? { color: v(p.tone) } : undefined }, p.text);
  }
  function TerminalPane(p) {
    var bar = null;
    if (p.state === 'running') {
      bar = h('div', { className: 'k-term-bar' },
        h('span', { className: 'k-spinner' }),
        h('span', { className: 'k-t2' }, 'Running ' + (p.label || '') + '…'),
        h('span', { className: 'k-spacer' }),
        h(Button, { variant: 'ghost', size: 'sm' }, 'Stop'));
    } else if (p.state === 'failed') {
      bar = h('div', { className: 'k-term-bar', style: { color: v('warn') } },
        h(SFSymbol, { name: 'exclamationmark.triangle.fill', size: 12, style: { '--sym-knock': v('subtle') } }),
        h('span', null, 'Exit ' + (p.exitCode != null ? p.exitCode : 1) + ' · ' + (p.meaning || 'general error')));
    }
    var body = p.text
      ? h('div', { className: 'k-term-body k-mono' }, p.text)
      : h('div', { className: 'k-term-empty' }, p.placeholder || 'Output appears here.');
    return h('div', { className: 'k-term', style: p.height ? { height: p.height + 'px' } : undefined }, bar, body);
  }
  function FormHeader(p) {
    return h('div', { className: 'k-formheader' },
      h(IconTile, { symbol: p.symbol, tint: p.tint, size: 48 }),
      h('div', { className: 'k-twoline' },
        h('span', { className: 'k-formheader-title' }, p.title),
        h('span', { className: 'k-t2' }, p.subtitle)));
  }

  // Feedback
  function Banner(p) {
    var tone = p.tone || 'danger';
    return h('div', { className: cx('k-banner', tone === 'danger' && 'k-banner-danger'), style: { '--c': v(tone) } },
      h(SFSymbol, { name: tone === 'ok' ? 'checkmark.circle.fill' : 'exclamationmark.circle.fill', size: 16, style: { '--sym-knock': v('panel') } }),
      h('div', { className: 'k-banner-text' },
        h('span', { className: 'k-banner-title' }, p.title),
        p.detail ? h('span', { className: 'k-t2' }, p.detail) : null));
  }
  function EmptyState(p) {
    return h('div', { className: 'k-empty' },
      h(SFSymbol, { name: p.symbol, size: 32, weight: 'light', color: 'text3' }),
      h('span', { className: 'k-empty-title' }, p.title),
      p.message ? h('span', { className: 'k-empty-msg' }, p.message) : null,
      p.children ? h('div', { className: 'k-empty-actions' }, p.children) : null);
  }

  // Navigation
  function SidebarItem(p) {
    return h('button', { type: 'button', className: cx('k-navitem', p.selected && 'on'), 'aria-current': p.selected ? 'page' : undefined, onClick: p.onClick },
      h(SFSymbol, { name: p.symbol, size: 16, color: p.selected ? 'text' : 'text2' }),
      h('span', null, p.title),
      h('span', { className: 'k-spacer' }),
      p.shortcut ? h('span', { className: 'k-navitem-key' }, p.shortcut)
        : (p.count ? h('span', { className: cx('k-navitem-count', p.countTone && 'tone'), style: p.countTone ? { '--c': v(p.countTone) } : undefined, title: p.countHelp }, String(p.count)) : null));
  }
  function GroupRow(p) {
    var total = p.total || 0, prot = p['protected'] || 0;
    var tone = prot === 0 ? 'text3' : (prot === total ? 'ok' : 'warn');
    var pct = total ? Math.round(prot / total * 1000) / 10 : 0;
    return h('div', { className: 'k-grouprow', title: prot + ' of ' + total + ' protected' },
      h('div', { className: 'k-row' },
        h(StatusDot, { tone: tone }),
        h('span', { className: cx('k-trunc', p.active ? 'k-t1' : 'k-t2') }, p.name),
        h('span', { className: 'k-spacer' }),
        h('span', { className: 'k-t3', style: { fontFamily: v('font-mono'), fontSize: '11px', lineHeight: '16px' } }, prot + '/' + total)),
      h('div', { className: 'k-bar', style: { '--c': v(tone) } }, h('i', { style: { width: pct + '%' } })));
  }
  function TabButton(p) {
    return h('div', { className: cx('k-tab', p.active && 'on', p.home && 'home') },
      h('button', { type: 'button', className: 'k-tab-main', 'aria-current': p.active ? 'page' : undefined, onClick: p.onClick },
        h(SFSymbol, { name: p.symbol, size: 12, weight: 'medium', color: p.active ? 'text' : 'text3' }),
        h('span', { className: 'k-trunc' }, p.title)),
      p.home ? null : h('button', { type: 'button', className: 'k-tab-x', title: 'Close ' + p.title, 'aria-label': 'Close ' + p.title, onClick: p.onClose }, h(SFSymbol, { name: 'xmark', size: 8, weight: 'bold' })));
  }
  function PanelHeader(p) {
    var tabs = p.tabs || [];
    return h('div', { className: 'k-header' },
      tabs.length > 1
        ? tabs.map(function (t, i) { return h(TabButton, { key: i, symbol: t.symbol, title: t.title, home: i === 0, active: i === (p.activeIndex || 0) }); })
        : h('span', { className: 'k-header-title' }, p.title),
      h('span', { className: 'k-spacer' }),
      h(Button, { variant: 'ghost', size: 'sm', help: 'Ask the agent (⌘J)', symbol: 'text.bubble' }),
      h(Button, { variant: 'ghost', size: 'sm', help: 'Read the inventory again (⌘R)', symbol: 'arrow.clockwise' }),
      p.action ? h('span', { style: { width: 'var(--space-8)' } }) : null,
      p.action ? h(Button, { variant: 'primary', symbol: p.action.symbol || 'plus' }, p.action.title) : null);
  }
  function MenuRow(p) {
    return h('button', { type: 'button', className: cx('k-menurow', p.highlighted && 'on'), onClick: p.onClick },
      h(IconTile, { symbol: p.symbol, tint: p.tint, size: 32 }),
      h('div', { className: 'k-twoline' },
        h('span', { className: 'k-rowtitle' }, p.title),
        h('span', { className: 'k-sub' }, p.help)),
      p.shortcut ? h('span', { className: 'k-navitem-key' }, p.shortcut) : null);
  }
  function CommandPalette(p) {
    // A combobox: the input keeps focus and the highlighted row is its active option, as in the app.
    var items = p.items || [], lid = useUid('palette'), cur = p.index || 0;
    return h('div', { className: 'k-palette', role: 'dialog', 'aria-label': 'Search' },
      h('div', { className: 'k-palette-input' },
        h(SFSymbol, { name: 'magnifyingglass', size: 16, color: 'text3' }),
        h('input', { className: 'k-input', role: 'combobox', 'aria-label': 'Search, go anywhere, or connect', 'aria-expanded': items.length > 0, 'aria-controls': lid, 'aria-activedescendant': items.length ? lid + '-' + cur : undefined,
          placeholder: p.runOn ? 'Type the command, for example uptime' : 'Find a target or place, connect to user@address, or type a komando command', defaultValue: p.query, spellCheck: false }),
        h('span', { className: 'k-kbd-out', 'aria-hidden': 'true' }, 'esc')),
      // Run a Command… with a Run on field (M-MV5): where it runs, as komando's target words, above the command.
      p.runOn ? h('div', { className: 'k-palette-runon' },
        h('span', { className: 'k-formfield-label' }, 'Run on'),
        h(TargetsField, p.runOn)) : null,
      h('div', { className: 'k-rule' }),
      h('div', { className: 'k-palette-list', role: 'listbox', id: lid, 'aria-label': 'Results' }, items.map(function (it, i) {
        return h('div', { key: i, id: lid + '-' + i, role: 'option', 'aria-selected': i === cur, className: cx('k-palette-row', i === cur && 'on') },
          h(IconTile, { symbol: it.symbol, tint: it.tint, size: 28 }),
          h('span', { className: 'k-t1' }, it.title),
          h('span', { className: 'k-t3 k-trunc' }, it.detail),
          h('span', { className: 'k-spacer' }),
          i === cur ? h('span', { className: 'k-t3', 'aria-hidden': 'true' }, '↩') : null);
      })));
  }

  // Account
  function ProfileCard(p) {
    var name = p.name || 'You';
    return h('div', { className: 'k-card k-profile' },
      h('span', { className: 'k-avatar' }, (p.initial || name.charAt(0)).toUpperCase()),
      h('div', { className: 'k-twoline' },
        h('span', { className: 'k-rowtitle' }, name),
        h('span', { className: 'k-meta' }, p.where || 'Local · on this Mac')),
      h(SFSymbol, { name: 'chevron.up.chevron.down', size: 12, color: 'text3' }));
  }

  // ---- The window, the terminal, data and the agent ----
  // The sidebar: six places (owner decision 2026-11-14: Files is the sixth, never a seventh), the rest under More,
  // Search only, a light footer. Files counts running transfers, not things: its count is accent and says so.
  var PLACES = [['house', 'Home'], ['server.rack', 'Hosts', 12], ['cylinder.split.1x2', 'Connections', 12],
    ['folder', 'Files'], ['arrow.left.arrow.right', 'Port Forwarding', 3], ['curlybraces', 'Recipes', 14]];
  var MORE = [['gearshape.2', 'Jobs', 3], ['key', 'Keychain', 9], ['clock.arrow.circlepath', 'Audit Log']];
  // Places that no longer exist land where their content went.
  var MOVED = { Dashboard: 'Home', Doctor: 'Home', VPNs: 'Connections', Console: null, Agent: null };
  function AppShell(p) {
    var tabs = p.tabs || [];
    var place = Object.prototype.hasOwnProperty.call(MOVED, p.place) ? MOVED[p.place] : p.place;
    var inMore = MORE.some(function (m) { return m[1] === place; });
    var moreOpen = p.moreOpen != null ? p.moreOpen : inMore;
    var item = function (pl) {
      var files = pl[1] === 'Files';
      return h(SidebarItem, { key: pl[1], symbol: pl[0], title: pl[1],
        count: files ? (p.transfers || null) : p.counts === false ? null : (pl[1] === 'Jobs' && p.jobs != null ? (p.jobs || null) : pl[2]),
        countTone: files ? 'accent' : undefined, countHelp: files && p.transfers ? p.transfers + ' transfers running' : undefined, selected: place === pl[1] });
    };
    var sidebar = h('div', { className: 'k-window-side' },
      // The window buttons, then Hide Sidebar (⌃⌘S, also in View): the sidebar folds away and the panel takes the width.
      h('div', { className: 'k-traffic' }, h('i', { className: 'r' }), h('i', { className: 'y' }), h('i', { className: 'g' }),
        h('span', { className: 'k-spacer' }),
        h(Button, { variant: 'ghost', size: 'xs', symbol: 'sidebar.left', help: 'Hide the sidebar (⌃⌘S)' })),
      h('div', { className: 'k-row', style: { padding: '0 var(--space-20) var(--space-16)' } },
        h(AppLogo, { size: 28 }), h('span', { style: { fontSize: '17px', lineHeight: '24px', fontWeight: 600 } }, 'Komando')),
      h('div', { style: { padding: '0 var(--space-12)' } },
        // Opens the command palette, as the app's search field does: a button that looks like the field.
        h('div', { className: 'k-field', role: 'button', tabIndex: 0, 'aria-haspopup': 'dialog', 'aria-label': 'Search, go anywhere, or connect', title: 'Search, go anywhere, or connect to user@address (⌘K)' },
          h(SFSymbol, { name: 'magnifyingglass', size: 16, color: 'text3' }),
          h('span', { className: 'k-t3' }, 'Search'))),
      h('nav', { className: 'k-sidebar', 'aria-label': 'Places', style: { width: 'auto', flex: '1 1 auto' } },
        PLACES.map(item),
        h('button', { type: 'button', className: 'k-navitem k-navmore' + (moreOpen ? ' open' : ''), 'aria-expanded': !!moreOpen },
          h(SFSymbol, { name: moreOpen ? 'chevron.down' : 'chevron.right', size: 12, color: 'text3', weight: 'semibold', style: { margin: '0 var(--space-2)' } }),
          h('span', null, 'More')),
        moreOpen ? MORE.map(item) : null),
      h('div', { style: { padding: 'var(--space-8) var(--space-12) var(--space-12)', flex: 'none' } },
        h(ProfileCard, { name: p.profileName || 'You', where: p.profileWhere })));
    // The sidebar's trailing edge is a SplitDivider (200 to 320, 256 by default, remembered app-wide); dragged under 200 it hides.
    return h('div', { className: 'k-window', style: p.sidebarWidth ? { '--sidebar-width': p.sidebarWidth + 'px' } : undefined },
      p.hideSidebar ? null : sidebar,
      p.hideSidebar ? null : h('div', { className: cx('k-side-edge', p.sidebarDrag && 'on'), role: 'separator', 'aria-orientation': 'vertical', 'aria-label': 'Sidebar width', 'aria-valuemin': 200, 'aria-valuemax': 320, 'aria-valuenow': p.sidebarWidth || 256, title: 'Drag to resize the sidebar. Double-click to put it back.' }),
      h('div', { className: cx('k-window-panel', p.hideSidebar && 'alone') },
        h(PanelHeader, { title: p.title || place || p.place, tabs: tabs, activeIndex: p.activeTab || 0, action: p.action }),
        h('main', { className: cx('k-window-body', p.flush ? 'flush' : 'k-page') }, p.children)));
  }

  // A terminal session: lines of [text, style] runs. Styles: red green yellow blue magenta cyan dim bold sel.
  function Terminal(p) {
    var lines = p.lines || [];
    return h('div', { className: cx('k-terminal', p.inactive && 'inactive'), style: p.height ? { height: p.height + 'px' } : undefined },
      lines.map(function (ln, i) {
        var runs = (typeof ln === 'string' ? [ln] : ln).map(function (r, j) {
          if (typeof r === 'string') return r;
          return h('span', { key: j, className: (r[1] || '').split(' ').map(function (c) { return 'a-' + c; }).join(' ') }, r[0]);
        });
        var last = i === lines.length - 1;
        return h('div', { key: i, className: 'k-terminal-line' }, runs, last && p.cursor !== false ? h('span', { className: cx('k-terminal-cursor', p.inactive && 'hollow') }, ' ') : null, runs.length ? null : ' ');
      }));
  }
  function StatusBar(p) {
    return h('div', { className: 'k-statusbar' },
      (p.items || []).map(function (it, i) { return h('span', { key: i, className: 'k-row' }, it); }),
      h('span', { className: 'k-spacer' }),
      (p.right || []).map(function (it, i) { return h('span', { key: 'r' + i, className: 'k-row' }, it); }));
  }
  function Segmented(p) {
    // Named by its own label, or by the FormField label it sits in (labelId), so a field holding only a Segmented is named.
    return h('div', { className: 'k-seg', role: 'tablist', 'aria-label': p.label, 'aria-labelledby': p.label ? undefined : p.labelId, 'aria-describedby': p.helpId }, (p.items || []).map(function (it) {
      var on = it === p.selected;
      return h('button', { key: it, type: 'button', role: 'tab', 'aria-selected': on, tabIndex: on ? 0 : -1, className: cx('k-seg-item', on && 'on'), onClick: p.onSelect ? function () { p.onSelect(it); } : undefined }, it);
    }));
  }
  function DataTable(p) {
    var cols = p.columns || [], rows = p.rows || [];
    return h('div', { className: cx('k-table-wrap', p.bare && 'bare') },
      h('table', { className: cx('k-table', p.dense && 'dense') },
        h('thead', null, h('tr', null, cols.map(function (c) {
          return h('th', { key: c.key, style: { width: c.width, textAlign: c.align || 'left' } }, c.label);
        }))),
        h('tbody', null, rows.map(function (r, i) {
          return h('tr', { key: i, className: (Array.isArray(p.selected) ? p.selected.indexOf(i) >= 0 : i === p.selected) ? 'on' : undefined }, cols.map(function (c) {
            var v = r[c.key];
            var content = v == null ? h('span', { className: 'k-null' }, 'NULL') : (typeof c.render === 'function' ? c.render(v, r) : v);
            return h('td', { key: c.key, className: c.mono ? 'mono' : undefined, style: { textAlign: c.align || 'left' } }, content);
          }));
        }))));
  }

  // Agent mode
  function AgentMessage(p) {
    if (p.role === 'user') {
      return h('div', { className: 'k-msg user' }, h('div', { className: 'k-msg-bubble' }, p.children));
    }
    return h('div', { className: 'k-msg agent' },
      h('span', { className: 'k-agent-mark' }, h(SFSymbol, { name: 'text.bubble', size: 16 })),
      h('div', { className: 'k-msg-body' }, p.children));
  }
  function ToolCall(p) {
    var status = p.status || 'ok';
    var tone = status === 'ok' ? 'ok' : status === 'running' ? 'accent' : status === 'denied' || status === 'notrun' ? 'text2' : 'danger';
    var word = { ok: 'Done', running: 'Running', failed: 'Failed', denied: 'Denied', notrun: 'Not run' }[status];
    return h('div', { className: 'k-tool' },
      h('div', { className: 'k-tool-head' },
        h(SFSymbol, { name: p.symbol || 'terminal', size: 16, color: 'text3' }),
        h('span', { className: 'k-mono k-trunc k-t1' }, p.command),
        h('span', { className: 'k-spacer' }),
        status === 'running' ? h('span', { className: 'k-spinner' }) : null,
        h(Pill, { tone: tone }, word),
        p.duration ? h('span', { className: 'k-meta' }, p.duration) : null,
        h(SFSymbol, { name: p.open ? 'chevron.down' : 'chevron.right', size: 12, color: 'text3', weight: 'semibold' })),
      p.open && p.output ? h('div', { className: 'k-tool-out k-mono' }, p.output) : null);
  }
  function ApprovalCard(p) {
    return h('div', { className: 'k-approval' },
      h('div', { className: 'k-row', style: { alignItems: 'flex-start' } },
        h(SFSymbol, { name: 'exclamationmark.triangle.fill', size: 16, color: 'warn', style: { '--sym-knock': v('panel') } }),
        h('div', { className: 'k-twoline', style: { gap: 'var(--space-4)' } },
          h('span', { className: 'k-rowtitle' }, p.title),
          p.detail ? h('span', { className: 'k-sub' }, p.detail) : null)),
      h('div', { className: 'k-surface k-mono', style: { padding: 'var(--space-12)' } }, p.command),
      h('div', { className: 'k-row', style: { justifyContent: 'flex-end' } },
        h(Button, { variant: 'ghost', size: 'sm' }, p.denyTitle || 'Don’t Run'),
        h(Button, { variant: 'secondary', size: 'sm' }, p.allowTitle || 'Allow Once')));
  }
  function AgentComposer(p) {
    // allowChanges: ☐ Allow changes ticked. (The prototype's old mode: 'Act' still reads as ticked.)
    var allow = p.allowChanges != null ? !!p.allowChanges : p.mode === 'Act';
    return h('div', { className: 'k-composer' },
      (p.targets && p.targets.length) ? h('div', { className: 'k-row', style: { flexWrap: 'wrap' } },
        p.targets.map(function (t) {
          return h('span', { key: t.title, className: 'k-ctx' }, h(IconTile, { symbol: t.symbol, tint: t.tint, size: 20 }), t.title,
            h('button', { type: 'button', className: 'k-ctx-x', title: 'Remove ' + t.title, 'aria-label': 'Remove ' + t.title }, h(SFSymbol, { name: 'xmark', size: 8, weight: 'bold' })));
        })) : null,
      h('div', { className: cx('k-composer-input', !p.value && 'empty') }, p.value || p.placeholder || 'Ask about your servers, or tell the agent what to do…'),
      h('div', { className: 'k-row' },
        h(Button, { variant: 'ghost', size: 'sm', symbol: 'at', help: 'Add a target (@)' }),
        h(Button, { variant: 'ghost', size: 'sm', symbol: 'paperclip', help: 'Attach output or a file' }),
        h(Check, { label: 'Allow changes', on: allow }),
        allow ? h('span', { className: 'k-meta', style: { color: v('warn') } }, 'Each change asks first') : null,
        h('span', { className: 'k-spacer' }),
        h('button', { type: 'button', className: cx('k-send', p.value && 'on'), title: 'Send (↩)', 'aria-label': 'Send', disabled: !p.value }, h(SFSymbol, { name: 'arrow.up', size: 12, weight: 'semibold' }))));
  }

  // ---- Overlays, pickers and progress ----
  function Checkbox(p) { return h(Check, { label: p.label, on: p.on }); }
  // A real button with the switch role: focusable, named by its label (or the title next to it, or the FormField
  // label it sits in, which FormField passes as labelId), Space toggles it.
  function Switch(p) {
    return h('button', { type: 'button', className: cx('k-switch', p.on && 'on'), role: 'switch', 'aria-checked': !!p.on, onClick: p.onClick,
      'aria-label': p.label, 'aria-labelledby': p.label ? undefined : (p.labelledBy || p.labelId), 'aria-describedby': p.describedBy || p.helpId, title: p.help });
  }
  // Drawn as the field it looks like (so it sizes as one), reached and named as the button it is.
  function PopupButton(p) {
    var vid = useUid('value');
    return h('div', { className: cx('k-field k-popup', p.size === 'sm' && 'sm'), role: 'button', tabIndex: 0, 'aria-haspopup': 'listbox',
      'aria-labelledby': p.labelId ? p.labelId + ' ' + vid : undefined, 'aria-label': !p.labelId && p.label ? p.label + ': ' + (p.value || p.placeholder || 'Choose…') : undefined, 'aria-describedby': p.helpId },
      p.symbol ? h(SFSymbol, { name: p.symbol, size: 16, color: p.tint || 'text3' }) : null,
      h('span', { id: vid, className: cx('k-spacer k-trunc', !p.value && 'k-t3') }, p.value || p.placeholder || 'Choose…'),
      h(SFSymbol, { name: 'chevron.up.chevron.down', size: 12, color: 'text3' }));
  }
  // The hops komando goes through to reach a target, in order (`--via a,b,c`). steps: [{ name, kind: 'vpn'|'host' }].
  // Each row: its number, the family glyph, the name, then Move Up, Move Down and Remove. A VPN can only be first,
  // so a host never moves above it. Add a Step… is a popup under the list; the last line names the target itself.
  function HopList(p) {
    var steps = p.steps || [];
    var hopRow = function (s, i) {
      var vpn = s.kind === 'vpn', unknown = s.kind === 'unknown';
      var upOff = i === 0 || (i === 1 && steps[0].kind === 'vpn'), downOff = i === steps.length - 1 || vpn;
      return h('div', { key: s.name, className: 'k-hop', role: 'listitem' },
        h('span', { className: 'k-hop-n' }, String(i + 1)),
        unknown ? h('span', { title: 'komando has no host or VPN by this name', style: { display: 'inline-flex' } }, h(SFSymbol, { name: 'exclamationmark.triangle.fill', size: 16, color: 'warn', style: { '--sym-knock': v('subtle') } }))
          : h(SFSymbol, { name: vpn ? 'network.badge.shield.half.filled' : 'server.rack', size: 16, color: vpn ? 'tint-vpns' : 'tint-servers' }),
        h('span', { className: 'k-hop-name k-trunc' }, s.name),
        vpn ? h('span', { className: 'k-meta' }, 'VPN') : null,
        h('span', { className: 'k-spacer' }),
        h(Button, { variant: 'ghost', size: 'xs', symbol: 'chevron.up', help: 'Move Up', disabled: upOff }),
        h(Button, { variant: 'ghost', size: 'xs', symbol: 'chevron.down', help: 'Move Down', disabled: downOff }),
        h(Button, { variant: 'ghost', size: 'xs', symbol: 'xmark', help: 'Remove ' + s.name }));
    };
    return h('div', { className: 'k-hops' },
      steps.length ? h('div', { className: 'k-surface k-hops-list', role: 'list', 'aria-label': 'Steps, in order' }, steps.map(hopRow)) : null,
      h(PopupButton, { symbol: 'plus', tint: 'text2', placeholder: steps.length ? 'Add a Step…' : 'Choose a server or VPN…', label: 'Add a step' }),
      p.target ? h('span', { className: 'k-sub' }, steps.length
        ? 'komando goes through ' + (steps.length > 1 ? 'these in order' : 'it') + ', then reaches ' + p.target + '. A VPN can only be the first step.'
        : 'A VPN can only be the first step.') : null);
  }
  // One "Run on" field for every screen that runs on many (M-MV5): komando's own target words as chips
  // (a name, web-*, @group, tag:, label:, kind:, os:, all; ! leaves one out), Add… for more, and under it komando's
  // own answer of what they pick (`komando list WORDS`), never worked out by the app.
  function TargetsField(p) {
    var words = p.words || [];
    return h('div', { className: 'k-targets' },
      h('div', { className: 'k-field k-targets-box', role: 'group', 'aria-label': 'Run on: ' + words.join(', ') },
        words.map(function (w) {
          var out = w.charAt(0) === '!';
          return h('span', { key: w, className: cx('k-ctx', out && 'k-targets-out') },
            out ? h('span', { className: 'k-t2' }, 'not') : null,
            h('span', { className: 'k-mono' }, out ? w.slice(1) : w),
            h('button', { type: 'button', className: 'k-ctx-x', title: 'Remove ' + w, 'aria-label': 'Remove ' + w }, h(SFSymbol, { name: 'xmark', size: 8, weight: 'bold' })));
        }),
        h('span', { className: 'k-spacer' }),
        h(Button, { variant: 'ghost', size: 'sm', symbol: 'plus', help: 'Hosts, groups, tags, labels and kinds; or leave one out' }, 'Add…')),
      p.picks ? h('div', { className: 'k-row k-sub' },
        h('span', { className: 'k-spacer' }, p.picks),
        p.protectedCount ? h('span', { className: 'k-row', style: { gap: 'var(--space-4)' } }, h(SFSymbol, { name: 'lock.fill', size: 12, color: 'warn' }), p.protectedCount + ' protected') : null,
        h(LinkButton, null, 'Show the List')) : null);
  }
  function ProgressBar(p) { return h('div', { className: 'k-bar', style: { '--c': v(p.tone || 'accent') } }, h('i', { style: { width: (p.value || 0) + '%' } })); }
  function Skeleton(p) { return h('span', { className: 'k-skel', style: { width: p.width || '100%', height: (p.height || 12) + 'px' } }); }
  function Popover(p) { return h('div', { className: 'k-popover', style: p.width ? { width: p.width + 'px' } : undefined }, p.children); }
  // A modal dialog named by its title. Escape calls onClose when one is given, as Cancel does in the app.
  function Sheet(p) {
    var tid = useUid('title'), sid = useUid('sub'), onClose = p.onClose;
    React.useEffect(function () {
      if (!onClose) return undefined;
      var key = function (e) { if (e.key === 'Escape') { e.preventDefault(); onClose(); } };
      window.addEventListener('keydown', key);
      return function () { window.removeEventListener('keydown', key); };
    }, [onClose]);
    return h('div', { className: 'k-sheet-scrim' }, h('div', { className: 'k-sheet', role: 'dialog', 'aria-modal': 'true', 'aria-labelledby': p.title ? tid : undefined, 'aria-describedby': p.subtitle ? sid : undefined, style: p.width ? { width: p.width + 'px' } : undefined },
      (p.symbol || p.title) ? h('div', { className: 'k-sheet-head' },
        p.symbol ? h(IconTile, { symbol: p.symbol, tint: p.tint, size: 48 }) : null,
        h('div', { className: 'k-twoline' }, h('span', { className: 'k-sheet-title', id: tid }, p.title), p.subtitle ? h('span', { className: 'k-sub', id: sid }, p.subtitle) : null)) : null,
      h('div', { className: 'k-sheet-body' }, p.children),
      p.actions ? h('div', { className: 'k-sheet-foot' }, p.actions) : null));
  }
  function AlertDialog(p) {
    var tid = useUid('title'), mid = useUid('msg');
    return h('div', { className: 'k-alert', role: 'alertdialog', 'aria-modal': 'true', 'aria-labelledby': tid, 'aria-describedby': p.message ? mid : undefined },
      h(AppLogo, { size: 48 }),
      h('span', { className: 'k-alert-title', id: tid }, p.title),
      p.message ? h('span', { className: 'k-alert-msg', id: mid },typeof p.message === 'string' ? p.message.split(/(\s+)/).map(function (w, i) { return /-/.test(w) ? h('span', { key: i, style: { whiteSpace: 'nowrap' } }, w) : w; }) : p.message) : null,
      h('div', { className: 'k-alert-actions' }, (p.buttons || []).map(function (b, i) {
        return h(Button, { key: i, variant: b.variant || 'secondary', wide: true, className: b.destructive ? 'k-btn-destructive' : undefined }, b.title);
      })));
  }

  var api = {
    AppLogo: AppLogo, SFSymbol: SFSymbol, IconTile: IconTile, StatusDot: StatusDot, Pill: Pill, DashedDivider: DashedDivider,
    Button: Button, LinkButton: LinkButton, Chip: Chip,
    FormField: FormField, TextField: TextField, SearchBar: SearchBar, CommandBar: CommandBar, ToggleCard: ToggleCard, UnderlineTabs: UnderlineTabs,
    SectionTitle: SectionTitle, Card: Card, HoverCard: HoverCard, Surface: Surface, CardList: CardList, InfoRow: InfoRow,
    AttentionCard: AttentionCard, RunningCard: RunningCard, TargetCard: TargetCard, ActivityRow: ActivityRow,
    TerminalPane: TerminalPane, OutputText: OutputText, FormHeader: FormHeader,
    Banner: Banner, EmptyState: EmptyState,
    SidebarItem: SidebarItem, GroupRow: GroupRow, TabButton: TabButton, PanelHeader: PanelHeader, MenuRow: MenuRow, CommandPalette: CommandPalette,
    ProfileCard: ProfileCard,
    AppShell: AppShell, Terminal: Terminal, StatusBar: StatusBar, Segmented: Segmented, DataTable: DataTable,
    AgentMessage: AgentMessage, ToolCall: ToolCall, ApprovalCard: ApprovalCard, AgentComposer: AgentComposer,
    Checkbox: Checkbox, Switch: Switch, PopupButton: PopupButton, HopList: HopList, TargetsField: TargetsField, ProgressBar: ProgressBar, Skeleton: Skeleton, Popover: Popover, Sheet: Sheet, AlertDialog: AlertDialog
  };
  window.Komando = window.Komando || {};
  for (var k in api) window.Komando[k] = api[k];
})();
