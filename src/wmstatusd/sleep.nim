import std/[os, times]

const
  delay250* = initDuration(milliseconds = 250)
  delay500* = initDuration(milliseconds = 500)
  delay700* = initDuration(milliseconds = 700)
  delay1000* = initDuration(seconds = 1)


proc sleep*(ms: int64) =
  sleep ms.int

proc sleep*(duration: Duration) =
  sleep duration.inMilliseconds

