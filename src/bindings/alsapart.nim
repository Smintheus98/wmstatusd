## This is a partial Nim wrapper for the libasound library

const asound* = "libasound.so"

type
  snd_mixer* = object
  snd_mixer_class* = object
  snd_mixer_elem* = object
  snd_mixer_selem_id* = object
  snd_mixer_selem_regopt* = object
  snd_mixer_selem_channel_id* {.size: sizeof(cint).} = enum
    SND_MIXER_SCHN_UNKNOWN = -1,                          ## * Front left
    SND_MIXER_SCHN_FRONT_LEFT = 0,                        ## * Front right
    SND_MIXER_SCHN_FRONT_RIGHT,                           ## * Rear left
    SND_MIXER_SCHN_REAR_LEFT,                             ## * Rear right
    SND_MIXER_SCHN_REAR_RIGHT,                            ## * Front center
    SND_MIXER_SCHN_FRONT_CENTER,                          ## * Woofer
    SND_MIXER_SCHN_WOOFER,                                ## * Side Left
    SND_MIXER_SCHN_SIDE_LEFT,                             ## * Side Right
    SND_MIXER_SCHN_SIDE_RIGHT,                            ## * Rear Center
    SND_MIXER_SCHN_REAR_CENTER,
    SND_MIXER_SCHN_LAST = 31                              ## * Mono (Front left alias)

const
  SND_MIXER_SCHN_MONO* = SND_MIXER_SCHN_FRONT_LEFT



{.push cdecl, importc, dynlib: asound.}

proc snd_mixer_open*(mixer: ptr ptr snd_mixer; mode: cint): cint
proc snd_mixer_close*(mixer: ptr snd_mixer): cint

proc snd_mixer_selem_id_malloc*(`ptr`: ptr ptr snd_mixer_selem_id): cint
proc snd_mixer_selem_id_free*(obj: ptr snd_mixer_selem_id) 

proc snd_mixer_selem_id_set_name*(obj: ptr snd_mixer_selem_id; val: cstring) 
proc snd_mixer_selem_id_set_index*(obj: ptr snd_mixer_selem_id; val: cuint) 

proc snd_mixer_attach*(mixer: ptr snd_mixer; name: cstring): cint 

proc snd_mixer_load*(mixer: ptr snd_mixer): cint 
proc snd_mixer_free*(mixer: ptr snd_mixer) 

proc snd_mixer_selem_register*(mixer: ptr snd_mixer; options: ptr snd_mixer_selem_regopt; classp: ptr ptr snd_mixer_class): cint 
proc snd_mixer_find_selem*(mixer: ptr snd_mixer; id: ptr snd_mixer_selem_id): ptr snd_mixer_elem 

proc snd_mixer_selem_get_playback_volume_range*(elem: ptr snd_mixer_elem; min: ptr clong; max: ptr clong): cint 
proc snd_mixer_selem_get_playback_switch*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: ptr cint): cint 
proc snd_mixer_selem_get_playback_volume*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: ptr clong): cint 

{.pop.}





