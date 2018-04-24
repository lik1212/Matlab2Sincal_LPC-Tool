function create_OpSer_txt(OpSer_Name, File_Path, File_suffix)
%create_OpSer_txt Create OpSer txt file to be read into the Sincal DB
%   create_OpSer_txt(OpSer_Name, File_Path, File_suffix) creates the txt
%   file to be read into the Sincal Database table OpSer to add new
%   profiles. The Table OpSer contains the basic information about the
%   profiles.
%
%   Author(s): J. Greiner
%              R. Brandalik

%% Create OpSer table
% Details about OpSer table can be find in the Sincal DB user manual

num_profil      = numel(OpSer_Name)                                       ; % number of profiles in OpSer table
OpSer_Shortname = strrep(strcat({'P_'}, num2str((1:num_profil)')),' ','0'); % shortname as ['P_', "running counter variable"]

table_OpSer              = table                   ; % initial OpSer table
table_OpSer.OpSer_ID     = double(1:num_profil)'   ; % Primary Key
table_OpSer.Name         = OpSer_Name              ;
table_OpSer.Shortname    = OpSer_Shortname         ;
table_OpSer.Flag_Typ     = ones(num_profil, 1) * 3 ; % Input Type: 3 - Power (P and Q)
table_OpSer.Variant_ID   = ones(num_profil, 1)     ;
table_OpSer.Flag_Variant = ones(num_profil, 1)     ;
table_OpSer.Tarif        = ones(num_profil, 1)     ;
table_OpSer.Branch       = ones(num_profil, 1)     ;
table_OpSer.SubName      = ones(num_profil, 1)     ;
table_OpSer.Power_a1     = ones(num_profil, 1)     ;
table_OpSer.Power_b1     = ones(num_profil, 1)     ;
table_OpSer.Reduce_a2    = ones(num_profil, 1)     ;
table_OpSer.Reduce_b2    = ones(num_profil, 1)     ;
table_OpSer.Flag_Ser     = ones(num_profil, 1) * 3 ; % Series Type: 3 - Yearly
table_OpSer.BaseT        = ones(num_profil, 1)     ;

% Save table
writetable(table_OpSer, [File_Path, 'OpSer', File_suffix, '.txt'] , 'Delimiter', ';' , 'QuoteStrings', false);