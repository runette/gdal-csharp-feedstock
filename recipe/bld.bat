Rem Run a separate PowerShell process because the script calls exit, so it will end the current PowerShell session.
powershell -NoProfile -ExecutionPolicy unrestricted -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; &([scriptblock]::Create((Invoke-WebRequest -UseBasicParsing 'https://dot.net/v1/dotnet-install.ps1'))) -InstallDir 'C:/Program Files/dotnet' -Version latest"
Rem if errorlevel 1 exit 1

cmake -DGDAL_CSHARP_ONLY=ON -DCSHARP_LIBRARY_VERSION=Net6.0 -DCSHARP_APPLICATION_VERSION=Net6.0 -S . -B ../build
if errorlevel 1 exit 1

cmake --build ../build --config Release -j 3 --target csharp_samples
if errorlevel 1 exit 1

cd ..\build\swig\csharp


ctest -R "^csharp.*" -VV -C Release
if errorlevel 1 exit 1

copy /B Release\*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

xcopy /B /i osgeo*.nupkg %LIBRARY_PREFIX%\share\gdal
if errorlevel 1 exit 1