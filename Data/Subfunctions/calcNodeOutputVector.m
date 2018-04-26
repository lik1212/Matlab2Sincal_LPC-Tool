function NodeResVariables = getNodeResVariables(Settings)
% Determines which node results values to output from Sincal Database
% For example only U or U, S, P, Q and so on
%
% Author(s): P. Gassler, R. Brandalik

% Check Data\Static_Input\Col_Name_ULFNodeResult.mat for more information

%% All Columns in ULFNodeRes

Col_Name_ULFNodeRes = { ...
    'Result_ID'         ...
    'Node_ID'           ...
    'Variant_ID'        ...
    'U1'                ...
    'U1_Un'             ...
    'phi1'              ...
    'P1'                ...
    'Q1'                ...
    'S1'                ...
    'U2'                ...
    'U2_Un'             ...
    'phi2'              ...
    'P2'                ...
    'Q2'                ...
    'S2'                ...
    'U3'                ...
    'U3_Un'             ...
    'phi3'              ...
    'P3'                ...
    'Q3'                ...
    'S3'                ...
    'Ue'                ...
    'Ue_Un'             ...
    'phie'              ...
    'Umin'              ...
    'Umin_Un'           ...
    'Umax'              ...
    'Umax_Un'           ...
    'P'                 ...
    'Q'                 ...
    'S'                 ...
    'U12'               ...
    'U12_Un'            ...
    'phi12'             ...
    'U23'               ...
    'U23_Un'            ...
    'phi23'             ...
    'U31'               ...
    'U31_Un'            ...
    'phi31'             ...
    'Fkt_Sym'           ...
    'Flag_Phase'        ...
    't'                 ...
    'tdiag'             ...
    'Flag_Result'       ...
    'ResDate'           ...
    'ResTime'           ...
    'Flag_State'        ...
    'U1_Uref'           ...
    'U2_Uref'           ...
    'U3_Uref'           ...
    'Ue_Uref'           ...
    'U12_Uref'          ...
    'U23_Uref'          ...
    'U31_Uref'          ...
};

%%

Vector = [2, 47];   % Node_ID & ResTime
if Settings.Output_option_U  ; Vector = [Vector, 4, 10, 16, 22]; end
if Settings.Output_option_phi; Vector = [Vector, 6, 12, 18    ]; end
if Settings.Output_option_P  ; Vector = [Vector, 7, 13, 19    ]; end
if Settings.Output_option_Q  ; Vector = [Vector, 8, 14, 20    ]; end
if Settings.Output_option_S  ; Vector = [Vector, 9, 15, 21, 31]; end
Vector = sort(Vector);
NodeResVariables = Col_Name_ULFNodeRes(Vector);