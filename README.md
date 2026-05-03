# Futhark Fighter!
* Spell FUTHARK by shooting the runes flying at your ship to score and level up (represented by the L: value)!
* Spelling FUTHARK powers up the ship, making it fire and shoot faster.
* Enemies spawn and move faster as the game goes on (represented by the D: value)

# Controls:
* WASD/Gamepad Stick/DPAD  = movement
* Space/XBox A/PS X = fire
* Esc/XBox B/PS O = restart on game over

# Building:
Requires latest [Odin](https://odin-lang.org) compiler.

## Windows:
* `.\build.ps1 debug` - makes a debug desktop build
* `.\build.ps1 release` - makes a release desktop build
* `.\build.ps1 web` - makes a web release build (in src/bin folder)

## Linux
* `sh build.sh debug` - makes a debug desktop build
* `sh build.sh release` - makes a release desktop build
* `sh build.sh web` - makes a web release build (in src/bin folder)
