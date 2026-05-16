import std/[os, times, strutils]

proc sleep*(duration: Duration) =
  sleep duration.inMilliseconds


proc `'h`*(lit: string): Duration =
  initDuration(hours = lit.parseInt)

proc `'min`*(lit: string): Duration =
  initDuration(minutes = lit.parseInt)

proc `'sec`*(lit: string): Duration =
  initDuration(seconds = lit.parseInt)

proc `'ms`*(lit: string): Duration =
  initDuration(milliseconds = lit.parseInt)


proc durNextMin*(t_start: DateTime): Duration =
  const
    total_ns = 1_000_000_000
    total_sec = 60
  let
    remain_ns  = total_ns - t_start.nanosecond
    remain_sec = total_sec - t_start.second - 1
  initDuration(seconds = remain_sec, nanoseconds = remain_ns)

proc durNextDay*(t_start: DateTime): Duration =
  const
    total_ns = 1_000_000_000
    total_sec = 60
    total_min = 60
    total_h = 24
  let
    remain_ns  = total_ns - t_start.nanosecond
    remain_sec = total_sec - t_start.second - 1
    remain_min = total_min - t_start.minute - 1
    remain_h   = total_h - t_start.hour - 1
  initDuration(
      hours = remain_h,
      minutes = remain_min,
      seconds = remain_sec,
      nanoseconds = remain_ns)

