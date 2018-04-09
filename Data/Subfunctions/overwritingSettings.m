function Settings_output = overwritingSettings(Inputs,Settings)
% overwritingSettings checks the content of Inputs and overwrite the
% simulation settings with this content
%
%
% Author(s): P. Gassler

if isfield(Inputs,'Output_option_del_temp_files')
    Settings.del_sim_files = Inputs.Output_option_del_temp_files;
end

if isfield(Inputs,'Output_option_del_temp_files_begin')
    Settings.del_sim_files_begin = Inputs.Output_option_del_temp_files_begin;
end

if isfield(Inputs,'Output_option_preparation')
    Settings.output_prepare = Inputs.Output_option_preparation;
end

if isfield(Inputs,'LP_dist_type')
    Settings.LP_dist_type = Inputs.LP_dist_type;
end

if isfield(Inputs,'PV_dist_type')
    Settings.PV_dist_type = Inputs.PV_dist_type;
end

if isfield(Inputs,'PV_dist_list_name')
    Settings.PV_dist_list_name = Inputs.PV_dist_list_name;
end

if isfield(Inputs,'LP_dist_list_name')
    Settings.LP_dist_list_name = Inputs.LP_dist_list_name;
end

if isfield(Inputs,'LP_Type')
    Settings.LP_Type = Inputs.LP_Type;
end

if isfield(Inputs,'PV_Type')
    Settings.PV_Type = Inputs.PV_Type;
end

if isfield(Inputs,'LP_DB_Name')
    Settings.LP_DB_Name = Inputs.LP_DB_Name;
end

if isfield(Inputs,'PV_DB_Name')
    Settings.PV_DB_Name = Inputs.PV_DB_Name;
end

if isfield(Inputs,'LP_dist_path')
    Settings.LP_dist_Path = Inputs.LP_dist_path;
end

if isfield(Inputs,'PV_dist_path')
    Settings.PV_dist_Path = Inputs.PV_dist_path;
end

if isfield(Inputs,'LP_Path')
    Settings.LP_Path = Inputs.LP_Path;
end

if isfield(Inputs,'PV_Path')
    Settings.PV_Path = Inputs.PV_Path;
end

Settings_output = Settings;
 
end