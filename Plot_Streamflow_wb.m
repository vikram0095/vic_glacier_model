function Plot_Streamflow_wb(obj)

plot_streamflow_shaded=1
plot_streamflow=1
plot_monthly=1

st=obj.basin_parameters.run_period(1);
en=obj.basin_parameters.run_period(2);

station_rout=obj.basin_parameters.station_name(~isspace(obj.basin_parameters.station_name));


filename1=[obj.paths.rout_result_dir,'/standard/',station_rout(1:5),'.month'];
filename2=[obj.paths.rout_result_dir,'/glacier/',station_rout(1:5),'.month'];
filename3=[obj.paths.rout_result_dir,'/clean/',station_rout(1:5),'.month'];
filename4=[obj.paths.rout_result_dir,'/debri/',station_rout(1:5),'.month'];
filename5=[obj.paths.rout_result_dir,'/snow/',station_rout(1:5),'.month'];

filename6=[obj.paths.rout_result_dir,'/base/',station_rout(1:5),'.month'];
filename7=[obj.paths.rout_result_dir,'/base_s/',station_rout(1:5),'.month'];

Year=[st en];

if obj.plot_obs==1
stind=int16(st-obj.basin_parameters.years_observed(1))*12+1;
endind=int16(en-obj.basin_parameters.years_observed(1)+1)*12;
Q_obs=obj.basin_parameters.Q_observed(stind+12:endind);
end
% startdate2 = datenum(strcat('01-',num2str(Year(1))),'mm-yyyy');
% enddate2 = datenum(strcat('12-',num2str(Year(end))),'mm-yyyy');
% dt2=linspace(startdate2,enddate2,(Year(end)-Year(1)+1)*12);
% 

streams=readRoutMonth(filename1);
streamcumec_snowmelt=cell2mat(streams(:,3))*0.0283;%to cumecs from cfps
dat_std=streamcumec_snowmelt(13:end);

stream=readRoutMonth(filename2);
streamcumec=cell2mat(stream(:,3))*0.0283;%to cumecs from cfps
dat2=streamcumec(13:end);

glacstream=readRoutMonth(filename3);
glacstreamcumec=cell2mat(glacstream(:,3))*0.0283;
dat_cln=glacstreamcumec(13:end);

glacstream=readRoutMonth(filename4);
glacstreamcumec=cell2mat(glacstream(:,3))*0.0283;
dat_deb=glacstreamcumec(13:end);

glacstream=readRoutMonth(filename5);
glacstreamcumec=cell2mat(glacstream(:,3))*0.0283;
dat_sno=glacstreamcumec(13:end);

streams=readRoutMonth(filename6);
streamcumec_base=cell2mat(streams(:,3))*0.0283;%to cumecs from cfps
dat_base=streamcumec_base(13:end);

stream=readRoutMonth(filename7);
streamcumec_base_s=cell2mat(stream(:,3))*0.0283;%to cumecs from cfps
dat_base_s=streamcumec_base_s(13:end);



dat_std(dat_std<0)=0;

if plot_streamflow==1

h = figure;set(h, 'Visible', 'off');
set(gcf, 'Position',  [100, 100, 1200, 500])

hold on
plot(dat_std-dat_sno,'g');
plot(dat_std,'r');
plot(dat_std+dat_cln,'b');
plot(dat_std+dat_cln+dat_deb,'Cyan');
%plot(dat2,'k:');
if obj.plot_obs==1
dat6=Q_obs;
dat6(dat6<0)=NaN;
plot(dat6,'k--');
legend('Rain','Rain+Snow','Rain+ Snow + Clean glaciers',...
    'Rain+ Snow + Clean + Debri glaciers',...
    'Total Observed Streamflow');
else
    
legend('Rain','Rain+Snow','Rain+ Snow + Clean glaciers',...
    'Rain+ Snow + Clean + Debri glaciers');
end
xlabel(strcat('Year (',num2str(st+1),'-',num2str(en+1),')'));
ylabel('Streamflow(cumecs)');
xticks(1:12:size(dat_std,1));
xticklabels(st+1:en+1);
set(gca,'XTickLabelRotation',90);
%    saveas(h,[ obj.paths.plot_result_dir,'/figure1.png']);
   print('-dtiff','-r500',[ obj.paths.plot_result_dir,'/figure_base11'])
end


if plot_monthly==1
%% plotiting fractional contribution
dat_Qt=dat_std+dat_cln+dat_deb;
sz=size(dat_Qt,1)/12;

tmp=(dat_sno-dat_base_s)./dat_Qt;
tmp2=reshape(tmp,12,sz);
c_snow_r=nanmean(tmp2,2);


tmp=(dat_base_s)./dat_Qt;
tmp2=reshape(tmp,12,sz);
c_snow_b=nanmean(tmp2,2);

tmp=(dat_std-dat_sno-dat_base+dat_base_s)./dat_Qt;
tmp2=reshape(tmp,12,sz);
c_rain_r=nanmean(tmp2,2);

tmp=(dat_base-dat_base_s)./dat_Qt;
tmp2=reshape(tmp,12,sz);
c_rain_b=nanmean(tmp2,2);

tmp=(dat_cln)./dat_Qt;
tmp2=reshape(tmp,12,sz);
c_clean=nanmean(tmp2,2);

