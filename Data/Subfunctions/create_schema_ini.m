function create_schema_ini(type,Sin_Path,num_grids,instants_per_grid,SinNameEmpty)
%create_schema_ini Creates schema.ini files
%
%
%

%   Author(s): P. Gassler
%              R. Brandalik
%              J. Greiner


if ~isfolder(Sin_Path); mkdir(Sin_Path); end % verify and create folder if does not exists
if exist([Sin_Path,'schema.ini'],'file'); delete([Sin_Path,'schema.ini']); end % delete old schema.ini file if exist
fileID = fopen([Sin_Path,'schema.ini'],'at');% create and open schema.ini file

switch type
    case 'input'
        for k_grid = 1:num_grids % over all grids for all important tables
            % read-in files from txt to Access
            fprintf(fileID,['[OpSer_',num2str(instants_per_grid),'inst_',num2str(k_grid),'.txt]\n']);
            fprintf(fileID,'Format=Delimited(;)\n');
            fprintf(fileID,'DecimalSymbol=.\n');
            fprintf(fileID,['[OpSerVal_',num2str(instants_per_grid),'inst_',num2str(k_grid),'.txt]\n']);
            fprintf(fileID,'Format=Delimited(;)\n');
            fprintf(fileID,'DecimalSymbol=.\n');
            % Important for right read-in of txt into Access
            fprintf(fileID,'Col1="OpSerVal_ID" Integer\n');
            fprintf(fileID,'Col2="OpSer_ID" Integer\n');
            fprintf(fileID,'Col3="OpTime" Double\n');
            fprintf(fileID,'Col4="Flag_Curve" Integer\n');
            fprintf(fileID,'Col5="Factor" Double\n');
            fprintf(fileID,'Col6="P" Double\n');
            fprintf(fileID,'Col7="Q" Double\n');
            fprintf(fileID,'Col8="Variant_ID" Integer\n');
            fprintf(fileID,'Col9="Flag_Variant" Integer\n');
            fprintf(fileID,'Col10="Op_ID" Integer\n');
        end
    case 'output'
        for k_grid = 1:num_grids % over all grids for all important tables
            % read-in files from txt to Acces
            % Branch and Node Results from Access to txt
            fprintf(fileID,['[BranchRes_',SinNameEmpty(1:end-6),'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'.txt]\n']);
            fprintf(fileID,'Format=Delimited(;)\n');
            fprintf(fileID,'NumberDigits = 15\n');
            fprintf(fileID,'DecimalSymbol=.\n');
            fprintf(fileID,['[NodeRes_',SinNameEmpty(1:end-6),'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'.txt]\n']);
            fprintf(fileID,'Format=Delimited(;)\n');
            fprintf(fileID,'NumberDigits = 15\n');
            fprintf(fileID,'DecimalSymbol=.\n');
        end
end
% close schema.ini file
fclose(fileID);


end