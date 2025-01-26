import nimscripter
import std/[os, strutils, strformat]
import ../../src/wmstatusd/config/config
import ../../src/wmstatusd/modules/all
import ../../src/wmstatusd/utils/[colors, locales]

const DEFAULT_CONFIG* = staticRead("./wmstatusd.conf")
const CONFIG_SCRIPT_MACROS* = staticRead("./configMacros.nims")

proc configFileExists*(filename: string): bool =
  return filename.fileExists

proc getDefaultConfigDir*(dirName = "wmstatusd"): string =
  "XDG_CONFIG_HOME".getEnv(default = getHomeDir()/".config") / dirName

proc createConfigFile*(fileName = "wmstatusd.conf"; overwrite = false): string =
  let
    dir = getDefaultConfigDir()
    filePath = dir / fileName

  dir.createDir()
  if not filePath.fileExists or overwrite:
    filePath.writeFile(DEFAULT_CONFIG)
  return filePath


proc readConfig*(config: var Config; configFile = "") =
  let configFile =
      if configFile == "":  createConfigFile()
      else:                 configFile
  let defaultConfig = config

  exportTo(nimsImpl, Tag, Color, Locale, Config, defaultConfig)
  let scriptHeader = implNimScriptModule(nimsImpl)

  let decl = fmt"var main* = defaultConfig"
  let scriptBody = configFile.readFile
  let script = NimScriptFile([CONFIG_SCRIPT_MACROS, decl, scriptBody].join("\n"))
  let interpreter = loadScript(script, scriptHeader)

  config = getGlobalVariable[Config](interpreter, "main")


