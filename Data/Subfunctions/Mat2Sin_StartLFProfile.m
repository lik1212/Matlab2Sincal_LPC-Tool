function Mat2Sin_StartLFProfile(GridName, GridPath, SincalVersion)
%Mat2Sin_StartLFProfile - Start Load-flow with profiles in Sincal
%
%   LF_Status = Mat2Sin_StartLF(GridName,GridPath)
%
%       GridName      (Required)  - String that defines the name of the
%                                   Sincal file
%
%       GridPath      (Optional)  - String that defines the path of the
%                                   Sincal file
%                                 - (default): 'pwd' - current folder
%
%       SincalVersion (Optional)  - Double that defines the Sincal Version
%                                   installed at your PC
%
%   Author(s): J. Greiner
%              R. Brandalik

%% Input check

if nargin < 2; GridPath = [pwd,'\']               ; end % Set the default path if no path is given
if GridPath(end) ~= '\'; GridPath = [GridPath,'\']; end % Correct the path if necessary
if nargin < 3   % Check installed Sincal Version
    max_Version_Sincal  = 14; max_Version_Mat2Sin = 11; VersionInstalled = false;
    while ~VersionInstalled
        try
            a_try = actxserver(['Sincal.Simulation.',num2str(max_Version_Mat2Sin)]); %#ok
            VersionInstalled = true; a_try = []; clear a_try                         %#ok
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

disp(['Starting power flow calculation of ',GridName,'.']);

DB_Path = [GridPath, GridName, '_files\database.mdb'] ; % Set the Database path
SinPath = [GridPath, GridName,                '.sin'] ; % Set the Sincal path

try % Setting of the Access COM server, try-catch connection problems
    s = actxserver(['Sincal.Simulation.',num2str(Mat2SinVersion)]);  % Server for the Matlab connection to Sincal
    s.Database(['TYP=NET;MODE=JET;FILE=', DB_Path, ...               % Connection with the Sincal Database
        ';USR=Admin;PWD=;SINFILE='      , SinPath, ';']);
catch
    error(['Error during the connection of Matlab with Sincal in.', GridName, '.']);
end

CalcMethod = 'LC'; % Set type of calculation, LC - Load Profile

try  % try-catch for errors during load-flow
    s.Start(CalcMethod); % Start the calculation
    if s.StatusID == 1101 % Status ID 1101 means successful load flow
        disp(['Power flow calculation of ',GridName,' successful.']);
    else % Load Flow was not successful, treat it as error
        clear s % s = []; % Stop the Sincal connection, to avoid Matlab from breaking down
        error(['Power flow calculation of ',GridName,' failed.'   ]);
    end
catch
    clear s % s = []; % Stop the Sincal connection, to avoid Matlab from breaking down
    error(['Matlab Error occured during ',GridName,' power flow calculation.']);
end
% Stop the Sincal connection, to avoid Matlab from breaking down
invoke(s,'delete')
clear s % s = [];

