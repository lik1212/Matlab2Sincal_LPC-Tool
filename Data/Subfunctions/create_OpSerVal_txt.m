function create_OpSerVal_txt(Profile_DB, File_Path, File_suffix)
%create_OpSerVal_txt Create OpSerVal txt file to be read into the Sincal DB
%   create_OpSerVal_txt(Profile_DB, File_Path, File_suffix) creates the txt
%   file to be read into the Sincal Database table OpSerVal to add new
%   profiles. The Table OpSerVal contains the power values of the profiles.
%
%   Author(s): J. Greiner
%              R. Brandalik

%% Create OpSerVal table
% Details about OpSerVal table can be find in the Sincal DB user manual

OpSer_Name   = fieldnames(Profile_DB)                       ; % Profile names
num_profil   = numel(OpSer_Name)                            ; % number of profiles
num_instants = unique(structfun(@(x) size(x,1), Profile_DB)); % number of instants (time steps)

% fillup P and Q values consecutive as one column
P_values = reshape(struct2array(structfun(@(x) x.P(:), Profile_DB, 'UniformOutput', 0)),[],1);
Q_values = reshape(struct2array(structfun(@(x) x.Q(:), Profile_DB, 'UniformOutput', 0)),[],1);
% NaN to zero
P_values(isnan(P_values)) = 0;
Q_values(isnan(Q_values)) = 0;

table_OpSerVal              = table                                     ; % initial OpSerVal table
table_OpSerVal.OpSerVal_ID  = double (1:num_instants * num_profil    )' ; % Primary Key
table_OpSerVal.OpSer_ID     = repelem(1:num_profil  , 1, num_instants)' ;
table_OpSerVal.OpTime       = repmat (1:num_instants, 1, num_profil  )' ;
table_OpSerVal.Flag_Curve   = ones   (num_instants * num_profil,1)      ;
table_OpSerVal.Factor       = ones   (num_instants * num_profil,1)      ;
table_OpSerVal.P            = P_values                                  ;
table_OpSerVal.Q            = Q_values                                  ;
table_OpSerVal.Variant_ID   = ones   (num_instants * num_profil, 1)     ;
table_OpSerVal.Flag_Variant = ones   (num_instants * num_profil, 1)     ;
table_OpSerVal.Op_ID        = ones   (num_instants * num_profil, 1)     ;

% Save table
writetable(table_OpSerVal, [File_Path, 'OpSerVal', File_suffix, '.txt'], 'Delimiter', ';', 'QuoteStrings', false);