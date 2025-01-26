import std/[sequtils, strutils, options]
import ../modules/all
import ../utils/[colors, locales]
import ../cli/cliparse


type Config* = object
  tags*: seq[Tag]
  separator*: string
  separatorColor*: Color
  padding*: int
  useColors*: bool
  savepower*: bool
  locale*: Locale

proc constructStr*(c: Config): string =
  ## Creates a string representation, of its object construction
  ## Basically does what `repr()` does, however since `repr()` should not
  ## be expected to never change, justifying the existence of this procedure
  # surprisingly it's that simple!
  return "Config" & $c


proc overwrite*(config: var Config; cli: CliArgs) =
  # colors
  if cli.no_colors.is_some: config.useColors = not cli.no_colors.get
  elif cli.colors.is_some:  config.useColors = cli.colors.get

  # tags
  if cli.tags.isSome:
    config.tags = cli.tags.get.mapIt(parseEnum[Tag](it))


  
