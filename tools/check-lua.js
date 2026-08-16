const fs = require('fs');
const path = require('path');
const luaparse = require('luaparse');

const failures = [];
let checked = 0;
function walk(directory) {
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    const file = path.join(directory, entry.name);
    if (entry.isDirectory()) walk(file);
    else if (file.endsWith('.lua')) {
      try {
        luaparse.parse(fs.readFileSync(file, 'utf8'), { luaVersion: '5.3' });
        checked += 1;
      } catch (error) {
        failures.push(`${file}: ${error.message}`);
      }
    }
  }
}
walk('src');

const klimbo = fs.readFileSync('src/UI/KlimboMenu.lua', 'utf8');
const forbiddenKlimbo = ['game:HttpGet', 'getrawmetatable', 'Mouse.Hit', 'ScriptScanner_GetEditable', ':FireServer(', ':InvokeServer('];
for (const token of forbiddenKlimbo) {
  if (klimbo.includes(token)) failures.push(`src/UI/KlimboMenu.lua: forbidden legacy capability ${token}`);
}
for (const file of ['src/UI/MainFrame.lua', 'src/UI/AnalyzerUI.lua', 'src/Core/GameAnalyzer.lua']) {
  const source = fs.readFileSync(file, 'utf8');
  if (/MouseButton\w*:Fire\s*\(/.test(source)) failures.push(`${file}: RBXScriptSignal does not expose Fire()`);
}

if (failures.length) {
  console.error(failures.join('\n'));
  process.exit(1);
}
console.log(`Syntax OK: ${checked} Lua files`);
