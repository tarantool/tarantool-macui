# Intro


# Building from source

Install xcode 

``` bash
xcode-select --install
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
/usr/bin/xcodebuild -target tarantoolui -configuration Release
```

Run
``` bash
open build/Release/tarantoolui.app
```

# Use
