function Mat2Sin_StartLFProfile(Sin_Name, Sin_Path, SincalVersion)
%Mat2Sin_StartLFProfile - Start Load-flow with profiles in Sincal
%
%   LF_Status = Mat2Sin_StartLF(Sin_Name,Sin_Path)
%
%       Sin_Name      (Required)  - String that defines the name of the
%                                   Sincal file
%
%       Sin_Path      (Optional)  - String that defines the path of the
%                                   Sincal file
%                                 - (default): 'pwd' - current folder 
%
%       SincalVersion (Optional)  - Double that defines the Sincal Version
%                                   installed at your PC
%
%       LF_Status     (Output)    - String
%                                 - Info message about the Load-flow status
%
%   Author(s): J. Greiner
%              R. Brandalik

%% Input check

if nargin < 2; Sin_Path = [pwd,'\']; end                % Set the default path if no path is given
if Sin_Path(end) ~= '\'; Sin_Path = [Sin_Path,'\']; end % Correct the path if necessary
% Check installed Sincal Version
if nargin < 3
    max_Version_Sincal  = 14;
    max_Version_Mat2Sin = 11;
    VersionInstalled = false;
    while ~VersionInstalled
        try
            actxserver(['Sincal.Simulation.',num2str(max_Version_Mat2Sin)]);
            VersionInstalled = true;
            clear ans
        catch
            max_Version_Mat2Sin = max_Version_Mat2Sin - 1  ;
            max_Version_Sincal  = max_Version_Sincal  - 0.5;
        end
    end
    Mat2SinVersion = max_Version_Mat2Sin;
else
    Mat2SinVersion = -17 + 2 * SincalVersion;
end

%% Matlab connection with the Access DB of the Sincal model 


disp(['Starting power flow calculation of ',Sin_Name,'.']);

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
    s.conn = actxserver(['Sincal.Simulation.',num2str(Mat2SinVersion)]);
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
        disp(['Power flow calculation of ',Sin_Name,' successful.']);
    else
        % Stop the Sincal connection, to avoid Matlab from breaking down
        [s.conn] = deal([]);
        % Load Flow was not successful, treat it as error
        error(['Power flow calculation of ',Sin_Name,' failed.']);
    end
catch
    % Stop the Sincal connection, to avoid Matlab from breaking down
    [s.conn] = deal([]); %#ok
    % Error in Matlab
    error(['Matlab Error occured during ',Sin_Name,' power flow calculation.']);
end

%% Stopping the Sincal connection

% Save results into the Database
s.conn.SaveDB(s.strMethod);
% Stop the Sincal connection, to avoid Matlab from breaking down
[s.conn] = deal([]); %#ok

end