dotnet new console
rm Program.cs
dotnet add package osgeo.GDAL -s %CONDA_PREFIX\Library\share\gdal
dotnet run