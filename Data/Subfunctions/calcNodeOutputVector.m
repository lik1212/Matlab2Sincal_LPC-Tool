function Vector = calcNodeOutputVector(options)
% Determines which node results values to output from Sincal Database
% For example only U or U,S,P,Q and so on
%
% Author(s): P. Gassler


Col_Name = load('Col_Name_ULFNodeResult.mat');

% Vector = [2,4,6,7,8,9,10,12,13,14,15,16,18,19,20,21,22,31,47];
Vector = [2,47];

if options.U
    Vector = [Vector,4,10,16,22];
end

if options.S
    Vector = [Vector,9,15,21,31];
end

if options.P
    Vector = [Vector,7,13,19];
end

if options.Q
    Vector = [Vector,8,14,20];
end

if options.phi
    Vector = [Vector,6,12,18];
end

Vector = sort(Vector);

end