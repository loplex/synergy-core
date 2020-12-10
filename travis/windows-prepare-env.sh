#!/bin/bash
set -e
set -v

echo "# $0:"
cd "$(dirname "$0")"

pwd

qt_installer_url='https://download.qt.io/archive/online_installers/3.2/qt-unified-windows-x86-3.2.3-online.exe'
qt_installer_path='/c/qt_installer/qt-unified-windows-x86-3.2.3-online.exe'
qt_account_ini_path="${APPDATA}/Qt/qtaccount.ini"
qt_installer_control_script='./extract-qt.qs'

env

function qt_account_set() {
  echo '# setting Qt account login'
  mkdir -p "$(dirname "$qt_account_ini_path")"
  ./qtaccount_ini_gen.sh >"$qt_account_ini_path"
}

function qt_online_installer_download() {
  if ! [[ -f "$qt_installer_path" ]]; then
    echo '# downloading Qt online installer'
    mkdir -p "$(dirname "$qt_installer_path")"
    wget --progress=dot:giga "$qt_installer_url" -O "$qt_installer_path"
  else
    echo '# using cached Qt online installer'
  fi
}

function qt_prefix_install() {
  if ! [[ -d "$CMAKE_PREFIX_PATH" ]]; then
    qt_account_set
    qt_online_installer_download
    echo '# installing Qt prerequisites using Qt online installer'
    "$qt_installer_path" -v --script "$qt_installer_control_script"
    #| grep -Ev "( Url is: |addDownloadable )"
  else
    echo '# using cached installed Qt prerequisites'
  fi
}

function wix() {
  choco install nuget.commandline
  nuget install WiX.Toolset
}

qt_prefix_install
#wix
