disp['run this code on graupel (and not on santaana, zephyr, mono, diablo) as there is some problem with HDF5 libraries);]


addpath('/data/code/PROJECTS/TERRACLIMATE/MAKE_NETCDFS/MAKE_NETCDFS_UIDAHO/');

%c = parcluster('local2')
%c.NumWorkers = 12
%matlabpool open local2 12

VAR_NAME_IN_FILE = {'pet';'ppt';'srad';'tmax';'tmin';'vap';'ws';'def';'aet';'q';'soil';'swe';'PDSI';'vpd'};
%years =1958:2022;
%years =2023;
years =2025;
for varnum=1:length(VAR_NAME_IN_FILE);
 	varname=char(VAR_NAME_IN_FILE{varnum});
	varname
	parfor year=years;
		make_dailynetcdf_terraclimate_integer(varname,year);
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





