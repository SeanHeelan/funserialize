# funserialize
Scripts and auxiliary files for fuzzing PHP's unserialize function. See
https://sean.heelan.io/2017/08/12/fuzzing-phps-unserialize-function/ for
details.

## Dependencies

GNU screen

clang (optional)

## Usage

`get.sh` retrieves the source for PHP and afl.

`build.sh` builds both PHP and afl. If you have `clang` available then
`afl-clang-fast` will also be built.

`fuzz.sh` starts a master afl instance and multiple slaves inside a GNU screen
instance with the session name `fuzz`.

A normal session might look as follows:

```
./get.sh

<...>

./build.sh

<...>

./fuzz.sh output_dir 3

<...>
```

The final command will start a master afl instance and 3 slaves, with
`output_dir` used as the top level output directory for afl. You can run `screen
-r fuzz` to attach to the screen instance and view the progress of the fuzzing
session.
