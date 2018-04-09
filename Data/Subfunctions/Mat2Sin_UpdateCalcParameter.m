function Mat2Sin_UpdateCalcParameter(Sin_Name,Sin_Path,ColumnToUpdate,value_in)
% Mat2Sin_UpdateCalcParameter - Update some column in the Sincal CalcParameter Table
%
%   Mat2Sin_UpdateCalcParameter(Sin_Name,Sin_Path,ColumnToUpdate,value_in)
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
%       value_in (Required)       - new value in the CalcParameter Table
%
%   Author(s): J. Greiner
%              R. Brandalik

%% Matlab connection with the Access DB of the Sincal model 

% Correct the path if necessary
if Sin_Path(end) ~= '\'
    Sin_Path = [Sin_Path,'\'];
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
SQL_in = ['UPDATE CalcParameter SET ',ColumnToUpdate, ' = NULL'];
a.conn.Execute(SQL_in); 

% Update Load Table
SQL_in = ['UPDATE CalcParameter SET ',ColumnToUpdate,' = ',...
    num2str(value_in),' WHERE CalcParameter_ID = 1'];
a.conn.Execute(SQL_in); 

% Static settings
SQL_in = 'UPDATE CalcParameter SET LC_StartDate = ''01.01.2014''';
a.conn.Execute(SQL_in); 
SQL_in = 'UPDATE CalcParameter SET LC_StartTime = 1';
a.conn.Execute(SQL_in); 
SQL_in = 'UPDATE CalcParameter SET LC_TimeStep = 1';
a.conn.Execute(SQL_in);
SQL_in = 'UPDATE CalcParameter SET Flag_LC_Incl = 4'; % 1 - Store Results Completely, 4 - Only Marked
a.conn.Execute(SQL_in);

% Close the connection with the DB
a.conn.Close
