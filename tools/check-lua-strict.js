// WiliExplorer — strict Lua 5.3 syntax verification (fengari).
// Catches constructs luaparse tolerates but real Luau loaders reject.
const { lua, lauxlib, lualib, to_luastring, to_jsstring } = require('fengari');
const fs = require('fs');
const path = require('path');

const L = lauxlib.luaL_newstate();
lualib.luaL_openlibs(L);

const failures = [];
let checked = 0;

function walk(directory) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const file = path.join(directory, entry.name);
    if (entry.isDirectory()) walk(file);
    else if (file.endsWith('.lua')) {
      const source = fs.readFileSync(file, 'utf8');
      const status = lauxlib.luaL_loadstring(L, to_luastring(source));
      if (status !== 0) {
        failures.push(`${file}: ${to_jsstring(lua.lua_tostring(L, -1))}`);
      } else {
        checked += 1;
      }
      lua.lua_settop(L, 0);
    }
  }
}

walk('src');

if (failures.length) {
  console.error(failures.join('\n'));
  process.exit(1);
}
console.log(`Strict parse OK: ${checked} Lua files`);
