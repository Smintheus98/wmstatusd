import std/times
import ../utils/[threadutils, colors, timeutils]

const tag* = "time"

proc time*(args: Args) {.thread.} =
  let timeout =
      if args.savepower: 30'sec
      else:              15'sec

  while true:
    let curr_time = now()
    let pred_dur = durNextMin(curr_time)

    args.channel[].send(
        if args.useColor: "Time: " & $CWHITE & curr_time.format("HH:mm") & $CRESET
        else:             "Time: " & curr_time.format("HH:mm")
    )

    sleep min(pred_dur, timeout) + 1'ms
