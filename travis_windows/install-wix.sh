#!/bin/bash
set -ev

echo '### installing WiX prerequisite'
#choco install nuget.commandline
#nuget install WiX.Toolset
choco install wixtoolset
