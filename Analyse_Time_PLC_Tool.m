% stript
Inputs = struct;
% Inputs.Grid_Path = 'Z:\Gassler\7_Hiwi\Grids';
% Inputs.Grid_Path = 'Z:\Gassler\7_Hiwi\Grids\Sincal 13';
% Inputs.Grid_Name = 'SmartSCADA_Netzmodell_2015_11_30';
% Inputs.Grid_Name = 'SmartSCADA_Netzmodell_2015_11_30_SIN13';
% Inputs.Grid_Name = 'Wessum-Riete_Netz_170726_1';
% Inputs.Grid_Name = 'Wessum-Riete_Netz_170726_empty';
Inputs.LP_dist_type = 'random';
Inputs.PV_dist_type = 'list';
Inputs.Output_option_raw = false;
Inputs.Output_option_del_temp_files = true;
Inputs.Output_option_del_temp_files_begin = true;
Inputs.Output_option_preparation = true;
Inputs.Output_option_per_node_branch = true;
Inputs.Output_option_per_unit = true;
Inputs.Output_option_U = true;
Inputs.Output_option_P = false;
Inputs.Output_option_Q = false;
Inputs.Output_option_S = false;
Inputs.Output_option_phi = true;
Inputs.Output_option_I = true;
Inputs.Output_option_P_flow = false;
Inputs.Output_option_Q_flow = false;
Inputs.Output_option_S_flow = false;
Inputs.Output_option_T_vector = true;
Inputs.Output_option_Sin_Info = true;
tic
Mat2Sin_LPCalc(Inputs);
toc
