import times

type Tag* = enum
  ## Tags for identifying different kinds of system information.
  date, time, pkgs, backlight, volume, cpu, battery

type Color* = enum
  ## Color names for indexing to actual escape sequence
  CBLACK, CRED, CGREEN, CYELLOW, CBLUE, CMAGENTA, CCYAN, CWHITE, CRESET

type Colors* = array[Color, string] ## Array-type mapping color names to escape sequences (strings)

type ThreadArg* = tuple
  ## Data structure to bundle arguments for thread procedures
  ## which can have only one parameter
  colors: Colors
  channel: ptr Channel[string]

const
  delay250* = initDuration(milliseconds = 250)
  delay500* = initDuration(milliseconds = 500)
  delay700* = initDuration(milliseconds = 700)
