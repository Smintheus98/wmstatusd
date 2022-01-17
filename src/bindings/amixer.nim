import alsapart

type Mixer* = object
  sid:    ptr snd_mixer_selem_id
  handle: ptr snd_mixer
  elem:   ptr snd_mixer_elem
  volmin, volmax: clong
  good*: bool


proc `=destroy`(mixer: var Mixer) =
  # TODO: Add some further free/close/unregister calls
  if mixer.elem != nil:
    mixer.elem = nil
  if mixer.handle != nil:
    snd_mixer_free(mixer.handle)
    discard snd_mixer_close(mixer.handle)
    mixer.handle = nil
  if mixer.sid != nil:
    snd_mixer_selem_id_free(mixer.sid)
    mixer.sid = nil


proc deinit*(mixer: var Mixer) =
  mixer.`=destroy`


proc init*(mixer: var Mixer; mixIdx = 0.cuint; mixName = "Master"; cardName = "default") =
  mixer.good = false
  if mixer.sid != nil:
    mixer.`=destroy`

  if snd_mixer_selem_id_malloc(addr mixer.sid) < 0:
    mixer.`=destroy`
    return

  snd_mixer_selem_id_set_index(mixer.sid, mixIdx)
  snd_mixer_selem_id_set_name(mixer.sid, mixName)

  if snd_mixer_open(addr mixer.handle, 0) < 0 or
      snd_mixer_attach(mixer.handle, cardName) < 0 or
      snd_mixer_selem_register(mixer.handle, nil, nil) < 0 or
      snd_mixer_load(mixer.handle) < 0:
    mixer.`=destroy`
    return

  mixer.elem = snd_mixer_find_selem(mixer.handle, mixer.sid)
  if mixer.elem == nil:
    mixer.`=destroy`
    return

  discard snd_mixer_selem_get_playback_volume_range(mixer.elem, addr mixer.volmin, addr mixer.volmax)
  mixer.good = true


proc initMixer*(mixIdx = 0.cuint; mixName = "Master"; cardName = "default"): Mixer =
  init(result, mixIdx, mixName, cardName)


proc update*(mixer: var Mixer): bool =
  if snd_mixer_handle_events(mixer.handle) < 0:
    return false
  mixer.elem = snd_mixer_find_selem(mixer.handle, mixer.sid)
  if mixer.elem == nil:
    return false
  return true


proc isMuted*(mixer: Mixer; channel = SND_MIXER_SCHN_FRONT_LEFT): bool =
  var switchstate: cint
  if snd_mixer_selem_get_playback_switch(mixer.elem, channel, addr switchstate) < 0:
    return false
  return not switchstate.bool


proc getVolume*(mixer: Mixer; channel = SND_MIXER_SCHN_FRONT_LEFT): int =
  var volume: clong
  if snd_mixer_selem_get_playback_volume(mixer.elem, channel, addr volume) < 0:
    return -1
  return ((volume-mixer.volmin) / (mixer.volmax-mixer.volmin) * 100).int

