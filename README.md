# wmstatusd
Daemon to show status information in the bar of some Window Manager like dwm or nimdow


## Usage
The standard usecase for this porgram is to start it with default values and see the informations in the window managers bar:
```
$ wmstatusd
```
It is recommended to start this program as background process.


To show only a subset of the available modules or reorder them, the desired module names may be given to the command as a space-separated list to overwrite the default configuration:
```
$ wmstatusd date time battery
```
The modules currently available are:
 - `time`
 - `date`
 - `pkgs`   (currently requires an external script which fetches the update list)
 - `backlight`
 - `volume`
 - `cpu`    (currently only shows temperature, will be changed in the furture)
 - `battery`


There are some further command line options:
```
-h, --help        print help message
-n, --nocolors    disable colors
-c, --config=     use alternative config file
-d, --debug       redirect program output to stdout
```


## Installation
This program is written in the [Nim Programming Language](https://nim-lang.org) so a [Nim](https://github.com/nim-lang/Nim/)-Compiler is required.
The prefered installation method is using [choosenim](https://github.com/dom96/choosenim).
(Do not forget to add the nimble binary directory (usually: `~/.nimble/bin`) to your system path by appending `export PATH=$PATH:$HOME/.nimble/bin` to according configuration file like `~/.bashrc` or `~/.profile`.)

Clone the repository:
```
$ git clone https://github.com/Smintheus98/wmstatusd.git
$ cd wmstatusd
```

After installation of Nim use:
```
$ nimble install
```
to install the programs dependencies and compile and install the program afterwards.

The program will be installed to `$HOME/.nimble/bin`.
Make sure to include that directory into your system path.
For explicit instructions see beginning of this section.

For the configuration via the NimScript file it is currently required having a recent installation of the nim compiler on the system.
This requirement will probably be removed in a future release.


## Configuration
The program can be configured by a NimScript file placed at `$XDG_CONFIG_HOME/wmstatusd/wmstatusd.conf`. If `XDG_CONFIG_HOME` is not defined the program defaults to `~/.config/wmstatusd/wmstatusd.conf`.
If the file does not exist, the program installs a default file automatically.
The default configuration looks like this:
```
config main:
  taglist = @[time, date, pkgs, backlight, volume, cpu, battery]
  separator = "|"
  separatorColor = CWHITE
  padding = 1
  useColors = true
  savepower = false
```
An invalid configuration will prevent the program from starting.

Details:
 - taglist: List and order of modules to show.
 - separator: String of symbols put between the modules information strings.
 - separatorColor: Color of the separator. May be one of:
    CBLACK, CRED, CGREEN, CYELLOW, CBLUE, CMAGENTA, CCYAN, CWHITE, CRESET
 - padding: Number of spaces between information and separator. May be completely replaced by according separator-string.
 - useColors: Use colored mode.
 - savepower: Mode affecting the refresh-times so the program consumes less power.


## Todo v1.0.0:
I have decided to give this project of mine a rather extensive make over including the redesign of the software.
This may or may not include the configuration using NimScript which, while being quite usefull, feels like a pretty heavy dependency.
 - [ ] Rewrite
 - [ ] Proper code documentation and functionality tests
