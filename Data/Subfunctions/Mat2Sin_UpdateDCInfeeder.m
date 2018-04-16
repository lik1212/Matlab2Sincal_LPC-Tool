function Mat2Sin_UpdateDCInfeeder(sql_in, DB_Name, DB_Path, DB_Type)
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