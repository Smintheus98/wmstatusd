import std / [
    strformat,
    strutils,
    sequtils,
    times,
    os,
]

import types/all, sleep, locales, bindings/amixer


const myLocale = localeDe

proc getDate*(arg: ThreadArg) {.thread.} =
  var timeout = initDuration(minutes = 5)
  if arg.savepower:
    timeout = initDuration(minutes = 30)
  var date_str: string
  var dtime_start, dtime_end: DateTime
  while true:
    dtime_start = now()
    dtime_end = dtime_start + initDuration(days = 1)
    dtime_end.nanosecond = 0
    dtime_end.second = 0
    dtime_end.minute = 0
    dtime_end.hour = 0
    date_str = fmt"""Date: {arg.colormap[CWHITE]}{dtime_start.format("ddd dd'.'MM'.'yyyy", myLocale)}{arg.colormap[CRESET]}"""

    arg.channel[].send(date_str)
    sleep min(dtime_end - dtime_start, timeout).inMilliseconds + 1
    

proc getTime*(arg: ThreadArg) {.thread.} =
  var timeout = initDuration(seconds = 15)
  if arg.savepower:
    timeout = initDuration(seconds = 30)
  var time_str: string
  var dtime_start, dtime_end: DateTime
  while true:
    dtime_start = now()
    dtime_end = dtime_start + initDuration(minutes = 1)
    dtime_end.nanosecond = 0
    dtime_end.second = 0
    time_str = fmt"""Time: {arg.colormap[CWHITE]}{dtime_start.format("HH:mm")}{arg.colormap[CRESET]}"""

    arg.channel[].send(time_str)
    sleep min(dtime_end - dtime_start, timeout).inMilliseconds + 1


proc getBattery*(arg: ThreadArg) {.thread.} =
  let battery_names = walkPattern("/sys/class/power_supply/BAT*").toSeq
  var timeout = initDuration(seconds = 5)
  if arg.savepower:
    timeout = initDuration(seconds = 10)
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
        bat_str &= fmt"{arg.colormap[CRED]}v"
      of "charging":
        bat_str &= fmt"{arg.colormap[CGREEN]}^"
      of "full", "not charging":
        bat_str &= fmt"{arg.colormap[CGREEN]}="
      else:
        bat_str &= fmt"{arg.colormap[CYELLOW]}>"
    bat_str &= fmt"{battery_level}%{arg.colormap[CRESET]}"

    arg.channel[].send(bat_str)
    sleep timeout


proc getCPU*(arg: ThreadArg) {.thread.} =
  # TODO (?): get CPU-Usage
  let zones = walkPattern("/sys/class/thermal/thermal_zone*").toSeq
  var timeout = initDuration(seconds = 3)
  if arg.savepower:
    timeout = initDuration(seconds = 6)
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
      cpu_str &= arg.colormap[CGREEN]
    else:
      cpu_str &= arg.colormap[CRED]
    cpu_str &= fmt"{temp}°C{arg.colormap[CRESET]}"

    arg.channel[].send(cpu_str)
    sleep timeout


proc getPkgs*(arg: ThreadArg) {.thread.} =
  let fileName = "/tmp/available-updates.txt"
  var timeout = initDuration(seconds = 20)
  if arg.savepower:
    timeout = initDuration(minutes = 1)
  if not fileName.fileExists:
    return
  while true:
    var pkgs_str = fmt"Pkgs: {arg.colormap[CCYAN]}"
    if fileName.fileExists and fileName.getFileSize() > 0:
      let updates_count = readFile(fileName).strip.splitLines.len
      pkgs_str &= fmt"{updates_count}{arg.colormap[CRESET]}"
    else:
      pkgs_str &= fmt"0{arg.colormap[CRESET]}"

    arg.channel[].send(pkgs_str)
    sleep timeout


proc getBacklight*(arg: ThreadArg) {.thread.} =
  let bldevices = walkPattern("/sys/class/backlight/*").toSeq
  var timeout = initDuration(milliseconds = 250)
  if arg.savepower:
    timeout = initDuration(seconds = 2)
  if bldevices.len == 0:
    return
  var
    backlight_str: string
    bldevice = bldevices[0]
    actual_brightness, max_brightness: int

  max_brightness = readFile(bldevice / "max_brightness").strip.parseInt
  
  while true:
    actual_brightness = readFile(bldevice / "actual_brightness").strip.parseInt
    backlight_str = fmt"BL: {arg.colormap[CYELLOW]}{(actual_brightness * 100) div max_brightness}%{arg.colormap[CRESET]}"

    arg.channel[].send(backlight_str)
    sleep timeout


proc getVolume*(arg: ThreadArg) {.thread.} =
  var
    mixer = initMixer()
    timeout = initDuration(milliseconds = 250)
  if arg.savepower:
    timeout = initDuration(seconds = 2)
  if not mixer.good:
    return
  while true:
    if not mixer.update():
      break
    let volume = mixer.getVolume()
    var vol_str = fmt"Vol: "

    if mixer.isMuted():
      vol_str &= fmt"{arg.colormap[CYELLOW]}mute{arg.colormap[CRESET]}"
    elif volume >= 0:
      vol_str &= fmt"{arg.colormap[CYELLOW]}{volume}%{arg.colormap[CRESET]}"
    else:
      vol_str &= fmt"{arg.colormap[CRED]}error{arg.colormap[CRESET]}"

    arg.channel[].send(vol_str)
    sleep timeout
  mixer.deinit()

