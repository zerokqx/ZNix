import fs, { mkdirpSync, mkdirSync, mkdtempSync, pathExistsSync } from "fs-extra"
import c from "chalk"
import { $ } from 'zx' // БЕЗ /globals!
import { cwdDir } from './constants'
import { hosts } from "../hostChoice/hosts"

export async function rebuildNixWithHost(host: string) {

  console.log(c.green(`Собираем сборку для ${host}`))
  const { stdout, stderr } = await $`sudo nixos-rebuild switch --flake ${cwdDir}#${host}`
  return stdout
}

export async function buildVmNixWithHost(host: string) {
  const lastBuild = "./result"
  const qcow = "./nixos.qcow2"
  if (fs.pathExistsSync(lastBuild)) {
    console.log(c.blue("Удаление старых сборок..."))
    fs.removeSync(lastBuild)
  }
  if (fs.pathExistsSync(qcow)) {

    console.log(c.blue("Удаление qcow2 файла..."))
    fs.removeSync(qcow)
  }

  console.log(c.green(`Собираем виртуальную машину для ${host}`))
  const { stdout, stderr } = await $`nixos-rebuild build-vm --flake ${cwdDir}#${host}`
  return stdout
}


export async function createNewProgram(name: string) {

  const path = `./programs/${name}`
  if (pathExistsSync(path)) return console.log(c.red(`Папка ${name}/ уже существует!`))
  mkdirpSync(
    path
  )
  console.log(c.green(`Папка ${name}/ создана!`))

  console.log(c.blue(`Инициализация flake.nix`))
  await $({ cwd: path })`nix flake init`

  console.log(c.green(`Успешно!`))
}
