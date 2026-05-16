import std/[sequtils, strutils, math]
import threadingtools
import ../utils/[colors, timeutils]

const tag* = "cpuload"

const cpu_stat_file= "/proc/stat"

proc cpuload*(args: ModuleArgs) {.thread.} =
  let timeout =
      if args.savepower: 4'sec
      else:              1'sec

  var rawload: seq[uint]
  var load = 0'u
  while true:
    let lastrawload = rawload
    rawload = cpu_stat_file.readLines(1)[0].splitWhitespace[1..^1].mapIt(it.parseUint)

    if lastrawload.len > 0:
      let sum = rawload.sum() - lastrawload.sum()
      if sum != 0:
        load = (rawload[0] - lastrawload[0] +
                rawload[1] - lastrawload[1] +
                rawload[2] - lastrawload[2] +
                rawload[5] - lastrawload[5] +
                rawload[6] - lastrawload[6]) * 100 div sum

    let color =
        if load < 60:   CGREEN
        elif load < 90: CYELLOW
        else:           CRED

    args.channel[].send(
        if args.useColor: "CPU: " & color.str & $load & "%" & CRESET.str
        else:             "CPU: " & $load & "%"
    )

    sleep timeout

