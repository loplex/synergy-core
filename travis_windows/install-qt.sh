#!/bin/bash
set -ev

### mandatory "input" env. variables:
# QT_INSTALLER_PATH
# QT_INSTALL_DIR ( e.g. 'C:\Qt' )
# QT_INSTALL_MSVC_PACKAGE (e.g. 'qt.qt5.599.win64_msvc2015_64' )

### optional "input" env. variables:
# QT_INSTALL_LOG
# QT_INSTALL_ACCOUNT_LOGIN
# QT_INSTALL_ACCOUNT_PASSWORD

echo '### installing Qt prerequisites using Qt online installer'
mkdir -p "$QT_INSTALL_DIR"
export QT_INSTALL_PACKAGES="$QT_INSTALL_MSVC_PACKAGE"
cd "$(dirname "$(realpath "$0")")"
if [[ -n "$QT_INSTALL_LOG" ]]; then
  "$(realpath "$QT_INSTALLER_PATH")" -v --script 'install-qt.qs' &>"$QT_INSTALL_LOG"
else
  "$(realpath "$QT_INSTALLER_PATH")" -v --script 'install-qt.qs'
fi
