cmake -DGDAL_CSHARP_ONLY=ON -S . -B ../build
if errorlevel 1 exit 1

cmake --build ../build --config Release -j 3
if errorlevel 1 exit 1

ctest --test-dir ../build -j 3 
if errorlevel 1 exit 1
