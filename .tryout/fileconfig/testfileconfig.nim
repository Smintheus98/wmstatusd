import fileconfig {.all.}
import ../../src/wmstatusd/config/config
import ../../src/wmstatusd/modules/all
import ../../src/wmstatusd/utils/[colors, locales]

var cfg = Config(tags: @[time], separator: " ", separatorColor: CCYAN, padding: 0, useColors: true, savepower: false, locale: de_DE)

echo cfg.repr, CRESET

let cfgfile = "./wmstatusd.conf"
cfg.readConfig(cfgfile)

echo cfg.repr, CRESET
