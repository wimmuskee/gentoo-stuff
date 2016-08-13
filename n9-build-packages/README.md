# Creating packages for the N9 using Gentoo's crossdev
What to do when you have a Nokia N9 that cannot update anymore from the Nokia Maemo repository, but still want to install some packages on. Surely there are simpler ways to do this, buying a new phone for instance, but this exercise seemed interesting.

This part of the repository contains an explanation of the steps I used, as well as some of the files, patches and scripts I made for this.

## The target
First we need to find out the architecture of the N9, but also the glibc version we need to use to make compatible packages. For both we need to log in to the phone and be able to ssh some stuff.
1. Open Terminal on the N9
2. Log in using *devel-su* and password *rootme*.
3. Set a password for the default user if you haven't already.
4. Connect to a local network, find out the ip using *ip a*, and connect using SSH with the user account.

Now you can easily view the processor architecture (armv7a), but also copy an executable to a computer which has *file* installed, in order to look up the required glibc version.
```
$ scp user@192.168.0.22:/bin/cp .
$ file -b cp
ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.3, stripped
```
And on the N9, look up where the lib links to.
```
$ readlink -f /lib/ld-linux.so.3
/lib/ld-2.10.1.so
```

## Prepare the Crossdev
We can instruct crossdev to build a cross compiler with our specific glibc version, but we first need to actually get that version from Gentoo's ebuild history and put it in a separate overlay where crossdev can find and use it later.

### Getting the ebuild
We can get the ebuild from the [Gentoo Sources](https://sources.gentoo.org) website, and the specific glibc ebuild files from your local Portage tree or the [Gentoo Historical Git repo](https://gitweb.gentoo.org/repo/gentoo/historical.git/tree/sys-libs/glibc/files).
I have added both to this repo (mostly for my own convenience for when I have go through this again).

Set up a local overlay for this ebuild for crossdev to use, following the [Gentoo Local Overlay for Crossdev](https://wiki.gentoo.org/wiki/Overlay/Local_overlay#Crossdev) document. In this readme, I set it up in */home/wim/code/gentoo-stuff/n9-build-packages/overlay*, but you can set it up anywhere you like.

### Patching the ebuild
When the glibc-2.10.1-r1 was made, there were no make versions above 3, so the default install will fail because it's configure.in only has a check for those.
We need to patch the configure.in and expand the regular expression for it. Also, the *.in* is deprecated as extension, so we are renaming this to configure.ac before rerunning the autoconf.
The resulting r2 ebuild is also available in the repository overlay.

## Make the cross compile environment
The resulting crossdev command builds the target, and specifies the exact glibc version to build, as well as specify the overlay where it can be found.
Apparently, when using overlays, the resulting overlay reference definition is saved somewhere as a sort of summary. Specifying the *--ov-output* is needed, so it won't pick a random overlay to add this. In the command below, I let it write to the /usr/portage.
```
# crossdev -v -S --libc "=2.10.1-r2" --ov-libc /home/wim/code/gentoo-stuff/n9-build-packages/overlay --ov-output /usr/portage -t armv7a-hardfloat-linux-gnueabi
```
When crossdev has finished, you need to specify a better *make.profile*, since the default is too generic and won't work. Also, removing the ~arm from the *make.conf* ACCEPT_KEYWORDS is recommended. When building packages, you can also set up a specific package.use file for the target environment on the host.
```
# cd /usr/armv7a-hardfloat-linux-gnueabi/etc/portage/
# rm make.profile
# ln -s /usr/portage/profiles/default/linux/arm/13.0/armv7a make.profile
# sed -i s/ACCEPT_KEYWORDS=\"arm\ ~arm\"/ACCEPT_KEYWORDS=\"arm\"/ make.conf
# ln -s /etc/portage/package.use/armv7a-hardfloat-linux-gnueabi package.use
```

## Create a package
With the cross compiler ready, we can make packages. For now I will present a simple example with only 1 binary, *telnet*. We basically emerge the package and the dependencies, and copy the required stuff over to the N9.
We also have to symlink the dynamic linker reference from the cross compile environment in the N9 environment.
```
# armv7a-hardfloat-linux-gnueabi-emerge telnet-bsd
# scp /usr/armv7a-hardfloat-linux-gnueabi/usr/bin/telnet user@192.168.0.22:.
# file -b /usr/armv7a-hardfloat-linux-gnueabi/usr/bin/telnet
ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, for GNU/Linux 2.6.16, stripped
```
And on the N9
```
# cd /lib
# ln -s ld-2.10.1.so ld-linux-armhf.so.3
# cp /home/user/telnet /usr/bin/.
```

I also added *nano* to the N9 using a similar approach. That was a bit more work, since I had to also copy the required ncurses lib files to the N9 as well. Copying or unpacking is not trivial, since there is only a BusyBox tar available.

## References
- [Gentoo Embedded Handbook](https://wiki.gentoo.org/wiki/Embedded_Handbook)
- [Gentoo Local Overlay for Crossdev](https://wiki.gentoo.org/wiki/Overlay/Local_overlay#Crossdev)
