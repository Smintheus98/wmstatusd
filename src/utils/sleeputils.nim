import std/[os, times]


template sleep*(ms: int64) =
  sleep ms.int

template sleep*(duration: Duration) =
  sleep duration.inMilliseconds


