import std/[sequtils, strutils, math, sugar]
import threadingtools
import ../utils/[colors, timeutils]

const tag* = "cpuload"

const cpu_stat_file= "/proc/stat"

type cpustat = seq[uint] # [cpu<string>] user<uint> nice<uint> system<uint> idle<uint> iowait<uint> irq<uint> softirq<uint>

proc empty(cs: cpustat): bool = cs.len == 0

proc `-`(a, b: cpustat): cpustat =
  @[ a[0] - b[0],
     a[1] - b[1],
     a[2] - b[2],
     a[3] - b[3],
     a[4] - b[4],
     a[5] - b[5],
     a[6] - b[6] ]

proc sum(cs: cpustat; at: openArray[int]): uint =
  let view = collect:
    for i in at:
      cs[i]
  view.sum()

proc getcpustat(): cpustat =
  cpu_stat_file.readLines(1)[0].splitWhitespace[1..^1].mapIt(it.parseUint).cpustat


proc cpuload*(args: ModuleArgs) {.thread.} =
  let timeout =
      if args.savepower: 4'sec
      else:              1'sec

  var rawload: cpustat
  var load = 0'u
  while true:
    let lastrawload = rawload
    rawload = getcpustat()

    if not lastrawload.empty:
      let
        diff = rawload - lastrawload
        sum = diff.sum()
      if sum != 0:
        load = diff.sum([0, 1, 2, 5, 6]) * 100 div sum

    let color =
        if load < 60:   CGREEN
        elif load < 90: CYELLOW
        else:           CRED

    args.channel[].send(
        if args.useColor: "CPU: " & color.str & $load & "%" & CRESET.str
        else:             "CPU: " & $load & "%"
    )

    sleep timeout

