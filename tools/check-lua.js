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
const registryOnlyUI = ['Sidebar', 'TreeView', 'FileViewer', 'MainFrame', 'AnalyzerUI'];
for (const name of registryOnlyUI) {
  const file = `src/UI/${name}.lua`;
  const source = fs.readFileSync(file, 'utf8');
  if (source.includes('game:HttpGet')) failures.push(`${file}: UI modules must resolve dependencies through _G.WiliModules`);
}
const deprecatedFiles = ['src/Theme/Stars.lua', 'src/UI/FileViewer.lua', 'src/UI/Sidebar.lua', 'src/UI/TreeView.lua'];
for (const file of deprecatedFiles) {
  const source = fs.readFileSync(file, 'utf8');
  if (/(^|[^.\w])spawn\s*\(/m.test(source)) failures.push(`${file}: use task.spawn`);
  if (/(^|[^.\w])wait\s*\(/m.test(source)) failures.push(`${file}: use task.wait`);
}
for (const removed of ['src/Security/Keys.lua', 'src/Security/AntiTamper.lua']) {
  if (fs.existsSync(removed)) failures.push(`${removed}: legacy security file must not ship`);
}
if (fs.readFileSync('src/Core/FileScanner.lua', 'utf8').includes('"RunContext"')) {
  failures.push('src/Core/FileScanner.lua: deprecated RunContext property');
}

if (failures.length) {
  console.error(failures.join('\n'));
  process.exit(1);
}
console.log(`Syntax OK: ${checked} Lua files`);
