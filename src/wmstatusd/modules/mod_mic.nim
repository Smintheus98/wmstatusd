import ../utils/[threadutils, colors, timeutils]
import ../alsa/amixer

const tag* = "mic"

proc mic*(args: Args) {.thread.} =
  let timeout =
      if args.savepower: 5'sec
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
        if args.useColor: "Mic: " & $CYELLOW & mute_or_vol & $CRESET
        else:             "Mic: " & $CYELLOW & mute_or_vol & $CRESET
    )

    sleep timeout
  mixer.deinit()
