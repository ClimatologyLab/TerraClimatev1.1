% example script for extracting point location data from terraclimate using OpenDap in MATLAB
% author: Katherine Hegewisch (khegewisch@uidaho.edu)
%===================================================
%enter your terraclimate variables
myVar = 'tmin';

%enter your terraclimate OPeNDAP URL
%find this here: http://thredds.northwestknowledge.net:8080/thredds/terraclimate_aggregated.html
myURL = ['http://thredds.northwestknowledge.net:8080/thredds/dodsC/agg_terraclimate_',myVar,'_1950_CurrentYear_GLOBE.nc'];

% enter your point locations as lat/lon pairs in the following arrays
latList=[41 44 45 41]; %list of north latitudes for each point location
lonList=[-110 -100 -101 -95]; %list of East longitudes for each point location
NUM_POINTS = length(latList);

%enter your time start and time end
year_start = 1950;
month_start=1;
year_end = 2025;
month_end=12;
%===================================================
timebounds_start =datenum(year_start,month_start,1)-datenum(1900,1,1);
timebounds_end = datenum(year_end,month_end,1)-datenum(1900,1,1);
timebounds = [timebounds_start timebounds_end];
lat=ncread(myURL,'lat');
lon=ncread(myURL,'lon');

time=ncread(myURL,'time');
[Y,M,D]=datevec(time+datenum(1900,1,1));
ftimei=find(time>=timebounds(1) & time<=timebounds(2));
time = time(ftimei);
NUM_TIME= length(time);

myData = NaN(NUM_POINTS,NUM_TIME);
myLat = NaN(NUM_POINTS,1);
myLon = NaN(NUM_POINTS,1);
for i= 1:NUM_POINTS;

        [dist,flati]=min(abs(lat-latList(i)));
        [dist,floni]=min(abs(lon-lonList(i)));
        myLat(i)=lat(flati);
        myLon(i)=lon(floni);

        % to change variables, see list here: http://thredds.northwestknowledge.net:8080/thredds/terraclimate_aggregated.html
        %dimensions of the data should be:
        myData(i,:)=ncread(myURL,myVar,[floni(1) flati(1) ftimei(1)],[length(floni) length(flati) length(ftimei)],[1 1 1]);
end;

%downloaded data is in myData (NUM_POINTS, NUM_TIME) with the grid cell centers myLat, myLon
