# Package

version       = "0.1.1"
author        = "Yannic Kitten"
description   = "Status daemon for window managers"
license       = "GPL-3.0"
srcDir        = "src"
binDir        = "bin"
bin           = @["wmstatusd"]


# Dependencies

requires "nim >= 1.6.2"
requires "cligen"
