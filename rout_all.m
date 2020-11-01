function rout_all(obj)
obj.basin
obj.paths.rout_result_dir;
obj.paths.vic_result_dir;

routinput=[obj.paths.io,'parameters/rout/rout_input.txt'];

vicout=[obj.paths.vic_result_dir,'standard/fluxes_'];
routoutput= [obj.paths.rout_result_dir,'standard/'] ;
rout_input(obj,vicout,routoutput);
system(['./bin/rout ',routinput,' &> ',obj.paths.rout_result_dir,'/rout_standard.txt']);
% system(['./bin/rout ',routinput,' &>  ./logs/rout_standard.txt']);


vicout=[obj.paths.vic_result_dir,'glacier/fluxes_'];
routoutput= [obj.paths.rout_result_dir,'glacier/'] ;
rout_input(obj,vicout,routoutput);
system(['./bin/rout ',routinput,' &> ',obj.paths.rout_result_dir,'/rout_glacier.txt']);
% system(['./bin/rout ',routinput,' &>  ./logs/rout_glacier.txt']);

vicout=[obj.paths.vic_result_dir,'snow/fluxes_'];
routoutput= [obj.paths.rout_result_dir,'snow/'] ;
rout_input(obj,vicout,routoutput);
system(['./bin/rout ',routinput,' &> ',obj.paths.rout_result_dir,'/rout_snow.txt']);
% system(['./bin/rout ',routinput,' &>  ./logs/rout_snow.txt']);

vicout=[obj.paths.vic_result_dir,'clean/fluxes_'];
routoutput= [obj.paths.rout_result_dir,'clean/'] ;
rout_input(obj,vicout,routoutput);
system(['./bin/rout ',routinput,' &> ',obj.paths.rout_result_dir,'/rout_clean.txt']);
% system(['./bin/rout ',routinput,' &>  ./logs/rout_clean.txt']);

vicout=[obj.paths.vic_result_dir,'debri/fluxes_'];
routoutput= [obj.paths.rout_result_dir,'debri/'] ;
rout_input(obj,vicout,routoutput);
system(['./bin/rout ',routinput,' &> ',obj.paths.rout_result_dir,'/rout_debri.txt']);
% system(['./bin/rout ',routinput,' &>  ./logs/rout_debri.txt']);

vicout=[obj.paths.vic_result_dir,'base/fluxes_'];
routoutput= [obj.paths.rout_result_dir,'base/'] ;
system(['mkdir -p ',routoutput])

rout_input(obj,vicout,routoutput);
system(['./bin/rout ',routinput,' &> ',obj.paths.rout_result_dir,'/rout_base.txt']);
% system(['./bin/rout ',routinput,' &>  ./logs/rout_clean.txt']);

vicout=[obj.paths.vic_result_dir,'base_s/fluxes_'];
routoutput= [obj.paths.rout_result_dir,'base_s/'] ;
system(['mkdir -p ',routoutput])
rout_input(obj,vicout,routoutput);
system(['./bin/rout ',routinput,' &> ',obj.paths.rout_result_dir,'/rout_base_s.txt']);
% system(['./bin/rout ',routinput,' &>  ./logs/rout_debri.txt']);
% 
end