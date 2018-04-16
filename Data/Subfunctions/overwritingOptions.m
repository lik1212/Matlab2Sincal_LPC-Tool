function Output_options = overwritingOptions(Inputs, options)
% overwritingOptions checks the content of Inputs and overwrite the options
% for simulation output with this content
%
% Author(s): P. Gassler, R. Brandalik

if isfield(Inputs,'Output_option_U'              ); options.U           = Inputs.Output_option_U                ; end
if isfield(Inputs,'Output_option_P'              ); options.P           = Inputs.Output_option_P                ; end
if isfield(Inputs,'Output_option_Q'              ); options.Q           = Inputs.Output_option_Q                ; end
if isfield(Inputs,'Output_option_S'              ); options.S           = Inputs.Output_option_S                ; end
if isfield(Inputs,'Output_option_phi'            ); options.phi         = Inputs.Output_option_phi              ; end
if isfield(Inputs,'Output_option_I'              ); options.I           = Inputs.Output_option_I                ; end
if isfield(Inputs,'Output_option_P_flow'         ); options.P_flow      = Inputs.Output_option_P_flow           ; end
if isfield(Inputs,'Output_option_Q_flow'         ); options.Q_flow      = Inputs.Output_option_Q_flow           ; end
if isfield(Inputs,'Output_option_S_flow'         ); options.S_flow      = Inputs.Output_option_S_flow           ; end
if isfield(Inputs,'Output_option_T_vector'       ); options.T_vector    = Inputs.Output_option_T_vector         ; end
if isfield(Inputs,'Output_option_Sin_Info'       ); options.Sin_Info    = Inputs.Output_option_Sin_Info         ; end
if isfield(Inputs,'Output_option_raw'            ); options.Raw         = Inputs.Output_option_raw              ; end
if isfield(Inputs,'Output_option_raw_only'       ); options.Raw_only    = Inputs.Output_option_raw_only         ; end
if isfield(Inputs,'Output_option_per_node_branch'); options.Node_Branch = Inputs.Output_option_per_node_branch  ; end
if isfield(Inputs,'Output_option_per_unit'       ); options.Unit        = Inputs.Output_option_per_unit         ; end
if isfield(Inputs,'Output_option_raw_generated'  ); options.Unit        = Inputs.Output_option_per_unit         ; end
Output_options = options;