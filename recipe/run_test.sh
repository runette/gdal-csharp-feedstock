export LD_LIBRARY_PATH=$CONDA_PREFIX/lib
echo $LD_LIBRARY_PATH
dotnet new console
rm Program.cs
dotnet add package OSGeo.GDAL -s $CONDA_PREFIX/share/gdal
dotnet run