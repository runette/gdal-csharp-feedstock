cmake -DGDAL_CSHARP_ONLY=ON -S . -B ../build
if errorlevel 1 exit 1

cmake --build ../build --config Release -j 3 --target csharp_samples
if errorlevel 1 exit 1

ctest -R “^csharp.*” 
if errorlevel 1 exit 1

tree .

mkdir  %LIBRARY_BIN%\gcs

copy /B *.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B apps\*.exe %LIBRARY_BIN%\gcs
if errorlevel 1 exit 1

copy /B apps\*.dll %LIBRARY_BIN%\gcs
if errorlevel 1 exit 1

copy /B apps\*csharp.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

copy /B apps\*.json %LIBRARY_BIN%\gcs
if errorlevel 1 exit 1

copy /B apps\*.pdb %LIBRARY_BIN%\gcs
if errorlevel 1 exit 1

copy /B apps\gdal_test.* %LIBRARY_BIN%
if errorlevel 1 exit 1

