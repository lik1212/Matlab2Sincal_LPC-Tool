function Dist_List = randomDistributionPV(SinInfo,Profiles_Names,method)
%
%
%
% Author(s): P. Gassler, R. Brandalik

if nargin~=3
   error('Too many or too few arguments'); 
end

Dist_List = table;
DC_Infeeder = sortrows(SinInfo.DCInfeeder.Name);
PV_Profile = cell(size(SinInfo.DCInfeeder,1),1);
nb_DCinf = size(SinInfo.DCInfeeder,1);
nb_DCinf_3p = nb_DCinf / 3;

nb_profiles = numel(Profiles_Names);
nb_profiles_3p = nb_profiles / 3;
Profiles_Names = sortrows(Profiles_Names);
nb_k = ceil(nb_DCinf_3p/nb_profiles_3p);
switch method
    case '3p'
        for k = 1 : nb_k
            perm = ((randperm(nb_profiles_3p) - 1) * 3) + 1;
            dist = zeros(nb_profiles,1);
            dist(1:3:end) = perm;
            dist(2:3:end) = perm + 1;
            dist(3:3:end) = perm + 2;
            if k ~= nb_k
                PV_Profile(1 + (k-1) * nb_profiles:nb_profiles * k) = Profiles_Names(dist);
            else
                PV_Profile(1 + (k-1) * nb_profiles:end) = Profiles_Names(dist(1:nb_DCinf - (nb_k-1)*nb_profiles));
            end
        end
    case '1p'
        for k = 1 : nb_k
            dist = randperm(nb_profiles);
            if k ~= nb_k
                PV_Profile(1 + (k-1) * nb_profiles:nb_profiles * k) = Profiles_Names(dist);
            else
                PV_Profile(1 + (k-1) * nb_profiles:end) = Profiles_Names(dist(1:nb_DCinf - (nb_k-1)*nb_profiles));
            end
        end
end

Dist_List.Grid_Load = cell(nb_DCinf,1);
Dist_List.Load_Profile = cell(nb_DCinf,1);
dist = zeros(nb_DCinf,1);
% dist(1:1:nb_DCinf_3p) = [1:3:nb_DCinf];
% dist(nb_DCinf_3p + 1:1:nb_DCinf_3p*2) = [2:3:nb_DCinf];
% dist(nb_DCinf_3p*2 + 1:1:nb_DCinf) = [3:3:nb_DCinf];
dist = 1 : nb_DCinf;                                        % TODO
Dist_List.Grid_Load = DC_Infeeder(dist);
Dist_List.Load_Profile = PV_Profile(dist);

end