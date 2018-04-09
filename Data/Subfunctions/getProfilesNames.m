function ListName = getProfilesNames(Sin_Name,Sin_Path)
%
%
%
%

ListName = struct;

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

%% Get all elements from the DB of the Sincal model

% SQL command: ['SELECET ', '"Column Names"', ' FROM ' '"Table Name"']
sql = ['SELECT ', 'Element_ID,ElementName,ElementType,Node_ID', ' FROM ', 'QueryTopologySinglePort'];
% Get the Recordset(ADO_rs) for the Elements
ADO_rs = invoke(a.conn,'Execute',sql);
% Get the elements from the Recordset (Values in the current Column of the current Table)
SinElement = invoke(ADO_rs,'GetRows')';
% Number of Elements
num_of_Element = size(SinElement,1);

% In this loop delete the free spaces of the strings in SinElements with
% "strtrim"
for kE = 1:num_of_Element
    SinElement{kE,2} = strtrim(SinElement{kE,2});
    SinElement{kE,3} = strtrim(SinElement{kE,3});
end
% Save Elements in SinInfo
ListName.Element = cell2table(SinElement,'VariableNames',{'Element_ID','Name','Type','Node1_ID'});
ListName.Element = sortrows(ListName.Element,'Name','ascend');


%% Close the connection with the DB

a.conn.Close
end