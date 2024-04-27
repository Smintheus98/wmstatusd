import std/times

type Locale* = enum
  en_US, de_DE

# unmutable collection of locales
const locales*: array[Locale, DateTimeLocale] =
  [
    en_US: DefaultLocale,
    de_DE: DateTimeLocale(
        MMM:  ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez"],
        MMMM: ["Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"],
        ddd:  ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"],
        dddd: ["Montag", "Dienstag", "Mittwoch", "Donnerstag", "Freitag", "Samstag", "Sonntag"]
    ), # German locales for date representation
  ]

