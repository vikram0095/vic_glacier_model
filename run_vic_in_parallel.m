    function NSE_value= run_vic_in_parallel()
    %run_type=  1 for calibration
    %           2 for testing run
    %           3 for normal run
    %           4 for future run

   
    %% Running VIC
    


    %% Running Temperature index model
 
    %%
  
    %% Writing params
    if verbose==1
        fprintf("Writing Parameters ...\n");
    end
    if calculate_nse==1
        dlmwrite(['../log/log_basin_',num2str(basin),'.txt'],[input,-9999,NSE_value],'delimiter','\t','-append');
    end
    %% Plot components
    if run_type == 2 || run_type == 3
        if verbose==1
            fprintf("Tracking snowmelt ...\n");
        end
        track_snowmelt(basin,run_type,output_folder);
        if verbose==1
            fprintf("Routing all ...\n");
        end
        rout_all(basin,run_type,output_folder);
        if verbose==1
            fprintf("Plotting ...\n");
        end
        Plot_Streamflow(run_type,basin,1,1,output_folder);
        if verbose==1
            fprintf("Completed run. \n");
        end
    end


    end

 