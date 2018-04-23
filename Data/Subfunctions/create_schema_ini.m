function create_schema_ini(File_Type, File_Path, num_grids, instants_per_grid, SinNameEmpty)
%create_schema_ini Creates schema.ini files
%
%   This file contains the important information to read-in or read-out txt
%   file from Access.
%
%   Author(s): P. Gassler,
%              R. Brandalik
%              J. Greiner

%% Main

if exist([File_Path, 'schema.ini'], 'file'); delete([File_Path, 'schema.ini']); end % delete old schema.ini file if exist

fileID = fopen([File_Path, 'schema.ini'], 'at'); % create and open schema.ini file
for k_grid = 1 : num_grids % Setup for all important tables in all grids
    input_file_suffix = [num2str(instants_per_grid), 'inst_', num2str(k_grid), '.txt]'];
    switch File_Type
        case 'input' % read-in txt to Access
            for k_Type = 1 : 2
                switch k_Type
                    case 1; fprintf(fileID, ['[OpSer_'   , input_file_suffix, '\n']);
                    case 2; fprintf(fileID, ['[OpSerVal_', input_file_suffix, '\n']);
                end
                fprintf(fileID, 'Format        = Delimited(;) \n');
                fprintf(fileID, 'DecimalSymbol = .            \n');
            end
        case 'output' % read-out Acces to txt
            output_file_suffix = [SinNameEmpty(1:end - 6), '_', input_file_suffix];
            for k_Type = 1 : 2
                switch k_Type
                    case 1; fprintf(fileID,['[BranchRes_', output_file_suffix, '\n']);
                    case 2; fprintf(fileID,['[NodeRes_'  , output_file_suffix, '\n']);
                end
                fprintf(fileID, 'Format        = Delimited(;) \n');
                fprintf(fileID, 'DecimalSymbol = .            \n');
                fprintf(fileID, 'NumberDigits  = 15           \n');
            end
        otherwise
            error('Unknown schema.ini type.');
    end
end
fclose(fileID); % close schema.ini file
