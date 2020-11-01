function rout_input(obj,vicout,routout)
%period routinput,vicout,routoutput,obj.basin,obj.basin_parameters.run_period
% 1 for cali
% 2 for testing
% 3 for full




fileout=[obj.paths.io,'parameters/rout/rout_input.txt'];
run_period=obj.basin_parameters.run_period;
filein='/home/vikram/VIC/VIC_Himalayas/parameters/rout/rout_inputo.txt';

vic_out_folder=vicout;%'/home/vikram/VIC/VIC_Himalayas/results/vic/standard/fluxes_';
rout_out_folder=routout;%'/home/vikram/VIC/VIC_Himalayas/results/rout/standard/';

fraction_file=[obj.paths.io,'parameters/rout/area_fraction.txt'];
flow_direction_file=[obj.paths.io,'parameters/rout/flow_direction.txt'];
station_file=[obj.paths.io,'parameters/rout/station_location.txt'];


rout_period=[num2str(run_period(1)),' 01 ',num2str(run_period(2)),' 12\n',...
    num2str(run_period(1)),' 01 ',num2str(run_period(2)),' 12'];



fid = fopen(filein,'r');
fido = fopen(fileout,'w');
count=0;

while ~feof(fid)
    count=count+1;
    
    if count==3
        tline = fgetl(fid);
        tline=flow_direction_file;
        fprintf(fido,tline);
        fprintf(fido,'\n');
    elseif count==15
        tline = fgetl(fid);
        tline=fraction_file;
        fprintf(fido,tline);
        fprintf(fido,'\n');
    elseif count==17
        tline = fgetl(fid);
        tline=station_file;
        fprintf(fido,tline);
        fprintf(fido,'\n');
    elseif count==19
        tline = fgetl(fid);
        tline=vic_out_folder;
        fprintf(fido,tline);
        fprintf(fido,'\n');
    elseif count==22
        tline = fgetl(fid);
        tline=rout_out_folder;
        fprintf(fido,tline);
        fprintf(fido,'\n');
    elseif count==24
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline=rout_period;
        fprintf(fido,tline);
        fprintf(fido,'\n');
    else
        tline = fgetl(fid);
        fprintf(fido,tline);
        fprintf(fido,'\n');
    end
end
fclose(fid);
fclose(fido);


end
