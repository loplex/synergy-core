echo on
cmake -G "Visual Studio 14 2015 Win64" -DCMAKE_BUILD_TYPE=Debug ..
"/c/Program Files (x86)/MSBuild/14.0/Bin/amd64/MSBuild.exe" synergy-core.sln /p:Platform="x64" /p:Configuration=Debug /m /verbosity:diag
"/c/Program Files (x86)/MSBuild/14.0/Bin/amd64/MSBuild.exe" synergy-core.sln /p:Platform="x86" /p:Configuration=Debug /m /verbosity:diag
