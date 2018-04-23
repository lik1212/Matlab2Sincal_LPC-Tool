function create_schema_ini(File_Type, File_Path, num_grids, instants_per_grid, SinNameEmpty)
%create_schema_ini Creates schema.ini files
%
%   Author(s): P. Gassler
%              R. Brandalik
%              J. Greiner

%% Main

if exist([File_Path,'schema.ini'],'file'); delete([File_Path,'schema.ini']); end % delete old schema.ini file if exist

fileID = fopen([File_Path,'schema.ini'],'at'); % create and open schema.ini file

for k_grid = 1 : num_grids % over all grids for all important tables
    switch File_Type
        case 'input'
            % read-in files from txt to Access
            % Important for right read-in of txt into Access
            file_suffix = [num2str(instants_per_grid),'inst_',num2str(k_grid),'.txt]'];
            fprintf(fileID, ['[OpSer_'   , file_suffix,   '\n']);
            fprintf(fileID, 'Format        = Delimited(;)  \n' );
            fprintf(fileID, 'DecimalSymbol = .             \n' );
            fprintf(fileID, ['[OpSerVal_', file_suffix,   '\n']);
            fprintf(fileID, 'Format        = Delimited(;)  \n' );
            fprintf(fileID, 'DecimalSymbol = .             \n' );
%             fprintf(fileID, 'Col1          = "OpSerVal_ID"  Integer \n');
%             fprintf(fileID, 'Col2          = "OpSer_ID"     Integer \n');
%             fprintf(fileID, 'Col3          = "OpTime"       Double  \n');
%             fprintf(fileID, 'Col4          = "Flag_Curve"   Integer \n');
%             fprintf(fileID, 'Col5          = "Factor"       Double  \n');
%             fprintf(fileID, 'Col6          = "P"            Double  \n');
%             fprintf(fileID, 'Col7          = "Q"            Double  \n');
%             fprintf(fileID, 'Col8          = "Variant_ID"   Integer \n');
%             fprintf(fileID, 'Col9          = "Flag_Variant" Integer \n');
%             fprintf(fileID, 'Col10         = "Op_ID"        Integer \n');
        case 'output'
            % read-in files from txt to Acces
            % Branch and Node Results from Access to txt
            file_suffix = [SinNameEmpty(1:end - 6),'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'.txt]'];
            fprintf(fileID,['[BranchRes_', file_suffix, '\n']);
            fprintf(fileID,'Format        = Delimited(;) \n' );
            fprintf(fileID,'NumberDigits  = 15           \n' );
            fprintf(fileID,'DecimalSymbol = .            \n' );
            fprintf(fileID,['[NodeRes_',   file_suffix, '\n']);
            fprintf(fileID,'Format        = Delimited(;) \n' );
            fprintf(fileID,'NumberDigits  = 15           \n' );
            fprintf(fileID,'DecimalSymbol = .            \n' );
        otherwise
            error('Unknown schema.ini type.');
    end
end
fclose(fileID); % close schema.ini file
