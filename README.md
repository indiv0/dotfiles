# M1 NixOS

This repository contains scripts for creating a NixOS ISO for use on an M1
Mac, along with the scripts to bootstrap a VM created from the ISO.

**NOTE**: This repo is nearly completely based on
[mitchellh/fusion-m1-514-repro](https://github.com/mitchellh/fusion-m1-514-repro)
so credit to Mitchell Hashimoto for pioneering NixOS on M1.

## Requirements

* Apple computer with an Apple M1 chip
* Parallels Desktop 17 for Mac
* Docker Desktop to build the NixOS aarch64 ISO

## Steps

**All of these steps must be run on an M1 Mac computer**. If you run it on an
Intel machine you will not end up with an aarch64 NixOS ISO.

1. `make nixos.iso` - This will create the NixOS ISO. If you want to recreate
   the ISO you must delete the old one. This will place the ISO in the
   current directory as `nixos.iso`.
2. Create a VM in Parallels (manually). I used the default settings.
3. Boot it up. You'll log in automatically as the `nixos` user. Become the
   root user and set the password to "root":
   ```shell
   $ sudo su
   $ passwd
   ```
4. Get the IP address, should be `10.211.something` from `ifconfig`.
5. **Optional:** Take a snapshot here if you want to try this multiple times.
6. Set `NIXADDR=<ip address of VM>` and run `make vm/bootstrap`. This will
   bootstrap your machine and automatically reboot the VM.
