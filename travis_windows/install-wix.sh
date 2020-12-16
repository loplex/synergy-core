#!/bin/bash
set -ev

echo '### installing WiX prerequisite'
#choco install nuget.commandline
#nuget install WiX.Toolset
#choco install wixtoolset
powershell Install-WindowsFeature Net-Framework-Core
#powershell Install-WindowsFeature Net-Framework
#choco install wixtoolset --version 3.11.1
#choco install microsoft-build-tools
#choco install visualstudio2015buildtools
choco install microsoft-build-tools --version=14.0.25420.1
which -a cinst
cinst -y wixtoolset
