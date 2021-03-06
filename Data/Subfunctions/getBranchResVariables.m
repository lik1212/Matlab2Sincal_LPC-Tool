function BranchResVariables = getBranchResVariables(Settings)
% Determines which branch results values to output from Sincal Database
% For example only I or I, S_flow, P_flow, Q_flow and so on
%
% Author(s): P. Gassler, R. Brandalik

% Check Data\Static_Input\Col_Name_ULFBranchResult.mat for more information

%% All Columns in ULFBranchRes

Col_Name_ULFBranchRes = {   ...
    'Result_ID'             ...
    'Terminal1_ID'          ...
    'Terminal2_ID'          ...
    'Variant_ID' 			...
    'P1'         			...
    'Q1'         			...
    'S1'         			...
    'I1'         			...
    'cos_phi1'   			...
    'I1_In'      			...
    'P2'         			...
    'Q2'         			...
    'S2'         			...
    'I2'         			...
    'cos_phi2'   			...
    'I2_In'      			...
    'P3'         			...
    'Q3'         			...
    'S3'         			...
    'I3'         			...
    'cos_phi3'   			...
    'I3_In'      			...
    'Ie'         			...
    'cos_phie'   			...
    'P'          			...
    'Q'          			...
    'S'          			...
    'Pl'         			...
    'Ql'         			...
    'Sl'         			...
    'Imin'       			...
    'Imin_In'    			...
    'Imax'       			...
    'Imax_In'    			...
    'Fkt_Sym'    			...
    'Flag_Phase' 			...
    't'          			...
    'tdiag'      			...
    'Flag_Result'			...
    'ResDate'     			...
    'ResTime'     			...
    'Flag_State'  			...
    'Imax_In1'    			...
    'Imax_In2'    			...
    'Imax_In3'    			...
    'phiI1'       			...
    'phiI2'       			...
    'phiI3'       			...
};

%% Get Variables based on the Settings

Vector = [2, 3, 41]; % Terminal1_ID, Terminal2_ID, ResTime
if Settings.Output_option_P_flow; Vector = [Vector, 5, 11, 17]; end
if Settings.Output_option_Q_flow; Vector = [Vector, 6, 12, 18]; end
if Settings.Output_option_S_flow; Vector = [Vector, 7, 13, 19]; end
if Settings.Output_option_I     ; Vector = [Vector, 8, 14, 20]; end
Vector = sort(Vector);
BranchResVariables = Col_Name_ULFBranchRes(Vector);