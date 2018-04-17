function Dist_List = randomDistributionPV(SinInfo, Profiles_Names)
%
%   Distribution List randomly sorted
%
% Author(s): P. Gassler, R. Brandalik

if nargin ~= 2; error('Too many or too few arguments'); end

Dist_List = table;
if isfield(SinInfo,'DCInfeeder')
    DC_Infeeder = sortrows(SinInfo.DCInfeeder.Name);
    if numel(Profiles_Names) > numel(DC_Infeeder)
        Dist_List.Grid_Load    = DC_Infeeder;
        Dist_List.Load_Profile = Profiles_Names(randperm(numel(Profiles_Names),numel(DC_Infeeder)));
    elseif numel(Profiles_Names) > 0
        mult_Profiles_Names = ceil(numel(DC_Infeeder)/numel(Profiles_Names));
        Profiles_Names = repmat(Profiles_Names,mult_Profiles_Names,1);
        Dist_List.Grid_Load    = DC_Infeeder;
        Dist_List.Load_Profile = Profiles_Names(randperm(numel(Profiles_Names),numel(DC_Infeeder)));
    else
        Dist_List.Grid_Load    = zeros(0);
        Dist_List.Load_Profile = zeros(0);
    end
else
    Dist_List.Grid_Load    = zeros(0);
    Dist_List.Load_Profile = zeros(0);
end