when not defined(NIMSCRIPT):
  import tags, colors

type Configuration* = object
  taglist*: TagList
  tagpadding*: int
  colormap*: ColorMap
  useColors*: bool

