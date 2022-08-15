# Package

version       = "0.2.3"
author        = "Yannic Kitten"
description   = "Status daemon for window managers"
license       = "GPL-3.0"
srcDir        = "src"
when not defined(depsOnly):
  binDir        = "bin"
  bin           = @["wmstatusd"]


# Dependencies

requires "nim >= 1.6.2"
requires "cligen"
requires "x11"
requires "nimscripter"


# Tasks

import os, strformat

task installConfig, "Installs config files":
  var dir, file: string
  let
    xdgConfigHome = "XDG_CONFIG_HOME".getEnv
    homeUserConfig = getHomeDir() / ".config"
  if xdgConfigHome != "":
    dir = xdgConfigHome / "wmstatusd"
  else:
    dir = homeUserConfig / "wmstatusd"

  mkDir dir
  file = dir / "wmstatusd.conf"
  if not file.fileExists:
    file.writeFile(slurp"./src/wmstatusd.conf")
    echo fmt"Created file: '{file}'"
  else:
    echo fmt"File '{file}' already exists"
