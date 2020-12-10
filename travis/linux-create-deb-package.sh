#!/bin/bash
set -ev

echo "# $0:"

echo '# create debian/changelog from git history'
gbp dch --ignore-branch

echo '# make linux DEB package'
dpkg-buildpackage -us -uc
