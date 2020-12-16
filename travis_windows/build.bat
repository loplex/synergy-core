echo HUUU
echo on
cmake -G "Visual Studio 14 2015 Win64" -DCMAKE_BUILD_TYPE=Debug ..
echo AHOJ
"C:\Program Files (x86)\MSBuild\14.0\Bin\amd64\MSBuild.exe" "synergy-core.sln" /verbosity:diag
echo AHOJKY
