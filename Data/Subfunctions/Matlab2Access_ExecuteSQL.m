function Done = Matlab2Access_ExecuteSQL(sql_in, DB_Name, DB_Path, DB_Type)
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
%
% RB, v2018.04.16

%% Input check

if nargin < 3;          DB_Path = [cd,'\'];       end	% Set the default path
if nargin < 4;          DB_Type = '.accdb';       end	% Set the default database typ
if DB_Path(end) ~= '\'; DB_Path = [DB_Path,'\'];  end   % Correct the path if necessary
if ischar(sql_in);      sql_in = cellstr(sql_in); end   % if sql-input is the class char 
    
%% Create the Matlab connection with the Access Database

provider  = 'Microsoft.ACE.OLEDB.12.0';                                     % Define the Provider
open_comm = ['Provider=' provider ';Data Source=' DB_Path DB_Name DB_Type]; % Sql command (as string) to open the Access Table
Done      = false;
max_tries = 10;
k_try     = 1 ;
while Done == false && k_try <= max_tries
    try
        srv = actxserver('ADODB.connection'  );             % Create a local OLE Automation server "srv" for starting the Access process
        invoke(srv,'Open'        , open_comm );             % Open the connection with the Access Database
        invoke(srv,'BeginTrans'              );             % Begin a new transaction in the open DB connection
        for sql_in_k = 1 : size(sql_in,1)                   % invoke the changes
            invoke(srv,'Execute' , sql_in{sql_in_k,1}    ); 
        end
        invoke(srv,'CommitTrans'             );             % Save all changes
        invoke(srv,'Close'                   );             % Close the Matlab connection with the Access Database
        srv = []; %#ok                                      % Set the srv variable to Nothing
        Done = true;
        fprintf(['Execution try ',num2str(k_try),' in ',DB_Name,' successful.\n']);
    catch
        fprintf(['Execution try ',num2str(k_try),'/',num2str(max_tries),' in ',DB_Name,' was not successful.\n']);
        if k_try == max_tries
            error(['Connection with ',DB_Name,' could not be created.']);
        end
        k_try = k_try + 1;
    end
end