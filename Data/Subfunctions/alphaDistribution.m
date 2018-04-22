function Dist_List = alphaDistribution(SinInfo, ElementType ,Profiles_Names, dist_type)
%
%   Distribution List alphabetical sorted
%
% Author(s): P. Gassler, R. Brandalik

%% Main

% Check input
if nargin ~= 4; error('Wrong number of input arguments'); end
% Create distribution list
Dist_List = table;
% Check num of profiles
num_Profiles = numel(Profiles_Names);
if isfield(SinInfo, ElementType) && num_Profiles > 0
    % If grid loads and profiles occur
    Dist_List.Grid_Load = sort(SinInfo.(ElementType).Name);
    num_Grid_Loads      = numel(Dist_List.Grid_Load);
    if num_Grid_Loads > num_Profiles
        % If less profiles than grids loads occur repeat the profiles
        mult_Profiles_Names = ceil(num_Grid_Loads/num_Profiles);
        Profiles_Names      = sort  (Profiles_Names)                        ;
        Profiles_Names      = repmat(Profiles_Names, mult_Profiles_Names, 1);
    end
    switch dist_type
        case 'random' % Randomly sorted
            Dist_List.Load_Profile = Profiles_Names(randperm(num_Profiles, num_Grid_Loads));
        case 'alphab' % Alphabetical sorted
            Dist_List.Load_Profile = Profiles_Names(1:num_Grid_Loads);
        otherwise
            error('Unknown Distribution Type.');
    end
else
    % If no grid loads nor profiles occur
    Dist_List.Grid_Load    = zeros(0);
    Dist_List.Load_Profile = zeros(0);
end