function Dist_List = alphaDistribution(SinInfo,Profiles_Names)
%
%
%
% Author(s): P. Gassler

if nargin~=2
   error('Too many or too few arguments'); 
end

Dist_List = table;
Grid_Load = sortrows(SinInfo.Load.Name);
Load_Profile = cell(size(SinInfo.Load,1),1);
nb_loads = size(SinInfo.Load,1);
nb_loads_3p = nb_loads / 3;

nb_profiles = numel(Profiles_Names);
nb_profiles_3p = nb_profiles / 3;
Profiles_Names = sortrows(Profiles_Names);
nb_k = ceil(nb_loads_3p/nb_profiles_3p);

for k = 1 : nb_k
    if k ~= nb_k
        Load_Profile(1 + (k-1) * nb_profiles:nb_profiles * k) = Profiles_Names();
    else
        Load_Profile(1 + (k-1) * nb_profiles:end) = Profiles_Names(1:nb_loads - (nb_k-1)*nb_profiles);
    end
end

Dist_List.Grid_Load = cell(nb_loads,1);
Dist_List.Load_Profile = cell(nb_loads,1);
dist = zeros(nb_loads,1);
dist(1:1:nb_loads_3p) = [1:3:nb_loads];
dist(nb_loads_3p + 1:1:nb_loads_3p*2) = [2:3:nb_loads];
dist(nb_loads_3p*2 + 1:1:nb_loads) = [3:3:nb_loads];

Dist_List.Grid_Load = Grid_Load(dist);
Dist_List.Load_Profile = Load_Profile(dist);

end