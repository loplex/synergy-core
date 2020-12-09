#!/bin/bash
set -ev
echo "# $0:"
cd "$(dirname "$0")"

qt_installer_url='https://download.qt.io/archive/online_installers/3.2/qt-unified-windows-x86-3.2.3-online.exe'
qt_installer_path='/c/qt_installer/qt-unified-windows-x86-3.2.3-online.exe'

function qt_account() {
  echo '# setting Qt account login'
  qt_account_ini_path="${APPDATA}\\Qt\\qtaccount.ini"
  mkdir -p "$(dirname "$qt_account_ini_path")"
  ./qtaccount_ini_gen.sh > "$qt_account_ini_path"
}

function qt_installer() {
  if ! [[ -f "$qt_installer_path" ]]; then
    echo '# downloading Qt online installer'
    mkdir -p "$(dirname "$qt_installer_path")"
    wget --progress=dot:giga "$qt_installer_url" -O "$qt_installer_path"
  else
    echo '# using cached Qt online installer'
  fi
}

function qt_prefix() {
  if ! [[ -d "$CMAKE_PREFIX_PATH" ]]; then
    qt_account
    qt_installer
    echo '# installing Qt prerequisites using Qt online installer'
    "$qt_installer_path" -v --script './extract-qt.qs' \
      | grep -Ev "( Url is: |addDownloadable )"
  else
    echo '# installed Qt prerequisites cached'
  fi
}

function wix() {
  choco install nuget.commandline
  nuget install WiX.Toolset
}


qt_prefix
#wix
