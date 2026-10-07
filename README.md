# Tanat

High-quality caffeination.

## Install

```sh
brew install timdarcet/tap/tanat
brew services start tanat    # optional: menu bar icon at login
```

Update with `brew upgrade tanat`, remove with `brew services stop tanat && brew uninstall tanat`.

## Usage

```sh
tanat                # awake until Ctrl-C
tanat make build     # awake until the command exits
tanat --bar          # menu bar icon: left click toggles, right click quits
```

## Build from source

```sh
cc -O2 -fobjc-arc -framework Cocoa -framework IOKit -o ~/.local/bin/tanat tanat.m
```

Start the menu bar icon at login:

```sh
cp com.timdarcet.tanat.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.timdarcet.tanat.plist
```
