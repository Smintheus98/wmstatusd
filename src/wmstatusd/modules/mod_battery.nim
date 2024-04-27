import std/[os, sequtils, strutils]
import ../utils/[threadutils, colors, timeutils]

const tag* = "battery"

const bat_dir = "/sys/class/power_supply"

proc getBatName(): string {.inline.} =
  let bat_names = walkPattern(bat_dir/"BAT*").toSeq
  if bat_names.len > 0:
    return bat_names[0]
  return ""

proc battery*(args: Args) {.thread.} =
  let timeout =
      if args.savepower: 10'sec
      else:               5'sec

  let bat_name = getBatName()
  if bat_name == "":
    return

  while true:
    let
      bat_level = readFile(bat_name / "capacity").strip
      bat_status = readFile(bat_name / "status").strip

    let (color, symbol) =
        case bat_status.toLower:
          of "discharging":          (CYELLOW, "v")
          of "charging":             (CGREEN,  "^")
          of "full", "not charging": (CGREEN,  "=")
          else:                      (CYELLOW, ">")

    args.channel[].send(
        if args.useColor: "Bat: " & $color & symbol & bat_level & "%" & $CRESET
        else:             "Bat: " & symbol & bat_level & "%"
    )

    sleep timeout

