import nimscripter
import std/[os, strutils, strformat]
import ../modules/all
import ../utils/[colors, locales]
import configtypes
export configtypes

const
  DEFAULT_CONFIG = staticRead("../../wmstatusd.conf")
  CONFIG_SCRIPT_MACROS = staticRead("./macros.nims")

proc configFileExists*(filename: string): bool =
  return filename.fileExists

proc getDefaultConfigDir*(dirName = "wmstatusd"): string =
  ## Get default config directory.
  ## Usually `"$XDG_CONFIG_HOME/<dirName>"` falling back to `"$HOME/.config/<dirName>"`
  "XDG_CONFIG_HOME".getEnv(default = getHomeDir()/".config") / dirName

proc getConfigFile*(fileName = "wmstatusd.conf"; create = true): string =
  let
    dir = getDefaultConfigDir()
    filePath = dir / fileName

  dir.createDir()

  if not filePath.fileExists:
    if create:
      filePath.writeFile(DEFAULT_CONFIG)
    else:
      raise newException(IOError, fmt"File does not exist: '{filePath}'")

  return filePath


proc readDefaultConfig*(): Config =
  exportTo(nimsDefImpl, Tag, Color, Locale, Config)
  let scriptHeader = implNimScriptModule(nimsDefImpl)

  let defaultScript = NimScriptFile([
      CONFIG_SCRIPT_MACROS,
      fmt"var main*: Config",
      DEFAULT_CONFIG
    ].join("\n"))
  let interpreter = loadScript(defaultScript, scriptHeader)

  return getGlobalVariable[Config](interpreter, "main")


proc readConfigFile*(defaultConfig: Config; configFile = getConfigFile()): Config =
  exportTo(nimsImpl, Tag, Color, Locale, Config)
  let scriptHeader = implNimScriptModule(nimsImpl)

  let mainScript = NimScriptFile([
      CONFIG_SCRIPT_MACROS,
      fmt"var main* = {defaultConfig.constructStr}",
      configFile.readFile
    ].join("\n"))
  let interpreter = loadScript(mainScript, scriptHeader)

  return getGlobalVariable[Config](interpreter, "main")

