#ncpdq  --cnk_plc=g3d --cnk_dmn lat,59 --cnk_dmn lon,139 --cnk_dmn day,1 --fl_fmt=netcdf4 --deflate=1 TerraClimate_tmax_1958.nc TerraClimate_tmax_1958_deflate.nc

for file in *.nc; do
ncpdq -O --deflate=1 $file $file
done


