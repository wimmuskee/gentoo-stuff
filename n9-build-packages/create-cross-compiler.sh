#!/bin/bash
target="armv7a-hardfloat-linux-gnueabi"
profile_dir="/usr/portage/profiles/default/linux/arm/13.0/armv7a"

crossdev -v -S --libc "=2.10.1-r2" --ov-libc /home/wim/code/gentoo-stuff/n9-build-packages/overlay --ov-output /usr/portage -t ${target}

echo "Creating better make.profile"
cd /usr/armv7a-hardfloat-linux-gnueabi/etc/portage/
rm make.profile
if [ -d ${profile_dir} ]; then
	ln -s ${profile_dir} make.profile
else
	echo "target profile dir does not exist: ${profile_dir}"
fi

echo "Setting make.conf to accept only stable"
sed -i s/ACCEPT_KEYWORDS=\"arm\ ~arm\"/ACCEPT_KEYWORDS=\"arm\"/ make.conf

echo "Setting up a package.use file"
if [ -d /etc/portage/package.use ]; then
	touch "/etc/portage/package.use/${target}"
	ln -s "/etc/portage/package.use/${target}" package.use
else
	echo "package.use not a dir, not able to create a ${target} package.use file"
fi
