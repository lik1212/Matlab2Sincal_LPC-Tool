function Dist_List = alphaDistribution(SinInfo, Profiles_Names)
%
%   Distribution List alphabetical sorted
%
% Author(s): P. Gassler, R. Brandalik

if nargin~=2; error('Wrong number of input arguments'); end

Dist_List = table;
Profiles_Names = sort(Profiles_Names);
if isfield(SinInfo,'Load')
    Grid_Load = sortrows(SinInfo.Load.Name);
    if numel(Profiles_Names) > numel(Grid_Load)
        Dist_List.Grid_Load    = Grid_Load;
        Dist_List.Load_Profile = Profiles_Names(1:numel(Grid_Load));
    elseif numel(Profiles_Names) > 0
        mult_Profiles_Names = ceil(numel(Grid_Load)/numel(Profiles_Names));
        Profiles_Names = repmat(Profiles_Names,mult_Profiles_Names,1);
        Dist_List.Grid_Load    = Grid_Load;
        Dist_List.Load_Profile = Profiles_Names(1:numel(Grid_Load));
    else
        Dist_List.Grid_Load    = zeros(0);
        Dist_List.Load_Profile = zeros(0);
    end
else
    Dist_List.Grid_Load    = zeros(0);
    Dist_List.Load_Profile = zeros(0);
end