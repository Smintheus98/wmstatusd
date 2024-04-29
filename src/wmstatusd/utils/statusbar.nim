import pkg/x11/xlib

type StatusBar* = object
  display: PDisplay = nil
  lastmsg: string

proc deinit*(sb: var StatusBar) =
  discard XCloseDisplay(sb.display)
  sb.display = nil
  sb.lastmsg = ""

proc init*(sb: var StatusBar) =
  if sb.display != nil:
    sb.deinit()
  sb.display = XOpenDisplay(nil)

proc initStatusBar*(): StatusBar =
  result.init

proc set*(sb: var StatusBar; msg: string; force = false) =
  if sb.display == nil:
    sb.init
  if msg != sb.lastmsg or force:
    discard XStoreName(sb.display, DefaultRootWindow(sb.display), msg.cstring)
    discard XFlush(sb.display)
    sb.lastmsg = msg
