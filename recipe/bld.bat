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

xcopy /B /i osgeo*.nupkg %LIBRARY_PREFIX%\share\gdal
if errorlevel 1 exit 1

xcopy /S /Y const "%PREFIX%\share\gdal\csharp"
if errorlevel 1 exit 1

xcopy /S /Y gdal "%PREFIX%\share\gdal\csharp"
if errorlevel 1 exit 1

xcopy /S /Y ogr "%PREFIX%\share\gdal\csharp"
if errorlevel 1 exit 1

xcopy /S /Y osr "%PREFIX%\share\gdal\csharp"
if errorlevel 1 exit 1
