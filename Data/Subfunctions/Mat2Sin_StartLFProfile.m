function LF_Status = Mat2Sin_StartLFProfile(Sin_Name,Sin_Path)
% Mat2Sin_StartLF - Start Load-flow in Sincal
%
%   LF_Status = Mat2Sin_StartLF(Sin_Name,Sin_Path)
%
%       Sin_Name   (Required)     - String that defines the name of the
%                                   Sincal file
%
%       Sin_Path   (Optional)     - String that defines the path of the
%                                   Sincal file
%                                 - (default): 'pwd' - current folder 
%
%       LF_Status (Output)        - String
%                                 - Info message about the Load-flow status
%
% RB, 2015
% PG, 05.10.2017

%% Matlab connection with the Access DB of the Sincal model 

% Set the default path if no path is given
if nargin<2
    Sin_Path = [pwd,'\'];
end

% Correct the path if necessary
if Sin_Path(end) ~= '\'
    Sin_Path = [Sin_Path,'\'];
end

% Define an object for the connection with Sincal
s=struct;
% Set the Database path:
s.PathDB = [Sin_Path,Sin_Name,'_files\database.mdb'];
% Set the Sincal path:
s.PathSin = [Sin_Path,Sin_Name,'.sin'];

% Setting of the Access COM server
% try-catch To get a message if an error occur during the Matlab connection with the DB
try  
    % Server for the Matlab connection to Sincal
    s.conn = actxserver('Sincal.Simulation.9');
%     s.conn = actxserver('Sincal.Simulation.8');
    % Connection with the Sincal Database 
    s.conn.Database(['NET;JET;', s.PathDB, ';;;Admin;;', s.PathSin, ';;;']); 
    % BatchMode defines the Save Mode, 1 - virtually DB, without saving
    s.conn.BatchMode(0);
    % Language used in Sincal
    s.conn.Language('US');       
catch
    disp('Error during the connection of Matlab with Sincal.');    
end

%% Start Load-flow

% try-catch for errors during load-flow
try         
    % Set type of calculation (LF_USYM – unsymmetrical load flow)
    s.strMethod = 'LC'; % 'LF'
    % Preparation of the DB
    s.conn.LoadDB(s.strMethod);
    % Start the calculation
    s.conn.Start(s.strMethod);    
    % Check if the Load Flow Calculation was successful
    if s.conn.StatusID == 1101
        % Status ID 1101 means successful load flow
        LF_Status = ['Power flow calculation of ',Sin_Name,' Successful'];
    else
        % No Error, but Load Flow was not successful
        LF_Status = ['Power flow calculation of ',Sin_Name,' Failed'];
        % Stop the Sincal connection, to avoid Matlab from breaking down
        [s.conn] = deal([]); %#ok
        return;
    end
catch
    % Stop the Sincal connection, to avoid Matlab from breaking down
    [s.conn] = deal([]); %#ok
    % Error in Matlab
    LF_Status = ['Matlab Error occured during ',Sin_Name,' power flow calculation'];
    return;
end

%% Stopping the Sincal connection

% Save results into the Database
s.conn.SaveDB(s.strMethod);
% Stop the Sincal connection, to avoid Matlab from breaking down
[s.conn] = deal([]); %#ok

end