# Undergrowth Utility Library

Copyright (C) 2015 Peter Brett

"undergrowth" is a utility library for programs that are written in
pure [LiveCode Builder](https://github.com/runrev/livecode).  It
provides:

* Logging
* Callback dispatch
* A simple main loop implementation

It is currently woefully incomplete and is expected to work only on
x86-64 Linux, if at all.

## Installation

````shell
# Check out source code
git clone --recursive https://github.com/runrev/livecode
git clone https://github.com/peter-b/undergrowth

# Build LiveCode Builder toolchain
cd livecode
make config
cd build-linux-x86_64/livecode
make lc-compile lc-run

# Build Undergrowth and run test suite
cd ../../../undergrowth
make
make check
````

## Using undergrowth in your programs

You **cannot** use undergrowth when creating a LiveCode extension (a
widget to be included in a LiveCode stack or a library to add handlers
to the script message path).  It does not know anything about
LiveCode's own main loop and it will generally screw everything up.

As a hint, undergrowth's module names studiously fail to comply with
the recommended naming convention enforced by LiveCode.

1. Add `--modulepath /path/to/undergrowth/_build` to your `lc-compile`
   command line.

2. Add `use _.<module>` to your LiveCode Builder source code

3. Add `--load /path/to/undergrowth/_build/<something>.lcm` when
   running your program with `lc-run`.

## Getting help

Please use the [issue tracker](https://github.com/peter-b/undergrowth).

## License

Undergrowth is freely distributable under the GNU Public License (GPL)
version 3.0 or (at your option) any later version.  See the
[LICENSE](LICENSE) file for the full text of the license.

The library and associated files are:

  Copyright (C) 2015 Peter TB Brett
