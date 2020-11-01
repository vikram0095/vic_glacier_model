function [] = gparam(fileout,result_dir,Emode,run_period,soil_file,forcing_file,forcing_start_year,MAX_SNOW_TEMP,MIN_RAIN_TEMP)

   filein='/home/vikram/VIC/VIC_Himalayas/parameters/vic/gparamo_prec_separated.txt';
   filein='/home/vikram/VIC/VIC_Himalayas/parameters/vic/gparamo.txt';
%         MAX_SNOW_TEMP       =    0.5;
%         MIN_RAIN_TEMP       =    -0.5;
                    FULL_ENERGY   =        'FALSE'; 
                    FROZEN_SOIL = 'FALSE';
if Emode==1
                    
                    FULL_ENERGY   =        'TRUE'; 
                    FROZEN_SOIL = 'FALSE';
end

                    STARTYEAR         =    num2str(run_period(1));
                    STARTMONTH =        '01'  ;
                    STARTDAY   =           '01'  ;
                    STARTHOUR  =           '00'   ;
                    ENDYEAR    =           num2str(run_period(2));
                    ENDMONTH   =           '12'    ; 
                    ENDDAY     =           '31'   ;

%                     STARTYEAR         =    '1981';
%                     STARTMONTH =        '01'  ;
%                     STARTDAY   =           '01'  ;
%                     STARTHOUR  =           '00'   ;
%                     ENDYEAR    =           '2006' ;
%                     ENDMONTH   =           '12'    ; 
%                     ENDDAY     =           '31'   ;

fid = fopen(filein,'r');

fido = fopen(fileout,'w');
count=0;
while ~feof(fid)
    count=count+1;
    
    if count==8
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
        tline = fgetl(fid);
            count=count+10;

            tline=strcat(   'STARTYEAR              \t',STARTYEAR,'   # year model simulation starts \n',...
                            'STARTMONTH             \t',STARTMONTH,'     # month model simulation starts \n',...
                            'STARTDAY               \t',STARTDAY,'   \n',...
                            'STARTHOUR              \t',STARTHOUR,'     # day model simulation starts \n',...
                            'ENDYEAR                \t',ENDYEAR,'   # year model simulation ends \n',...
                            'ENDMONTH               \t',ENDMONTH,'     # month model simulation ends \n',...
                            'ENDDAY                 \t',ENDDAY,'     # day model simulation ends \n',...
                            'FULL_ENERGY            \t',FULL_ENERGY,'  # TRUE = calculate full energy balance;  \n',...%FALSE = compute water balance only
                            'FROZEN_SOIL            \t',FROZEN_SOIL,'\n',...
                            'MAX_SNOW_TEMP          \t',num2str(MAX_SNOW_TEMP),'     # day model simulation ends \n',...
                            'MIN_RAIN_TEMP          \t',num2str(MIN_RAIN_TEMP),' ');

    fprintf(fido,tline);
    fprintf(fido,'\n');
    elseif count==44
        tline = fgetl(fid);
        tline=['SOIL             ',soil_file,'     # Soil parameter path/file'];
        fprintf(fido,tline);
        fprintf(fido,'\n');
    elseif count==24
        tline = fgetl(fid);
        tline=['FORCING1             ',forcing_file,'  # Forcing file path and prefix, ending in '];
        fprintf(fido,tline);
        fprintf(fido,'\n');
        
    elseif count==32
        tline = fgetl(fid);
        %FORCEYEAR            1981  # Year of first forcing record

        tline=['FORCEYEAR             ',num2str(forcing_start_year),'  # Forcing file path and prefix, ending in '];
        fprintf(fido,tline);
        fprintf(fido,'\n');
    elseif count==59
        tline = fgetl(fid);
        tline=['RESULT_DIR          ',result_dir,'  # result '];
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
