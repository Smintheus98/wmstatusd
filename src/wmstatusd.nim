import std / [
    strformat,
    strutils,
    sequtils,
    sugar,
    options,
]

import wmstatusd / [types/all, threadingprocs, sleep, configuration]

import cligen, x11/xlib


var
  config: Configuration
  data: array[Tag, string]
  tprocs: array[Tag, proc(arg: ThreadArg) {.thread.}]
  channels: ptr array[Tag, Channel[string]]
  threads: array[Tag, Thread[ThreadArg]]


tprocs[date]      = getDate
tprocs[time]      = getTime
tprocs[battery]   = getBattery
tprocs[cpu]       = getCPU
tprocs[pkgs]      = getPkgs
tprocs[backlight] = getBacklight
tprocs[volume]    = getVolume

proc resetDefault(config: var Configuration) =
  config.taglist = @[time, date, pkgs, backlight, volume, cpu, battery]
  config.tagPadding = 1
  config.colormap[CBLACK..CRESET] = ["\e[30m", "\e[31m", "\e[32m", "\e[33m", "\e[34m", "\e[35m", "\e[36m", "\e[37m", "\e[0m"]
  config.useColors = true


proc wmstatusd(taglist: seq[Tag], nocolors = false, padding = 1, removeTag: seq[Tag] = @[], debug = false) =
  config.resetDefault()
  config.readConfig()

  # paramters overwriting
  if nocolors or not config.useColors:
    config.colormap[CBLACK..CRESET] = ["", "", "", "", "", "", "", "", ""]
  if taglist.len != 0:
    config.taglist = taglist

  # list of only those elements in tags that are not in removeTag
  config.taglist = config.taglist.filter(tag => tag notin removeTag)


  # allocate non-GC-ed shared memory for channels
  channels = cast[ptr array[Tag, Channel[string]]] (createShared(Channel[string], Tag.items.toSeq.len))

  for tag in config.taglist.deduplicate:
    data[tag] = ""
    channels[tag].open()
    createThread(threads[tag], tprocs[tag], (config.colormap, addr channels[tag]))
  sleep delay700

  var
    dpy: PDisplay = XOpenDisplay(nil)
    status, laststatus: string

  if debug:
    echo fmt"Tags: {config.taglist} ({config.taglist.len}), Threads: {config.taglist.deduplicate.len} (+1)"

  while true:
    status = " "
    for tag in config.taglist:
      while channels[tag].peek >= 1:
        data[tag] = channels[tag].recv()
      status &= fmt"{data[tag]}" & " ".repeat(config.tagPadding)
    
    if status != laststatus:
      if debug:
        echo status
      else:
        discard XStoreName(dpy, DefaultRootWindow(dpy), status.cstring)
        discard XFlush(dpy)
      laststatus = status

    sleep delay250

  for tag in config.taglist.deduplicate:
    channels[tag].close()
  freeShared(channels)

# Get Commandline options and call main function
cligen.dispatch(wmstatusd)

