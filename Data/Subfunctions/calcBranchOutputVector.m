function Vector = calcBranchOutputVector(options)
% Determines which branch results values to output from Sincal Database
% For example only I or I,S_flow,P_flow,Q_flow and so on
%
% Author(s): P. Gassler

Col_Name = load('Col_Name_ULFBranchResult.mat');

% Vector = [2,3,5,6,8,11,12,14,17,18,20,41];
Vector = [2,3,41];

if options.I
    Vector = [Vector,8,14,20];
end

if options.P_flow
    Vector = [Vector,5,11,17];
end

if options.Q_flow
    Vector = [Vector,6,12,18];
end

if options.S_flow
    Vector = [Vector,7,13,19];
end

Vector = sort(Vector);

end