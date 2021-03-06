%% Demonstration of the Load Profile Calculation Tool without GUI
% Power flow calculation with load profiles in Sincal

%% Input settings

Inputs = struct;
Inputs.Grid_Path          = [pwd, '\Inputs\Grids\'        ];
Inputs.Grid_Name          = 'S1a_de'                       ;
Inputs.LP_DB_Path         = [pwd, '\Inputs\Load_Profiles\']; % Path for load profiles
Inputs.LP_DB_Type         = 'DB'                           ;
Inputs.LP_DB_Name         = 'IEEE_Lo_Profiles.mat'         ;
Inputs.LP_dist_type       = 'DB_order'                     ;    
Inputs.PV_DB_Path         = [pwd, '\Inputs\PV_Profiles\'  ]; % Path for PV profiles
Inputs.PV_DB_Type         = 'DB'                           ;
Inputs.PV_DB_Name         = 'RB_PV_Profiles.mat'           ;
Inputs.PV_dist_type       = 'DB_order'                     ;
Inputs.ResultsSuffix      = 'Initial'                      ; % Optional

Inputs.VerSincal          = 14  ;
Inputs.ParrallelCom       = true;
Inputs.NumelCores         = 3  ;

Inputs.Outputs_Path       = [pwd, '\Outputs\'         ]   ; % Path for load profiles

% If LP_dist_type or PV_dist_type is set to 'list', define the list:
% Inputs.LP_dist_path       = [pwd, '\Inputs\Profiles_Distribution\' ] ; % Path for the L.P. distribution file
% Inputs.LP_dist_list_name  = 'LoadName_IEEE_LV_Profiles.txt'          ; 
% Inputs.PV_dist_path       = [pwd, '\Inputs\Profiles_Distribution\' ] ; % Path for the PV.P. distribution file
% Inputs.PV_dist_list_name  = 'DCInfeederName_IEEE_LV_Profiles.txt'    ;

% Example of other functions:
% Inputs.Output_option_raw      = true ;
% Inputs.waitbar_activ          = false;
% Inputs.Output_option_raw_only = true ;

%% Start function

status = Mat2Sin_LPCalc(Inputs);
