
type Color* = enum
  ## Color names expanding to actual escape sequence
  CRESET
  CBLACK
  CRED
  CGREEN
  CYELLOW
  CBLUE
  CMAGENTA
  CCYAN
  CWHITE
  CBLACK_BRIGHT
  CRED_BRIGHT
  CGREEN_BRIGHT
  CYELLOW_BRIGHT
  CBLUE_BRIGHT
  CMAGENTA_BRIGHT
  CCYAN_BRIGHT
  CWHITE_BRIGHT


proc str*(c: Color): string =
  case c:
    of CRESET:          "\e[0m"
    of CBLACK:          "\e[30m"
    of CRED:            "\e[31m"
    of CGREEN:          "\e[32m"
    of CYELLOW:         "\e[33m"
    of CBLUE:           "\e[34m"
    of CMAGENTA:        "\e[35m"
    of CCYAN:           "\e[36m"
    of CWHITE:          "\e[37m"
    of CBLACK_BRIGHT:   "\e[90m"
    of CRED_BRIGHT:     "\e[91m"
    of CGREEN_BRIGHT:   "\e[92m"
    of CYELLOW_BRIGHT:  "\e[93m"
    of CBLUE_BRIGHT:    "\e[94m"
    of CMAGENTA_BRIGHT: "\e[95m"
    of CCYAN_BRIGHT:    "\e[96m"
    of CWHITE_BRIGHT:   "\e[97m"

