// Column Placer -- auto-place windows into a 4-column grid on creation.
//
// The screen work area is split into 4 equal-width columns (index 0 = leftmost,
// 3 = rightmost). Each rule pins a matched window to a contiguous [startCol,
// endCol] range (inclusive), full work-area height. Because the move happens
// inside the shell, it IS Mutter moving the window -- so it works under Wayland,
// unlike an app positioning its own toplevel (e.g. GVim's :winpos).
//
// This only fires once, when a window is first created. Tactile is left alone
// for interactive re-tiling afterward.
//
// RELOADING AFTER AN EDIT: `gnome-extensions disable/enable` does NOT re-read
// this file -- GNOME imports the module once per shell session, so toggling
// only re-runs the already-loaded enable()/disable(). To actually pick up a
// code change on Wayland (where you can't restart the shell in place) either
// log out and back in, or unload+reload from Looking Glass (Alt+F2, `lg`):
//   (EM=>{ EM.unloadExtension(EM.lookup('column-placer@woodenbits'));
//     const dir=imports.gi.Gio.File.new_for_path(imports.gi.GLib.get_home_dir()
//       +'/.local/share/gnome-shell/extensions/column-placer@woodenbits');
//     EM.loadExtension(EM.createExtensionObject('column-placer@woodenbits', dir, 2));
//     EM.enableExtension('column-placer@woodenbits'); })(imports.ui.main.extensionManager)

import Meta from 'gi://Meta';
import Shell from 'gi://Shell';
import GLib from 'gi://GLib';
import Gio from 'gi://Gio';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';

const COLUMNS = 4;

// Every placed-or-skipped window is appended here, one line per window, so you
// can discover an app's real WM_CLASS (needed to add a rule) without Looking
// Glass -- just open the app and tail this file. Under Wayland the app_id often
// differs from the X11 remoting name (e.g. Firefox reports 'firefox', not
// 'firefox_firefox'), and xprop can't see Wayland-native windows, so this log
// is the reliable way to find the string to match on.
const LOG_PATH = GLib.get_home_dir() + '/tmp/column-placer.log';

// Local wall-clock time as 'YYYY-MM-DD HH:MM:SS'.
function timestamp() {
  return GLib.DateTime.new_now_local().format('%Y-%m-%d %H:%M:%S');
}

function logWindow(wmClass, instance, matched) {
  try {
    const line = `${timestamp()}  wm_class=${wmClass}  instance=${instance}  ` +
      `${matched ? 'placed' : 'no-rule'}\n`;
    const file = Gio.File.new_for_path(LOG_PATH);
    const stream = file.append_to(Gio.FileCreateFlags.NONE, null);
    stream.write(line, null);
    stream.close(null);
  } catch (e) {
    // Logging is best-effort; never let it break placement.
  }
}

// WM_CLASS (class field) -> [startCol, endCol], inclusive, on a 0..3 grid.
// Matching is case-insensitive and supports a trailing '*' wildcard, so
// 'chrome-*' catches PWA/app-mode Chrome windows too. First match wins.
const RULES = [
  { match: 'org.gnome.nautilus',    cols: [0, 1] }, // ht -- left half
  { match: 'gnome-terminal-server', cols: [0, 2] }, // hn -- left three-quarters
  { match: 'gvim',                  cols: [1, 3] }, // ts -- right three-quarters
  { match: 'google-chrome',         cols: [1, 3] }, // ts -- right three-quarters
  { match: 'firefox_firefox',       cols: [1, 3] }, // ts -- right three-quarters (snap Firefox reports this)
  { match: 'brave-browser',         cols: [1, 3] }, // ts -- right three-quarters (snap Firefox reports this)
  { match: 'slack',                 cols: [1, 3] }, // ts -- right three-quarters
  { match: 'signal*',               cols: [2, 3] }, // ns -- Signal messenger
  { match: 'chrome-*',              cols: [2, 3] }, // ns -- Chrome app/PWA windows
  { match: 'jetbrains-idea',        cols: [0, 3] }, // hs -- full width
];

