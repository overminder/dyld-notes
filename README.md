# NOTES ON DYLD

OSX's `dyld` is a bit different from Linux's `ld`. The concepts are similar
though.

## tl;dr

Either put your shared libraries in `$(HOME)/lib:/usr/local/lib:/lib:/usr/lib`,
or use `@executable_path / @rpath / @loader_path` to specify custom library
loading paths in your executables.

## What happened at the runtime

Mach-O executables and shared libraries contain `LC_LOAD_DYLIB` entries
that point to the shared libraries that will be loaded in the run time. The
entries are pwd-relative rather than executable-path-relative. That is, if
you run the executable in another directory, things will not work.

Therefore, we should almost always use absolute paths to specify the
libraries. To ease that, `dyld` provides several special variables that will
be expanded in the search path: `@executable_path, @rpath` and `@loader_path`.

- `@rpath` for an executable or a shared library can be added using
  `install_name_tool`

  + Note that the loadee will inherit the loader's `@rpath`.

- `@executable_path` is the basedir for the executable binary

  + The same as `$ORIGIN` on Linux.

- `@loader_path` is the basedir for the loader (it could be either an
  executable, which in this case is the same as the `@executable_path`,
  or another shared library).

### `DYLD_LIBRARY_PATH` and `DYLD_FALLBACK_LIBRARY_PATH`.

Fortunately, they work the same as the `LD_LIBRARY_PATH` in Linux. By default,
`DYLD_FALLBACK_LIBRARY_PATH` is `$(HOME)/lib:/usr/local/lib:/lib:/usr/lib`

Libraries in those paths don't need to have the executable's `LC_LOAD_DYLIB`
entries match their full paths - only the file names are needed to match.

## Compile-time linking

A Mach-O shared library has a `LC_ID_DYLIB` entry to specify the location
that this file will be installed to (so called install name).
Linux systems don't have any counterpart for that.

`LC_ID_DYLIB` on its own does nothing. It's used by the loader in the link
time. When linking the object files and the shared libraries into a binary
executable, the `LC_ID_DYLIB` entries for the libraries will be copied
into `LC_LOAD_DYLIB` entries in the executable.

## install_name_tool

It can be used to change the install names (`LC_ID_DYLIB`) of
the shared libraries, and the rpaths of the executables.

## DEMO

See Makefile for a demonstration of using @rpath, @executable_path and
@loader_path.

