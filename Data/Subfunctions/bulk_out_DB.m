function Done = bulk_out_DB(sql_in, DB_Name, DB_Path, DB_Type)
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

%% Input check

if nargin < 3                   % Set the default path
    DB_Path = [cd,'\'];
end
if nargin < 4                   % Set the default database typ
    DB_Type = '.accdb';
end
if DB_Path(end) ~= '\'          % Correct the path if necessary
    DB_Path = [DB_Path,'\'];
end

%% Create the Matlab connection with the Access Database

provider  = 'Microsoft.ACE.OLEDB.12.0';                                     % Define the Provider
open_comm = ['Provider=' provider ';Data Source=' DB_Path DB_Name DB_Type]; % Sql command (as string) to open the Access Table
Done      = false;
max_tries = 10;
k_try     = 1 ;
while Done == false && k_try < max_tries
    try
        srv = actxserver('ADODB.connection'  ); % Create a local OLE Automation server "srv" for starting the Access process
        invoke(srv,'Open'        , open_comm );	% Open the connection with the Access Database
        invoke(srv,'BeginTrans'              ); % Begin a new transaction in the open DB connection
        invoke(srv,'Execute'     , sql_in    ); % invoke the changes
        invoke(srv,'CommitTrans'             ); % Save all changes
        invoke(srv,'Close'                   ); % Close the Matlab connection with the Access Database
        srv = []; %#ok                       	% Set the srv variable to Nothing
        Done = true;
        fprintf(['Execution try ',num2str(k_try),' in ',DB_Name,' successful.\n']);
    catch
        fprintf(['Execution try ',num2str(k_try),'/',num2str(max_tries),' in ',DB_Name,' was not successful.\n']);
        if k_try == max_tries
            fprintf(['Connection with ',DB_Name,' could not be created. Programm will stop.\n']);
            return;
        end
    end
end