
#!/bin/bash

set -ex # Abort on error.

# Force python bindings to not be built.
unset PYTHON

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0

export PATH=$PATH:~/.dotnet

# Filter out -std=.* from CXXFLAGS as it disrupts checks for C++ language levels.
re='(.*[[:space:]])\-std\=[^[:space:]]*(.*)'
if [[ "${CXXFLAGS}" =~ $re ]]; then
    export CXXFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi

# export DYLD_LIBRARY_PATH=$PREFIX/lib:$DYLD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

cmake ${CMAKE_ARGS} -DGDAL_CSHARP_ONLY=ON -DCSHARP_LIBRARY_VERSION=Net10.0 -DCSHARP_APPLICATION_VERSION=Net10.0 -DBUILD_TESTING=ON "-DCMAKE_PREFIX_PATH=${CONDA_PREFIX}" -S . -B ../build
cmake --build ../build --config Release -j 3 --target csharp_samples

cp swig/csharp/apps/GDALTest.cs $PREFIX/share/gdal

cd ../build/swig/csharp

ctest -R "^csharp.*" -VV -C Release

#install libraries
cp *wrap.dylib $PREFIX/lib || :
cp *wrap.so $PREFIX/lib || :
cp osgeo*.nupkg $PREFIX/share/gdal
cp OSGeo*.nupkg $PREFIX/share/gdal
