dotnet new console
rm Program.cs
dotnet add package OSGeo.GDAL -s %CONDA_PREFIX%\Library\share\gdal
dotnet run