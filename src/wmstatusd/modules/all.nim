import threadingtools
export threadingtools

# TODO: This file could be much more elegant if it used some meta programming!

import mod_backlight
import mod_battery
import mod_cputemp
import mod_date
import mod_mic
import mod_time
import mod_volume

type Tag* = enum
  backlight
  battery
  cputemp
  date
  mic
  time
  volume

let moduleProcs*: array[Tag, proc(args: ModuleArgs) {.thread.}] =
  [
    backlight: mod_backlight.backlight,
    battery:   mod_battery.battery,
    cputemp:   mod_cputemp.cputemp,
    date:      mod_date.date,
    mic:       mod_mic.mic,
    time:      mod_time.time,
    volume:    mod_volume.volume,
  ]

