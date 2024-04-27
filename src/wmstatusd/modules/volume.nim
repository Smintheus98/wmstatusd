import ../utils/[threadutils, colors, timeutils]
import ../alsa/amixer

const tag* = "volume"

proc volume*(args: Args) {.thread.} =
  let timeout =
      if args.savepower: 2'sec
      else:              250'ms

  var mixer = initMixer()
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
        if args.useColor: "Vol: " & $CYELLOW & mute_or_vol & $CRESET
        else:             "Vol: " & $CYELLOW & mute_or_vol & $CRESET
    )

    sleep timeout
  mixer.deinit()
