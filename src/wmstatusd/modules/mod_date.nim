import std/times
import threadingtools
import ../utils/[colors, timeutils, locales]

const tag* = "date"

proc date*(args: ModuleArgs) {.thread.} =
  let timeout =
      if args.savepower: 30'min
      else:               5'min
  let locale = locales[args.locale]

  while true:
    let curr_time = now()
    let pred_dur = durNextDay(curr_time)

    args.channel[].send(
        if args.useColor: "Date: " & CWHITE.str & curr_time.format("ddd dd'.'MM'.'yyyy", locale) & CRESET.str
        else:             "Date: " & curr_time.format("ddd dd'.'MM'.'yyyy", locale)
    )

    sleep min(pred_dur, timeout) + 1'ms

