import std/options
export options

import pkg/simple_parseopt

# Extension guide:
#  to add a new option:
#   - add an according variable to the `CliArg` object
#   - add a (ideally similarly named) variable to the argument of the `get_options_and_supplied` macro
#   - copy the options value (if present) to the result variable of the `parseCli` procedure

type CliArgs* = object
  colors*: Option[bool]
  no_colors*: Option[bool]
  config*: Option[string]
  debug*: Option[bool]
  list_tags*: Option[bool]
  tags*: Option[seq[string]]

proc parseCli*(): CliArgs =
  simple_parseopt.command_name("wmstatusd")
  simple_parseopt.dash_dash_parameters()
  simple_parseopt.no_slash()
  simple_parseopt.value_after_equals()

  let (options, supplied) = get_options_and_supplied:
    colors: bool        {. info("enable colors"), aka("c") .}
    no_colors: bool     {. info("disable colors") .}
    config: string      {. info("alternative config file"), aka("C") .}
    debug: bool         {. info("debug mode"), aka("d") .}
    list_tags: bool     {. info("list available tags"), aka("l") .}
    tags: seq[string]   {. info("list of tags to present in status line (space separated)"), aka("t") .}

  if supplied.colors and supplied.no_colors and options.colors == options.no_colors:
    echo "  Options 'colors' and 'no-colors' are conflicting and can not be combined!"
    QuitFailure.quit

  result.colors    = if supplied.colors:    some(options.colors)    else: none(bool)
  result.no_colors = if supplied.no_colors: some(options.no_colors) else: none(bool)
  result.config    = if supplied.config:    some(options.config)    else: none(string)
  result.debug     = if supplied.debug:     some(options.debug)     else: none(bool)
  result.list_tags = if supplied.list_tags: some(options.list_tags) else: none(bool)
  result.tags      = if supplied.tags:      some(options.tags)      else: none(seq[string])