tmp=(dat_deb)./dat_Qt;
tmp2=reshape(tmp,12,sz);
c_debri=nanmean(tmp2,2);
 h = figure;set(h, 'Visible', 'off'); 
 set(gcf, 'Position',  [100, 100, 1200, 500])

subplot(1,2,1,'Box','on');

hold on

plot(c_snow_b,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'k','Marker', 'o', 'MarkerFaceColor', 'k')
plot(c_rain_b,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'y','Marker', 'o', 'MarkerFaceColor', 'y')
plot(c_snow_r,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Cyan','Marker', 'o', 'MarkerFaceColor', 'Cyan')
plot(c_rain_r,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Red','Marker', 'o', 'MarkerFaceColor', 'Red')
plot(c_clean,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Green','Marker', 'o', 'MarkerFaceColor', 'Green')
plot(c_debri,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Blue','Marker', 'o', 'MarkerFaceColor', 'Blue')

% dlmwrite(['/home/vikram/Him_runs/Figures and data/data_2_',num2str(basin),'_.txt'],...
%     [c_rain_r,c_snow_r,c_clean,c_debri]);

legend('Snow b ','Rain b','Snow r','Rain r','Clean glaciers','Debri glaciers')
ylabel('fractional contribution');
set(gca,'xtick',1:12,...
    'xticklabel',{'Jan','Feb','Mar','Apr','May','Jun',...
    'Jul','Aug','Sep','Oct','Nov','Dec'})
axis([1 12 0 1])
%% area plot plotiting nanmean monthly contribution

% figure
% pallete=winter(10);

pallete=flipud([
    186,214,218;
    1  170  193;
    2  116  150;    
    5  32  53;]./255);
pallete=flipud([
    1,0,0;
   0,1,0;
    0,0,1;    
    1,1,1;
    1,1,0;
    1,0,1;
    0,1,1]);
% pallete=['k','y','Cyan','Red','Blue','green','gray']
tmp=(dat_sno-dat_base_s);
c_snow_r=reshape(tmp,12,sz);
e_c_snow_r=std(c_snow_r,1,2);

tmp=(dat_std-dat_sno-dat_base+dat_base_s);
c_rain_r=reshape(tmp,12,sz);
e_c_rain_r=std(c_rain_r,1,2);

tmp=(dat_base_s);
c_snow_b=reshape(tmp,12,sz);
e_c_snow_r=std(c_snow_b,1,2);

tmp=(dat_base-dat_base_s);
c_rain_b=reshape(tmp,12,sz);
e_c_rain_b=std(c_rain_b,1,2);

tmp=(dat_cln);
c_clean=reshape(tmp,12,sz);
e_c_clean=std(c_clean,1,2);

tmp=(dat_deb);
c_debri=reshape(tmp,12,sz);
e_c_debri=std(c_debri,1,2);
% dlmwrite(['/home/vikram/Him_runs/Figures and data/data_3_mean_',num2str(basin),'_.txt'],...
%     [nanmean(c_rain_r,2) nanmean(c_snow_r,2) nanmean(c_clean,2) nanmean(c_debri,2) nanmean(reshape(dat6,12,size(dat6,1)/12)')' ]);
% dlmwrite(['/home/vikram/Him_runs/Figures and data/data_3_std_',num2str(basin),'_.txt'],...
%     [e_c_rain_r e_c_snow_r e_c_clean e_c_debri ]);

subplot(1,2,2,'Box','on');
area(1:12,[ nanmean(c_rain_b,2) nanmean(c_snow_b,2)  nanmean(c_clean,2) nanmean(c_debri,2) nanmean(c_snow_r,2) nanmean(c_rain_r,2)],'FaceColor','flat','LineStyle',':');
hold on
% plot(nanmean(reshape(dat6,12,size(dat6,1)/12)'),'r--','LineWidth',2);
set(gca,'Color',[0.95 0.95 0.95]);
legend('rain baseflow','Snow baseflow','Clean glaciers','Debri glaciers','Snow Runoff','Rain Runoff','Observered Flow','Location','northwest')
colormap(pallete);
ylabel('Streamflow(cumecs)');

set(gca,'xtick',1:12,...
    'xticklabel',{'Jan','Feb','Mar','Apr','May','Jun',...
    'Jul','Aug','Sep','Oct','Nov','Dec'})
% axis([1 12 0 max(nanmean(reshape(dat6,12,size(dat6,1)/12)'))]) 
   saveas(h,[ obj.paths.plot_result_dir,'/figure_base3.png']);
%    print('-dtiff','-r500',[output_folder,'/plots/figure33'])

end
close all
%  dlmwrite('plot_test.csv',[nanmean(c_snow,2) nanmean(c_rain,2) nanmean(c_clean,2) nanmean(c_debri,2)]);
end



%
% figure
% hold on
%
% errorbar(1:12,nanmean(c_snow,2),e_c_snow,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Cyan')
% errorbar(1:12,nanmean(c_rain,2),e_c_rain,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Blue')
% errorbar(1:12,nanmean(c_clean,2),e_c_clean,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Red')
% errorbar(1:12,nanmean(c_debri,2),e_c_debri,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Green')
%
% legend('Snow','Rain','Clean glaciers','Debri glaciers')
%
% set(gca,'xtick',1:12,...
%     'xticklabel',{'Jan','Feb','Mar','Apr','May','Jun',...
%     'Jul','Aug','Sep','Oct','Nov','Dec'})