function Dist_List = create_DistributionList(SinInfo, ElementType ,Profiles_Names, dist_type)
%create_DistributionList - Create the distribution list of profiles to grid
%load or DCInfeeders.
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
        Profiles_Names      = repmat(Profiles_Names, mult_Profiles_Names, 1);
        num_Profiles        = numel (Profiles_Names); % Correct number of profiles     
    end
    switch dist_type
        case 'random'   % Randomly sorted
            Profiles_Names = Profiles_Names(randperm(num_Profiles, num_Grid_Loads));
        case 'alphab'   % Alphabetical sorted
            Profiles_Names = sort(Profiles_Names);
        case 'DB_order' % Database order sorted
        otherwise
            error('Unknown Distribution Type.');
    end
    Dist_List.Load_Profile = Profiles_Names(1:num_Grid_Loads);
else
    % If no grid loads nor profiles occur
    Dist_List.Grid_Load    = zeros(0);
    Dist_List.Load_Profile = zeros(0);
end