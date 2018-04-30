function Settings = defaultSettings(Inputs)
% defaultSettings checks the content of Inputs and based on it define the
% Settings. If some optional field do not occur in "Inputs" set the default
% values for it.
%
% Author(s): P. Gassler, R. Brandalik

%% Transfer main info from "Inputs

Settings = Inputs;

%% Default setting if the inputs do not occur in the variable "Inputs"

default_Options = {...
    'Output_option_U'               , true           ;...
    'Output_option_P'               , true           ;...
    'Output_option_Q'               , true           ;...
    'Output_option_S'               , true           ;...
    'Output_option_phi'             , true           ;...
    'Output_option_I'               , true           ;...
    'Output_option_P_flow'          , true           ;...
    'Output_option_Q_flow'          , true           ;...
    'Output_option_S_flow'          , true           ;...
    'Output_option_Sin_Info'        , true           ;...
    'Output_option_raw'             , false          ;...
    'Output_option_raw_only'        , false          ;...
    'Output_option_per_node_branch' , true           ;...
    'Output_option_per_unit'        , true           ;...
    'Output_option_Sin_Info'        , true           ;...
    'Output_option_del_temp_files'  , true           ;...
    'Output_option_preparation'     , true           ;...
    'waitbar_activ'                 , true           ;...
    'Temp_Sim_Path'                 , [pwd,'\Temp\'] ;...
    };

for k_Opt = 1 : size(default_Options,1)
    if ~isfield(Inputs, default_Options{k_Opt,1})
        Settings.(default_Options{k_Opt,1}) = default_Options{k_Opt,2};
    end
end

% Timestamp
Settings.Timestamp = char(datetime('now','Format','yyMMdd_HH_mm_ss'));

% TODO: Output_option_T_vector -> T_vector