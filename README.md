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
 - time
 - date
 - pkgs
 - backlight
 - volume
 - cpu
 - battery

There are some further command line options:
```
  -h, --help        prints help message
  -n, --nocolors    disables colors. 
  -p, --padding=    set costume right padding between the 
                    information modules
  -r, --removeTag=  remove tags from module list to display
  -d, --debug       redirect program output to stdout
```
