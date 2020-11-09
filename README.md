# VIC-glacier model
# General Notes
VIC-glacier model is an integration glacier model with Variable infiltration capacity (VIC) Hydrological model. The glacier model implements a temperature index approach for calculating melt from glaciers and a volume area scaling equation for dynamic evolution of glacier with time. 

# Files
“track_snowmelt.m” : This file implements snowmelt tracking algorithm based on Li et al 2013.      
“tindex_model.m”: Implements the glacier model as discussed in methods section of main paper.
“soil_param.m”: creates soil parameter file for VIC model.  
“run_vic_in _parallel.m” : runs VIC model in parallel   
“rout_input”: creates input files for routing model.  
“rout_all.m” Runs routing model  
“gparam.m” creates global parameter file for VC model  
“eval_performance.m”: calculates performance criteria such as Root mean square error, Pearson’s correlation, Nash Sutcliffe Efficiency etc for model testing.  
“run_vic_basin_example.m” : An example file demonstrating the usage of the VIC-glacier  combined model.  
“vic_g_model.m”: A matlab class file that runs all other routines.  
Other Files “nse.m, islpyr.m”  
# Usage and required inputs files
We have provided an example file “run_vic_basin_example.m” that demonstrates the inputs required.     
The input folder must have two folders with the inputs in same format as in the provided sample input folder.  
The bin folder should have binaries for the VIC and the routing model.  
The mat folder should have files in the same format as in the folder provided.  

