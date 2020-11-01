function track_snowmelt(obj)

   
    output= obj.paths.vic_result_dir;
    
vicout= [output,'standard/'];
snowout=[output,'snow/'];

st=obj.basin_parameters.run_period(1);
en=obj.basin_parameters.run_period(2);

NoOfGrids=size(obj.IndexMatrix,1);
FORCINGSTARTDATE=datetime(obj.forcing.start_year,1,1);
STARTDATE=datetime(st,1,1);
ENDDATE=datetime(en,12,31);
NOD=days(ENDDATE-STARTDATE+1);

grid_counter=1;
for grid=obj.basin_parameters.Mask'
        filename1 = strcat(vicout,'fluxes_',num2str(obj.IndexMatrix.IndexMatrix(grid,2),'%0.4f'),'_',num2str(obj.IndexMatrix.IndexMatrix(grid,3),'%0.4f'));
        
        VAR_OUT=dlmread(filename1);
        
        Rain=[0 ; VAR_OUT(:,11)];
        SWE=[0 ; VAR_OUT(:,8)];
        Snowfall=[0 ; VAR_OUT(:,10)];
        M=[0 ; VAR_OUT(:,9)];
        R=[0 ; VAR_OUT(:,6)];
        B=[0 ; VAR_OUT(:,7)];
        ET=[0 ; VAR_OUT(:,5)];
        W1=[0 ; VAR_OUT(:,12)];
        W2=[0 ; VAR_OUT(:,13)];
        W3=[0 ; VAR_OUT(:,14)];
        W=W1+W2+W3;
        
        %   OUTVAR	OUT_PREC            4
        %   OUTVAR	OUT_EVAP            5
        %   OUTVAR	OUT_RUNOFF          6
        %   OUTVAR	OUT_BASEFLOW        7
        %   OUTVAR	OUT_SWE             8
        %   OUTVAR	OUT_SNOW_MELT       9
        %   OUTVAR	OUT_SNOWF           10
        %   OUTVAR	OUT_RAINF           11
        %   OUTVAR  OUT_SOIL_MOIST      12
        
        f_W_snow(1)=0;
        f_W_rain(1)=0;
        f_i_snow(1)=0.5;
        f_i_rain(1)=0.5;
        count=0;
        
        for t=2:NOD+1
            
            
            if(M(t)==0&&Rain(t)==0)
       
                f_i_snow(t)=f_i_snow(t-1);
                f_i_rain(t)= f_i_rain(t-1);
                
            else
                f_i_snow(t)=M(t)/(M(t)+Rain(t));
                f_i_rain(t)=Rain(t)/(M(t)+Rain(t));
            end
            
            i(t)=Rain(t)+M(t)-R(t);
            
            Sub(t)=(SWE(t-1)+Snowfall(t)-M(t)-SWE(t));
            
            f_W_snow(t)=(f_W_snow(t-1)*W(t-1)+f_i_snow(t-1)*i(t)-f_W_snow(t-1)*(ET(t)-Sub(t))-f_W_snow(t-1)*B(t))/W(t);
            
            if f_W_snow(t)<0
                f_W_snow(t)=0;
            elseif f_W_snow(t)>1
                f_W_snow(t)=1;
            end
            
            f_W_rain(t)=(f_W_rain(t-1)*W(t-1)+f_i_rain(t-1)*i(t)-f_W_rain(t-1)*(ET(t)-Sub(t))-f_W_rain(t-1)*B(t))/W(t);
            
            
            if f_W_rain(t)<0
                f_W_rain(t)=0;
            elseif f_W_rain(t)>1
                f_W_rain(t)=1;
            end
            
            
            if f_W_rain(t)+f_W_snow(t)>1
                f_W_rain(t)=1-f_W_snow(t);
            end
            
            f_W_unknown(t)=1-f_W_snow(t)-f_W_rain(t);
            
            R_snow(t)=M(t)-f_i_snow(t)*i(t);
            B_snow(t)=f_W_snow(t)*B(t);
            if (R(t)+B(t))==0
                f_Q_snow(t)=0;
            else
                f_Q_snow(t)=(R_snow(t)+B_snow(t))/(R(t)+B(t));
            end
            
            if   R_snow(t)-R(t)>0.0001 ||  B_snow(t)-B(t)>0.0001
                fprintf('Runoff or baseflow from snow greater than normal');
                %fprintf('Vars:%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f\n%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f\t%0.4f\n------',R_snow(t),B_snow(t),R(t),B(t),Rain(t),M(t),Snowfall(t),R_snow(t-1),B_snow(t-1),R(t-1),B(t-1),Rain(t-1),M(t-1),Snowfall(t-1))
            end
            
        end
        grid_counter=grid_counter+1;
        
        if(find(B_snow<-0.001))
            fprintf('Baseflow low');
        end
        
        
        filename_snowmelt = strcat(snowout,'fluxes_',num2str(obj.IndexMatrix.IndexMatrix(grid,2),'%0.4f'),'_',num2str(obj.IndexMatrix.IndexMatrix(grid,3),'%0.4f'));
        VAR_OUT(:,6)=R_snow(2:end)';
        VAR_OUT(:,7)=B_snow(2:end)';
        dlmwrite(filename_snowmelt,VAR_OUT,'\t');
        
        
        if obj.baseflow_sep==1
        vicout_base= [output,'base/'];
        snowout_base=[output,'base_s/'];
        system([  'mkdir -p ',obj.paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/base/']);
        system([  'mkdir -p ',obj.paths.io,'results_P',num2str(obj.p),'_T',num2str(obj.t),'/vic/base_s/']) ;
        filename_base = strcat(vicout_base,'fluxes_',num2str(obj.IndexMatrix.IndexMatrix(grid,2),'%0.4f'),'_',num2str(obj.IndexMatrix.IndexMatrix(grid,3),'%0.4f'));
        VAR_OUT(:,6)=0;
        VAR_OUT(:,7)=B(2:end);
        dlmwrite(filename_base,VAR_OUT,'\t');
        
        filename_snowbase = strcat(snowout_base,'fluxes_',num2str(obj.IndexMatrix.IndexMatrix(grid,2),'%0.4f'),'_',num2str(obj.IndexMatrix.IndexMatrix(grid,3),'%0.4f'));
        VAR_OUT(:,6)=0;
        VAR_OUT(:,7)=B_snow(2:end)';
        dlmwrite(filename_snowbase,VAR_OUT,'\t');
        
        end
    
end
