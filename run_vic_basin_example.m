basin=1;
load(['/home/vikram/VIC/VIC_Himalayas/scripts/mat/observed_discharge/basin_',num2str(basin),'_Q_observed.mat'])
Mask=dlmread(['./mat/mask_basin_',num2str(basin),'.txt']);

input=[0.379	0.701	7.449	0.776	1.48	1.08	-0.0047	-0.006	5.5	5.5	0.12	2150	5400	1.88];
basin_parameters.run_period=[1998 2015];%
basin_parameters.mb_calc_period=[2000 2015];%
basin_parameters.basin=basin;

basin_parameters.Mask=Mask;

basin_parameters.calibration_period=calibration_period;
basin_parameters.Q_observed=Q_observed;
basin_parameters.river_name=river_name;
basin_parameters.station_name=station_name;
basin_parameters.testing_period=testing_period;
basin_parameters.years_observed=years_observed;
p=5;
t=5;
forcing.path=['/home/vikram/VIC/VIC_Himalayas/forcings_scen_scaled/P',num2str(p),'_T',num2str(t),'/'];
forcing.start_year=1981;

paths.io=['/home/vikram/H/basin_',num2str(basin),'/'];

parameters.binf=input(1);
parameters.Ds=input(2);
parameters.Ds_MAX=input(3);
parameters.Ws=input(4);
parameters.d2=input(5);
parameters.d3=input(6);

parameters.lapse_rate_summer=input(7);
parameters.lapse_rate_winter=input(8);

parameters.ddf_clean_ice=input(9);
parameters.ddf_debri_ice=input(10);
parameters.PG=input(11);
parameters.HREF=input(12);
parameters.HMAX=input(13);
parameters.Melt_Thresh=input(14);

model_obj=vic_g_model(basin_parameters,forcing,paths,parameters,[p t]);

run_vic(model_obj);
run_glacier_model(model_obj);
%[a b c d]=calculate_evals(model_obj)

track_snowmelt(model_obj)
rout_all(model_obj)
Plot_Streamflow(model_obj)
Plot_Streamflow_wb(model_obj)




