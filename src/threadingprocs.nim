import std / [
    strformat,
    strutils,
    sequtils,
    times,
    math,
    os,
    osproc,
]

import defs, utils / [
  sleeputils,
  locales
]

const myLocale = localeDe

proc getDate*(arg: ThreadArg) {.thread.} =
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
    date_str = fmt"""Date: {arg.colors[CWHITE]}{dtime_start.format("ddd dd'.'MM'.'yyyy", myLocale)}{arg.colors[CRESET]}"""

    arg.channel[].send(date_str)
    sleep min(dtime_end - dtime_start, timeout).inMilliseconds + 1
    

proc getTime*(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(seconds = 15)
  var time_str: string
  var dtime_start, dtime_end: DateTime
  while true:
    dtime_start = now()
    dtime_end = dtime_start + initDuration(minutes = 1)
    dtime_end.nanosecond = 0
    dtime_end.second = 0
    time_str = fmt"""Time: {arg.colors[CWHITE]}{dtime_start.format("HH:mm")}{arg.colors[CRESET]}"""

    arg.channel[].send(time_str)
    sleep min(dtime_end - dtime_start, timeout).inMilliseconds + 1


proc getBattery*(arg: ThreadArg) {.thread.} =
  let
    timeout = initDuration(seconds = 5)
    battery_names = walkPattern("/sys/class/power_supply/BAT*").toSeq
  if battery_names.len == 0:
    return
  let battery_name = battery_names[0]

  while true:
    let
      battery_level = readFile(battery_name / "capacity").strip
      battery_status = readFile(battery_name / "status").strip
    var bat_str = "Bat: "
    case battery_status.toLower:
      of "discharging":
        bat_str &= fmt"{arg.colors[CRED]}v"
      of "charging":
        bat_str &= fmt"{arg.colors[CGREEN]}^"
      of "full", "not charging":
        bat_str &= fmt"{arg.colors[CGREEN]}="
      else:
        bat_str &= fmt"{arg.colors[CYELLOW]}>"
    bat_str &= fmt"{battery_level}%{arg.colors[CRESET]}"

    arg.channel[].send(bat_str)
    sleep timeout


proc getCPU*(arg: ThreadArg) {.thread.} =
  # TODO (?): get CPU-Usage
  let
    timeout = initDuration(seconds = 3)
    zones = walkPattern("/sys/class/thermal/thermal_zone*").toSeq
  var zone: string

  for z in zones:
    if readFile(z / "type").strip == "x86_pkg_temp":
      zone = z
      break
  if zone == "":
    return

  while true:
    let temp = readFile(zone / "temp").strip.parseInt div 1000
    var cpu_str = "CPU: "
    if temp < 65:
      cpu_str &= arg.colors[CGREEN]
    else:
      cpu_str &= arg.colors[CRED]
    cpu_str &= fmt"{temp}°C{arg.colors[CRESET]}"

    arg.channel[].send(cpu_str)
    sleep timeout


proc getPkgs*(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(seconds = 20)
  var fileName = "/tmp/available-updates.txt"
  while true:
    var pkgs_str = fmt"Pkgs: {arg.colors[CCYAN]}"
    if fileName.fileExists and fileName.getFileSize() > 0:
      let updates_count = readFile(fileName).strip.splitLines.len
      pkgs_str &= fmt"{updates_count}{arg.colors[CRESET]}"
    else:
      pkgs_str &= fmt"0{arg.colors[CRESET]}"

    arg.channel[].send(pkgs_str)
    sleep timeout


proc getBacklight*(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(milliseconds = 250)
  var
    backlight_str: string
    bldevice: string
    actual_brightness, max_brightness: int
  while true:
    try:
      bldevice = "ls /sys/class/backlight | grep backlight".execCmdEx.output.strip.split[0]
      break
    except:
      sleep delay500
      continue
  max_brightness = readFile("/sys/class/backlight/" / bldevice / "max_brightness").strip.parseInt
  
  while true:
    actual_brightness = readFile("/sys/class/backlight/" / bldevice / "actual_brightness").strip.parseInt
    backlight_str = fmt"BL: {arg.colors[CYELLOW]}{(actual_brightness * 100) div max_brightness}%{arg.colors[CRESET]}"

    arg.channel[].send(backlight_str)

    sleep timeout


proc getVolume*(arg: ThreadArg) {.thread.} =
  let timeout = initDuration(milliseconds = 250)
  while true:
    var volume_info: seq[string]
    try:
      # TODO: Use systemfiles or internal structures
      volume_info = "amixer get Master".execCmdEx.output.strip.splitLines
    except:
      sleep delay500
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

      vol_str &= fmt"{arg.colors[CYELLOW]}"
      if allmute:
        vol_str &= fmt"mute{arg.colors[CRESET]}"
      else:
        vol_str &= fmt"{volumes.sum div volumes.len}%{arg.colors[CRESET]}"
    except:
      vol_str &= fmt"{arg.colors[CRED]}error{arg.colors[CRESET]}"

    arg.channel[].send(vol_str)

    sleep timeout
