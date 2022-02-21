import colors

type ThreadArg* = tuple
  ## Data structure to bundle arguments for thread procedures
  ## which can have only one parameter
  colormap: ColorMap
  channel: ptr Channel[string]

