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
  var t_end = t_start + initDuration(minutes = 1)
  t_end.nanosecond = 0
  t_end.second = 0
  return t_end - t_start

proc durNextDay*(t_start: DateTime): Duration =
  var t_end = t_start + initDuration(days = 1)
  t_end.nanosecond = 0
  t_end.second = 0
  t_end.minute = 0
  t_end.hour = 0
  return t_end - t_start
