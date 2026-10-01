const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const root = path.resolve(__dirname, '..');
const shell = fs.readFileSync(path.join(root, 'tools/harden_web.py'), 'utf8');
const game = fs.readFileSync(path.join(root, 'main.gd'), 'utf8');
assert(!game.includes('JavaScriptBridge.eval('), 'Browser calls must work without CSP-blocked eval');
assert(!shell.includes("'unsafe-eval'"), 'Do not loosen JavaScript CSP for the bridge');
const script = shell.match(/browser_bridge = """([\s\S]*?)"""/)[1].replace(/^<script[^>]*>\s*/, '').replace(/\s*<\/script>$/, '');
const blobs = [], links = [], timers = [], revoked = [];
const context = {
  window: {SONNENHAIN_CONTROL_MODE: 'desktop', matchMedia: () => ({matches: true})},
  navigator: {userAgent: 'Android', maxTouchPoints: 5},
  document: {
    body: {appendChild: link => links.push(link)},
    createElement: name => {assert.equal(name, 'a'); return {click() {this.clicked = true}, remove() {this.removed = true}}},
  },
  Blob: class {constructor(parts, options) {this.parts = parts; this.options = options; blobs.push(this)}},
  URL: {createObjectURL: () => 'blob:test', revokeObjectURL: value => revoked.push(value)},
  setTimeout: (callback, delay) => timers.push({callback, delay}),
};
vm.createContext(context, {codeGeneration: {strings: false, wasm: false}});
vm.runInContext(script, context);
const bridge = context.window.SonnenhainBrowser;
assert.equal(bridge.touchCapability(), false, 'Desktop override wins over touch detection');
context.window.SONNENHAIN_CONTROL_MODE = 'mobile';
assert.equal(bridge.touchCapability(), true);
context.window.SONNENHAIN_CONTROL_MODE = '';
assert.equal(bridge.touchCapability(), true);
context.navigator.userAgent = 'Desktop'; context.navigator.maxTouchPoints = 0;
assert.equal(bridge.touchCapability(), false);
const payload = JSON.stringify({hero_name: 'Test "Magier"\nÄ', inventory: [{name: '`$() ring'}]});
assert.equal(bridge.downloadBackup(payload, 'sonnenhain_slot2.json'), true);
assert.equal(blobs[0].parts[0], payload);
assert.equal(blobs[0].options.type, 'application/json');
assert.equal(links[0].download, 'sonnenhain_slot2.json');
assert(links[0].clicked && links[0].removed);
assert.equal(timers[0].delay, 1000); timers[0].callback();
assert.equal(revoked[0], 'blob:test');
console.log('BROWSER_BRIDGE_OK no eval/CSP relaxation; desktop/mobile detection and exact JSON backup download with URL cleanup');
