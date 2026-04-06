% example script for subsetting terraclimate using OpenDap
% enter your bounding lat/lon for data extraction
latbounds=[41 44];
lonbounds=[75 80];
%enter your time start and time end
year_start = 1950;
month_start=1;
year_end = 2025;
month_end=12;

timebounds_start =datenum(year_start,month_start,1)-datenum(1900,1,1); 
timebounds_end = datenum(year_end,month_end,1)-datenum(1900,1,1); 
timebounds = [timebounds_start timebounds_end];
lat=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_terraclimate_aet_1950_CurrentYear_GLOBE.nc','lat');
lon=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_terraclimate_aet_1950_CurrentYear_GLOBE.nc','lon');
flati=find(lat>=latbounds(1) & lat<=latbounds(2));
floni=find(lon>=lonbounds(1) & lon<=lonbounds(2));

lat=lat(flati);
lon=lon(floni);

time=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_terraclimate_aet_1950_CurrentYear_GLOBE.nc','time');
[Y,M,D]=datevec(time+datenum(1900,1,1)); 
ftimei=find(time>=timebounds(1) & time<=timebounds(2));
time = time(ftimei);


% to change variables, see list here: http://thredds.northwestknowledge.net:8080/thredds/terraclimate_aggregated.html

aet=ncread('http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_terraclimate_aet_1950_CurrentYear_GLOBE.nc','aet',[floni(1) flati(1) ftimei(1)],[length(floni) length(flati) length(ftimei)],[1 1 1]);
