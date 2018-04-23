function Vector = calcBranchOutputVector(Settings)
% Determines which branch results values to output from Sincal Database
% For example only I or I, S_flow, P_flow, Q_flow and so on
%
% Author(s): P. Gassler, R. Brandalik

% Check Data\Static_Input\Col_Name_ULFBranchResult.mat for more information

Vector = [2, 3, 41]; % Terminal1_ID, Terminal2_ID, ResTime
if Settings.Output_option_P_flow; Vector = [Vector, 5, 11, 17]; end
if Settings.Output_option_Q_flow; Vector = [Vector, 6, 12, 18]; end
if Settings.Output_option_S_flow; Vector = [Vector, 7, 13, 19]; end
if Settings.Output_option_I     ; Vector = [Vector, 8, 14, 20]; end
Vector = sort(Vector);