import threadingtools
import ../utils/[colors, timeutils]
import ../alsa/amixer

const tag* = "mic"

proc mic*(args: ModuleArgs) {.thread.} =
  let timeout =
      if args.savepower:   5'sec
      else:              500'ms

  var mixer = initMixer(Capture)
  if not mixer.good:
    return

  while true:
    if not mixer.update():
      break
    let volume = mixer.getVolume()
    let mute_or_vol =
        if mixer.isMuted(): "mute"
        else:               $volume & "%"

    args.channel[].send(
        if args.useColor: "Mic: " & CYELLOW.str & mute_or_vol & CRESET.str
        else:             "Mic: " & mute_or_vol
    )

    sleep timeout
  mixer.deinit()
