function AccessDelValues(DB_Name,Tab_Name,DB_Path,DB_Type)
% AccessDelValues - Delete all Values in Tab_Name Table from DB_Name
%                   Database
%
%   AccessDelValues(DB_Name,Tab_Name,DB_Path,DB_Type)
%
%       DB_Name       (Required) - String that defines the name of the DB
%       Tab_Name      (Required) - String that defines the Table Name
%       DB_Path       (Optional) - String, Path of the database
%                                - (default): 'cd' - current folder 
%       DB_Type       (Optional) - String, Type of the database
%                                - Allowed types: .accdb and .mdb 
%                                - (default): '.accdb'     

% RB, v2016.05.11

%% Input check

% Set the default path
if nargin < 3
    DB_Path = [cd,'\'];
end
% Set the default database typ
if nargin < 4
    DB_Type = '.accdb';
end
% Correct the path if necessary
if DB_Path(end) ~= '\'
    DB_Path = [DB_Path,'\'];
end

%% Create the Matlab connection with the Access Database

% Create a local OLE Automation server "svr" for starting the Access process
srv      = actxserver('ADODB.connection');
% Define the Provider
provider = 'Microsoft.ACE.OLEDB.12.0';
% Open the connection with the Access Database
srv.Open(['Provider=' provider ';Data Source=' DB_Path DB_Name DB_Type]);

%% Sql command (as string) for deleting data from Access Table

sql_command_str = ['DELETE FROM ',Tab_Name,';'];

%% transaction in the open DB

% Begin a new transaction in the open DB connection
invoke(srv,'BeginTrans'); 
try
    % invoke the changes
    invoke(srv,'Execute',sql_command_str);
catch
    % If Table doesn't exist
    fprintf('Some error occure! Check if Table exist in Database');
end

%% Close the Matlab connection with the Access Database

% Save all changes
invoke(srv,'CommitTrans');
% Close the connection
invoke(srv,'Close');

end