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
 - `pkgs`
 - `backlight`
 - `volume`
 - `cpu`
 - `battery`


There are some further command line options:
```
-h, --help        prints help message
-n, --nocolors    disables colors
-p, --padding=    set costume right padding between the
                  information modules
-r, --removeTag=  remove tags from module list to display
-d, --debug       redirect program output to stdout
```


## Installation
This program is written in the [Nim Programming Language](https://nim-lang.org) so a [Nim](https://github.com/nim-lang/Nim/)-Compiler is required.
The prefered installation method is using [choosenim](https://github.com/dom96/choosenim).
(Do not forget to add the nimble binary directory (usually: `~/.nimble/bin`) to your systems path by appending `export PATH=$PATH:$HOME/.nimble/bin` to according configuration file like `~/.bashrc` or `~/.profile`.)

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
  tagpadding = 1
  useColors = true
```
An invalid configuration will prevent the program from starting.


## Todo v1.0.0:
 - [X] Replace global writeback variables by using channels (ipc)
 - [X] Remove all system calls in favor of internal soluions
 - [X] Use NimScript configuration file
 - [X] Fix program to use arc garbage collector
 - [ ] Proper code documentation and functionality tests

Currently there are no further functional requirements.
After some time of testing and improved documentation the repository will be upgraded to version v1.0.0.
