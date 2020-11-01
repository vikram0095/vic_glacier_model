function Plot_vic_outputs(obj)

st=obj.basin_parameters.run_period(1);
en=obj.basin_parameters.run_period(2);
load('./mat/AvgElevation.mat');
forcing_start_year=obj.forcing.start_year;


FORCING_START_DATE=datetime(forcing_start_year,1,1);
VIC_STARTDATE=datetime(st,1,1);
VIC_ENDDATE=datetime(en,12,31);
index_of_forcing_start=days(VIC_STARTDATE-FORCING_START_DATE)+1;
index_of_forcing_end=days(VIC_ENDDATE-FORCING_START_DATE)+1;


%%
PREC          =  4;
EVAP        =    5;
RUNOFF       =   6;
BASEFLOW      =  7;
SWE           =  8;
SNOW_MELT=9;
SNOWF  =10;
RAINF=11;
SOIL_MOIST   = 12:14;

%%
forcingpath=obj.forcing.path;
forcing_file=[forcingpath,'forcing_'];
temp_forc=[forcingpath,'tas_'];
IndexMatrix=obj.IndexMatrix.IndexMatrix;


countgrid=0;
grid_id=[];
Mask=obj.basin_parameters.Mask;
%     result_dir_standard=[obj.paths.vic_result_dir,'standard'];
result_dir_glacier=[obj.paths.vic_result_dir,'glacier'];
result_dir_snow=[obj.paths.vic_result_dir,'snow'];
result_dir_glacier_clean=[obj.paths.vic_result_dir,'clean'];
result_dir_glacier_debri=[obj.paths.vic_result_dir,'debri'];

