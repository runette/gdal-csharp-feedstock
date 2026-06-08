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

mkdir "%PREFIX%\share\gdal\csharp\const"
if errorlevel 1 exit 1
mkdir "%PREFIX%\share\gdal\csharp\gdal"
if errorlevel 1 exit 1
mkdir "%PREFIX%\share\gdal\csharp\ogr"
if errorlevel 1 exit 1
mkdir "%PREFIX%\share\gdal\csharp\osr"
if errorlevel 1 exit 1

xcopy /s /e /i /y const "%PREFIX%\share\gdal\csharp\const"
if errorlevel 1 exit 1
xcopy /s /e /i /y gdal  "%PREFIX%\share\gdal\csharp\gdal"
if errorlevel 1 exit 1
xcopy /s /e /i /y ogr   "%PREFIX%\share\gdal\csharp\ogr"
if errorlevel 1 exit 1
xcopy /s /e /i /y osr   "%PREFIX%\share\gdal\csharp\osr"
if errorlevel 1 exit 1
