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

import cligen

import
  utils/sleeputils,
  locales/de


const
  delay = initDuration(milliseconds = 500)                                      ## Delay for failing system calls to retry


type
  Tag = enum
    ## Tags for identifying different kinds of system information.
    date, time, pkgs, backlight, volume, cpu, battery

  Color = enum
    ## Color names for indexing to actual escape sequence
    black, red, green, yellow, blue, magenta, cyan, white, reset

  Colors = array[Color, string] ## Array-type mapping color names to escape sequences (strings)


var
  colors: Colors
  tags: seq[Tag]
  data: SharedTable[Tag, string]    # TODO (?): migrate to shared array or omit in favour of channels
  newData: Table[Tag, string]
  procs: Table[Tag, proc(colors: Colors) {.thread.}]
  threads: array[Tag, Thread[Colors]]
  mutex: array[Tag, Lock]


procs[date] = proc(colors: Colors) {.thread.} =
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
    date_str = fmt"""Date: {colors[white]}{dtime_start.format("ddd dd'.'MM'.'yyyy", locale)}{colors[reset]}"""

    withLock mutex[date]:
      data[date] = date_str

    sleep (dtime_end - dtime_start).min(timeout).inMilliseconds + 1
    

procs[time] = proc(colors: Colors) {.thread.} =
  let timeout = initDuration(seconds = 15)
  var time_str: string
  var dtime_start, dtime_end: DateTime
  while true:
    dtime_start = now()
    dtime_end = dtime_start + initDuration(minutes = 1)
    dtime_end.nanosecond = 0
    dtime_end.second = 0
    time_str = fmt"""Time: {colors[white]}{dtime_start.format("HH:mm")}{colors[reset]}"""

    withLock mutex[time]:
      data[time] = time_str

    sleep (dtime_end - dtime_start).min(timeout).inMilliseconds + 1


procs[battery] = proc(colors: Colors) {.thread.} =
  let timeout = initDuration(seconds = 5) 
  while true:
    let battery_level = readFile("/sys/class/power_supply/BAT0/capacity").strip
    let battery_status = readFile("/sys/class/power_supply/BAT0/status").strip
    var bat_str = "Bat: "
    case battery_status.toLower:
      of "discharging":
        bat_str &= fmt"{colors[red]}v"
      of "charging":
        bat_str &= fmt"{colors[green]}^"
      of "full", "not charging":
        bat_str &= fmt"{colors[green]}="
      else:
        bat_str &= fmt"{colors[yellow]}>"
    bat_str &= fmt"{battery_level}%{colors[reset]}"

    withLock mutex[battery]:
      data[battery] = bat_str

    sleep timeout


procs[cpu] = proc(colors: Colors) {.thread.} =
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
      cpu_str &= colors[green]
    else:
      cpu_str &= colors[red]
    cpu_str &= fmt"{temp}°C{colors[reset]}"

    withLock mutex[cpu]:
      data[cpu] = cpu_str

    sleep timeout


procs[pkgs] = proc(colors: Colors) {.thread.} =
  let timeout = initDuration(seconds = 20)
  var fileName = "/tmp/available-updates.txt"
  while true:
    var pkgs_str = fmt"Pkgs: {colors[cyan]}"
    if fileName.fileExists and fileName.getFileSize() > 0:
      let updates_count = readFile(fileName).strip.splitLines.len
      pkgs_str &= fmt"{updates_count}{colors[reset]}"
    else:
      pkgs_str &= fmt"0{colors[reset]}"

    withLock mutex[pkgs]:
      data[pkgs] = pkgs_str

    sleep timeout


procs[backlight] = proc(colors: Colors) {.thread.} =
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
    backlight_str = fmt"BL: {colors[yellow]}{(actual_brightness * 100) div max_brightness}%{colors[reset]}"

    withLock mutex[battery]:
      data[backlight] = backlight_str

    sleep timeout


procs[volume] = proc(colors: Colors) {.thread.} =
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

      vol_str &= fmt"{colors[yellow]}"
      if allmute:
        vol_str &= fmt"mute{colors[reset]}"
      else:
        vol_str &= fmt"{volumes.sum div volumes.len}%{colors[reset]}"
    except:
      vol_str &= fmt"{colors[red]}error{colors[reset]}"

    withLock mutex[volume]:
      data[volume] = vol_str

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


  data.init
  for tag in tags.deduplicate:
    data[tag] = ""
    initLock(mutex[tag])
    createThread(threads[tag], procs[tag], colors)
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
      if tryAcquire(mutex[tag]):
        newData[tag] = data.mget(tag)
        release(mutex[tag])
      str &= fmt"{newData[tag]}" & " ".repeat(padding)
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

  data.deinitSharedTable


# Get Commandline options and call main function
cligen.dispatch(wmstatusd)
