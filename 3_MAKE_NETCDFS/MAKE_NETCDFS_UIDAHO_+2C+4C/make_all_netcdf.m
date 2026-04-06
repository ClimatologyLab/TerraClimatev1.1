disp['run this code on graupel (and not on santaana, zephyr, mono, diablo) as there is some problem with HDF5 libraries);]


addpath('/data/code/USER_CODE/KATHERINE/DATASETS/TERRACLIMATE/MAKE_NETCDFS_UIDAHO');
parpool(10);

%c = parcluster('local2')
%c.NumWorkers = 12
%matlabpool open local2 12
SCENARIOS = {'2C';'4C';'cf'};
VAR_NAME_IN_FILE = {'pet';'ppt';'srad';'tmax';'tmin';'vap';'ws';'def';'aet';'q';'soil';'swe';'PDSI';'vpd'};
years = 1950:2025;
for scennum = 1:length(SCENARIOS);
	scenario = char(SCENARIOS{scennum});
	for varnum=1:length(VAR_NAME_IN_FILE);
		varname=char(VAR_NAME_IN_FILE{varnum});
		varname
		parfor year=years;
			make_netcdf_terraclimate_integer(varname,year,scenario);
		end;
	end;
end;

%matlabpool close;

%this part needs to be done separately to fix metadata of netcdf files!!!

%on the newer machines, we will have to run the bash script to fix the metadata by itself outside of matlab: ... there's issues with text ( and ) here:
%for varnum = 1:length(VAR_NAME_IN_FILE);
%varname = char(VAR_NAME_IN_FILE{varnum});
%	for year = years;
%		status=system(['./terraclimate_metdata.sh ',num2str(year),' ',varname]);
%		status=system(['/data/code/PROJECTS/TERRACLIMATE/MAKE_NETCDFS_UIDAHO/terraclimate_metdata.sh ',num2str(year),' ',varname]);
%	end;
end;
%at the commande line, execute





