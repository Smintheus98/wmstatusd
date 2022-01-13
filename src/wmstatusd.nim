import std / [
    strformat,
    strutils,
    sequtils,
    times,
    math,
    sugar,
    locks,
    tables,
    sharedtables,
    os,
    osproc,
]

import utils / [
  sleeputils,
  locales
]

import cligen


const
  myLocale = localeDe
  delay = initDuration(milliseconds = 500)                                      ## Delay for failing system calls to retry


type
  Tag = enum
    ## Tags for identifying different kinds of system information.
    date, time, pkgs, backlight, volume, cpu, battery

  Color = enum
    ## Color names for indexing to actual escape sequence
    black, red, green, yellow, blue, magenta, cyan, white, reset

  Colors = array[Color, string] ## Array-type mapping color names to escape sequences (strings)

  ThreadArg = tuple
    colors: Colors
    channel: ptr Channel[string]


var
  colors: Colors
  tags: seq[Tag]
  data: array[Tag, string]
  procs: Table[Tag, proc(arg: ThreadArg) {.thread.}]
  threads: array[Tag, Thread[ThreadArg]]
  channels: ptr array[Tag, Channel[string]]


procs[date] = proc(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(minutes = 5)
  var date_str: string
  var dtime_start, dtime_end: DateTime
  while true:
    dtime_start = now()
    dtime_end = dtime_start + initDuration(days = 1)
    dtime_end.nanosecond = 0
    dtime_end.second = 0
    dtime_end.minute = 0
    dtime_end.hour = 0
    date_str = fmt"""Date: {arg.colors[white]}{dtime_start.format("ddd dd'.'MM'.'yyyy", myLocale)}{arg.colors[reset]}"""

    arg.channel[].send(date_str)

    sleep min(dtime_end - dtime_start, timeout).inMilliseconds + 1
    

procs[time] = proc(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(seconds = 15)
  var time_str: string
  var dtime_start, dtime_end: DateTime
  while true:
    dtime_start = now()
    dtime_end = dtime_start + initDuration(minutes = 1)
    dtime_end.nanosecond = 0
    dtime_end.second = 0
    time_str = fmt"""Time: {arg.colors[white]}{dtime_start.format("HH:mm")}{arg.colors[reset]}"""

    arg.channel[].send(time_str)

    sleep min(dtime_end - dtime_start, timeout).inMilliseconds + 1


procs[battery] = proc(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(seconds = 5) 
  while true:
    let battery_level = readFile("/sys/class/power_supply/BAT0/capacity").strip
    let battery_status = readFile("/sys/class/power_supply/BAT0/status").strip
    var bat_str = "Bat: "
    case battery_status.toLower:
      of "discharging":
        bat_str &= fmt"{arg.colors[red]}v"
      of "charging":
        bat_str &= fmt"{arg.colors[green]}^"
      of "full", "not charging":
        bat_str &= fmt"{arg.colors[green]}="
      else:
        bat_str &= fmt"{arg.colors[yellow]}>"
    bat_str &= fmt"{battery_level}%{arg.colors[reset]}"

    arg.channel[].send(bat_str)

    sleep timeout


procs[cpu] = proc(arg: ThreadArg) {.thread.} =
  # TODO (?): get CPU-Usage
  let timeout = initDuration(seconds = 3)
  var zones: int
  while true:
    try:
      # TODO: use language features instead of `execCmdEx`
      zones = "ls /sys/class/thermal | grep thermal_zone | wc -l".execCmdEx.output.strip.parseInt
      break
    except:
      sleep delay
      continue

  var zone_nr: int
  for i in 0..<zones:
    var zone_type = readFile(fmt"/sys/class/thermal/thermal_zone{i}/type").strip
    if zone_type == "x86_pkg_temp":
      zone_nr = i
      break
  while true:
    let temp = readFile(fmt"/sys/class/thermal/thermal_zone{zone_nr}/temp").strip.parseInt div 1000
    var cpu_str = "CPU: "
    if temp < 65:
      cpu_str &= arg.colors[green]
    else:
      cpu_str &= arg.colors[red]
    cpu_str &= fmt"{temp}°C{arg.colors[reset]}"

    arg.channel[].send(cpu_str)

    sleep timeout


procs[pkgs] = proc(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(seconds = 20)
  var fileName = "/tmp/available-updates.txt"
  while true:
    var pkgs_str = fmt"Pkgs: {arg.colors[cyan]}"
    if fileName.fileExists and fileName.getFileSize() > 0:
      let updates_count = readFile(fileName).strip.splitLines.len
      pkgs_str &= fmt"{updates_count}{arg.colors[reset]}"
    else:
      pkgs_str &= fmt"0{arg.colors[reset]}"

    arg.channel[].send(pkgs_str)

    sleep timeout


procs[backlight] = proc(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(milliseconds = 250)
  var backlight_str: string
  var bldevice: string
  var actual_brightness, max_brightness: int
  while true:
    try:
      bldevice = "ls /sys/class/backlight | grep backlight".execCmdEx.output.strip.split[0]
      break
    except:
      sleep delay
      continue
  max_brightness = readFile("/sys/class/backlight/" / bldevice / "max_brightness").strip.parseInt
  
  while true:
    actual_brightness = readFile("/sys/class/backlight/" / bldevice / "actual_brightness").strip.parseInt
    backlight_str = fmt"BL: {arg.colors[yellow]}{(actual_brightness * 100) div max_brightness}%{arg.colors[reset]}"

    arg.channel[].send(backlight_str)

    sleep timeout


procs[volume] = proc(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(milliseconds = 250)
  while true:
    var volume_info: seq[string]
    try:
      # TODO: Use systemfiles or internal structures
      volume_info = "amixer get Master".execCmdEx.output.strip.splitLines
    except:
      sleep delay
      continue
    var channels = newSeq[string]()
    var volumes = newSeq[int]()
    var allmute = true

    var vol_str = fmt"Vol: "
    try:
      for line in volume_info:
        # Extract required information
        # Pretty over fitted: probably requires future adaption when `amixer` changes
        let l = line.strip.toLower
        if l.startsWith("playback channels"):
          for channel in l.split(':')[1].split('-'):
            channels.add(channel.strip)
        else:
          for channel in channels:
            if l.startsWith(channel):
              let 
                vol = l.split[4].strip(chars={'[','%',']'}).parseInt
                mute = l.split[5].strip(chars={'[',']'}) == "off"
              volumes.add(vol)
              allmute = allmute and mute

      vol_str &= fmt"{arg.colors[yellow]}"
      if allmute:
        vol_str &= fmt"mute{arg.colors[reset]}"
      else:
        vol_str &= fmt"{volumes.sum div volumes.len}%{arg.colors[reset]}"
    except:
      vol_str &= fmt"{arg.colors[red]}error{arg.colors[reset]}"

    arg.channel[].send(vol_str)

    sleep timeout


proc wmstatusd(taglist: seq[Tag], nocolors = false, padding = 1, removeTag: seq[Tag] = @[], debug = false) =
  colors[black..reset] = ["\e[30m", "\e[31m", "\e[32m", "\e[33m", "\e[34m", "\e[35m", "\e[36m", "\e[37m", "\e[0m"]
  if nocolors:
    colors[black..reset] = ["", "", "", "", "", "", "", "", ""]

  tags = @[time, date, pkgs, backlight, volume, cpu, battery]
  if taglist.len != 0:
    tags = taglist

  # list of only those elements in tags that are not in removeTag
  tags = tags.filter(tag => tag notin removeTag)


  #channels = cast[ptr array[Tag, Channel[string]]] (allocShared0(Channel[string].sizeof * Tag.items.toSeq.len))
  channels = cast[ptr array[Tag, Channel[string]]] (createShared(Channel[string], Tag.items.toSeq.len))

  for tag in tags.deduplicate:
    data[tag] = ""
    channels[tag].open()
    createThread(threads[tag], procs[tag], (colors, addr channels[tag]))
  sleep initDuration(milliseconds = 700)

  var str, cmd, laststr: string

  if debug:
    echo fmt"Tags: {tags} ({tags.len}), Threads: {tags.deduplicate.len} (+1)"
    cmd = "echo -e ' "
  else:
    cmd = "xsetroot -name ' "

  while true:
    str = cmd

    for tag in tags:
      # TODO: try recv from channels
      while channels[tag].peek >= 1:
        data[tag] = channels[tag].recv()
      str &= fmt"{data[tag]}" & " ".repeat(padding)
    str &= "'"
    
    if str == laststr:
      # reduces system calls
      sleep initDuration(milliseconds = 250)
      continue

    try:
      discard str.execCmd
      laststr = str
    except:
      discard

    sleep initDuration(milliseconds = 250)

  #data.deinitSharedTable
  for tag in tags.deduplicate:
    channels[tag].close()
  freeShared(channels)


# Get Commandline options and call main function
cligen.dispatch(wmstatusd)

