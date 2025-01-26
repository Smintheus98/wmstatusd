# Package

version       = "0.4.0"
author        = "Yannic Kitten"
description   = "Status daemon for window manager"
license       = "GPL-3.0"
srcDir        = "src"
when not defined(depsOnly):
  binDir        = "bin"
  bin           = @["wmstatusd"]


# Dependencies

requires "nim >= 2.0.14"
#requires "cligen"
requires "simpleparseopt >= 1.1.1"
requires "x11"
requires "nimscripter >= 1.1.5"


# Tasks

import os

task installConfig, "Installs config files":
  let
    xdgConfigHome = "XDG_CONFIG_HOME".getEnv
    homeUserConfig = getHomeDir() / ".config"
  let dir =
      if xdgConfigHome != "":
        xdgConfigHome / "wmstatusd"
      else:
        homeUserConfig / "wmstatusd"
  mkDir dir

  let file = dir / "wmstatusd.conf"

  if not file.fileExists:
    file.writeFile(slurp"./src/wmstatusd.conf")
    echo "Created file: '" & file & "'"
  else:
    echo "File '" & file & "' already exists"
