import std/sequtils
import wmstatusd/utils/[timeutils, locales]
import wmstatusd/modules/all

# variables
var
  data: array[Tag, string]
  channels: ptr array[Tag, Channel[string]]
  threads: array[Tag, Thread[Args]]

channels = cast[ptr array[Tag, Channel[string]]] (createShared(Channel[string], Tag.toSeq.len))

# setup
for tag in Tag:
  data[tag] = ""
  channels[tag].open()
  createThread(threads[tag], moduleProcs[tag], (true, false, de_DE, addr channels[tag]))

sleep 500'ms

var laststatus, status = ""

while true:
  status = " "
  for tag in Tag:
    while channels[tag].peek >= 1:
      data[tag] = channels[tag].recv()
    let padding = " "
    status &= data[tag]
    status &= padding & "|" & padding

  if status != laststatus:
    echo status
  laststatus = status

  sleep 250'ms

for tag in Tag:
  channels[tag].close()
freeShared(channels)
