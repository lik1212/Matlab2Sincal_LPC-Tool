function Dist_List = randomDistribution(SinInfo,Profiles_Names)
%
%
%
% Author(s): P. Gassler

if nargin~=3
   error('Too many or too few arguments'); 
end

Dist_List = table;
if isfield(SinInfo,'Load')
    Grid_Load = sortrows(SinInfo.Load.Name);
% Load_Profile = cell(size(SinInfo.Load,1),1);
% nb_loads = size(SinInfo.Load,1);
% % nb_loads_3p = nb_loads / 3;
% 
% nb_profiles = numel(Profiles_Names);
% % nb_profiles_3p = nb_profiles / 3;
% Profiles_Names = sortrows(Profiles_Names);
% nb_k = ceil(nb_loads_3p/nb_profiles_3p);
% switch type
%     case '3p'
%         for k = 1 : nb_k
%             perm = ((randperm(nb_profiles_3p) - 1) * 3) + 1;
%             dist = zeros(nb_profiles,1);
%             dist(1:3:end) = perm;
%             dist(2:3:end) = perm + 1;
%             dist(3:3:end) = perm + 2;
%             if k ~= nb_k
%                 Load_Profile(1 + (k-1) * nb_profiles:nb_profiles * k) = Profiles_Names(dist);
%             else
%                 Load_Profile(1 + (k-1) * nb_profiles:end) = Profiles_Names(dist(1:nb_loads - (nb_k-1)*nb_profiles));
%             end
%         end
%     case '1p'
%         for k = 1 : nb_k
%             dist = randperm(nb_profiles);
%             if k ~= nb_k
%                 Load_Profile(1 + (k-1) * nb_profiles:nb_profiles * k) = Profiles_Names(dist);
%             else
%                 Load_Profile(1 + (k-1) * nb_profiles:end) = Profiles_Names(dist(1:nb_loads - (nb_k-1)*nb_profiles));
%             end
%         end
% end
% 
% Dist_List.Grid_Load = cell(nb_loads,1);
% Dist_List.Load_Profile = cell(nb_loads,1);
% dist = zeros(nb_loads,1);
% % dist(1:1:nb_loads_3p) = [1:3:nb_loads];
% dist(nb_loads_3p + 1:1:nb_loads_3p*2) = [2:3:nb_loads];
% dist(nb_loads_3p*2 + 1:1:nb_loads) = [3:3:nb_loads];
% 
% Dist_List.Grid_Load = Grid_Load(dist);
% Dist_List.Load_Profile = Load_Profile(dist);
    if numel(Profiles_Names) > numel(Grid_Load)
        Dist_List.Grid_Load    = Grid_Load;
        Dist_List.Load_Profile = Profiles_Names(randperm(numel(Profiles_Names),numel(Grid_Load)));
    elseif numel(Profiles_Names) > 0
        mult_Profiles_Names = ceil(numel(Grid_Load)/numel(Profiles_Names));
        Profiles_Names = repmat(Profiles_Names,mult_Profiles_Names,1);
        Dist_List.Grid_Load    = Grid_Load;
        Dist_List.Load_Profile = Profiles_Names(randperm(numel(Profiles_Names),numel(Grid_Load)));
    else
        Dist_List.Grid_Load    = zeros(0);
        Dist_List.Load_Profile = zeros(0);
    end
else
    Dist_List.Grid_Load    = zeros(0);
    Dist_List.Load_Profile = zeros(0);
end