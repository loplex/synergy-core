#!/bin/bash
set -ev

echo "# $0:"
cd "$(dirname "$0")"

qt_installer_url='https://download.qt.io/archive/online_installers/3.2/qt-unified-windows-x86-3.2.3-online.exe'
qt_installer_path='/c/qt_installer/qt-unified-windows-x86-3.2.3-online.exe'
qt_account_ini_path="${APPDATA}/Qt/qtaccount.ini"
qt_installer_control_script="$(dirname "$0")/windows-install-qt.qs"
qt_account_login='lop.spm@seznam.cz'

### mandatory "input" env. variables:
# CMAKE_PREFIX_PATH ( e.g. 'C:\Qt\5.9.9\msvc2015_64' )
# either QT_ACCOUNT_PASSWORD or QT_ACCOUNT_TOKEN
# QT_INSTALL_DIR ( e.g. 'C:\Qt' )
# QT_INSTALL_PACKAGES (e.g. 'qt.qt5.599.win64_msvc2015_64' )

### optional "input" env. variables:
# QT_ACCOUNT_LOGIN ( overrides qt_account_login )

function qt_account_set() {
  echo '### setting Qt account login'
  mkdir -p "$(dirname "$qt_account_ini_path")"
  printf '%s\n' \
    '[QtAccount]' \
    "email=$qt_account_login" \
    "jwt=$QT_ACCOUNT_TOKEN" \
      > "$qt_account_ini_path"
}

function qt_online_installer_download() {
  if ! [[ -f "$qt_installer_path" ]]; then
    echo '### downloading Qt online installer'
    mkdir -p "$(dirname "$qt_installer_path")"
    wget --progress=dot:giga "$qt_installer_url" -O "$qt_installer_path"

  else
    echo '### using cached Qt online installer'
  fi
}

function qt_prefix_install() {
  if ! [[ -d "$CMAKE_PREFIX_PATH" ]]; then
    qt_account_set
    qt_online_installer_download

    echo '### installing Qt prerequisites using Qt online installer'
    mkdir -p "$(dirname "$CMAKE_PREFIX_PATH")"

    "$qt_installer_path" -v --script "$qt_installer_control_script" \
      | grep -Ev "( Url is: |addDownloadable | Done$)"

  else
    echo '### using cached installed Qt prerequisites'
  fi
}

function wix() {
  echo '### installing WiX prerequisite'
  choco install nuget.commandline
  nuget install WiX.Toolset
}

qt_prefix_install
wix
