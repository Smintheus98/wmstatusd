
type Tag* = enum
  ## Tags for identifying different kinds of system information.
  date, time, pkgs, backlight, volume, cpu, battery

type TagList* = seq[Tag]

