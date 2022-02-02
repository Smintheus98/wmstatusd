# Package

version       = "0.1.6"
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
