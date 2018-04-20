function Vector = calcNodeOutputVector(Settings)
% Determines which node results values to output from Sincal Database
% For example only U or U, S, P, Q and so on
%
% Author(s): P. Gassler, R. Brandalik

% Check Data\Static_Input\Col_Name_ULFNodeResult.mat for more information

Vector = [2, 47];   % Node_ID & ResTime
if Settings.Output_option_U  ; Vector = [Vector, 4, 10, 16, 22]; end
if Settings.Output_option_phi; Vector = [Vector, 6, 12, 18    ]; end
if Settings.Output_option_P  ; Vector = [Vector, 7, 13, 19    ]; end
if Settings.Output_option_Q  ; Vector = [Vector, 8, 14, 20    ]; end
if Settings.Output_option_S  ; Vector = [Vector, 9, 15, 21, 31]; end
Vector = sort(Vector);