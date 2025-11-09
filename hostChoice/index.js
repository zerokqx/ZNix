import { spawn } from "child_process";
import { existsSync, mkdirSync, readdirSync, readFileSync, writeFileSync } from "fs";
import chalk from "chalk";

const folder = "znix";
const tmpInitial = `/tmp/${folder}/initial`;
const lastUsesHost = `/tmp/${folder}/last_host`;

// Создаём tmp директорию, если её нет
if (!existsSync(`/tmp/${folder}`)) {
  mkdirSync(`/tmp/${folder}`);
}

function chooseHost(hosts) {
  return new Promise((resolve, reject) => {
    if (existsSync(lastUsesHost)) {
      hosts.unshift(readFileSync(lastUsesHost, "utf-8").trim());
    }

    const gum = spawn("gum", ["choose", ...hosts, "--header", "Hosts"], {
      stdio: ["inherit", "pipe", "inherit"],
    });

    let input = "";
    gum.stdout.on("data", (data) => {
      input += data.toString();
    });

    gum.on("close", () => {
      input = input.trim();
      if (!input) return reject(new Error("No host selected"));
      writeFileSync(lastUsesHost, input);
      console.log(chalk.blue(`Вы выбрали: ${input}`));
      resolve(input);
    });
  });
}

function rebuildNix(host) {
  return new Promise((resolve, reject) => {
    const nix = spawn("sudo", ["nixos-rebuild", "switch", "--flake", `.#${host}`], {
      stdio: "inherit",
    });

    nix.on("close", (code) => {
      if (code === 0) {
        console.log(chalk.green.bold(`Rebuild on ${host} successful!`));
        resolve();
      } else {
        console.log(chalk.red.bold(`Error during rebuild on ${host}`));
        reject(new Error("nixos-rebuild failed"));
      }
    });
  });
}

async function main() {
  try {
    // пометка, что init уже был
    if (!existsSync(tmpInitial)) {
      writeFileSync(tmpInitial, "");
    }

    const hosts = readdirSync("./hosts", { withFileTypes: true })
      .filter((item) => item.isDirectory())
      .map((item) => item.name);

    if (!hosts.length) {
      console.log(chalk.red("No hosts found in ./hosts"));
      return;
    }

    const selectedHost = await chooseHost(hosts);
    await rebuildNix(selectedHost);
  } catch (err) {
    console.error(chalk.red(err.message));
  }
}

main();
