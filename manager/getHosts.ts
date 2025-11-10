import fs from "fs-extra"
import { cwdDir, lastHost } from "./constants"

export const getLastHost = () => fs.pathExists(lastHost)

/** Получает хостов из папки `hosts` в конфиге. */
export const getHosts = () => {
  const hosts = fs.readdirSync(`${cwdDir}/hosts`, {

    withFileTypes: true
  }).filter((item) => item.isDirectory()).map((dir) => dir.name)
  return hosts
}