#[
proc snd_mixer_first_elem*(mixer: ptr snd_mixer): ptr snd_mixer_elem {.cdecl, importc: "snd_mixer_first_elem", dynlib: asound.}
proc snd_mixer_last_elem*(mixer: ptr snd_mixer): ptr snd_mixer_elem {.cdecl, importc: "snd_mixer_last_elem", dynlib: asound.}
proc snd_mixer_handle_events*(mixer: ptr snd_mixer): cint {.cdecl, importc: "snd_mixer_handle_events", dynlib: asound.}
proc snd_mixer_attach_hctl*(mixer: ptr snd_mixer; hctl: ptr snd_hctl_t): cint {.cdecl, importc: "snd_mixer_attach_hctl", dynlib: asound.}
proc snd_mixer_detach_hctl*(mixer: ptr snd_mixer; hctl: ptr snd_hctl_t): cint {.cdecl, importc: "snd_mixer_detach_hctl", dynlib: asound.}
proc snd_mixer_get_hctl*(mixer: ptr snd_mixer; name: cstring; hctl: ptr ptr snd_hctl_t): cint {.cdecl, importc: "snd_mixer_get_hctl", dynlib: asound.}
proc snd_mixer_poll_descriptors_count*(mixer: ptr snd_mixer): cint {.cdecl, importc: "snd_mixer_poll_descriptors_count", dynlib: asound.}
proc snd_mixer_poll_descriptors*(mixer: ptr snd_mixer; pfds: ptr pollfd; space: cuint): cint {. cdecl, importc: "snd_mixer_poll_descriptors", dynlib: asound.}
proc snd_mixer_poll_descriptors_revents*(mixer: ptr snd_mixer; pfds: ptr pollfd; nfds: cuint; revents: ptr cushort): cint {. cdecl, importc: "snd_mixer_poll_descriptors_revents", dynlib: asound.}
proc snd_mixer_wait*(mixer: ptr snd_mixer; timeout: cint): cint {.cdecl, importc: "snd_mixer_wait", dynlib: asound.}
proc snd_mixer_set_compare*(mixer: ptr snd_mixer; msort: snd_mixer_compare_t): cint {. cdecl, importc: "snd_mixer_set_compare", dynlib: asound.}
proc snd_mixer_set_callback*(obj: ptr snd_mixer; val: snd_mixer_callback_t) {.cdecl, importc: "snd_mixer_set_callback", dynlib: asound.}
proc snd_mixer_get_callback_private*(obj: ptr snd_mixer): pointer {.cdecl, importc: "snd_mixer_get_callback_private", dynlib: asound.}
proc snd_mixer_set_callback_private*(obj: ptr snd_mixer; val: pointer) {.cdecl, importc: "snd_mixer_set_callback_private", dynlib: asound.}
proc snd_mixer_get_count*(obj: ptr snd_mixer): cuint {.cdecl, importc: "snd_mixer_get_count", dynlib: asound.}
proc snd_mixer_class_unregister*(clss: ptr snd_mixer_class): cint {.cdecl, importc: "snd_mixer_class_unregister", dynlib: asound.}
proc snd_mixer_elem_next*(elem: ptr snd_mixer_elem): ptr snd_mixer_elem {.cdecl, importc: "snd_mixer_elem_next", dynlib: asound.}
proc snd_mixer_elem_prev*(elem: ptr snd_mixer_elem): ptr snd_mixer_elem {.cdecl, importc: "snd_mixer_elem_prev", dynlib: asound.}
proc snd_mixer_elem_set_callback*(obj: ptr snd_mixer_elem; val: snd_mixer_elem_callback_t) {.cdecl, importc: "snd_mixer_elem_set_callback", dynlib: asound.}
proc snd_mixer_elem_get_callback_private*(obj: ptr snd_mixer_elem): pointer {. cdecl, importc: "snd_mixer_elem_get_callback_private", dynlib: asound.}
proc snd_mixer_elem_set_callback_private*(obj: ptr snd_mixer_elem; val: pointer) {. cdecl, importc: "snd_mixer_elem_set_callback_private", dynlib: asound.}
proc snd_mixer_elem_get_type*(obj: ptr snd_mixer_elem): snd_mixer_elemype_t {. cdecl, importc: "snd_mixer_elem_get_type", dynlib: asound.}
proc snd_mixer_class_register*(class: ptr snd_mixer_class; mixer: ptr snd_mixer): cint {. cdecl, importc: "snd_mixer_class_register", dynlib: asound.}
proc snd_mixer_elem_new*(elem: ptr ptr snd_mixer_elem; `type`: snd_mixer_elemype_t; compare_weight: cint; private_data: pointer; private_free: proc ( elem: ptr snd_mixer_elem) {.cdecl.}): cint {.cdecl, importc: "snd_mixer_elem_new", dynlib: asound.}
proc snd_mixer_elem_add*(elem: ptr snd_mixer_elem; class: ptr snd_mixer_class): cint {. cdecl, importc: "snd_mixer_elem_add", dynlib: asound.}
proc snd_mixer_elem_remove*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_elem_remove", dynlib: asound.}
proc snd_mixer_elem_free*(elem: ptr snd_mixer_elem) {.cdecl, importc: "snd_mixer_elem_free", dynlib: asound.}
proc snd_mixer_elem_info*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_elem_info", dynlib: asound.}
proc snd_mixer_elem_value*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_elem_value", dynlib: asound.}
proc snd_mixer_elem_attach*(melem: ptr snd_mixer_elem; helem: ptr snd_hctl_elem): cint {. cdecl, importc: "snd_mixer_elem_attach", dynlib: asound.}
proc snd_mixer_elem_detach*(melem: ptr snd_mixer_elem; helem: ptr snd_hctl_elem): cint {. cdecl, importc: "snd_mixer_elem_detach", dynlib: asound.}
proc snd_mixer_elem_empty*(melem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_elem_empty", dynlib: asound.}
proc snd_mixer_elem_get_private*(melem: ptr snd_mixer_elem): pointer {.cdecl, importc: "snd_mixer_elem_get_private", dynlib: asound.}
proc snd_mixer_class_sizeof*(): csize_t {.cdecl, importc: "snd_mixer_class_sizeof", dynlib: asound.}


proc snd_mixer_class_malloc*(`ptr`: ptr ptr snd_mixer_class): cint {.cdecl, importc: "snd_mixer_class_malloc", dynlib: asound.}
proc snd_mixer_class_free*(obj: ptr snd_mixer_class) {.cdecl, importc: "snd_mixer_class_free", dynlib: asound.}
proc snd_mixer_class_copy*(dst: ptr snd_mixer_class; src: ptr snd_mixer_class) {. cdecl, importc: "snd_mixer_class_copy", dynlib: asound.}
proc snd_mixer_class_get_mixer*(class_: ptr snd_mixer_class): ptr snd_mixer {. cdecl, importc: "snd_mixer_class_get_mixer", dynlib: asound.}
proc snd_mixer_class_get_event*(class_: ptr snd_mixer_class): snd_mixer_event_t {. cdecl, importc: "snd_mixer_class_get_event", dynlib: asound.}
proc snd_mixer_class_get_private*(class_: ptr snd_mixer_class): pointer {.cdecl, importc: "snd_mixer_class_get_private", dynlib: asound.}
proc snd_mixer_class_get_compare*(class_: ptr snd_mixer_class): snd_mixer_compare_t {. cdecl, importc: "snd_mixer_class_get_compare", dynlib: asound.}
proc snd_mixer_class_set_event*(class_: ptr snd_mixer_class; event: snd_mixer_event_t): cint {.cdecl, importc: "snd_mixer_class_set_event", dynlib: asound.}
proc snd_mixer_class_set_private*(class_: ptr snd_mixer_class; private_data: pointer): cint {.cdecl, importc: "snd_mixer_class_set_private", dynlib: asound.}
proc snd_mixer_class_set_private_free*(class_: ptr snd_mixer_class; private_free: proc ( a1: ptr snd_mixer_class) {.cdecl.}): cint {.cdecl, importc: "snd_mixer_class_set_private_free", dynlib: asound.}
proc snd_mixer_class_set_compare*(class_: ptr snd_mixer_class; compare: snd_mixer_compare_t): cint {.cdecl, importc: "snd_mixer_class_set_compare", dynlib: asound.}



proc snd_mixer_selem_channel_name*(channel: snd_mixer_selem_channel_id): cstring {. cdecl, importc: "snd_mixer_selem_channel_name", dynlib: asound.}
proc snd_mixer_selem_get_id*(element: ptr snd_mixer_elem; id: ptr snd_mixer_selem_id) {.cdecl, importc: "snd_mixer_selem_get_id", dynlib: asound.}
proc snd_mixer_selem_get_name*(elem: ptr snd_mixer_elem): cstring {.cdecl, importc: "snd_mixer_selem_get_name", dynlib: asound.}
proc snd_mixer_selem_get_index*(elem: ptr snd_mixer_elem): cuint {.cdecl, importc: "snd_mixer_selem_get_index", dynlib: asound.}
proc snd_mixer_selem_is_active*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_is_active", dynlib: asound.}
proc snd_mixer_selem_is_playback_mono*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_is_playback_mono", dynlib: asound.}
proc snd_mixer_selem_has_playback_channel*(obj: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id): cint {.cdecl, importc: "snd_mixer_selem_has_playback_channel", dynlib: asound.}
proc snd_mixer_selem_is_capture_mono*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_is_capture_mono", dynlib: asound.}
proc snd_mixer_selem_has_capture_channel*(obj: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id): cint {.cdecl, importc: "snd_mixer_selem_has_capture_channel", dynlib: asound.}
proc snd_mixer_selem_get_capture_group*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_get_capture_group", dynlib: asound.}
proc snd_mixer_selem_has_common_volume*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_has_common_volume", dynlib: asound.}
proc snd_mixer_selem_has_playback_volume*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_has_playback_volume", dynlib: asound.}
proc snd_mixer_selem_has_playback_volume_joined*(elem: ptr snd_mixer_elem): cint {. cdecl, importc: "snd_mixer_selem_has_playback_volume_joined", dynlib: asound.}
proc snd_mixer_selem_has_capture_volume*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_has_capture_volume", dynlib: asound.}
proc snd_mixer_selem_has_capture_volume_joined*(elem: ptr snd_mixer_elem): cint {. cdecl, importc: "snd_mixer_selem_has_capture_volume_joined", dynlib: asound.}
proc snd_mixer_selem_has_common_switch*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_has_common_switch", dynlib: asound.}
proc snd_mixer_selem_has_playback_switch*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_has_playback_switch", dynlib: asound.}
proc snd_mixer_selem_has_playback_switch_joined*(elem: ptr snd_mixer_elem): cint {. cdecl, importc: "snd_mixer_selem_has_playback_switch_joined", dynlib: asound.}
proc snd_mixer_selem_has_capture_switch*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_has_capture_switch", dynlib: asound.}
proc snd_mixer_selem_has_capture_switch_joined*(elem: ptr snd_mixer_elem): cint {. cdecl, importc: "snd_mixer_selem_has_capture_switch_joined", dynlib: asound.}
proc snd_mixer_selem_has_capture_switch_exclusive*(elem: ptr snd_mixer_elem): cint {. cdecl, importc: "snd_mixer_selem_has_capture_switch_exclusive", dynlib: asound.}
proc snd_mixer_selem_ask_playback_vol_dB*(elem: ptr snd_mixer_elem; value: clong; dBvalue: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_ask_playback_vol_dB", dynlib: asound.}
proc snd_mixer_selem_ask_capture_vol_dB*(elem: ptr snd_mixer_elem; value: clong; dBvalue: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_ask_capture_vol_dB", dynlib: asound.}
proc snd_mixer_selem_ask_playback_dB_vol*(elem: ptr snd_mixer_elem; dBvalue: clong; dir: cint; value: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_ask_playback_dB_vol", dynlib: asound.}
proc snd_mixer_selem_ask_capture_dB_vol*(elem: ptr snd_mixer_elem; dBvalue: clong; dir: cint; value: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_ask_capture_dB_vol", dynlib: asound.}
proc snd_mixer_selem_get_capture_volume*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_get_capture_volume", dynlib: asound.}
proc snd_mixer_selem_get_playback_dB*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_get_playback_dB", dynlib: asound.}
proc snd_mixer_selem_get_capture_dB*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_get_capture_dB", dynlib: asound.}
proc snd_mixer_selem_get_capture_switch*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: ptr cint): cint {.cdecl, importc: "snd_mixer_selem_get_capture_switch", dynlib: asound.}
proc snd_mixer_selem_set_playback_volume*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: clong): cint {.cdecl, importc: "snd_mixer_selem_set_playback_volume", dynlib: asound.}
proc snd_mixer_selem_set_capture_volume*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: clong): cint {.cdecl, importc: "snd_mixer_selem_set_capture_volume", dynlib: asound.}
proc snd_mixer_selem_set_playback_dB*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: clong; dir: cint): cint {.cdecl, importc: "snd_mixer_selem_set_playback_dB", dynlib: asound.}
proc snd_mixer_selem_set_capture_dB*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: clong; dir: cint): cint {.cdecl, importc: "snd_mixer_selem_set_capture_dB", dynlib: asound.}
proc snd_mixer_selem_set_playback_volume_all*(elem: ptr snd_mixer_elem; value: clong): cint {.cdecl, importc: "snd_mixer_selem_set_playback_volume_all", dynlib: asound.}
proc snd_mixer_selem_set_capture_volume_all*(elem: ptr snd_mixer_elem; value: clong): cint {.cdecl, importc: "snd_mixer_selem_set_capture_volume_all", dynlib: asound.}
proc snd_mixer_selem_set_playback_dB_all*(elem: ptr snd_mixer_elem; value: clong; dir: cint): cint {.cdecl, importc: "snd_mixer_selem_set_playback_dB_all", dynlib: asound.}
proc snd_mixer_selem_set_capture_dB_all*(elem: ptr snd_mixer_elem; value: clong; dir: cint): cint {.cdecl, importc: "snd_mixer_selem_set_capture_dB_all", dynlib: asound.}
proc snd_mixer_selem_set_playback_switch*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: cint): cint {.cdecl, importc: "snd_mixer_selem_set_playback_switch", dynlib: asound.}
proc snd_mixer_selem_set_capture_switch*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; value: cint): cint {.cdecl, importc: "snd_mixer_selem_set_capture_switch", dynlib: asound.}
proc snd_mixer_selem_set_playback_switch_all*(elem: ptr snd_mixer_elem; value: cint): cint {.cdecl, importc: "snd_mixer_selem_set_playback_switch_all", dynlib: asound.}
proc snd_mixer_selem_set_capture_switch_all*(elem: ptr snd_mixer_elem; value: cint): cint {. cdecl, importc: "snd_mixer_selem_set_capture_switch_all", dynlib: asound.}
proc snd_mixer_selem_get_playback_dB_range*(elem: ptr snd_mixer_elem; min: ptr clong; max: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_get_playback_dB_range", dynlib: asound.}
proc snd_mixer_selem_set_playback_volume_range*(elem: ptr snd_mixer_elem; min: clong; max: clong): cint {.cdecl, importc: "snd_mixer_selem_set_playback_volume_range", dynlib: asound.}
proc snd_mixer_selem_get_capture_volume_range*(elem: ptr snd_mixer_elem; min: ptr clong; max: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_get_capture_volume_range", dynlib: asound.}
proc snd_mixer_selem_get_capture_dB_range*(elem: ptr snd_mixer_elem; min: ptr clong; max: ptr clong): cint {.cdecl, importc: "snd_mixer_selem_get_capture_dB_range", dynlib: asound.}
proc snd_mixer_selem_set_capture_volume_range*(elem: ptr snd_mixer_elem; min: clong; max: clong): cint {.cdecl, importc: "snd_mixer_selem_set_capture_volume_range", dynlib: asound.}
proc snd_mixer_selem_is_enumerated*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_is_enumerated", dynlib: asound.}
proc snd_mixer_selem_is_enum_playback*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_is_enum_playback", dynlib: asound.}
proc snd_mixer_selem_is_enum_capture*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_is_enum_capture", dynlib: asound.}
proc snd_mixer_selem_get_enum_items*(elem: ptr snd_mixer_elem): cint {.cdecl, importc: "snd_mixer_selem_get_enum_items", dynlib: asound.}
proc snd_mixer_selem_get_enum_item_name*(elem: ptr snd_mixer_elem; idx: cuint; maxlen: csize_t; str: cstring): cint {.cdecl, importc: "snd_mixer_selem_get_enum_item_name", dynlib: asound.}
proc snd_mixer_selem_get_enum_item*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; idxp: ptr cuint): cint {.cdecl, importc: "snd_mixer_selem_get_enum_item", dynlib: asound.}
proc snd_mixer_selem_set_enum_item*(elem: ptr snd_mixer_elem; channel: snd_mixer_selem_channel_id; idx: cuint): cint {.cdecl, importc: "snd_mixer_selem_set_enum_item", dynlib: asound.}
proc snd_mixer_selem_id_sizeof*(): csize_t {.cdecl, importc: "snd_mixer_selem_id_sizeof", dynlib: asound.}

proc snd_mixer_selem_id_copy*(dst: ptr snd_mixer_selem_id; src: ptr snd_mixer_selem_id) {.cdecl, importc: "snd_mixer_selem_id_copy", dynlib: asound.}
proc snd_mixer_selem_id_get_name*(obj: ptr snd_mixer_selem_id): cstring {.cdecl, importc: "snd_mixer_selem_id_get_name", dynlib: asound.}
proc snd_mixer_selem_id_get_index*(obj: ptr snd_mixer_selem_id): cuint {.cdecl, importc: "snd_mixer_selem_id_get_index", dynlib: asound.}
proc snd_mixer_selem_id_parse*(dst: ptr snd_mixer_selem_id; str: cstring): cint {. cdecl, importc: "snd_mixer_selem_id_parse", dynlib: asound.}
]#
