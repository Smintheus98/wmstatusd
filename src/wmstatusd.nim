import std / [
    strformat,
    strutils,
    sequtils,
    sugar,
]

import wmstatusd / [defs, threadingprocs, sleeputils]

import cligen, x11/xlib


var
  colormap: ColorMap
  tags: seq[Tag]
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


proc wmstatusd(taglist: seq[Tag], nocolors = false, padding = 1, removeTag: seq[Tag] = @[], debug = false) =
  colormap[CBLACK..CRESET] = ["\e[30m", "\e[31m", "\e[32m", "\e[33m", "\e[34m", "\e[35m", "\e[36m", "\e[37m", "\e[0m"]
  if nocolors:
    colormap[CBLACK..CRESET] = ["", "", "", "", "", "", "", "", ""]

  tags = @[time, date, pkgs, backlight, volume, cpu, battery]
  if taglist.len != 0:
    tags = taglist

  # list of only those elements in tags that are not in removeTag
  tags = tags.filter(tag => tag notin removeTag)


  # allocate non-GC-ed shared memory for channels
  channels = cast[ptr array[Tag, Channel[string]]] (createShared(Channel[string], Tag.items.toSeq.len))

  for tag in tags.deduplicate:
    data[tag] = ""
    channels[tag].open()
    createThread(threads[tag], tprocs[tag], (colormap, addr channels[tag]))
  sleep delay700

  var
    dpy: PDisplay = XOpenDisplay(nil)
    status, laststatus: string

  if debug:
    echo fmt"Tags: {tags} ({tags.len}), Threads: {tags.deduplicate.len} (+1)"

  while true:
    status = " "
    for tag in tags:
      while channels[tag].peek >= 1:
        data[tag] = channels[tag].recv()
      status &= fmt"{data[tag]}" & " ".repeat(padding)
    
    if status != laststatus:
      if debug:
        echo status
      else:
        discard XStoreName(dpy, DefaultRootWindow(dpy), status.cstring)
        discard XFlush(dpy)
      laststatus = status

    sleep delay250

  for tag in tags.deduplicate:
    channels[tag].close()
  freeShared(channels)

# Get Commandline options and call main function
cligen.dispatch(wmstatusd)

