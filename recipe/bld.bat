cmake -DGDAL_CSHARP_ONLY=ON -S . -B ../build
if errorlevel 1 exit 1

cmake --build ../build --config Release -j 3 --target csharp_samples
if errorlevel 1 exit 1

ctest -R "^csharp.*" -VV
if errorlevel 1 exit 1

cd ..\build\csharp\swig

copy /B Release\*.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B GDALTest\*.* %LIBRARY_BIN%
if errorlevel 1 exit 1
