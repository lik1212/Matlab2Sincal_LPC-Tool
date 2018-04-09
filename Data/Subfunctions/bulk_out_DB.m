function Done = bulk_out_DB(DB_PathNameType,Table_Name,Col_Name,Txt_Path,Txt_Name)
% bulk_out_DB - Save the Col_Name columns of the Table_Name table from the
%  DB_PathNameType Access Database in the Txt_Name txt file in the Txt_Path
%  path
%
%       DB_PathNameType   (Required) - Exakt full name and path of the DB
%       Table_Name        (Required) - Table name
%       Col_Name          (Required) - Column name
%       Txt_Path          (Required) - Path of the txt file
%       Txt_Name          (Required) - Name of the txt file

%   Author(s): J. Greiner
%              R. Brandalik

% Matlab connection with the Access DB of the Sincal model 

%% Sql command (as string) for reading data from Access

% Sql command (string) part that contains Column Names
Column_str = strjoin(Col_Name,', ');
% Sql command for reading from Table FROM ULFNodeResult + writing Table
% ULFNodeResult in a .txt-file
sql_command_str = ['SELECT ' ,Column_str, ' INTO [Text;HDR=YES;DATABASE=',Txt_Path,'].[',Txt_Name,'] FROM ', Table_Name ];

%% Create the Matlab connection with the Access Database
try
    % Create a local OLE Automation server "svr" for starting the Access process
    srv = actxserver('ADODB.connection');
    % Define the Provider
    provider = 'Microsoft.ACE.OLEDB.12.0';
    % Open the connection with the Access Database
    srv.Open(['Provider=' provider ';Data Source=' DB_PathNameType]);

    % transaction in the open DB
    % Begin a new transaction in the open DB connection
    invoke(srv,'BeginTrans'); 

    % Get the Recordset(ADO_rs) of the Table
    invoke(srv,'Execute',sql_command_str);
    
    % Save all changes
    invoke(srv,'CommitTrans');
    % Close the connection
    invoke(srv,'Close');  
    delete(srv);
    clear srv
%     fprintf('File %s has been created.\n',Txt_Name);
    disp(['File ',Txt_Name,' hast been created']);
    Done = true;
    
catch
    fprintf('\nSome error occure in %s.\n',DB_PathNameType);
%     bulk_out_DB(DB_PathNameType,Table_Name,Col_Name,Txt_Path,Txt_Name);
    Done = false;
    % Close the connection
%     invoke(srv,'Close');  
    delete(srv);
    clear srv
end
end

