cmake -DGDAL_CSHARP_ONLY=ON -S . -B ../build
if errorlevel 1 exit 1

cmake --build ../build --config Release -j 3 --target csharp_samples
if errorlevel 1 exit 1

xcopy /i swig\csharp\apps\GDALTest.cs  %LIBRARY_PREFIX%\share\gdal
if errorlevel 1 exit 1

cd ..\build\swig\csharp

ctest -R "^csharp.*" -VV -C Release
if errorlevel 1 exit 1

copy /B Release\*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

xcopy /B /i osgeo*.nupkg %LIBRARY_PREFIX%\share\gdal
if errorlevel 1 exit 1