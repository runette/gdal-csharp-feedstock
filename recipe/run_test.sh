export DYLD_LIBRARY_PATH=$CONDA_PREFIX/lib
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib
dotnet new console
rm Program.cs
dotnet add package OSGeo.GDAL -s $CONDA_PREFIX/share/gdal
dotnet run