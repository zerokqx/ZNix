import inquirer from 'inquirer';
import { getHosts } from './getHosts';
import { buildVmNixWithHost, createNewProgram, rebuildNixWithHost } from './commands';
import { hosts } from '../hostChoice/hosts';


async function loop() {
  console.clear();
  const allHosts = getHosts();
  const { menu, host, host_vm, program_name } = await inquirer.prompt([
    { type: "list", name: "menu", message: "Menu", choices: ["Rebuild", "BuildVm", "Create new program", "Выйти"] },
    { type: "list", name: "host_vm", message: "Host", choices: allHosts, when: (a) => a.menu === "BuildVm" },
    { type: "list", name: "host", message: "Host", choices: allHosts, when: (a) => a.menu === "Rebuild" },
    { type: "input", name: "program_name", message: "Name", validate: (i) => i.length > 0, when: (a) => a.menu === "Create new program" },
  ]);

  if (menu === "Выйти") return;
  if (host) await rebuildNixWithHost(host);
  if (host_vm) await buildVmNixWithHost(host_vm);
  if (program_name) await createNewProgram(program_name);

  // рекурсивный вызов
  await loop();
}

loop();
