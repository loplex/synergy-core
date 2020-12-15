#!/bin/bash
set -ev

### mandatory "input" env. variables:
# QT_INSTALLER_PATH

qt_installer_url='https://download.qt.io/archive/online_installers/3.2/qt-unified-windows-x86-3.2.3-online.exe'

echo '### downloading Qt online installer'
mkdir -p "$(dirname "$QT_INSTALLER_PATH")"
wget --progress=dot:giga "$qt_installer_url" -O "$QT_INSTALLER_PATH"
