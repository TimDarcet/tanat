# Tanat

High-quality caffeination.

```sh
cc -O2 -fobjc-arc -framework Cocoa -framework IOKit -o ~/.local/bin/tanat tanat.m

tanat                # awake until Ctrl-C
tanat make build     # awake until the command exits
tanat --bar          # menu bar icon: left click toggles, right click quits
```

Start the menu bar icon at login:

```sh
cp com.timdarcet.tanat.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.timdarcet.tanat.plist
```
