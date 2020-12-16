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
choco install microsoft-build-tools --version=14.0.25420.1 --side-by-side
choco install visualcpp-build-tools --version 14.0.25420.1
find 'C:\' -name 'vs_buildtools*.exe' -print0 |xargs -0 ls -ld
which -a cinst
cinst -y wixtoolset
