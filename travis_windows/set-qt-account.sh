#!/bin/bash
set -e

### mandatory "input" env. variables:
# QT_ACCOUNT_LOGIN
# QT_ACCOUNT_TOKEN

qt_account_ini_path="${APPDATA}/Qt/qtaccount.ini"

echo '### setting Qt account login'
mkdir -p "$(dirname "$qt_account_ini_path")"
printf '%s\n' '[QtAccount]' "email=$QT_ACCOUNT_LOGIN" "jwt=$QT_ACCOUNT_TOKEN" > "$qt_account_ini_path"
