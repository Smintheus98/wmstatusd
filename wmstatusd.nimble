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
requires "simple_parseopt >= 1.1.1"
requires "x11"
requires "nimscripter >= 1.1.5"


# Tasks

import os

task installConfig, "Installs config files":
  let
    dir = "XDG_CONFIG_HOME".getEnv(default = getHomeDir() / ".config") / "wmstatusd"
    file = dir / "wmstatusd.conf"
  mkDir dir
  if not file.fileExists:
    cpFile("./src/wmstatusd.conf", file)
    echo "Created file: '" & file & "'"
  else:
    echo "File '" & file & "' already exists. Abort."
