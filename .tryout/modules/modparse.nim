

# GOAL:
 #[

import macros
dumpTree:
  import modules/[mod1, mod2, mod3]

  type Tag* = enum
    ## Tags for identifying different kinds of system information.
    time, date, mod3

  var modProcs*: array[Tag, proc(arg: int)]
  modProcs[Tag.time] = mod1.f
  modProcs[Tag.date] = mod2.f
  modProcs[Tag.mod3] = mod3.f

# ]#

# maybe read: https://nim-docs.readthedocs.io/en/latest/manual/macros/


import modules/[mod1, mod2, mod3]

type Tag* = enum
  ## Tags for identifying different kinds of system information.
  time, date, mod3

var modProcs*: array[Tag, proc(arg: int)]
modProcs[Tag.time] = mod1.f
modProcs[Tag.date] = mod2.f
modProcs[Tag.mod3] = mod3.f

