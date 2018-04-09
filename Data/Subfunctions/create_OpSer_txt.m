function create_OpSer_txt(fieldnames_DB,Sin_PathInput,OpSer_suffix) % TODO, Comments anpassen
%create_txt Create OpSer txt files to be read in the Sincal DB
%   create_OpSer_txt(LoadProfile,k_grid) creates the txt files
%   to be read in the Sincal Database based on the load profiles in
%   LoadProfile and for the k_grid in the path

%   Author(s): J. Greiner
%              R. Brandalik

%% Create OpSer table

table_OpSer         = table;                                                    % initial OpSer table
num_of_profiles     = numel(fieldnames_DB);                                     % number of profiles in OpSer table, number of load*3 (phase L1, L2, L3)
OpSer_Name          = cellfun(@(x) x(6:end), fieldnames_DB,'UniformOutput',0);	% Without 'Load_' or 'PV___'
OpSer_Shortname     = strcat(repmat('P',num_of_profiles,1),...                  % shortname as ['P_', "running counter variable"]
    num2str((1:num_of_profiles)'));                                             
OpSer_Shortname     = strrep(cellstr(OpSer_Shortname),' ','0');                 % ...

% Table OpSer setup and fillup, more details in the Sincal Database user manual
table_OpSer.OpSer_ID     =     (1:num_of_profiles)'; % Primary Key
table_OpSer.Name         =     OpSer_Name;
table_OpSer.Shortname    =     OpSer_Shortname;
table_OpSer.Flag_Typ     = 3 * ones(num_of_profiles,1); % Input Type: 3 - Power (P and Q)
table_OpSer.Variant_ID   =     ones(num_of_profiles,1);
table_OpSer.Flag_Variant =     ones(num_of_profiles,1);
table_OpSer.Tarif        =     ones(num_of_profiles,1);
table_OpSer.Branch       =     ones(num_of_profiles,1);
table_OpSer.SubName      =     ones(num_of_profiles,1);
table_OpSer.Power_a1     =     ones(num_of_profiles,1);
table_OpSer.Power_b1     =     ones(num_of_profiles,1);
table_OpSer.Reduce_a2    =     ones(num_of_profiles,1);
table_OpSer.Reduce_b2    =     ones(num_of_profiles,1);
table_OpSer.Flag_Ser     =     ones(num_of_profiles,1) * 3; % Series Type: 3 - Yearly
table_OpSer.BaseT        =     ones(num_of_profiles,1);

% Save table
writetable(table_OpSer,[Sin_PathInput,'OpSer',OpSer_suffix,'.txt'],'Delimiter',';','QuoteStrings',false);

end