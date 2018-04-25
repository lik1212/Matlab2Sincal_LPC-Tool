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
%   Author(s): J. Greiner
%              R. Brandalik

%% Input check

if nargin < 2; Sin_Path = [pwd,'\']               ; end % Set the default path if no path is given
if Sin_Path(end) ~= '\'; Sin_Path = [Sin_Path,'\']; end % Correct the path if necessary
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

disp(['Starting power flow calculation of ',Sin_Name,'.']);

s         = struct                                      ; % Define an object for the connection with Sincal
s.PathDB  = [Sin_Path, Sin_Name, '_files\database.mdb'] ; % Set the Database path
s.PathSin = [Sin_Path, Sin_Name,                '.sin'] ; % Set the Sincal path

try % Setting of the Access COM server, try-catch connection problems
    s.conn = actxserver(['Sincal.Simulation.',num2str(Mat2SinVersion)]);    % Server for the Matlab connection to Sincal
    s.conn.Database(['TYP=NET;MODE=JET;FILE=', s.PathDB, ...                % Connection with the Sincal Database
        ';USR=Admin;PWD=;SINFILE=', s.PathSin, ';']);
catch
    error(['Error during the connection of Matlab with Sincal in.', Sin_Name, '.']);
end

%% Start Load-flow

try  % try-catch for errors during load-flow
    s.strMethod = 'LC';        % Set type of calculation, LC - Load Profile
    s.conn.Start(s.strMethod); % Start the calculation
    if s.conn.StatusID == 1101 % Status ID 1101 means successful load flow
        disp(['Power flow calculation of ',Sin_Name,' successful.']);
    else % Load Flow was not successful, treat it as error
        [s.conn] = deal([]); % Stop the Sincal connection, to avoid Matlab from breaking down
        error(['Power flow calculation of ',Sin_Name,' failed.']);
    end
catch
    [s.conn] = deal([]); %#ok % Stop the Sincal connection, to avoid Matlab from breaking down
    error(['Matlab Error occured during ',Sin_Name,' power flow calculation.']);
end

%% Stop the Sincal connection, to avoid Matlab from breaking down

[s.conn] = deal([]); %#ok

end