import ../utils/locales
#export locales

type ModuleArgs* = tuple
  ## Data structure to bundle arguments for threaded procedures
  ## (which can have only one parameter)
  ## extend as neccessary
  useColor: bool
  savepower: bool
  locale: Locale
  channel: ptr Channel[string]

