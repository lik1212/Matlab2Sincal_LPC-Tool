%% Demonstration of the Load Profile Calculation Tool without GUI
% Power flow calculation with load profiles in Sincal

%% Basic path settings




%% Input settings

Inputs = struct;
Inputs.LP_DB_Path         = [pwd, '\Inputs\Load_Profiles\'         ]   ; % Path for load profiles
Inputs.LP_DB_Name         = 'IEEE_Lo_Profiles.mat'                    ;
Inputs.LP_DB_Type         = 'DB'                                      ;
Inputs.LP_dist_path       = [pwd, '\Inputs\Profiles_Distribution\' ]   ; % Path for the L.P. distribution file    
Inputs.LP_dist_list_name  = 'LoadName_IEEE_LV_Profiles.txt'           ; 
Inputs.LP_dist_type       = 'list'                                    ;
Inputs.PV_DB_Path         = [pwd, '\Inputs\PV_Profiles\'           ]   ; % Path for PV profiles
Inputs.PV_DB_Name         = 'IEEE_PV_Profiles.mat'                    ;
Inputs.PV_DB_Type         = 'DB'                                      ;
Inputs.PV_dist_path       = [pwd, '\Inputs\Profiles_Distribution\' ]   ; % Path for the PV.P. distribution file
Inputs.PV_dist_list_name  = 'DCInfeederName_IEEE_LV_Profiles.txt'     ;
Inputs.PV_dist_type       = 'list'                                    ;
Inputs.Output_option_del_temp_files       = false;	% delete all temporary simulation files after simulation is complete
Inputs.Output_option_del_temp_files_begin = true;     % TODO, see comment later
Inputs.Output_option_preparation          = true;
Inputs.Grid_Path = [pwd, '\Inputs\Grids\'];
Inputs.Grid_Name = 'IEEE_LV_EU_TestFeeder';
Inputs.VerSincal      = 13  ;
Inputs.ParrallelCom   = true;
Inputs.NumelCores     = 3   ;
Inputs.Outputs_Path   = [pwd, '\Outputs\'         ]   ; % Path for load profiles

%% Start function

status = Mat2Sin_LPCalc(Inputs)