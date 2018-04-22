function Dist_List = randomDistributionPV(SinInfo, ElementType ,Profiles_Names)
%
%   Distribution List randomly sorted
%
% Author(s): P. Gassler, R. Brandalik

if nargin ~= 3; error('Too many or too few arguments'); end

Dist_List = table;
if isfield(SinInfo, ElementType)
    Grid_Element = sortrows(SinInfo.(ElementType).Name);
    if numel(Profiles_Names) > numel(Grid_Element)
        Dist_List.Grid_Load    = Grid_Element;
        Dist_List.Load_Profile = Profiles_Names(randperm(numel(Profiles_Names),numel(Grid_Element)));
    elseif numel(Profiles_Names) > 0
        mult_Profiles_Names = ceil(numel(Grid_Element)/numel(Profiles_Names));
        Profiles_Names = repmat(Profiles_Names,mult_Profiles_Names,1);
        Dist_List.Grid_Load    = Grid_Element;
        Dist_List.Load_Profile = Profiles_Names(randperm(numel(Profiles_Names),numel(Grid_Element)));
    else
        Dist_List.Grid_Load    = zeros(0);
        Dist_List.Load_Profile = zeros(0);
    end
else
    Dist_List.Grid_Load    = zeros(0);
    Dist_List.Load_Profile = zeros(0);
end