import std/[os, times]


proc sleep*(ms: int64) =
  sleep ms.int

proc sleep*(duration: Duration) =
  sleep duration.inMilliseconds


