import std / [
  os,
  strformat,
  strutils,
]
import types/all
import nimscripter

const
  DEFAULT_CONFIG = staticRead("../wmstatusd.conf")
  TYPE_TAG = staticRead("./types/tags.nim")
  TYPE_COLORS = staticRead("./types/colors.nim")
  TYPE_CONFIGURATION = staticRead("./types/configuration.nim")


proc configFileExists*(filename: string): bool =
  return filename.fileExists


proc createConfigFile*(overwrite = false): string =
  let
    dir = "XDG_CONFIG_HOME".getEnv(default = getHomeDir() / ".config") / "wmstatusd"
    file = dir / "wmstatusd.conf"
    
  dir.createDir()

  if not file.fileExists or overwrite:
    file.writeFile(DEFAULT_CONFIG)

  return file


proc readConfig*(config: var Configuration; configFile = "") =
  var configFile = configFile
  if configFile == "":
    configFile = createConfigFile()

  let header = ["const NIMSCRIPT = true", TYPE_TAG, TYPE_COLORS, TYPE_CONFIGURATION].join("\n")
  let decl = fmt"var main* = Configuration{$config}"
  let body = configFile.readFile
  let interpreter = loadScript(NimScriptFile([header, decl, body].join("\n")))
  
  config = getGlobalVariable[Configuration](interpreter, "main")
  
