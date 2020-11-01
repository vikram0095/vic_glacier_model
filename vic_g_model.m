classdef vic_g_model
    %VIC_G_MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        basin_parameters
        baseflow_sep

        %years_observed, testing_period, station_name, river_name,
        %Q_observed, calibration_period
        %load(['./mat/observed_discharge/basin_',num2str(basin),'_Q_observed.mat']);
        %    Mask=dlmread(['./mat/mask_basin_',num2str(basin),'.txt']);
        paths
        %             soil_file
        %             io
        %             rout_result_dir
        parameters
        %              obj.parameters.binf,Ds,Ds_MAX,Ws,d2,d3,
        basin
        forcing
        run_vic_in_parallel
        IndexMatrix
        p
        t
        plot_obs
        data_plots
    end
    
    methods
        function obj = vic_g_model(basin_parameters,forcing,paths,parameters,run_params)
          obj.plot_obs=0;
            obj.IndexMatrix=load('./mat/IndexMatrix.mat') ;
            obj.basin_parameters=basin_parameters;
            obj.paths.io=paths.io;
            obj.forcing=forcing;
            obj.parameters=parameters;
            obj.basin=obj.basin_parameters.basin;
            obj.p=run_params(1);
            obj.t=run_params(2);
            
            obj.run_vic_in_parallel=1;
            obj.baseflow_sep=1;
            
            %Defining constatnts
            obj.parameters.Rexp=0.2;
            
            obj.paths.vic_forcing_file=[forcing.path,'forcing_'];
            obj.paths.tas_forcing_file=[forcing.path,'tas_'];
            
            obj.paths.vic_result_dir=[paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/'];
            obj.paths.rout_result_dir=[paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/rout/'];
            obj.paths.plot_result_dir=[paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/plots/'];
            
            
            
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/standard/']);
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/glacier/']);
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/clean/']);
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/debri/']) ;
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/glacier_states/']);
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/snow/']);
            
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/rout/standard/']);
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/rout/glacier/']);
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/rout/clean/']);
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/rout/debri/']) ;
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/rout/snow/']);
            
            system([  'mkdir -p ',paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/plots/']);
            
            
        end
        
        function run_vic(obj)
            Emode=1;
            obj.parameters.snow_rough=0.0001;
            min_rain_temp=-0.5;
            max_snow_temp=0.5;
            output=obj.paths.io;
            
            if obj.run_vic_in_parallel==1
                
                MaskPar(1)={obj.basin_parameters.Mask(1:int32(end/4))};
                MaskPar(2)={obj.basin_parameters.Mask(int32(end/4)+1:int32(end/2))};
                MaskPar(3)={obj.basin_parameters.Mask(int32(end/2)+1:int32(3*end/4))};
                MaskPar(4)={obj.basin_parameters.Mask(int32(3*end/4)+1:end)};
                
                for par=1:4
                    obj.paths.soil_file=[output,'/parameters/vic/soil_param',num2str(par),'.txt'];
                    gparam([output,'/parameters/vic/gparam',num2str(par),'.txt'],...
                        [obj.paths.vic_result_dir,'/standard/'],Emode,obj.basin_parameters.run_period,obj.paths.soil_file,obj.paths.vic_forcing_file,obj.forcing.start_year,max_snow_temp,min_rain_temp);
                    soil_param(  obj.paths.soil_file,cell2mat(MaskPar(par)),obj.parameters.binf,obj.parameters.Ds,...
                        obj.parameters.Ds_MAX,obj.parameters.Ws,obj.parameters.d2,obj.parameters.d3,obj.parameters.snow_rough);
                end
                
                job1 = batch(['!./bin/vicNl -g ',output,'/parameters/vic/gparam1.txt &> ./logs/vic_log1.txt']);
                job2 = batch(['!./bin/vicNl -g ',output,'/parameters/vic/gparam2.txt &> ./logs/vic_log2.txt']);
                job3 = batch(['!./bin/vicNl -g ',output,'/parameters/vic/gparam3.txt &> ./logs/vic_log3.txt']);
                job4 = batch(['!./bin/vicNl -g ',output,'/parameters/vic/gparam4.txt &> ./logs/vic_log4.txt']);
                
                wait(job1)
                wait(job2)
                wait(job3)
                wait(job4)
                
                delete(job1)
                delete(job2)
                delete(job3)
                delete(job4)
            else
                obj.paths.soil_file=[output,'/parameters/vic/soil_param.txt'];
                
                gparam([output,'/parameters/vic/gparam.txt'],...
                    obj.paths.vic_result_dir,Emode,obj.basin_parameters.run_period,obj.paths.soil_file,obj.paths.vic_forcing_file,obj.forcing.start_year,max_snow_temp,min_rain_temp);
                
                soil_param(  obj.paths.soil_file,obj.basin_parameters.Mask,obj.parameters.binf,obj.parameters.Ds,...
                    obj.parameters.Ds_MAX,obj.parameters.Ws,obj.parameters.d2,obj.parameters.d3,obj.parameters.snow_rough);
                
                system(['./bin/vicNl -g ',output,'/parameters/vic/gparam.txt &> ./logs/vic_log.txt']);
            end
            
            
        end
        
        function run_glacier_model(obj)
%             temp_forc='/home/vikram/VIC/VIC_Himalayas/forcings/forcing_scaled_PG/tas_';
            temp_forc=obj.paths.tas_forcing_file;
            forcing_start_year=obj.forcing.start_year;
            Melt_Thresh=obj.parameters.Melt_Thresh;
            Area_threshold=0;
            forcing_file=['/home/vikram/VIC/VIC_Himalayas/forcings/forcings_no_scaling/forcing_'];
            
            %                 forcing_file=obj.paths.vic_forcing_file;
            run_type=1
            obj.basin
            write_output=1
            write_components_output=1
            
            mb_all=tindex_model([obj.paths.io],temp_forc,forcing_file,forcing_start_year,Area_threshold,...
                obj.parameters.ddf_clean_ice,obj.parameters.ddf_debri_ice,...
                obj.parameters.lapse_rate_summer,obj.parameters.lapse_rate_winter,obj.parameters.PG,obj.parameters.Rexp,Melt_Thresh,...
                obj.basin_parameters.Mask,obj.IndexMatrix,obj.basin_parameters.run_period,...
                obj.basin,write_output,write_components_output,obj.parameters.HREF,...
                obj.parameters.HMAX,obj.basin_parameters.mb_calc_period,obj);
            mb_sim=mb_all/(obj.basin_parameters.mb_calc_period(2)-obj.basin_parameters.mb_calc_period(1)+1);
            
            dlmwrite([obj.paths.plot_result_dir,'/mb.txt'],mb_sim);
            
            vicout=[obj.paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/glacier/fluxes_'];
%             vicout=['/home/vikram/VIC/VIC_Himalayas/results/vic/basin_1/glacier/fluxes_'];
            routout= [obj.paths.rout_result_dir,'glacier/'] ;
            rout_input(obj,vicout,routout);
            
            routinput=[obj.paths.io,'parameters/rout/rout_input.txt'];
            
            system(['./bin/rout ',routinput])
            %&> ./logs/rout_glacier.txt
            
        end
        
        
        function [NSE,CORR,rmse,per_rmse]= calculate_evals(obj)
            
            
            station_rout=obj.basin_parameters.station_name(~isspace(obj.basin_parameters.station_name));
            filename_rout=[obj.paths.rout_result_dir,'/glacier/', station_rout(1:5),'.month'] ;
            Q_sim_total=dlmread(filename_rout);
            Q_sim=Q_sim_total(:,3)*0.0283;
            temp_st=int16(obj.basin_parameters.run_period(1)-obj.basin_parameters.years_observed(1))*12+1;
            temp_en=int16(obj.basin_parameters.run_period(2)-obj.basin_parameters.years_observed(1)+1)*12;
            Q_obs=obj.basin_parameters.Q_observed(temp_st:temp_en);
            
            
            [NSE,CORR,rmse,per_rmse]=eval_performance(Q_sim(25:end),Q_obs(25:end));
            %             Q_obs(Q_obs<0)=0;
            %             NSE_value=nse(Q_sim(25:end),Q_obs(25:end));
%                         plot(Q_sim(25:end))
%                         hold on
%                         plot(Q_obs(25:end))
        end
        
    end
end


