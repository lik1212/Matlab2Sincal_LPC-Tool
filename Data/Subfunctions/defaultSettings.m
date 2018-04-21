function Settings = defaultSettings(Inputs)
% defaultSettings checks the content of Inputs and based on it define the
% Settings. If some optional field do not occur in "Inputs" set the default
% values for it.
%
% Author(s): P. Gassler, R. Brandalik

%% Transfer main info from "Inputs

Settings = Inputs;

%% Default setting if the inputs do not occur in the variable "Inputs"

if ~isfield(Inputs,'Output_option_U'                    ); Settings.Output_option_U               = true  ; end
if ~isfield(Inputs,'Output_option_P'                    ); Settings.Output_option_P               = true  ; end
if ~isfield(Inputs,'Output_option_Q'                    ); Settings.Output_option_Q               = true  ; end
if ~isfield(Inputs,'Output_option_S'                    ); Settings.Output_option_S               = true  ; end
if ~isfield(Inputs,'Output_option_phi'                  ); Settings.Output_option_phi             = true  ; end
if ~isfield(Inputs,'Output_option_I'                    ); Settings.Output_option_I               = true  ; end
if ~isfield(Inputs,'Output_option_P_flow'               ); Settings.Output_option_P_flow          = true  ; end
if ~isfield(Inputs,'Output_option_Q_flow'               ); Settings.Output_option_Q_flow          = true  ; end
if ~isfield(Inputs,'Output_option_S_flow'               ); Settings.Output_option_S_flow          = true  ; end
if ~isfield(Inputs,'Output_option_Sin_Info'             ); Settings.Output_option_Sin_Info        = true  ; end
if ~isfield(Inputs,'Output_option_raw'                  ); Settings.Output_option_raw             = false ; end
if ~isfield(Inputs,'Output_option_raw_only'             ); Settings.Output_option_raw_only        = false ; end
if ~isfield(Inputs,'Output_option_per_node_branch'      ); Settings.Output_option_per_node_branch = true  ; end
if ~isfield(Inputs,'Output_option_per_unit'             ); Settings.Output_option_per_unit        = true  ; end
if ~isfield(Inputs,'Output_option_Sin_Info'             ); Settings.Output_option_Sin_Info        = true  ; end
if ~isfield(Inputs,'Output_option_del_temp_files'       ); Settings.Output_option_del_temp_files  = false ; end % delete all temporary simulation files after simulation is complete
if ~isfield(Inputs,'Output_option_preparation'          ); Settings.Output_option_preparation     = true  ; end
if ~isfield(Inputs,'waitbar_activ'                      ); Settings.waitbar_activ                 = true  ; end
% if ~isfield(Inputs,'Output_option_T_vector'           ); Settings.T_vector                      = true  ; end

if ~isfield(Inputs,'Temp_Sim_Path'                      ); Settings.Temp_Sim_Path = [pwd,'\Temp\']; end