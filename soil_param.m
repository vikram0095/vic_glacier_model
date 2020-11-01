function [] = soil_param(file,Mask,binf,Ds,Ds_MAX,Ws,d2,d3,snow_rough)

    % '/home/vikram/VIC/VIC_Himalayas/parameters/vic/soil_param.txt'
    %`file output file name
    % basin 1 for sutlej
    %       2 for Nepalese
    % d1,d2,d3 soil depths

    load('./mat/IndexMatrix.mat') 
    load('./mat/MU_COMMON.mat')
    load('./mat/SoilData.mat')
    load('./mat/MeanTempP.mat')
    load('./mat/AvgElevation.mat')
    load('./mat/MnAnnPrec.mat')
   
    %file='/home/vikram/VIC/HIM.calibration/parameters/soil_param.txt'
    
    fileID = fopen(file,'w');
    
    TOTAL_GRIDS=size(IndexMatrix,1);

        for current_grid=1:TOTAL_GRIDS
            
            RUN=0;
                    if(find(Mask==current_grid))
                        RUN=1;
                    end
            GRID=current_grid;
            LAT=IndexMatrix(current_grid,2);
            LON=IndexMatrix(current_grid,3);
            C=2;
            INFILT= binf;  
                    if MU_COMMON(current_grid)==0
                        continue;
                    end
                    
            ind=find(SoildataHWSD(:,1)==MU_COMMON(current_grid),1);
            
            soiltype1=SoildataHWSD(ind,2);
            soiltype2=SoildataHWSD(ind,4);
            
                     if(soiltype1<0)
                            soiltype1=9;
                     end
                     
                     if(soiltype2<0)
                            soiltype2=soiltype1;
                     end
             
            DEPTH_1=0.1;
            DEPTH_2=d2;
            DEPTH_3=d3;
            
            EXPT_1= 3+2*SoildataSchaake(soiltype1,10);
            EXPT_3= 3+2*SoildataSchaake(soiltype2,10);
            if DEPTH_2 < 0.2
                EXPT_2=EXPT_1;
            else
                EXPT_2= ( (DEPTH_2-0.2) *EXPT_3  +  0.2 * EXPT_1)   /   DEPTH_2;
            end
           
            Ksat_1=SoildataSchaake(soiltype1,9) * 240;%cm/hr to mm/day
            Ksat_3=SoildataSchaake(soiltype2,9) * 240;
            if DEPTH_2 < 0.2
                Ksat_2=Ksat_1;
            else
                Ksat_2=  DEPTH_2 / ( (DEPTH_2-0.2) / Ksat_3  +  0.2 / Ksat_1) ;
            end
             
            PHI_1=-9999;
            PHI_2=-9999;
            PHI_3=-9999;
            
            
            poro1=SoildataSchaake(soiltype1,8);
            poro3=SoildataSchaake(soiltype2,8);
            if DEPTH_2 < 0.2
                poro2=poro1;
            else
                poro2=( (DEPTH_2-0.2) * poro3  +  0.2 * poro1)   /   DEPTH_2;
            end
            
            MOIST_1=poro1*DEPTH_1*1000;% mm
            MOIST_2=poro2*DEPTH_2*1000;
            MOIST_3=poro3*DEPTH_3*1000;

            ELEV=AvgEle(current_grid);%dem

            AVG_T=MeanTemperature(current_grid);% from_forcing;
            DP=4;
            
            BUBLE1=SoildataSchaake(soiltype1,11);
            BUBLE3=SoildataSchaake(soiltype2,11);
            if DEPTH_2 < 0.2
                BUBLE2=BUBLE1;
            else
                BUBLE2=( (DEPTH_2-0.2) * BUBLE3  +  0.2 * BUBLE1)   /   DEPTH_2;
            end
            
            QUARZ1=0.6930;
            QUARZ2=0.6930;
            QUARZ3=0.6930;

            BULKDN1=SoildataHWSD(ind,3)*1000;
            BULKDN3=SoildataHWSD(ind,5)*1000;
            if DEPTH_2 < 0.2
                BULKDN2=BULKDN1;
            else
                BULKDN2=( (DEPTH_2-0.2) * BULKDN3  +  0.2 * BULKDN1)   /   DEPTH_2;
            end
            
            if BULKDN1<1000
                 BULKDN1=SoildataSchaake(soiltype1,5)*1000;
            end

            if BULKDN3<1000
                 BULKDN3=SoildataSchaake(soiltype2,5)*1000;
                 BULKDN2=( (DEPTH_2-0.2) * BULKDN3  +  0.2 * BULKDN1)   /   DEPTH_2;
            end

            PARTDN1	=   2650;
            PARTDN2 =   2650;
            PARTDN3 =   2650;
            
            OFF_GMT	= LON * 24/360;
            
            WcrFT1=SoildataSchaake(soiltype1,6)/ poro1;
            WcrFT3=SoildataSchaake(soiltype2,6)/ poro3;
            if DEPTH_2 < 0.2
                WcrFT2=WcrFT1;
            else
                WcrFT2=( (DEPTH_2-0.2) * WcrFT3  +  0.2 * WcrFT1)   /   DEPTH_2;
            end
           
            WpFT1=SoildataSchaake(soiltype1,7)/ poro1;
            WpFT3=SoildataSchaake(soiltype2,7)/ poro3;
            if DEPTH_2 < 0.2
                WpFT2=WpFT1;
            else
                WpFT2=( (DEPTH_2-0.2) * WpFT3  +  0.2 * WpFT1)   /   DEPTH_2;
            end
            Z0_SOIL=0.01;
%             Z0_SNOW=0.03;
            Z0_SNOW=snow_rough;
            PRCP=Mean_Annual_Precipitaion(current_grid);%forcing
            
            RESM1=SoildataSchaake(soiltype1,12);
            RESM3=SoildataSchaake(soiltype2,12);
            RESM2=( (DEPTH_2-0.2) * RESM3  +  0.2 * RESM1)   /   DEPTH_2;
             
            FS_ACTV=1;
            %slpdistr=5.5;
            if(RUN)
                        fprintf(fileID,'%d %d %.4f %.4f %0.4f %.4f %.4f %0.4f %d %.4f %.4f %.4f %.4f %.4f %.4f %d %d %d %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %d %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %d\r\n',...
                        RUN,GRID, LAT,LON,INFILT,   Ds , Ds_MAX , Ws , C ,... 
                        EXPT_1,  EXPT_2 ,EXPT_3 ,  Ksat_1,  Ksat_2,Ksat_3 , ...
                        PHI_1   ,PHI_2  ,PHI_3   ,   MOIST_1, MOIST_2 , MOIST_3 ,...
                        ELEV   , DEPTH_1, DEPTH_2, DEPTH_3 , AVG_T ,...
                        DP  ,BUBLE1  ,BUBLE2  , BUBLE3  ,  QUARZ1 ,QUARZ2,QUARZ3  , ...
                        BULKDN1, BULKDN2, BULKDN3,PARTDN1, PARTDN2 , PARTDN3, OFF_GMT, ...
                        WcrFT1 , WcrFT2, WcrFT3  ,  WpFT1,   WpFT2 ,WpFT3   ,   ...
                        Z0_SOIL, Z0_SNOW ,PRCP  ,  RESM1  , RESM2 , RESM3 ,     FS_ACTV);
            end
        end
    fclose(fileID);
end
