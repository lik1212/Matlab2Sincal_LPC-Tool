function Dist_List = meanPDistribution(SinInfo,scada_list,scada_DB,LP_DB,type)
%
%   Function OUT!
%
% Author(s): P.Gassler

Dist_List = table;
Grid_Load = sortrows(SinInfo.Load.Name);
Load_Profile = cell(size(SinInfo.Load,1),1);
nb_loads = size(SinInfo.Load,1);
nb_loads_3p = nb_loads / 3;
fieldname_LPs = fieldnames(LP_DB);
% fieldname_SCADA_LPs = fieldnames(scada_DB);
nb_profiles = numel(fieldname_LPs);
% nb_profiles_scada = numel(fieldname_SCADA_LPs);
nb_profiles_3p = nb_profiles / 3;
LP2GL_Lo = readtable(scada_list,'Delimiter',';');
LP2GL_Lo = sortrows(LP2GL_Lo);
if nb_loads ~= size(LP2GL_Lo.Grid_Load,1)
    error('Error: the number of Loads in the grid is not the same as the number of Loads in the distribution List!');
end
switch type
    case '1p'
        mean_P_LP = zeros(nb_profiles,1);
        for k_LP = 1 : nb_profiles
            mean_P_LP(k_LP) = mean(LP_DB.(fieldname_LPs{k_LP}).P);
        end
        for k_LP = 1 :  nb_loads
            mean_P_current_LP = mean(scada_DB.(LP2GL_Lo.Load_Profile{k_LP}).P);
            [min_diff,min_pos] = min(abs(mean_P_LP - mean_P_current_LP));
            Load_Profile(k_LP) = fieldname_LPs(min_pos);
        end
    case '3p_reuse'
        mean_P_LP = zeros(nb_profiles_3p,1);
%         mean_P_SCADA_LP = zeros(fieldname_SCADA_LPs/3,1);
        for k_LP = 1 : 3 : nb_profiles
            mean_P_LP(floor(k_LP/3) + 1) = mean(LP_DB.(fieldname_LPs{k_LP}).P +...
                LP_DB.(fieldname_LPs{k_LP+1}).P + LP_DB.(fieldname_LPs{k_LP+2}).P);
        end
%         for k_LP = 1 : 3 : nb_profiles_scada
%             mean_P_SCADA_LP(floor(k_LP/3) + 1) = mean(scada_DB.(fieldname_SCADA_LPs{k_LP}).P +...
%                 scada_DB.(fieldname_SCADA_LPs{k_LP+1}).P + scada_DB.(fieldname_SCADA_LPs{k_LP+2}).P);
%         end
        for k_LP = 1 : 3 : nb_loads
            mean_P_current_LP = mean(scada_DB.(LP2GL_Lo.Load_Profile{k_LP}).P +...
                scada_DB.(LP2GL_Lo.Load_Profile{k_LP+1}).P + scada_DB.(LP2GL_Lo.Load_Profile{k_LP+2}).P);
            [min_diff,min_pos] = min(abs(mean_P_LP - mean_P_current_LP));
            Load_Profile(k_LP) = fieldname_LPs((min_pos-1)*3 + 1);
            Load_Profile(k_LP+1) = fieldname_LPs((min_pos-1)*3 + 2);
            Load_Profile(k_LP+2) = fieldname_LPs((min_pos-1)*3 + 3);
        end
    case '3p_no_reuse'
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
