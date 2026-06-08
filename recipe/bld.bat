cmake -DGDAL_CSHARP_ONLY=ON -DCSHARP_LIBRARY_VERSION=Net10.0 -DCSHARP_APPLICATION_VERSION=Net10.0  -S . -B ../build
if errorlevel 1 exit 1

cmake --build ../build --config Release -j 3 --target csharp_samples
if errorlevel 1 exit 1

copy swig\csharp\apps\GDALTest.cs %LIBRARY_PREFIX%\share\gdal
if errorlevel 1 exit 1

cd ..\build\swig\csharp

ctest -R "^csharp.*" -VV -C Release
if errorlevel 1 exit 1

copy /B Release\*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

@echo off
setlocal

powershell -NoProfile -Command ^
  "Compress-Archive -Path const,gdal,ogr,osr -DestinationPath csharp-source.zip -Force"

if errorlevel 1 exit /b 1

if not exist "%PREFIX%\share\gdal" (
    mkdir "%PREFIX%\share\gdal"
)

copy /Y csharp-source.zip "%PREFIX%\share\gdal\csharp-source.zip"
if errorlevel 1 exit /b 1
