
type Color* = enum
  ## Color names expanding to actual escape sequence
  CBLACK
  CRED
  CGREEN
  CYELLOW
  CBLUE
  CMAGENTA
  CCYAN
  CWHITE
  CRESET


proc str*(c: Color): string =
  case c:
    of CRESET:    "\e[0m"
    of CBLACK:    "\e[30m"
    of CRED:      "\e[31m"
    of CGREEN:    "\e[32m"
    of CYELLOW:   "\e[33m"
    of CBLUE:     "\e[34m"
    of CMAGENTA:  "\e[35m"
    of CCYAN:     "\e[36m"
    of CWHITE:    "\e[37m"

