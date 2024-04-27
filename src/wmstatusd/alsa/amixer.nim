## This is a high-level interface for a subset of the libasound library.
## It provides types an procedures which can be used to obtain the systems audio volume and mute-state for output and input devices.
## It is based on the low-level bindings within the `asoundlib` module.

# TODO:
#   - overthink interface design
#   - make programming interface easier and more straight forward to use! (?)

import asoundlib

type Channel* = enum
  ## nicer looking channel names compared to `snd_mixer_selem_channel_id`
  ## (may be extended if neccessary; be careful about the corresponding values!)
  ChannelFrontLeft, ChannelFrontRight

type MixKind* = enum
  ## determined Mixer names
  ## (may be extended if neccessary; keep in mind that their string representations have to be valid amixer identifiers)
  Master, Capture

type Mixer* = object
  ## Mixer type able to ask the systems volume level and if system audio is muted for input as well as output devices
  ## It wrapps some calls to the `libasound` library in a nice interface
  good*: bool
  mixKind: MixKind
  volmin, volmax: clong
  # internal attributes required for interfacing with the low level API:
  sid:    ptr snd_mixer_selem_id
  handle: ptr snd_mixer
  elem:   ptr snd_mixer_elem


proc deinit*(mixer: var Mixer) =
  ## clear object and free all resources
  if mixer.elem != nil:
    mixer.elem = nil
  if mixer.handle != nil:
    snd_mixer_free(mixer.handle)
    discard snd_mixer_close(mixer.handle)
    mixer.handle = nil
  if mixer.sid != nil:
    snd_mixer_selem_id_free(mixer.sid)
    mixer.sid = nil


proc init*(mixer: var Mixer; mixKind = Master; mixIdx = 0; cardName = "default") =
  ## In-place init procedure
  let mixIdx = mixIdx.cuint

  mixer.good = false
  # clean object if already allocated
  if mixer.sid != nil:
    mixer.deinit

  # try allocate mixer, setting its ID
  if snd_mixer_selem_id_malloc(addr mixer.sid) < 0:
    mixer.deinit
    return  # fail!

  # set mixer name and index
  mixer.mixKind = mixKind
  snd_mixer_selem_id_set_name(mixer.sid, ($mixKind).cstring)
  snd_mixer_selem_id_set_index(mixer.sid, mixIdx)

  # try to open the mixer handle, attach a card, register it and finally load it
  if snd_mixer_open(addr mixer.handle, 0) < 0 or
      snd_mixer_attach(mixer.handle, cardName) < 0 or
      snd_mixer_selem_register(mixer.handle, nil, nil) < 0 or
      snd_mixer_load(mixer.handle) < 0:
    mixer.deinit
    return  # fail!

  # try find mixer element by handle and sid
  mixer.elem = snd_mixer_find_selem(mixer.handle, mixer.sid)
  if mixer.elem == nil:
    mixer.deinit
    return  # fail!

  # get volume range for playback/capture
  let mixer_get_volume_range =  # choose correct function
      case mixKind:
        of Master:  snd_mixer_selem_get_playback_volume_range
        of Capture: snd_mixer_selem_get_capture_volume_range
  discard mixer_get_volume_range(mixer.elem, addr mixer.volmin, addr mixer.volmax)
  mixer.good = true


proc initMixer*(mixKind = Master; mixIdx = 0; cardName = "default"): Mixer =
  ## Constructor
  result.init(mixKind, mixIdx, cardName)


proc update*(mixer: var Mixer): bool =
  ## Updates Information
  ## Required for multiple checks on the same object at different times (e.g. for use in loops)
  ## Without this procedure (or a reinitiation of the entire object) the `isMuted` and `getVolume` procedures
  ## would always return the same (old) values.
  if snd_mixer_handle_events(mixer.handle) < 0:
    return false
  mixer.elem = snd_mixer_find_selem(mixer.handle, mixer.sid)
  if mixer.elem == nil:
    return false
  return true


proc isMuted*(mixer: Mixer; channel = ChannelFrontLeft): bool =
  ## Checks if system audio in-/output is muted
  ## Value may be out of date, see `update` procedure
  let channel = channel.snd_mixer_selem_channel_id
  let mixer_get_switch =  # choose correct function
      case mixer.mixKind:
        of Master:  snd_mixer_selem_get_playback_switch
        of Capture: snd_mixer_selem_get_capture_switch
  var switchstate: cint

  if mixer_get_switch(mixer.elem, channel, addr switchstate) < 0:
    return false

  return not switchstate.bool


proc getVolume*(mixer: Mixer; channel = ChannelFrontLeft): int =
  ## Returns system volume level
  ## Value may be out of date, see `update` procedure
  let channel = channel.snd_mixer_selem_channel_id
  let mixer_get_volume =  # choose correct function
      case mixer.mixKind:
        of Master:  snd_mixer_selem_get_playback_volume
        of Capture: snd_mixer_selem_get_capture_volume
  var volume: clong

  if mixer_get_volume(mixer.elem, channel, addr volume) < 0:
    return -1
  let volume_percent = (((volume-mixer.volmin) * 100) / (mixer.volmax-mixer.volmin) + 0.5).int
  return volume_percent


# TODO: remove?
proc getFreshVolume(mixer: var Mixer; channel = ChannelFrontLeft): int =
  if not mixer.update():
    return -1
  return mixer.getVolume(channel)
