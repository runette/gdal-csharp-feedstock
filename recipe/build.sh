
#!/bin/bash

set -ex # Abort on error.

# Force python bindings to not be built.
unset PYTHON

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export OPENSSL_ENABLE_SHA1_SIGNATURES=1

export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0

export PATH=$PATH:~/.dotnet

# Filter out -std=.* from CXXFLAGS as it disrupts checks for C++ language levels.
re='(.*[[:space:]])\-std\=[^[:space:]]*(.*)'
if [[ "${CXXFLAGS}" =~ $re ]]; then
    export CXXFLAGS="${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
fi

if [[ "${target_platform}" == "linux-64" ]]; then
for CSPROJ in $(find . -name "*.csproj"); do
    echo "Patching $CSPROJ"

    if ! grep -q "GenerateDocumentationFile" "$CSPROJ"; then
        sed -i '/<\/PropertyGroup>/ i\
    <GenerateDocumentationFile>true</GenerateDocumentationFile>\
    <NoWarn>$(NoWarn);1591</NoWarn>' "$CSPROJ"
    fi
done
fi

# export DYLD_LIBRARY_PATH=$PREFIX/lib:$DYLD_LIBRARY_PATH
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

cmake ${CMAKE_ARGS} -DGDAL_CSHARP_ONLY=ON -DCSHARP_LIBRARY_VERSION=Net10.0 -DCSHARP_APPLICATION_VERSION=Net10.0 -DBUILD_TESTING=ON "-DCMAKE_PREFIX_PATH=${CONDA_PREFIX}" -S . -B ../build
cmake --build ../build --config Release -j 3 --target csharp_samples

cp swig/csharp/apps/GDALTest.cs $PREFIX/share/gdal

cd ../build/swig/csharp

case "$target_platform" in
    linux-aarch64|osx-arm64)
        # no tests for ARM platforms
        ;;
    *)
        ctest -R "^csharp.*" -VV -C Release
        ;;
esac

#install libraries
cp *wrap.dylib $PREFIX/lib || :
cp *wrap.so $PREFIX/lib || :
cp osgeo*.nupkg $PREFIX/share/gdal
cp OSGeo*.nupkg $PREFIX/share/gdal

#create the docs
if [[ "${target_platform}" == "linux-64" ]]; then
    echo "Running DocFX on linux-64"

    # Ensure runtime can find GDAL
    export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

    DLL_DIR=$(find . -name "gdal_csharp.dll" -exec dirname {} \; | head -n 1)
    echo "Using DLL_DIR=$DLL_DIR"

    # Generate docfx config dynamically
    cat > docfx.json <<EOF
{
  "metadata": [
    {
      "src": [
        {
          "files": ["gdal_csharp.dll", "osr_csharp.dll", "ogr_csharp.dll", "gdalconst_csharp.dll"],
          "src": "$DLL_DIR"
        }
      ],
      "dest": "api"
    }
  ],
  "build": {
    "content": [
      { "files": ["api/**.yml"] },
      { "files": ["index.md"] }
    ],
    "globalMetadata": {
      "projectName": "GDAL C# Bindings",
      "namespaceLayout": "nested",
      "version": "${PKG_VERSION}"
    },
    "dest": "_site"
  }
}
EOF

    docfx metadata docfx.json
    docfx build docfx.json

# ---- DEPLOY STEP ----

    if [[ -z "${GH_PAGES_TOKEN}" ]]; then
        echo "ERROR: GH_PAGES_TOKEN is not set"
        exit 1
    fi

    DOCS_REPO="https://${GH_PAGES_TOKEN}@github.com/ViRGIS-Team/gdal-csharp-docs.git"

    git clone --depth 1 "$DOCS_REPO" docs-repo
    cd docs-repo

    # Switch to gh-pages (create if needed)
    git checkout gh-pages || git checkout --orphan gh-pages

    # Remove old content
    rm -rf *

    # Copy new site
    cp -r ../_site/* .

    # Optional: prevent Jekyll processing
    touch .nojekyll

    # Commit + push
    git config user.name "conda-forge bot"
    git config user.email "conda-forge@users.noreply.github.com"

    git add .
    git commit -m "Update docs from feedstock build ${BUILD_BUILDNUMBER}" || echo "No changes"
    git push origin gh-pages

    cd ..

else
    echo "Skipping DocFX (not linux-64: ${target_platform})"
fi
