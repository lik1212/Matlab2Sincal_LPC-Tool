function Mat2Sin_UpdateLoad(Sin_Name,Sin_Path,ColumnToUpdate,value_in)
% Mat2Sin_UpdateLoad - Update some column in the Sincal Load Table
%
%   Mat2Sin_UpdateLoad(Sin_Name,Sin_Path,ColumnToUpdate,value_in)
%
%       Sin_Name   (Required)     - String that defines the name of the
%                                   Sincal file
%
%       Sin_Path   (Required)     - String that defines the path of the
%                                   Sincal file
%
%       ColumnToUpdate (Required) - String that defines the column in the 
%                                   Load table to be updated
%
%       value_in (Required)       - table or array of two columns where the
%                                   first column defines the Load 
%                                   Element_ID and the second the 
%                                   correspoding value in ColumnToUpdate 
%
%   Author(s): J. Greiner
%              R. Brandalik

%% Matlab connection with the Access DB of the Sincal model 

% Correct the path if necessary
if Sin_Path(end) ~= '\'
    Sin_Path = [Sin_Path,'\'];
end

% Table2Array for value_in
if istable(value_in)
    value_in = table2array(value_in);
end

% Define an object for the connection with the DB
a=struct;
% Set the DB path:
a.DB_Path = [Sin_Path,Sin_Name,'_files\database.mdb'];

% Setting of the Access COM server
% try-catch To get a message if an error occur during the Matlab connection with the DB
try
    % Server for the Matlab connection to Access
    a.conn = actxserver('ADODB.connection');
    % Define the Provider
    a.provider = 'Microsoft.ACE.OLEDB.12.0';
    % Open the connection with the Access Database
    a.conn.Open(['Provider=' a.provider ';Data Source=' a.DB_Path]);
catch
    % If an error occur during the Matlab connection with the DB:
    disp('Error during the connection of Matlab with Access.');
end

%delete all old values in ColumnToUpdate
SQL_in = ['UPDATE DCInfeeder SET ',ColumnToUpdate, ' = NULL'];
a.conn.Execute(SQL_in); 

% Update Load Table
for i=1:size(value_in,1)
    SQL_in = ['UPDATE DCInfeeder SET ',ColumnToUpdate,' = ',...
        num2str(value_in(i,2)),' WHERE Element_ID = ',...
        num2str(value_in(i,1))];
    a.conn.Execute(SQL_in); 
end

% Close the connection with the DB
a.conn.Close
