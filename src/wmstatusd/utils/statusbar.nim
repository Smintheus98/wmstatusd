import pkg/x11/xlib

type StatusBar* = object
  display: PDisplay = nil
  lastmsg: string
  debug: bool

proc deinit*(sb: var StatusBar)
proc set*(sb: var StatusBar; msg: string; force = false)

proc `=destroy`*(sb: var StatusBar) =
  sb.deinit
  sb.lastmsg.`=destroy`

proc deinit*(sb: var StatusBar) =
  if not sb.debug:
    discard XCloseDisplay(sb.display)
  sb.display = nil
  sb.lastmsg = ""

proc init*(sb: var StatusBar; startupMsg = ""; debug = false) =
  sb.debug = debug
  if not debug:
    if sb.display != nil:
      sb.deinit
    sb.display = XOpenDisplay(nil)
  sb.set(startupMsg)

proc initStatusBar*(startupMsg = ""; debug = false): StatusBar =
  result.init(startupMsg, debug)

proc set*(sb: var StatusBar; msg: string; force = false) =
  if not sb.debug and sb.display == nil:
    sb.init
  if msg != sb.lastmsg or force:
    if sb.debug:
      echo msg
    else:
      discard XStoreName(sb.display, DefaultRootWindow(sb.display), msg.cstring)
      discard XFlush(sb.display)
    sb.lastmsg = msg

