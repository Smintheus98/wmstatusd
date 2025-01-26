import std/times
import threadingtools
import ../utils/[colors, timeutils]

const tag* = "time"

proc time*(args: ModuleArgs) {.thread.} =
  let timeout =
      if args.savepower: 30'sec
      else:              15'sec

  while true:
    let curr_time = now()
    let pred_dur = durNextMin(curr_time)

    args.channel[].send(
        if args.useColor: "Time: " & CWHITE.str & curr_time.format("HH:mm") & CRESET.str
        else:             "Time: " & curr_time.format("HH:mm")
    )

    sleep min(pred_dur, timeout) + 1'ms
