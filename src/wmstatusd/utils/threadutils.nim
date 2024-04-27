import locales
export locales

type Args* = tuple
  ## Data structure to bundle arguments for threaded procedures
  ## (which can have only one parameter)
  ## extend as neccessary
  useColor: bool
  savepower: bool
  locale: Locale
  channel: ptr Channel[string]

