# Intro

![logo](https://raw.githubusercontent.com/tarantool/tarantool-macui/master/tnt-macui.png)


Simple Graphical User Interface for Tarantool Database for MacOSX

# Building from source

Install xcode 

``` bash
xcode-select --install
```

Git clone 

``` bash
git clone git@github.com:tarantool/tarantool-macui.git
cd tarantool-macui
git submodule update --init --recursive 
```

Install brew

``` bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Install cmake

``` bash
brew install cmake
```

Use xcode for building app bundle

``` bash
/usr/bin/xcodebuild -target tarantool-macui -configuration Release
```

Run
``` bash
open build/Release/tarantool-macui.app
```
