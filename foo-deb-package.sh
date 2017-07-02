#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## Simple DEB packaging step by step (thanks https://ubuntuforums.org/showthread.php?t=910717)

# Standard Debian notation: <project>_<major version>.<minor version>-<package revision>
PRJ_NAME="hellopackage_1.0-2"

mkdir -p $PRJ_NAME/usr/local/bin
cat >$PRJ_NAME/usr/local/bin/hellopackage<< EOF
#!/usr/bin/env bash
echo "Hello Package!"
EOF

mkdir -p $PRJ_NAME/DEBIAN/
cat >$PRJ_NAME/DEBIAN/control<< EOF
Package: hellopackage
Version: 1.0-2
Section: base
Priority: optional
Architecture: amd64
Depends: 
Maintainer: Carlo Lobrano <c.lobrano@gmail.com>
Description: Hello Package
 I really hate "Hello World", my first one was in java and I called it
 hello java, so...
EOF

tree $PRJ_NAME
dpkg-deb --build $PRJ_NAME
apt install -s ./$PRJ_NAME.deb
