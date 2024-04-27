import std/[os, sequtils, strutils]
import ../utils/[threadutils, colors, timeutils]

const tag* = "cputemp"

const zones_dir = "/sys/class/thermal"

proc getZoneName(zone_type = "x86_pkg_temp"): string {.inline.} =
  let zones = walkPattern(zones_dir / "thermal_zone*").toSeq
  for zone in zones:
    if readFile(zone / "type").strip == zone_type:
      return zone
  return ""

proc cputemp*(args: Args) {.thread.} =
  # TODO (?): get CPU-Usage
  let timeout =
      if args.savepower: 6'sec
      else:              3'sec

  let zone = getZoneName()
  if zone == "":
    return

  while true:
    let temp_dC = readFile(zone / "temp").strip.parseInt div 1000

    let color =
        if temp_dC < 65: CGREEN
        else:            CYELLOW

    args.channel[].send(
        if args.useColor: "CPU: " & $color & $temp_dC & "°C" & $CRESET
        else:             "CPU: " & $temp_dC & "°C"
    )

    sleep timeout

