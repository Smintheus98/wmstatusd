import std / [
    strformat,
    strutils,
    sequtils,
]
import wmstatusd / [types/all, threadingprocs, sleep, configuration]
import cligen, x11/xlib


var
  conf: Configuration
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


proc resetDefault(conf: var Configuration) =
  ## Reset default configuration
  conf.taglist = @[time, date, pkgs, backlight, volume, cpu, battery]
  conf.separator = "|"
  conf.separatorColor = CWHITE
  conf.padding = 1
  conf.useColors = true
  conf.savepower = false


proc wmstatusd(taglist: seq[Tag]; nocolors = false; config: string = ""; debug = false) =
  ## Main procedure
  # Set default configuration
  conf.resetDefault()
  # Read Configuration from file
  if config == "":
    conf.readConfig()
  else:
    if not config.configFileExists:
      echo fmt"ERROR: File does not exist: '{config}'"
      quit QuitFailure
    conf.readConfig(config)

  var colormap: ColorMap
  colormap[CBLACK..CRESET] = ["\e[30m", "\e[31m", "\e[32m", "\e[33m", "\e[34m", "\e[35m", "\e[36m", "\e[37m", "\e[0m"]
  # paramters overwriting
  if nocolors or not conf.useColors:
    colormap[CBLACK..CRESET] = ["", "", "", "", "", "", "", "", ""]
  if taglist.len != 0:
    conf.taglist = taglist


  # allocate non-GC-ed shared memory for channels
  channels = cast[ptr array[Tag, Channel[string]]] (createShared(Channel[string], Tag.items.toSeq.len))

  for tag in conf.taglist.deduplicate:
    data[tag] = ""
    channels[tag].open()
    createThread(threads[tag], tprocs[tag], (colormap, conf.savepower, addr channels[tag]))
  sleep delay700

  var
    dpy: PDisplay = XOpenDisplay(nil)
    status, laststatus: string

  if debug:
    echo fmt"Tags: {conf.taglist} ({conf.taglist.len}), Threads: {conf.taglist.deduplicate.len} (+1)"

  while true:
    status = " "
    for tag in conf.taglist:
      while channels[tag].peek >= 1:
        data[tag] = channels[tag].recv()
      let padding = " ".repeat(conf.padding)
      status &= fmt"{data[tag]}"
      status &= padding & colormap[conf.separatorColor] & conf.separator & colormap[CRESET] & padding

    if status != laststatus:
      if debug:
        echo status
      else:
        discard XStoreName(dpy, DefaultRootWindow(dpy), status.cstring)
        discard XFlush(dpy)
      laststatus = status

    if conf.savepower:
      sleep delay1000
    else:
      sleep delay250

  for tag in conf.taglist.deduplicate:
    channels[tag].close()
  freeShared(channels)

# Get Commandline options and call main function
cligen.dispatch(wmstatusd)

