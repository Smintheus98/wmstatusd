import std/[sequtils, strutils, strformat]
import wmstatusd/utils/[timeutils, statusbar, colors]
import wmstatusd/config/fileConfig
import wmstatusd/cli/cliparse
import wmstatusd/modules/all


# thread variables
var data: array[Tag, string]
var threads: array[Tag, Thread[ModuleArgs]]
let channels = cast[ptr array[Tag, Channel[string]]] (createShared(Channel[string], Tag.toSeq.len))

# load config based on default-config then overwrite with cli-config
let cliConfig = parseCli()
if cliConfig.list_tags.is_some:
  for tag in Tag:
    echo fmt"  {tag}"
  QuitSuccess.quit
let configFile =
  if cliConfig.config.is_some: cliConfig.config.get
  else: getConfigFile()
var config = readDefaultConfig().readConfigFile(configFile)
config.overwrite(cliConfig)
var moduleArgs: ModuleArgs = (config.useColors, config.savepower, config.locale, nil)

# setup and start threads
for tag in config.tags.deduplicate:
  data[tag] = ""
  channels[tag].open()
  moduleArgs.channel = addr channels[tag]
  createThread(threads[tag], moduleProcs[tag], moduleArgs)

# configure output
let paddingWhitespace = " ".repeat(config.padding)
let debug = cliConfig.debug.is_some
let startupMsg = 
  if debug: fmt"Tags: {config.tags} ({config.tags.len}), Threads: {config.tags.deduplicate.len} (+1)"
  else: "Welcome"
var status = initStatusBar(startupMsg, debug)

# wait for the threads to generate data
sleep 500'ms

# main loop
while true:
  var msg: string = " "
  # collect data and build massage
  for tag in config.tags:
    while channels[tag].peek >= 1:
      data[tag] = channels[tag].recv()
    msg &= data[tag] & paddingWhitespace
    msg &= (
      if config.useColors: config.separatorColor.str & config.separator & CRESET.str
      else:                config.separator
    )
    msg &= paddingWhitespace

  # set status
  status.set(msg)

  sleep(
    if config.savepower:    1'sec
    else:                 250'ms
  )

# free memory
for tag in config.tags.deduplicate:
  channels[tag].close()
freeShared(channels)

