import std/[os, sequtils, strutils, math]
import ../utils/[threadutils, colors, timeutils]

const tag* = "backlight"

const bl_dir = "/sys/class/backlight"

proc getBlDevice(): string =
  let blDevices = walkPattern(bl_dir / "*").toSeq
  if blDevices.len > 0:
    return blDevices[0]
  return ""

proc backlight*(args: Args) {.thread.} =
  let timeout =
      if args.savepower: 2'sec
      else:              250'ms

  let blDevice = getBlDevice()
  if blDevice == "":
    return

  let max_brightness = readFile(blDevice / "max_brightness").strip.parseInt

  while true:
    let actual_brightness = readFile(blDevice / "actual_brightness").strip.parseInt
    let perc_brightness = ((actual_brightness * 100) / max_brightness).round.int

    args.channel[].send(
        if args.useColor: "BL: " & $CYELLOW & $perc_brightness & "%" & $CRESET
        else:             "BL: " & $perc_brightness & "%"
    )

    sleep timeout
