import ../utils/threadutils
export threadutils

import backlight as backlight_mod
import battery as battery_mod
import cputemp as cputemp_mod
import date as date_mod
import mic as mic_mod
import time as time_mod
import volume as volume_mod

type Tag* = enum
  backlight
  battery
  cputemp
  date
  mic
  time
  volume

var moduleProcs*: array[Tag, proc(args: Args) {.thread.}]
moduleProcs[backlight] = backlight_mod.backlight
moduleProcs[battery] = battery_mod.battery
moduleProcs[cputemp] = cputemp_mod.cputemp
moduleProcs[date] = date_mod.date
moduleProcs[mic] = mic_mod.mic
moduleProcs[time] = time_mod.time
moduleProcs[volume] = volume_mod.volume

