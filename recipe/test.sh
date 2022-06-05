cd $CONDA_PREFIX/share/gdal
dotnet new console
dotnet add reference osgeo.GDAL -s $CONDA_PREFIX/share/gdal
dotnet run