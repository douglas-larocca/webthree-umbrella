Development build container
---

This will configure and build a container that sets up a build environment
(Ubuntu 14.04).

# Building

Running `make` will call `bootstrap.sh` which generates a Dockerfile
in the current directory. **If you do not have an ATI-based graphics card 
you should unset the default `GFX_DRIVER=fglrx` option.** If you don't care
to run the GUI apps, just unset `GFX_DRIVER`. Everything should build normally
and you'll be able to use `solc` and friends as usual. Edit `bootstrap.sh` first,
then `Makefile`.

## `bootstrap.sh`

Adjust the following options in `bootstrap.sh` to fit your host system:

- `GFX_DRIVER` this should be set to the name of the Ubuntu package that
  provides graphics drivers for the host. ATI/Radeon cards will likely
  work with `GFX_DRIVER=fglrx`.
- By default, the number of processors to use for the `webthree-umbrella`
  should "just work" but you may adjust this to fit your configuration.
- The current user is assumed when mapping the X11 socket to the container.
  This will work in most situations. If you need to, change `UID`, `GID`, 
  and `USER` to suit your needs.

## `Makefile`

The Makefile is deliberately very simple and can be called to generate
the Dockerfile then build the container. There is one option to adjust:

- `IMAGE` determines what the name of the docker image will be. By default
  it is `ethereum-dev`. Change this if you need to avoid name conflicts with
  existing containers.

Running `make` will then generate the Dockerfile and build the container.

# Running

In order to run GUI applications the container needs to be run with the `--privileged`
option set and should have the system's GPU device mapped with `+rw` permissions.

The following example is provided in `run.sh`. This maps the X11-socket but you may
also use other options such as `vnc`.

```shell
docker run -it --privileged --rm \
    -e DISPLAY=$DISPLAY \
    -v /dev/ati/card0:/dev/ati/card0:rw \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    "$@"
```

If you do not plan to use the GUI apps the privileged options and mappings are
unnecessary.