for grid=Mask'
    countgrid=countgrid+1;
    grid_id(countgrid)=grid;
    filename_glacier = strcat(result_dir_glacier,'/fluxes_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
    filename_clean_glacier = strcat(result_dir_glacier_clean,'/fluxes_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
    filename_debri_glacier = strcat(result_dir_glacier_debri,'/fluxes_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
    filename_snow = strcat(result_dir_snow,'/fluxes_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
    
    filename_forcing = strcat(forcing_file,num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
    filename_temp_forcing = strcat(temp_forc ,num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
    %
    
    FLUX=   dlmread(filename_glacier);
    FLUX_c=   dlmread(filename_clean_glacier);
    FLUX_d=   dlmread(filename_debri_glacier);
    FLUX_s=   dlmread(filename_snow);
    
    TAVG= dlmread(filename_temp_forcing);
    TAVG=TAVG(index_of_forcing_start:index_of_forcing_end,:);
    
    FORCEI= dlmread(filename_forcing);
    FORCEI=FORCEI(index_of_forcing_start:index_of_forcing_end,:);
    data.et(countgrid,1:366)= time_series_mean_daily(FLUX_d(:,EVAP),st+2,en);
    data.rainfall(countgrid,1:366)= time_series_mean_daily(FLUX_d(:,RAINF),st+2,en);
    data.snowfall(countgrid,1:366)= time_series_mean_daily(FLUX_d(:,SNOWF),st+2,en);
    data.SWE(countgrid,1:366)= time_series_mean_daily(FLUX_d(:,SWE),st+2,en);
    
    data.prec(countgrid,1:366)= time_series_mean_daily(FORCEI(:,1),st+2,en);
    
    data.glaccont(countgrid,1:366)= time_series_mean_daily(FLUX_d(:,6),st+2,en)+time_series_mean_daily(FLUX_c(:,6),st+2,en);
    data.snowcont(countgrid,1:366)= time_series_mean_daily(FLUX_s(:,6),st+2,en)+time_series_mean_daily(FLUX_s(:,7),st+2,en);
    
    data.total_q(countgrid,1:366)= time_series_mean_daily(FLUX(:,6),st+2,en)+time_series_mean_daily(FLUX(:,7),st+2,en);
    
    %data.prec_long(countgrid,:)=time_series_subset(FORCEI(:,1),1981,2016,st,en);
    
    data.tmax(countgrid,1:366)= time_series_mean_daily(FORCEI(:,2),st+2,en);
    data.tmin(countgrid,1:366)= time_series_mean_daily(FORCEI(:,3),st+2,en);
    data.tavg(countgrid,1:366)= time_series_mean_daily(TAVG,st+2,en);
    %     data.tavg_long(countgrid,:)= time_series_subset(TAVG,1981,2016,st,en);
    
    
end

%% monthly ts
for co=1:countgrid
    %             1 for sum
    %             2 for avg
    data.et_monthly(co,1:12)= time_series_daily_to_monthly(data.et(co,:),2004,2004,1);
    data.rainfall_monthly(co,1:12)= time_series_daily_to_monthly(data.rainfall(co,:),2004,2004,1);
    data.snowfall_monthly(co,1:12)= time_series_daily_to_monthly(data.snowfall(co,:),2004,2004,1);
    data.SWE_monthly(co,1:12)= time_series_daily_to_monthly(data.SWE(co,:),2004,2004,2);
    data.prec_monthly(co,1:12)= time_series_daily_to_monthly(data.prec(co,:),2004,2004,1);
    data.glaccont_monthly(co,1:12)= time_series_daily_to_monthly(data.glaccont(co,:),2004,2004,1);
    data.snowcont_monthly(co,1:12)= time_series_daily_to_monthly( data.snowcont(co,:),2004,2004,1);
    data.total_q_monthly(co,1:12)= time_series_daily_to_monthly(data.total_q(co,:),2004,2004,1);
    data.tmax_monthly(co,1:12)= time_series_daily_to_monthly(data.tmax(co,:),2004,2004,2);
    data.tmin_monthly(co,1:12)= time_series_daily_to_monthly(data.tmin(co,:),2004,2004,2);
    data.tavg_monthly(co,1:12)= time_series_daily_to_monthly(data.tavg(co,:),2004,2004,2);
end

%% plots
figure('position',[0,0,1920,1080], 'Visible', 'off')
set(gca,'position',[0.05,0.05,0.9,0.9])

subplot(2,3,1)
plot(mean(data.glaccont));
hold on
plot(mean(data.snowcont));
plot(mean(data.total_q));
legend('Glac cont','Snow cont','Total Q')
xlabel('Day of year')
xticks(15:30:366);
xticklabels({'J','F','M','A','M','J','J','A','S','O','N','D'});
xlim([1 366])
ylabel(' (mm) ')
title(['River basin: ',obj.basin_parameters.river_name]) 

subplot(2,3,2)
plot(mean(data.tmax));
hold on
plot(mean(data.tmin));
plot(mean(data.tavg));
legend('T max','Tmin','T avg')
xlabel('Day of year')
xticks(15:30:366);
xticklabels({'J','F','M','A','M','J','J','A','S','O','N','D'});
xlim([1 366])
ylabel('Temperature (deg C) ')
title(['River basin: ',obj.basin_parameters.river_name]) 


subplot(2,3,3)
plot(smoothdata(mean(data.et),'movmean',5));
hold on
plot(smoothdata(mean(data.snowfall),'movmean',5));
plot(smoothdata(mean(data.rainfall),'movmean',5));
plot(smoothdata(mean(data.prec),'movmean',5));
plot(smoothdata(mean(data.rainfall+data.snowfall),'movmean',5));
legend('ET','Snowfall','Rainfall','Precitpitaion','Rain+Snow')
xlabel('Day of year')
xticks(15:30:366);
xticklabels({'J','F','M','A','M','J','J','A','S','O','N','D'});
xlim([1 366])
ylabel('Daily (mm)')
title(['River basin: ',obj.basin_parameters.river_name]) 


subplot(2,3,4)
plot(mean(data.glaccont_monthly));
hold on
plot(mean(data.snowcont_monthly));
plot(mean(data.total_q_monthly));
legend('Glac cont','Snow cont','Total Q')
xlabel('Months')
xticks(1:12);
xticklabels({'J','F','M','A','M','J','J','A','S','O','N','D'});
ylabel('Accumulated in month (mm) ')
xlim([1 12])
title(['River basin: ',obj.basin_parameters.river_name]) 

subplot(2,3,5)
plot(mean(data.tmax_monthly));
hold on
plot(mean(data.tmin_monthly));
plot(mean(data.tavg_monthly));
legend('T max','Tmin','T avg')
xlabel('Months')
xticks(1:12);
xticklabels({'J','F','M','A','M','J','J','A','S','O','N','D'});
ylabel('Temperature (deg C) ')
xlim([1 12])
title(['River basin: ',obj.basin_parameters.river_name]) 


subplot(2,3,6)
plot(mean(data.et_monthly));
hold on
plot(mean(data.snowfall_monthly));
plot(mean(data.rainfall_monthly));
plot(mean(data.prec_monthly));
plot(mean(data.rainfall_monthly+data.snowfall_monthly));
legend('ET','Snowfall','Rainfall','Precitpitaion','Rain+Snow')
xlabel('Months')
xticks(1:12);
xticklabels({'J','F','M','A','M','J','J','A','S','O','N','D'});
ylabel('Accumulated in month (mm)')
xlim([1 12])
title(['River basin: ',obj.basin_parameters.river_name]) 

obj.data_plots=data;
print('-dtiff','-r500',[ obj.paths.plot_result_dir,'/figure4'])
save( [ obj.paths.plot_result_dir,'data.mat'],'data','grid_id');
end