function matchRule(wmClass) {
  if (!wmClass)
    return null;
  const cls = wmClass.toLowerCase();
  for (const rule of RULES) {
    const pat = rule.match.toLowerCase();
    if (pat.endsWith('*')) {
      if (cls.startsWith(pat.slice(0, -1)))
        return rule;
    } else if (cls === pat) {
      return rule;
    }
  }
  return null;
}

export default class ColumnPlacerExtension extends Extension {
  enable() {
    this._sourceIds = new Set();
    this._createdId = global.display.connect('window-created',
      (_display, window) => this._onWindowCreated(window));

    // A keyboard shortcut (default <Super><Alt>t, see the gschema) to
    // re-tile everything at once -- handy after monitor changes or once
    // windows have drifted from their columns. addKeybinding needs a real
    // GSettings, which is why this extension ships a compiled gschema.
    this._settings = this.getSettings();
    Main.wm.addKeybinding(
      'retile-all',
      this._settings,
      Meta.KeyBindingFlags.NONE,
      Shell.ActionMode.NORMAL,
      () => this._retileAll());
  }

  disable() {
    if (this._createdId) {
      global.display.disconnect(this._createdId);
      this._createdId = null;
    }
    if (this._sourceIds) {
      for (const id of this._sourceIds)
        GLib.Source.remove(id);
      this._sourceIds = null;
    }
    Main.wm.removeKeybinding('retile-all');
    this._settings = null;
  }

  _retileAll() {
    // Re-apply the column rule to every currently open window. This is the
    // same placement used at creation time, so it overrides any manual
    // Tactile adjustment made since -- that's the point of a "reset" hotkey.
    for (const actor of global.get_window_actors())
      this._place(actor.get_meta_window(), false);
  }

  _onWindowCreated(window) {
    // WM_CLASS is often not populated yet at window-created time, and the frame
    // geometry isn't final. Place once at the next idle tick (log there), then
    // reassert a few more times: some apps (Chrome, Firefox) apply their OWN
    // remembered geometry during startup, AFTER our first placement -- so we
    // re-place over the first ~second to make sure ours is the last word.
    const id = GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
      this._sourceIds.delete(id);
      this._place(window, true);
      return GLib.SOURCE_REMOVE;
    });
    this._sourceIds.add(id);

    for (const delay of [150, 400, 800, 1200, 1500]) {
      const tid = GLib.timeout_add(GLib.PRIORITY_DEFAULT, delay, () => {
        this._sourceIds.delete(tid);
        this._place(window, false);
        return GLib.SOURCE_REMOVE;
      });
      this._sourceIds.add(tid);
    }
  }

  _place(window, shouldLog) {
    // A deferred tick may fire after the window is gone; bail if it's unusable.
    if (!window || typeof window.get_window_type !== 'function')
      return;
    try {
      if (window.get_window_type() !== Meta.WindowType.NORMAL)
        return;
    } catch (e) {
      return;
    }

    const rule = matchRule(window.get_wm_class());
    if (shouldLog)
      logWindow(window.get_wm_class(), window.get_wm_class_instance(), rule !== null);
    if (!rule)
      return;

    // CRITICAL: a deferred/reassert tick can fire while the window is being
    // torn down (e.g. closing IntelliJ), at which point it's on no monitor.
    // get_work_area_current_monitor() would then hit a mutter g_assert that
    // ABORTS the whole shell (a JS try/catch cannot save us -- it's a native
    // assert, not an exception). get_monitor() returning -1 is exactly that
    // condition, so bail before touching any geometry API.
    if (window.get_monitor() < 0)
      return;

    // A maximized/fullscreen window can't be moved until unmaximized.
    if (window.get_maximized())
      window.unmaximize(Meta.MaximizeFlags.BOTH);

    const area = window.get_work_area_current_monitor();
    const [startCol, endCol] = rule.cols;
    const colWidth = area.width / COLUMNS;

    const x = Math.round(area.x + startCol * colWidth);
    const width = Math.round((endCol - startCol + 1) * colWidth);

    window.move_resize_frame(false, x, area.y, width, area.height);
  }
}
