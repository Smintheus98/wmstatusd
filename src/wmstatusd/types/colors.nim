
type Color* = enum
  ## Color names for indexing to actual escape sequence
  CBLACK, CRED, CGREEN, CYELLOW, CBLUE, CMAGENTA, CCYAN, CWHITE, CRESET

type ColorMap* = array[Color, string] ## Array-type mapping color names to escape sequences (strings)

