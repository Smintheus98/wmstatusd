# wmstatusd
Daemon to show status information in the bar of some Window Manager like dwm or nimdow

## Usage
The standard usecase for this porgram is to start it with default values and see the informations in the windowmanagers bar:
```
$ wmstatusd &
```

To show only a subset of the available modules or reorder them the desired module names may be given to the command as a space-separated list:
```
$ wmstatusd date time battery &
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
  -n, --nocolors    disables colors. 
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
