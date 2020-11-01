function Plot_Streamflow(obj)

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
dat1=streamcumec_snowmelt(13:end);

stream=readRoutMonth(filename2);
streamcumec=cell2mat(stream(:,3))*0.0283;%to cumecs from cfps
dat2=streamcumec(13:end);

glacstream=readRoutMonth(filename3);
glacstreamcumec=cell2mat(glacstream(:,3))*0.0283;
dat3=glacstreamcumec(13:end);

glacstream=readRoutMonth(filename4);
glacstreamcumec=cell2mat(glacstream(:,3))*0.0283;
dat4=glacstreamcumec(13:end);

glacstream=readRoutMonth(filename5);
glacstreamcumec=cell2mat(glacstream(:,3))*0.0283;
dat5=glacstreamcumec(13:end);



dat1(dat1<0)=0;

if plot_streamflow==1

h = figure;set(h, 'Visible', 'off');
set(gcf, 'Position',  [100, 100, 1200, 500])

hold on
plot(dat1-dat5,'g');
plot(dat1,'r');
plot(dat1+dat3,'b');
plot(dat1+dat3+dat4,'Cyan');
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
xticks(1:12:size(dat1,1));
xticklabels(st+1:en+1);
set(gca,'XTickLabelRotation',90);
%    saveas(h,[ obj.paths.plot_result_dir,'/figure1.png']);
   print('-dtiff','-r500',[ obj.paths.plot_result_dir,'/figure11'])
end

if plot_streamflow_shaded==1


h = figure;set(h, 'Visible', 'off'); 
set(gcf, 'Position',  [100, 100, 1200, 500])
hold on
datx=dat1+dat3+dat4;
sddata=datx*0.5;
plot(datx,'red','LineWidth',2);
%plot(dat2,'green');
if obj.plot_obs==1

plot(dat6,'k:','LineWidth',2);
end
x=1:size(datx,1);
y=[datx+sddata,datx-sddata]';
px=[x,fliplr(x)]; % make closed patch
py=[y(1,:), fliplr(y(2,:))];
patch(px,py,1,'FaceColor','red','EdgeColor','none','FaceAlpha',0.2);
if obj.plot_obs==1
legend('Simulated diascharge',...%'Rain+ Snow + Clean + Debri glaciers',
    'Total Observed Streamflow','+-1 standard deviation');
else
    legend('Simulated diascharge',...%'Rain+ Snow + Clean + Debri glaciers',
   '+-1 standard deviation');
end
xlabel(strcat('Year (',num2str(st+1),'-',num2str(en+1),')'));

ylabel('Streamflow(cumecs)');
xticks(1:12:size(dat1,1));
xticklabels(st+1:en+1);
set(gca,'XTickLabelRotation',90);
%     saveas(h,[ obj.paths.plot_result_dir,'/figure2.png']);
   print('-dtiff','-r500',[ obj.paths.plot_result_dir,'/figure22'])

end

if plot_monthly==1
%% plotiting fractional contribution
dat2=dat1+dat3+dat4;
sz=size(dat2,1)/12;
tmp=(dat5)./dat2;
% close all
tmp2=reshape(tmp,12,sz);
c_snow=nanmean(tmp2,2);

tmp=(dat1-dat5)./dat2;
tmp2=reshape(tmp,12,sz);
c_rain=nanmean(tmp2,2);

tmp=(dat3)./dat2;
tmp2=reshape(tmp,12,sz);
c_clean=nanmean(tmp2,2);

tmp=(dat4)./dat2;
tmp2=reshape(tmp,12,sz);
c_debri=nanmean(tmp2,2);

h = figure;set(h, 'Visible', 'off'); 
set(gcf, 'Position',  [100, 100, 1200, 500])

subplot(1,2,1,'Box','on');

hold on

plot(c_snow,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Cyan','Marker', 'o', 'MarkerFaceColor', 'Cyan')
plot(c_rain,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Red','Marker', 'o', 'MarkerFaceColor', 'Red')
plot(c_clean,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Green','Marker', 'o', 'MarkerFaceColor', 'Green')
plot(c_debri,'LineStyle', '-', 'LineWidth', 1.0, 'Color', 'Blue','Marker', 'o', 'MarkerFaceColor', 'Blue')
legend('Snow','Rain','Clean glaciers','Debri glaciers')
ylabel('fractional contribution');
set(gca,'xtick',1:12,...
    'xticklabel',{'Jan','Feb','Mar','Apr','May','Jun',...
    'Jul','Aug','Sep','Oct','Nov','Dec'})


mean_monthly_percent=[(c_snow),(c_rain),(c_clean),(c_debri)];
dlmwrite([ obj.paths.plot_result_dir,'/mean_monthly_percent.txt'],mean_monthly_percent);

axis([1 12 0 1])

%% area plot plotiting nanmean monthly contribution

% figure
% pallete=winter(10);
pallete=flipud([
    186,214,218;
    1  170  193;
    2  116  150;    
    5  32  53;]./255);

tmp=(dat5);
c_snow=reshape(tmp,12,sz);
e_c_snow=std(c_snow,1,2);

tmp=(dat1-dat5);
c_rain=reshape(tmp,12,sz);
e_c_rain=std(c_rain,1,2);

tmp=(dat3);
c_clean=reshape(tmp,12,sz);
e_c_clean=std(c_clean,1,2);

tmp=(dat4);
c_debri=reshape(tmp,12,sz);
e_c_debri=std(c_debri,1,2);

subplot(1,2,2,'Box','on');
area(1:12,[ nanmean(c_clean,2) nanmean(c_debri,2) nanmean(c_snow,2) nanmean(c_rain,2) ],'FaceColor','flat','LineStyle',':');
hold on
if obj.plot_obs==1

obs_dat=nanmean(reshape(dat6,12,size(dat6,1)/12)');
plot(obs_dat,'r--','LineWidth',2);
else
    obs_dat=0;
end
set(gca,'Color',[0.95 0.95 0.95]);
if obj.plot_obs==1

legend('Clean glaciers','Debri glaciers','Snow','Rain','Observered Flow','Location','northwest')
else
    legend('Clean glaciers','Debri glaciers','Snow','Rain','Location','northwest')

end
colormap(pallete);
ylabel('Streamflow(cumecs)');

set(gca,'xtick',1:12,...
    'xticklabel',{'Jan','Feb','Mar','Apr','May','Jun',...
    'Jul','Aug','Sep','Oct','Nov','Dec'})

mean_monthly=[ (nanmean(c_clean,2)) (nanmean(c_debri,2)) (nanmean(c_snow,2)) (nanmean(c_rain,2)) ];
maxxx=ceil(1.2*max(max(max(mean_monthly)),max(obs_dat))/100)*100;
dlmwrite([ obj.paths.plot_result_dir,'/mean_monthly.txt'],mean_monthly);

axis([1 12 0 maxxx])
%    saveas(h,[ obj.paths.plot_result_dir,'/figure3.png']);
   print('-dtiff','-r500',[ obj.paths.plot_result_dir,'/figure33'])
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