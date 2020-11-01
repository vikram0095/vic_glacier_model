function [mb_all]=tindex_model(output_1,tempforc,precforc,forcing_start_year,Area_threshold,...
    ddf_clean_ice,ddf_debri_ice,lapse_rate_summer,lapse_rate_winter,PG,Rexp,Melt_Thresh,...
    Mask,IndexMatrix,run_period,basin,write_output,write_components_output,HREF,HMAX,mb_calc_period,obj)


% write_output=1;
%% Loading datasets
load('./mat/IndexMatrix.mat');
load('./mat/AvgElevation.mat');
load(['./mat/init_glacier_states/init_data_basin_',num2str(basin),'.mat'])
load(['./mat/dem_cdf_glaciers/dem_cdf_basin_all.mat'])
counter_glaciers=0;
%% Defining Constants
% Area_threshold= 2 ;        % km^2
GRID_AREA=592.5;        % km2
c_scaling=0.03;        %   Volume = c_scaling x Area ^ gamma_scaling
gamma_scaling=1.375;    %   Area  = (Volume/c_scaling) ^  (1/gamma_scaling)
% HREF=2500;  % meters

alpha=[ones(1,5)*lapse_rate_winter,ones(1,4)*lapse_rate_summer,ones(1,3)*lapse_rate_winter];
alpha_year=[ones(1,31)'*alpha(1);...
    ones(1,28)'*alpha(2);...
    ones(1,31)'*alpha(3);...
    ones(1,30)'*alpha(4);...
    ones(1,31)'*alpha(5);...
    ones(1,30)'*alpha(6);...
    ones(1,31)'*alpha(7);...
    ones(1,31)'*alpha(8);...
    ones(1,30)'*alpha(9);...
    ones(1,31)'*alpha(10);...
    ones(1,30)'*alpha(11);...
    ones(1,31)'*alpha(12)];
alpha_leap_year=[ones(1,31)'*alpha(1);...
    ones(1,29)'*alpha(2);...
    ones(1,31)'*alpha(3);...
    ones(1,30)'*alpha(4);...
    ones(1,31)'*alpha(5);...
    ones(1,30)'*alpha(6);...
    ones(1,31)'*alpha(7);...
    ones(1,31)'*alpha(8);...
    ones(1,30)'*alpha(9);...
    ones(1,31)'*alpha(10);...
    ones(1,30)'*alpha(11);...
    ones(1,31)'*alpha(12)];
output=[output_1,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/']

vicout =         [  output,'standard/'];
glacout=         [  output,'glacier/'];
glacout_clean=   [  output,'clean/'];
glacout_debri=   [  output,'debri/'] ;
glacier_vol =    [  output,'glacier_states/'];

st=run_period(1);
en=run_period(2);
forcing_start_date=datetime(forcing_start_year,1,1);
run_start_date=datetime(st,1,1);
run_end_date=datetime(en,12,31);
DR=days(run_start_date-forcing_start_date)+1:days(run_end_date-forcing_start_date)+1;
area_glac_basin=0;%km2
% abl_area_sum=0;%km2
% acc_area_sum=0;%km2
mb_sum_basin=0;%km3
% ab_sum_basin=0;%km3
% acc_sum_basin=0;%km3
%% Run for grids
ar_sum=0;  %
count_grids_melt=0;

for grid=Mask'%7096%
    
    
    index=1;
    melt_daily_full_run=[];
    melt_daily_full_run_cd=[];
    area_glac_grid=0;
    elevation_grid=AvgEle(grid);
    filename_prec = strcat(precforc,num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
    
    TEMPC=dlmread(strcat(tempforc,'', num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f')));
    TEMPC=TEMPC(DR);
    FORCE=dlmread(filename_prec);
    
    PREC=FORCE(DR,1);
    PREC(isnan(PREC))=0;
    
    if TEMPC<-50 | TEMPC>50
        fprintf('Temp error\n')
        fprintf('Fixing Kelvin / celcius error\n')
        TEMPC=TEMPC+273.15;
        %         pause;
    end
    if TEMPC>230
        fprintf('Fixing Kelvin / celcius error\n')
        TEMPC=TEMPC-273.15;
    end
    
    if elevation_grid<500 | elevation_grid>9000
        fprintf('Elevation error\n')
        pause;
    end
    
    TEMPC=TEMPC-Melt_Thresh;
    
    %% Extracting glaciers in grid
    if st==1981 || st==1998
        filename_gl_ar_vl = [output_1,'/glacier_inits/state_',num2str(st-1),'_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'),'.mat'];
    else
        filename_gl_ar_vl = [glacier_vol,'state_',num2str(st-1),'_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'),'.mat'];
    end
    if isfile(filename_gl_ar_vl)
        
        for yeaR=st:en
            data=[];
            melt_clean_daily_year=[];
            melt_debri_daily_year=[];
            if islpyr(yeaR)
                grid_melt=zeros(1,366);
                grid_melt_clean=zeros(1,366);
                grid_melt_debri=zeros(1,366);
            else
                grid_melt=zeros(1,365);
                grid_melt_clean=zeros(1,365);
                grid_melt_debri=zeros(1,365);
            end
            
            if( yeaR==st &&(yeaR==1981||yeaR==1998))
                filename_gl_ar_vl = [output_1,'/glacier_inits/state_',num2str(yeaR-1),'_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'),'.mat'];
                load(filename_gl_ar_vl);% glacier_data : x 3
            else
                filename_gl_ar_vl = [glacier_vol,'state_',num2str(yeaR-1),'_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'),'.mat'];
                load(filename_gl_ar_vl);% glacier_data : x 3
            end
            if( yeaR==st)
                 if size(glacier_data,1)>0
                    glacier_data(glacier_data(:,3)<Area_threshold,:)=[];
                    area_glac_grid=sum((glacier_data(:,2)./c_scaling).^(1/gamma_scaling));%km2
                    area_glac_basin=area_glac_basin+area_glac_grid;
                else
                    fprintf("Breaking123\n");
                    break;
                    
                 end
            end
            
            if islpyr(yeaR)
                step=366;
                alph=alpha_leap_year;
            else
                step=365;
                alph=alpha_year;
            end
            
            
            
            
            for glacier=1:size(glacier_data,1)
                if yeaR==st
                    counter_glaciers=counter_glaciers+1;
                end
                %             glaciers_indices;
                glac_rgiid=glacier_data(glacier,1);
                glacier_index=find(glacier_init_data(:,3)== glac_rgiid);
                glac_debri_fraction=glacier_init_data(glacier_index,11);
                glac_aspect=glacier_init_data(glacier_index,9);
                glac_area=(glacier_data(glacier,2)./c_scaling).^(1/gamma_scaling);
                glac_clean_area=glac_area*(1-glac_debri_fraction);
                glac_debri_area=glac_area*glac_debri_fraction;
                
                %                 if yeaR==st
                %                     ar_sum=ar_sum+glac_clean_area+glac_debri_area;
                %                 end
                
                
                glac_AbAR=zeros(1,step);
                glac_AAR=zeros(1,step);
                
                sum_Ti_x_cdf_ablation=zeros(1,step);
                sum_Ti_x_cdf_accumulation=zeros(1,step);
                
                glac_T_ablation=zeros(1,step);
                glac_T_accumulation=zeros(1,step);
                
                grid_temp=TEMPC(index:index+step-1);
                grid_prec=PREC(index:index+step-1);
                
                glac_cdf= dem_cdf.(['rgi_',num2str(floor(glac_rgiid/100000)),'_',num2str(mod(glac_rgiid,100000),'%05.0f')]).cdf;
                glac_pdf=[0 ,glac_cdf(2:end)-glac_cdf(1:end-1)];
                glac_cdf_range=double(dem_cdf.(['rgi_',num2str(floor(glac_rgiid/100000)),'_',num2str(mod(glac_rgiid,100000),'%05.0f')]).range);
                
                glac_prec_corr=zeros(size(grid_prec));
                
                for daY=1:step
                    
                    z_cdf=glac_cdf_range(1);
                    z_max_cdf=glac_cdf_range(end);
                    z_0_deg=(-grid_temp(daY))./alph(daY)+elevation_grid;
                    z_2_deg=(2-grid_temp(daY))./alph(daY)+elevation_grid;
                    %                                         Plot to understand
                    %                                         clf
                    %                                         plot(glac_cdf_range,glac_cdf)
                    %                                         hold on
                    %                                         plot([z_0_deg z_0_deg],[0 1],'r');
                    %                                         plot([z_2_deg z_2_deg],[0 1],'b');
                    
                    glac_AbAR(daY)=0;
                    glac_AAR(daY)=0;
                    
                    sum_Ti_x_cdf_ablation(daY)=0;
                    sum_Ti_x_cdf_accumulation(daY)=0;
                    
                    i=1;
                    while z_cdf <= z_0_deg &&  z_cdf < z_max_cdf
                        glac_AbAR(daY)=glac_AbAR(daY)+glac_pdf(i);
                        
                        %                     clf
                        %                     plot(glac_cdf_range,glac_cdf)
                        %                     hold on
                        %                     plot([z_0_deg z_0_deg],[0 1],'r');
                        %                     plot([z_2_deg z_2_deg],[0 1],'b');
                        %                     plot([z_cdf z_cdf],[0 1],'g');
                        
                        Ti=(-elevation_grid+double(z_cdf))*alph(daY)+grid_temp(daY);
                        sum_Ti_x_cdf_ablation(daY)=sum_Ti_x_cdf_ablation(daY) + Ti * glac_pdf(i);
                        i=i+1;
                        z_cdf=glac_cdf_range(i);
                    end
                    
                    glac_T_ablation(daY)=sum_Ti_x_cdf_ablation(daY)./glac_AbAR(daY);
                    
                    i=1;
                    z_cdf=glac_cdf_range(1);
                    while z_cdf < z_max_cdf
                        z_cdf=glac_cdf_range(i);
                        if  z_cdf >= z_2_deg
                            %                             clf
                            %                             plot(glac_cdf_range,glac_cdf)
                            %                             hold on
                            %                             plot(glac_cdf_range,glac_pdf)
                            %                             plot([z_0_deg z_0_deg],[0 1],'r');
                            %                             plot([z_2_deg z_2_deg],[0 1],'b');
                            %                             plot([z_cdf z_cdf],[0 1],'g');
                            glac_AAR(daY)=glac_AAR(daY)+glac_pdf(i);
                            
                            Ti=(-elevation_grid+double(z_cdf))*alph(daY)+grid_temp(daY);
                            sum_Ti_x_cdf_accumulation(daY)=sum_Ti_x_cdf_accumulation(daY) + Ti * glac_pdf(i);
                            
                            if z_cdf > 7500
                                glac_prec_corr(daY)=glac_prec_corr(daY);
                                
                            elseif z_cdf > HMAX
                                glac_prec_corr(daY)=glac_prec_corr(daY)+grid_prec(daY)* (1+(((HMAX-HREF)+(HMAX-double(z_cdf)))*PG*0.01))*glac_pdf(i);
                            elseif z_cdf <= HMAX && z_cdf >= HREF
                                glac_prec_corr(daY)=glac_prec_corr(daY)+grid_prec(daY)* (1+(((double(z_cdf)-HREF))*PG*0.01))*glac_pdf(i);
                                %
                            else
                                glac_prec_corr(daY)=glac_prec_corr(daY)+grid_prec(daY)*glac_pdf(i);
                            end
                            if isnan(glac_prec_corr(daY))
                                printf("Prec corr Nan");
                            end
                        end
                        i=i+1;
                    end
                    
                    glac_T_accumulation(daY)=sum_Ti_x_cdf_accumulation(daY)./glac_AAR(daY);
                end
                
                
                glac_T_ablation(isnan(glac_T_ablation))=0;
                glac_T_ablation(glac_T_ablation<0)=0;
                accumulation=nansum(glac_prec_corr *glac_area)*10^-6 ;
                
                melt_clean_daily_year(glacier,:)=ddf_clean_ice * (glac_T_ablation) .* glac_AbAR * glac_clean_area *(1-Rexp*cosd(glac_aspect));% km2 *mm
                melt_debri_daily_year(glacier,:)=ddf_debri_ice * (glac_T_ablation).* glac_AbAR* glac_debri_area *(1-Rexp*cosd(glac_aspect));%area of grid is approx 592.5 km2
                
                %                add melt over the year
                melt_year=sum(melt_clean_daily_year(glacier,:),2) +sum(melt_debri_daily_year(glacier,:),2);
                ablation=sum(melt_year) * (10^-6);%km3
                
                %                 abl_area_sum=abl_area_sum +  mean(glac_AbAR) * glac_area;
                %                 acc_area_sum=acc_area_sum + mean(glac_AAR) * glac_area;
                
                mb=accumulation-ablation;%km3
                if (yeaR >= mb_calc_period(1) && yeaR <=mb_calc_period(2))
                    mb_sum_basin=mb_sum_basin+mb;%km3;
                end
                
                
                vol_old=glacier_data(glacier,2);
                vol_new=vol_old-ablation+accumulation;
                
                if (isnan(vol_new))
                    fprintf('Volume null error\n')
                    pause;
                end
                
                if vol_new<0
                    vol_new=0;
                    area_new=0;
                else
                    area_new=(vol_new./c_scaling).^(1/gamma_scaling);
                end
                
                data=[data;[glac_rgiid,vol_new,area_new]];
                
            end
            
            filename_state_out = [glacier_vol,'state_',num2str(yeaR),'_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'),'.mat'];
            glacier_data=data;
            save(filename_state_out,'glacier_data');
            index=index+step;
            
            grid_melt=sum(melt_clean_daily_year+melt_debri_daily_year,1);
            grid_melt_clean=sum(melt_clean_daily_year,1);
            grid_melt_debri=sum(melt_debri_daily_year,1);
            
            melt_daily_full_run=[melt_daily_full_run;grid_melt'];
            melt_daily_full_run_cd=[melt_daily_full_run_cd,[grid_melt_clean;grid_melt_debri]];
        end
        1;
    else
        melt_daily_full_run=0;
        melt_daily_full_run_cd=[0;0];
        count_grids_melt=count_grids_melt+1;
        fprintf("Breaking\n");
    end
    %     end
    
    if write_output==1
        filename_standard = strcat(vicout,'fluxes_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
        filename_glacier = strcat(glacout,'fluxes_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
        filename_clean = strcat(glacout_clean,'fluxes_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
        filename_debri= strcat(glacout_debri,'fluxes_',num2str(IndexMatrix(grid,2),'%0.4f'),'_',num2str(IndexMatrix(grid,3),'%0.4f'));
        
        
        FLUX=dlmread(filename_standard);
        if size(melt_daily_full_run>0)
            %             tt=TEMPC;
            %             Q1=time_series_daily_to_monthly(FLUX(:,6),1994,2006,1);
            %             tt(tt<0)=0;
            %             plot(Q1,'r');hold on
            %             plot(time_series_daily_to_monthly(melt_daily_full_run./GRID_AREA,1994,2006,1),'b');
            %             plot(time_series_daily_to_monthly((ddf_clean_ice*tt*area_glac_grid)/GRID_AREA,1994,2006,1),'g');
            %             plot(FLUX(:,6)+FLUX(:,7)); hold on
            %             plot(melt_daily_full_run./GRID_AREA)
            FLUX(:,6)=FLUX(:,6)  .*  (GRID_AREA-area_glac_grid)/GRID_AREA  +  melt_daily_full_run./GRID_AREA ;
            %             plot(FLUX(:,6)+FLUX(:,7),'r'); hold on
            
            
            dlmwrite(filename_glacier,FLUX(:,:),'\t');
            if write_components_output==1
                FLUX(:,6)=melt_daily_full_run_cd(1,:)./GRID_AREA;
                FLUX(:,7)=zeros(size(FLUX(:,6)));
                dlmwrite(filename_clean,FLUX(:,:),'\t');
                FLUX(:,6)=(melt_daily_full_run_cd(2,:))./GRID_AREA;
                FLUX(:,7)=zeros(size(FLUX(:,6)));
                dlmwrite(filename_debri,FLUX(:,:),'\t');
            end
        else
            
            dlmwrite(filename_glacier,FLUX(:,:),'\t');
            if write_components_output==1
                FLUX(:,6)=zeros(size(FLUX(:,6)));
                FLUX(:,7)=zeros(size(FLUX(:,6)));
                dlmwrite(filename_clean,FLUX(:,:),'\t');
                dlmwrite(filename_debri,FLUX(:,:),'\t');
            end
        end
        
        
        
        %
    end
end
%counter_glaciers
count_grids_melt
mb_all=(mb_sum_basin/area_glac_basin*1000);
%stopped using acc and ab mass balance because  model is not simualting
%flow
% ab_all=(ab_sum_basin/abl_area_sum)*1000;
% acc_all=(acc_sum_basin/acc_area_sum)*1000;
% acc_area_sum
% abl_area_sum
% area_glac_basin
%ab_sum_basin
%acc_sum_basin
%m w e per year for total run period %%km3/%km2
%area_glac_basin
%GRID_AREA*size(Mask,1)
%ar_sum
%
end
% end



