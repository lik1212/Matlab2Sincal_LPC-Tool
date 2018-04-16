function create_OpSerVal_txt(LoadProfile,Sin_PathInput,OpSer_suffix)
%create_txt Create OpSerVal txt files to be read in the Sincal DB
%   create_txt(LoadProfile,k_grid) creates the OpSer and OpSerVal txt files
%   to be read in the Sincal Database based on the load profiles in
%   LoadProfile and for the k_grid in the path

%   Author(s): J. Greiner
%              R. Brandalik

%% Create OpSerVal table

num_of_profiles     = numel(fieldnames(LoadProfile));                         % number of profiles in OpSer table, number of load*3 (phase L1, L2, L3)
fieldnames_DB       = fieldnames(LoadProfile);               	% fieldnames will be given for load profile names
instants_per_grid   = size(LoadProfile.(fieldnames_DB{1}),1);

table_OpSerVal = table;                                         % initial OpSerVal table
P_values       = zeros(instants_per_grid*num_of_profiles,1);    % initial P_values for all load profiles
Q_values       = zeros(instants_per_grid*num_of_profiles,1);    % initial Q_values for all load profiles

% fillup P and Q values
for k_fieldnames = 1:numel(fieldnames_DB)
    P_values((k_fieldnames-1)*instants_per_grid + 1:...
        (k_fieldnames)*instants_per_grid)  = ...
        LoadProfile.(fieldnames_DB{k_fieldnames}).P;
    Q_values((k_fieldnames-1)*instants_per_grid + 1:...
        (k_fieldnames)*instants_per_grid)  = ...
        LoadProfile.(fieldnames_DB{k_fieldnames}).Q;
end

% NaN to zero
P_values(isnan(P_values))   = 0;
Q_values(isnan(Q_values))   = 0;
% Table OpSer setup and fillup, more details in the Sincal Database user manual
table_OpSerVal.OpSerVal_ID  = (1:instants_per_grid*num_of_profiles)'; % Primary Key
table_OpSerVal.OpSer_ID     = kron(1:num_of_profiles,ones(1,instants_per_grid))';
table_OpSerVal.OpTime       = repmat(1:instants_per_grid,1,k_fieldnames)';
table_OpSerVal.Flag_Curve   = ones(instants_per_grid*num_of_profiles,1);
table_OpSerVal.Factor       = ones(instants_per_grid*num_of_profiles,1);
table_OpSerVal.P            = P_values;
table_OpSerVal.Q            = Q_values;
table_OpSerVal.Variant_ID   = ones(instants_per_grid*num_of_profiles,1);
table_OpSerVal.Flag_Variant = ones(instants_per_grid*num_of_profiles,1);
table_OpSerVal.Op_ID        = ones(instants_per_grid*num_of_profiles,1);

% Save table
writetable(table_OpSerVal,[Sin_PathInput,'OpSerVal',OpSer_suffix,'.txt'],'Delimiter',';','QuoteStrings',false);

end