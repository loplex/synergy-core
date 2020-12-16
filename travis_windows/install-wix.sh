#!/bin/bash
set -ev

echo '### installing WiX prerequisite'
#choco install nuget.commandline
#nuget install WiX.Toolset
#choco install wixtoolset
powershell Install-WindowsFeature Net-Framework-Core
#choco install wixtoolset --version 3.11.1
choco install microsoft-build-tools
choco install visualstudio2015buildtools
cinst -y wixtoolset
