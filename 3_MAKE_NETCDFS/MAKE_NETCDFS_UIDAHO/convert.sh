#station_influence here
for file in *_tmax_*.nc; do
        #ncap2 -4 -O -v -s 'tmax=short(tmax);crs=short(crs)' $file $file
        #ncatted -a missing_value,tmax,m,short,-32767 $file
        #ncatted -a _FillValue,tmax,m,short,-32767 $file
        ncatted -a _Unsigned,tmax,m,c,'false' $file
done
