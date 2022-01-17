import strformat, os
import ../src/bindings/alsapart

proc test_classical =
  var
    sid:    ptr snd_mixer_selem_id
    handle: ptr snd_mixer
    elem:   ptr snd_mixer_elem
    outvol: clong
    minv, maxv: clong
    switch: cint

    mix_index = 0.cuint
    mix_name = "Master".cstring
    sound_card = "default".cstring

  discard snd_mixer_selem_id_malloc(addr sid)


  snd_mixer_selem_id_set_index(sid, mix_index)
  snd_mixer_selem_id_set_name(sid, mix_name)

  if snd_mixer_open(addr handle, 0) < 0:
    quit QuitFailure
  if snd_mixer_attach(handle, soundcard) < 0:
    discard snd_mixer_close(handle)
    quit QuitFailure
  if snd_mixer_selem_register(handle, nil, nil) < 0:
    discard snd_mixer_close(handle)
    quit QuitFailure
  if snd_mixer_load(handle) < 0:
    discard snd_mixer_close(handle)
    quit QuitFailure
  elem = snd_mixer_find_selem(handle, sid)
  if elem == nil:
    discard snd_mixer_close(handle)
    quit QuitFailure

  discard snd_mixer_selem_get_playback_volume_range(elem, addr minv, addr maxv)
  echo &"Limits: {minv} - {maxv}"

  if snd_mixer_selem_get_playback_volume(elem, 0.snd_mixer_selem_channel_id, addr outvol) < 0:
    discard snd_mixer_close(handle);
    quit QuitFailure

  if snd_mixer_selem_get_playback_switch(elem, 0.snd_mixer_selem_channel_id, addr switch) < 0:
    discard snd_mixer_close(handle);
    quit QuitFailure
    

  snd_mixer_selem_id_free(sid)

  echo &"Volume: {outvol} ({(outvol-minv) / (maxv-minv) * 100}%)"
  echo &"Switch: {switch} (" & (if switch == 1: "on" else: "off: mute") & ")"



import ../src/bindings/amixer
proc test_advanced() =
  var mixer: Mixer = initMixer()
  if not mixer.good:
    quit QuitFailure
  for i in 0..<50000:
    if not mixer.update:
      break
    echo &"Volume: {mixer.getVolume}"
    echo &"Muted: {mixer.isMuted}"
    sleep(250)
  mixer.deinit


echo "1: Classical Test: (imperative)"
test_classical()
echo "\n2: Advanced Test: (object orientated)"
test_advanced()
