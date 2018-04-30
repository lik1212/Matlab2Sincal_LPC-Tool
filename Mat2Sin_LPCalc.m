function status = Mat2Sin_LPCalc(Inputs)
%%Mat2Sin_LPCalc
%   
%   Mat2Sin_LPCalc - This script demonstrates the work of the load
%                    flow calculation for load profiles (load flow 
%                    calculation for more than one timestamp at once) 
%                    in Sincal managed from Matlab.
%
%                  - Duo to the maximum 2GB database size of Access
%                    databases, the profiles need to be split into
%                    smaller profiles if the load flow results 
%                    exceed 2GB.
%
%   Inputs  - Structure with all necessary inputs:
%
% 		Inputs.Grid_Path   						(required)
% 		Inputs.Grid_Name   						(required)
% 		Inputs.LP_DB_Path  						(required)
% 		Inputs.LP_DB_Type  						(required)
% 		Inputs.LP_DB_Name  						(required)
% 		Inputs.LP_dist_type						(required)
% 		Inputs.PV_DB_Path  						(required)
% 		Inputs.PV_DB_Type  						(required)
% 		Inputs.PV_DB_Name  						(required)
% 		Inputs.PV_dist_type						(required)
% 		Inputs.VerSincal   						(required)
% 		Inputs.ParrallelCom						(required)
% 		Inputs.NumelCores  						(required)
% 		Inputs.Outputs_Path						(required)
% 		
% 		Inputs.LP_dist_path                 	(required if LP_dist_type 'list')
% 		Inputs.LP_dist_list_name            	(required if LP_dist_type 'list')
% 		Inputs.PV_dist_path                 	(required if PV_dist_type 'list')
% 		Inputs.PV_dist_list_name            	(required if PV_dist_type 'list')
%
% 		Inputs.Output_option_U              	(optional)
% 		Inputs.Output_option_P              	(optional)
% 		Inputs.Output_option_Q              	(optional)
% 		Inputs.Output_option_S              	(optional)
% 		Inputs.Output_option_phi            	(optional)
% 		Inputs.Output_option_I              	(optional)
% 		Inputs.Output_option_P_flow         	(optional)
% 		Inputs.Output_option_Q_flow         	(optional)
% 		Inputs.Output_option_S_flow         	(optional)
% 		Inputs.Output_option_Sin_Info       	(optional)
% 		Inputs.Output_option_raw            	(optional)
% 		Inputs.Output_option_raw_only       	(optional)
% 		Inputs.Output_option_per_node_branch	(optional)
% 		Inputs.Output_option_per_unit       	(optional)
% 		Inputs.Output_option_Sin_Info       	(optional)
% 		Inputs.Output_option_del_temp_files 	(optional)
% 		Inputs.Output_option_preparation    	(optional)
% 		Inputs.waitbar_activ                	(optional)
% 		Inputs.Temp_Sim_Path                	(optional)
%
%   Basic Flowchart:
%
%       1. Path and directory preparation
%       2. Setting preperation
%       3. Prepare sincal grid and get the info about the grid
%       4. Load the load and photovoltaic (PV) profiles
%       5. Preparing the profiles as txt files to be read in into Sincal
%       6. Make copys of the Sincal grid & Put txt file of profiles to database
%       7. Load flow calculation with load profiles
%       8. Read out database table values into txt files
%       9. Output preperation
%      10. Save Simulation Details
%
%
% Author(s): R. Brandalik
%            P. Gassler
%            J. Greiner
%            H. Kreten
%
% Contact: brandalikrobert@gmail.com, brandalik@eit.uni-kl.de
%
% Special thanks go to the entire TUK ESEM team.
%
% Parts of the work were the result of the project CheapFlex, sponsored by
% the German Federal Ministry of Economic Affairs and Energy as part of the
% 6th Energy Research Programme of the German Federal Government.

%% Default Path definition and directory preparation

addpath([pwd, '\Data\Subfunctions']); % Add Subfunction path
addpath([pwd, '\Data\Static_Input']); % Add path for static input (e.q. column names in a database)

%% Set the settings based on the Inputs

Settings = defaultSettings(Inputs);

%% To have smaller variables in the Code, extract some fields from Settings

Outputs_Path   =  Settings.Outputs_Path       ; % Path for the simulation's output files
Grid_Path      =  Settings.Grid_Path          ; % Path for input Sincal Grids
Grid_Name      =  Settings.Grid_Name          ; % Grid name of Sincal Grid
Grid_NameEmpty = [Settings.Grid_Name,'_empty']; % Name of empty Sincal Grid 
waitbar_activ  =  Settings.waitbar_activ      ; % Use waitbar yes/no
VerSincal      =  Settings.VerSincal          ; % Sincal Version

%% Split the folder meant for temporary files

Temp_Input_Path  = [Settings.Temp_Sim_Path, 'InputFiles\'  ];  % Path for simulation temp. Input Files
Temp_Output_Path = [Settings.Temp_Sim_Path, 'OutputFiles\' ];  % Path for simulation temp. Output Files
Temp_Grids_Path  = [Settings.Temp_Sim_Path, 'Grids\'       ];  % Path for simulation temp. copies of Grids

%% Estimating time for waitbar

if waitbar_activ
    wb_stat = [0; 0.01; 0.03; 0.05; 0.06; 0.07; 0.08; 0.55; 0.8; 1];
end

%% Main waitbar initialisation

if waitbar_activ
    % Check if waitbar exists
    wb_Fig = findall(0, 'Name', 'LPC Tool main progress');
    if isempty(wb_Fig)
        wb_Fig = waitbar(0, 'Main progress', 'Name', 'LPC Tool main progress');
    end
    waitbar(wb_stat(1), wb_Fig, 'Initialisation');
end
% Optional TODO: Integrate Waitbar in GUI figure (not working/finished)

%% Setting up Time Vector (TODO: Implement in future)

% Default values
% TimeSetup = struct;
% TimeSetup.First_Moment      = datetime('01.01.2015 00:00:00','Format','dd.MM.yyyy HH:mm:ss');
% TimeSetup.Last_Moment       = datetime('31.12.2015 23:50:00','Format','dd.MM.yyyy HH:mm:ss');
% TimeSetup.Time_Step         = 1; % Minutes
% TimeSetup.num_of_instants   = 1440;
% TimeSetup.instants_per_grid = 1440; % Temp, RB
% TimeSetup                   = Setting_Time_Parameters(TimeSetup,Inputs);

%% Delete temporary files if exist and set the temporary folder

if isdir(Temp_Input_Path ); rmdir(Temp_Input_Path, 's'); end % delete input  Files
if isdir(Temp_Output_Path); rmdir(Temp_Output_Path,'s'); end % delete output Files
if isdir(Temp_Grids_Path ); rmdir(Temp_Grids_Path, 's'); end % delete grids  Files
 
mkdir(Temp_Input_Path ); 
mkdir(Temp_Output_Path);
mkdir(Temp_Grids_Path );

%% Get and set static input (e.q. column names of tables in sincal database)

NodeResVariables   = getNodeResVariables  (Settings);
BranchResVariables = getBranchResVariables(Settings);

DB_Name = 'database';
DB_Type = '.mdb'    ;

%% Prepare a copy of sincal grid and get the Info about the grid

if waitbar_activ; waitbar(wb_stat(2), wb_Fig, 'Preparing Sincal Grid'); end % Waitbar Update

GridNameMain = [Grid_Path       , Grid_Name      , '.sin'   ];
GridNameCopy = [Temp_Input_Path , Grid_NameEmpty , '.sin'   ];
DB__PathMain = [Grid_Path       , Grid_Name      , '_files\'];
DB__PathCopy = [Temp_Input_Path , Grid_NameEmpty , '_files\'];

copyfile(GridNameMain, GridNameCopy); % copy the sincal file
copyfile(DB__PathMain, DB__PathCopy); % copy the sincal Grid folder with database

%% Get Grind basic information (nodes, lines, loads,etc.)

SinInfo = Mat2Sin_GetSinInfo(Grid_NameEmpty, Temp_Input_Path); % TODO, maybe better position in Code
if Settings.Output_option_Sin_Info
    SimData_Filename = [Outputs_Path, Grid_Name, '_Grid_Info_', Settings.Timestamp, '.mat'];
    SinInfo_Bytes    = whos('SinInfo');
    SinInfo_Bytes    = SinInfo_Bytes.bytes;
    if SinInfo_Bytes > 2 * 1024^3 ; save(SimData_Filename,'SinInfo', '-v7.3' );
    else                          ; save(SimData_Filename,'SinInfo'          ); end
end

%% Load the load and photovoltaic (PV) profiles

if waitbar_activ; waitbar(wb_stat(3), wb_Fig, 'Loading Load and PV profiles'); end % Waitbar Update

switch Settings.LP_DB_Type     % Loading Load Profiles Database
    case 'DB'
        Load_Profiles = load([Settings.LP_DB_Path,Settings.LP_DB_Name]);
        temp_field    = fields(Load_Profiles);
        Load_Profiles = Load_Profiles.(temp_field{:});
    case 'AAPD'
        error('Database Type not yet implemented.'); % (TODO: Implement in future)
%         Load_Profiles = generate_AAPD_LPs(numel(SinInfo.Load.Element_ID),'1P','PLC_Tool',TimeSetup.Time_Step);
%         save([Outputs_Path,Grid_Name,'_AAPD_LP_DB.mat'],'Load_Profiles','-v7.3');
    otherwise
        error('Unknown Database Type.');
end
switch Settings.PV_DB_Type      % Loading PV Profiles Database
    case 'DB'
        PV___Profiles = load([Settings.PV_DB_Path,Settings.PV_DB_Name]);
        temp_field    = fields(PV___Profiles);
        PV___Profiles = PV___Profiles.(temp_field{:});
    otherwise
        error('Unknown Database Type.');
end

fields_names_LoP = fields(Load_Profiles); % LoP - Load profiles
fields_names_PvP = fields(PV___Profiles); % PvP - PV   profiles

% Loading or Generating the distribution of the Load Profiles on the Grid Loads
switch Settings.LP_dist_type
    case 'list'
        LP2GL_Lo = readtable([Settings.LP_dist_path, Settings.LP_dist_list_name],'Delimiter',';');
    case 'random'
        LP2GL_Lo = create_DistributionList(SinInfo, 'Load' ,fields_names_LoP, Settings.LP_dist_type);
        Settings.LP_dist_list_name = ['Load_Distribution_random_', Settings.Timestamp, '.txt'];
    case 'alphab'
        LP2GL_Lo = create_DistributionList(SinInfo, 'Load' ,fields_names_LoP, Settings.LP_dist_type);
        Settings.LP_dist_list_name = ['Load_Distribution_alphabetical_order_', Settings.Timestamp, '.txt'];
    case 'DB_order'
        LP2GL_Lo = create_DistributionList(SinInfo, 'Load' ,fields_names_LoP, Settings.LP_dist_type);
        Settings.LP_dist_list_name = ['Load_Distribution_database_order_', Settings.Timestamp, '.txt'];
    otherwise
        error('Unknown Distribution Type.');
end
% Save distribution list as output
writetable(LP2GL_Lo, [Outputs_Path,Grid_Name, '_', Settings.LP_dist_list_name],'Delimiter',';');

% Loading or Generating the distribution of the PV Profiles on the Grid PV
switch Settings.PV_dist_type
    case 'list'
        LP2GL_Pv     = readtable([Settings.PV_dist_path,Settings.PV_dist_list_name],'Delimiter',';');
    case 'random'
        LP2GL_Pv = create_DistributionList(SinInfo, 'DCInfeeder' ,fields_names_PvP, Settings.PV_dist_type);
        Settings.PV_dist_list_name = ['DCInfeeder_Distribution_random_', Settings.Timestamp, '.txt'];
    case 'alphab'
        LP2GL_Pv = create_DistributionList(SinInfo, 'DCInfeeder' ,fields_names_PvP, Settings.PV_dist_type);
        Settings.PV_dist_list_name = ['DCInfeeder_Distribution_alphabetical_order_', Settings.Timestamp, '.txt'];
    case 'DB_order'
        LP2GL_Pv = create_DistributionList(SinInfo, 'DCInfeeder' ,fields_names_PvP, Settings.PV_dist_type);
        Settings.PV_dist_list_name = ['DCInfeeder_Distribution_database_order_', Settings.Timestamp, '.txt'];
    otherwise
        error('Unknown Distribution Type.');
end
% Save distribution list as output
writetable(LP2GL_Pv, [Outputs_Path,Grid_Name, '_', Settings.PV_dist_list_name],'Delimiter',';');

%% Connect the load and PV profiles to one profile database 

% Check if all Profiles have same number of instants
num_steps_Profiles = [structfun(@(x) size(x,1),Load_Profiles);structfun(@(x) size(x,1),PV___Profiles)];
if numel(unique(num_steps_Profiles)) ~= 1
    error('The number of instants in the Profiles are not same.');
end
if any(ismember(fields(Load_Profiles), fields(PV___Profiles)))
    error('Profiles for Loads and DCInfeeders are not allowed to have same name.');
end
TimeSetup.num_of_instants = unique(num_steps_Profiles);

Profile_DB = struct;        % Profile_DB - Database with all profiles    
for k = 1:size(LP2GL_Lo, 1) % Load Profiles
    if ismember(           LP2GL_Lo.Load_Profile(k), fields_names_LoP)
        Profile_DB.       (LP2GL_Lo.Load_Profile{k}) = ...
            Load_Profiles.(LP2GL_Lo.Load_Profile{k})(1 : TimeSetup.num_of_instants, :);
    end
end
for k = 1:size(LP2GL_Pv, 1) % DCInfedder Profiles
    if ismember(           LP2GL_Pv.Load_Profile(k), fields_names_PvP)
        Profile_DB.       (LP2GL_Pv.Load_Profile{k}) = ...
            PV___Profiles.(LP2GL_Pv.Load_Profile{k})(1 : TimeSetup.num_of_instants, :);
    end
end
clear Load_Profiles PV___Profiles k     % To reduce RAM usage

%% Set instants_per_grid number 

% They are two reasons for calculating on more than one grid, one is that
% the maximum memory of an Access Database is 2 GB, the other is the option
% to calculate with more than one processor core (be faster).

% Check approximate memory for all timesteps (TODO: maybe a better approx.)
Needed_MemorySize = 10 + 1.5 * 10^-3 * size(SinInfo.Node,1) * ...
    TimeSetup.num_of_instants; % in MB
Max_MemorySize    = 2024;      % in MB per processor core
if Settings.NumelCores * Max_MemorySize > Needed_MemorySize
    % If all calculation can be done with one run per core
    TimeSetup.instants_per_grid = ...
        ceil(TimeSetup.num_of_instants / Settings.NumelCores);
else
    % If not all calculation can be done with one run per core
    TimeSetup.instants_per_grid = ...
        ceil(TimeSetup.num_of_instants/(         ...
        ceil(Needed_MemorySize / Max_MemorySize) ... % Total number of runs
        ));
end
% Maximum instans per a Sincal grid is 8760 (365 days * 24 hour)
if TimeSetup.instants_per_grid > 365 * 24
    TimeSetup.instants_per_grid = 365 * 24;
end
instants_per_grid = TimeSetup.instants_per_grid; % shorter name
num_grids         = ceil(TimeSetup.num_of_instants/instants_per_grid); % Number of necessary grids

%% Save Simulation Details (Parameters)

SimDetails                                  = Settings                      ;
SimDetails.instants_per_grid                = instants_per_grid             ;
SimDetails.num_grids                        = num_grids                     ;
SimDetails.SinInfo                          = SinInfo                       ;
SimDetails.LoadProfiles_Distribution_List   = LP2GL_Lo                      ;
SimDetails.PVProfiles_Distribution_List     = LP2GL_Pv                      ;
SimDetails.SimType                          = 'LC'                          ;
% SimDetails.First_Moment                   = TimeSetup.First_Moment        ; % (TODO: Implement in future)
% SimDetails.Last_Moment                    = TimeSetup.Last_Moment         ;
% SimDetails.Time_Step                      = TimeSetup.Time_Step           ;
% SimDetails.num_of_instants                = TimeSetup.num_of_instants     ;
% SimDetails.Time_Vector                    = Time_Vector                   ;

SimData_Filename = [Outputs_Path, Grid_Name, '_Simulation_Details_', Settings.Timestamp, '.mat'];

SimDetails_Bytes = whos('SimDetails');
SimDetails_Bytes = SimDetails_Bytes.bytes;
if   SimDetails_Bytes > 2 * 1024^3; save(SimData_Filename, 'SimDetails', '-v7.3');
else                              ; save(SimData_Filename, 'SimDetails'         ); end

%% Add Profile ID to the associated grid element (Load/DCInfeeder)

if waitbar_activ; waitbar(wb_stat(4), wb_Fig, 'Add profile IDs to the associated grid element'); end % Waitbar Update

% Add an ID (Primary key) to the profiles (to the LoadProfile_Info table)
LoadProfile_Info = table;              	
LoadProfile_Info.ProfileName     = fieldnames(Profile_DB);
LoadProfile_Info.Load_Profile_ID = double(1 : size(LoadProfile_Info,1))';

for k_Type = 1 : 2
    switch k_Type
        case 1
            Element_Type = 'Load'      ; % For Loads
            LP2GE_Names  = LP2GL_Lo    ;
        case 2
            Element_Type = 'DCInfeeder'; % For DCInfeeders (PVs)
            LP2GE_Names  = LP2GL_Pv    ;
    end
    LP2GE_IDs = table; % initial table for IDs
    LP2GE_IDs.Element_ID = zeros(size(LP2GE_Names,1), 1);
    LP2GE_IDs.Profile_ID = zeros(size(LP2GE_Names,1), 1);
    for k_Ele = 1 : size(LP2GE_Names, 1) % Grid Element Name -> Grid Element ID -> Profile Name -> Profile ID
        LP2GE_IDs.Element_ID(k_Ele) = SinInfo.(Element_Type).Element_ID(strcmp(SinInfo.(Element_Type).Name , LP2GE_Names.Grid_Load   {k_Ele}));
        LP2GE_IDs.Profile_ID(k_Ele) = LoadProfile_Info.Load_Profile_ID (strcmp(LoadProfile_Info.ProfileName, LP2GE_Names.Load_Profile{k_Ele}));
    end
    sql_in = {['UPDATE ', Element_Type, ' SET DayOpSer_ID = NULL']}; % delete all old values in ColumnToUpdate
    for k_sql = 1 : size(LP2GE_IDs, 1)
        sql_in{ 1 + k_sql, 1} = [...
            'UPDATE '             , Element_Type                        ,...
            ' SET DayOpSer_ID = ' , num2str(LP2GE_IDs.Profile_ID(k_sql)),...
            ' WHERE Element_ID = ', num2str(LP2GE_IDs.Element_ID(k_sql))];
    end
    Matlab2Access_ExecuteSQL(sql_in, DB_Name, DB__PathCopy, DB_Type);
end

%% Sincal Setup in CalcParameter, OpSer and OpSerVal

% Update CalcParameter LC_Duration to equal the number of instans per grid
LC_Duration = num2str(instants_per_grid - 1); 
sql_in = {...
    ['UPDATE CalcParameter SET LC_Duration  = ', LC_Duration]  ;...  
    ('UPDATE CalcParameter SET LC_StartDate = ''01.01.2014''') ;...
    ('UPDATE CalcParameter SET LC_StartTime = 1'             ) ;...
    ('UPDATE CalcParameter SET LC_TimeStep  = 1'             ) ;...
    ('UPDATE CalcParameter SET Flag_LC_Incl = 4'             ) ; ... % 1 - Store Results Completely, 4 - Only Marked
    ('DELETE FROM OpSer;'                                    ) ;...  % Delete old load profiles (if they exist) 
    ('DELETE FROM OpSerVal;'                                 )  ...
    };
Matlab2Access_ExecuteSQL(sql_in, DB_Name, DB__PathCopy, DB_Type);

%% Create schema.ini files

create_schema_ini('input' , Temp_Input_Path , num_grids, instants_per_grid                ); % Input  File
create_schema_ini('output', Temp_Output_Path, num_grids, instants_per_grid, Grid_NameEmpty); % Output File

%% Start parallel pool (for parallel computing)

if waitbar_activ; waitbar(wb_stat(5), wb_Fig, 'Preparing parallel computing'); end % Waitbar Update

poolobj = gcp('nocreate');
if Settings.NumelCores == 1; Settings.ParrallelCom = false; end % Input correction
if Settings.ParrallelCom == true && Settings.NumelCores > 1
    if size(poolobj,1) == 1 % If par-com is already running
        if poolobj.NumWorkers ~= Settings.NumelCores % If numel core's wrong
            delete(poolobj);
            parpool('local', Settings.NumelCores);   % start a new par-com
        end
    else
        parpool('local', Settings.NumelCores);
    end
else
    delete(poolobj); % stop par-com if is already running but should not
end

%% Preparing the profiles as txt files to be read in into Sincal
% To add profiles in Sincal the database tables OpSer and OpSerVal has to
% be modified. In this section the txt input files for the OpSer and
% OpSerVal tables will be created based on the profiles. Based on the
% number of grids, the profiles will be cut to appropriate size.

if waitbar_activ; waitbar(wb_stat(6), wb_Fig, 'Preparing the profiles for reading into Sincal'); end % Waitbar Update

if num_grids > 1 % If more than one grid is needed, divide the profiles.
    Profile_divide = structfun(@(x) fields(x), Profile_DB, 'UniformOutput', 0); % Initial
    for k_grid = 1 : num_grids
        if k_grid < num_grids % last sub-grid can have a smaller number of instrants
            Profile_divide(k_grid) = structfun(@(x) x(...
                ((k_grid - 1) * instants_per_grid + 1) : k_grid * instants_per_grid,...
                :), Profile_DB, 'UniformOutput', 0);
        else % last sub-grid
            Profile_divide(k_grid) = structfun(@(x) x(...
                ((k_grid - 1) * instants_per_grid + 1) : end,...
                :), Profile_DB, 'UniformOutput', 0);
        end
    end
    Profile_DB = Profile_divide;    % To reduce RAM usage
    clear Profile_divide
end
% Create the txt files to read in profiles into Sincal
if Settings.ParrallelCom == false % Not parralel
    for k_grid =    1 : num_grids % over all grids
        File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
        create_txt_input(Profile_DB(k_grid), Temp_Input_Path, File_suffix);
    end
else % Parralel
    parfor k_grid = 1 : num_grids % over all grids
        File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
        create_txt_input(Profile_DB(k_grid), Temp_Input_Path, File_suffix);
    end
end
clear Profile_DB    % To reduce RAM usage

%% Make copys of the Sincal grid & Put txt file of profiles to database

if waitbar_activ; waitbar(wb_stat(7), wb_Fig, 'Loading Files into DB and performing power flow'); end % Waitbar Update

if Settings.ParrallelCom == false % Not parralel
    for k_grid    = 1 : num_grids % over all grids
        File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
        Txt2Database(Grid_Name, Temp_Input_Path, Temp_Grids_Path, File_suffix);
    end
else
    parfor k_grid = 1 : num_grids % over all grids
        File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
        Txt2Database(Grid_Name, Temp_Input_Path, Temp_Grids_Path, File_suffix);
    end
end

%% Load flow calculation with load profiles

if Settings.ParrallelCom == false % Not parralel    
    for k_grid    = 1 : num_grids % over all grids
        File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
        Mat2Sin_StartLFProfile([Grid_Name, File_suffix], Temp_Grids_Path, VerSincal); % Calculate load flow with load profiles
    end
else
    parfor k_grid = 1 : num_grids % over all grids
        File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];  
        Mat2Sin_StartLFProfile([Grid_Name, File_suffix], Temp_Grids_Path, VerSincal); % Calculate load flow with load profiles
    end
end

% It seems that sometimes it is mor sable to restart parallel pool
% poolobj = gcp('nocreate'); delete(poolobj); parpool('local', Settings.NumelCores);

%% Read out database table values into txt files

if waitbar_activ; waitbar(wb_stat(8), wb_Fig, 'Creating NodeRes and BranchRes files'); end % Waitbar Update

Column_str_Node   = strjoin(NodeResVariables  , ', '); % Sql command part that contains Column Names in ULFNodeRes
Column_str_Branch = strjoin(BranchResVariables, ', '); % Sql command part that contains Column Names in ULFBranchRes

Done_all = false(num_grids, 1);     % If some executions fail in parrallel, they will be done without parralel
if Settings.ParrallelCom == false   % Not parralel
    for k_grid = 1 : num_grids % over all grids
        if ~Done_all(k_grid)
            File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];  
            Done_all(k_grid) = create_txt_output(Grid_Name, Temp_Grids_Path, Temp_Output_Path, File_suffix, Column_str_Node, Column_str_Branch);
        end
    end
else
    parfor k_grid = 1 : num_grids % over all grids
        if ~Done_all(k_grid)
            File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];  
            Done_all(k_grid) = create_txt_output(Grid_Name, Temp_Grids_Path, Temp_Output_Path, File_suffix, Column_str_Node, Column_str_Branch);
        end
    end
end

% It seems that sometimes it is mor sable to restart parallel pool
% poolobj = gcp('nocreate'); delete(poolobj); parpool('local', Settings.NumelCores);

%% Second try Database2Txt, not parallel (fall-back solution)

for k_grid = 1 : num_grids % over all grids
    if ~Done_all(k_grid)
        File_suffix = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
        Done_all(k_grid) = create_txt_output(Grid_Name, Temp_Grids_Path, Temp_Output_Path, File_suffix, Column_str_Node, Column_str_Branch);
    end
end

%% Output preperation

if Settings.Output_option_preparation
    if waitbar_activ; waitbar(wb_stat(9), wb_Fig, 'Preparing Power Flow results for analysis'); end % Waitbar Update
    if Settings.ParrallelCom == false % Not parralel
        for    k_Type = 1 : 2
            switch k_Type
                case 1; Output_read_NodeRes  (Outputs_Path, Temp_Output_Path, Grid_Name, instants_per_grid, num_grids, SinInfo, Settings);
                case 2; Output_read_BranchRes(Outputs_Path, Temp_Output_Path, Grid_Name, instants_per_grid, num_grids, SinInfo, Settings);
            end
        end
    else
        parfor k_Type = 1 : 2
            switch k_Type
                case 1; Output_read_NodeRes  (Outputs_Path, Temp_Output_Path, Grid_Name, instants_per_grid, num_grids, SinInfo, Settings);
                case 2; Output_read_BranchRes(Outputs_Path, Temp_Output_Path, Grid_Name, instants_per_grid, num_grids, SinInfo, Settings);
            end
        end
    end
%     if Output_options.T_vector % (TODO: Implement in future)
%         Output_Filename = [Output_Name,'_Time_Vector.mat'];
%         SimData_Filename = [Outputs_Path,Output_Filename];
%         save(SimData_Filename,'Time_Vector','-v7.3');
%     end
else % If no output preperation is wanted just copy the txt files. 
    if waitbar_activ; waitbar(wb_stat(9), wb_Fig, 'Copying NodeRes and BranchRes files'); end % Waitbar Update
    files = [Temp_Output_Path, 'NodeRes*'  ]; copyfile(files, Outputs_Path);
    files = [Temp_Output_Path, 'BranchRes*']; copyfile(files, Outputs_Path);
end

%% Delete all temporary simulation files

if Settings.Output_option_del_temp_files    
    rmdir(Temp_Input_Path ,'s'); % delete input  Files    
    rmdir(Temp_Output_Path,'s'); % delete output Files    
    rmdir(Temp_Grids_Path ,'s'); % delete grids  Files
end

%% Delete Main Waitbar and finalising simulation process

if waitbar_activ; waitbar(wb_stat(10), wb_Fig, 'Finishing'); delete(wb_Fig); end
disp('Simulation completed');
status = true;

end

%% Create the txt input files for reading profiles into Sincal

function create_txt_input(Profile_DB, File_Path, File_suffix)
OpSer_Name = fieldnames(Profile_DB);
% Create txt files for OpSer and OpSerVal (read in profiles)
create_OpSer_txt   (OpSer_Name, File_Path, File_suffix);
create_OpSerVal_txt(Profile_DB, File_Path, File_suffix);
end

%% Make copys of the Sincal grid and load profiles into them

function Txt2Database(Grid_Name, GridPathMain, GridPathCopy, File_suffix)
% Prepare Sincal files and folders for copying
GridNameMain = [GridPathMain, Grid_Name, '_empty'   , '.sin'   ];
GridNameCopy = [GridPathCopy, Grid_Name, File_suffix, '.sin'   ];
DB__PathMain = [GridPathMain, Grid_Name, '_empty'   , '_files\'];
DB__PathCopy = [GridPathCopy, Grid_Name, File_suffix, '_files\'];

copyfile(GridNameMain, GridNameCopy); % copy the sincal file
copyfile(DB__PathMain, DB__PathCopy); % copy the sincal Grid folder with database

% Adjust database.ini
delete([DB__PathCopy,'database.ini']);
fileID = fopen([DB__PathCopy,'database.ini'],'at');
fprintf(fileID,[                                             ...
    '[Config]                \n'                             ...
    'DisableStdDocHandling=0 \n'                             ...
    '[Exclude]               \n'                             ...
    '[Database]              \n'                             ...
    'MODE=JET                \n'                             ...
    strrep(['FILE=', DB__PathCopy, 'database.mdb'],'\','\\') ...
    ]); fclose(fileID);

% Read in OpSer and OpSerVal txt files into Access DB
sql_in = {...
    ['INSERT INTO OpSer    SELECT * FROM [Text;DATABASE=', GridPathMain, '].[OpSer'   , File_suffix, '.txt]'];...
    ['INSERT INTO OpSerVal SELECT * FROM [Text;DATABASE=', GridPathMain, '].[OpSerVal', File_suffix, '.txt]'] ...
    };
Matlab2Access_ExecuteSQL(sql_in, 'database', DB__PathCopy , '.mdb');
end

%% Create the txt output files with results of the Sincal calculation

function Done_this = create_txt_output(Grid_Name, Temp_Grids_Path, Temp_Output_Path, File_suffix, Column_str_Node, Column_str_Branch)
sql_command_str = {... % Sql command for reading write a table as txt file
    ['SELECT ', Column_str_Node  , ' INTO [Text;HDR=YES;DATABASE=', Temp_Output_Path, '].[NodeRes_'  , [Grid_Name, File_suffix], '.txt] FROM ULFNodeResult'  ];...
    ['SELECT ', Column_str_Branch, ' INTO [Text;HDR=YES;DATABASE=', Temp_Output_Path, '].[BranchRes_', [Grid_Name, File_suffix], '.txt] FROM ULFBranchResult'] ...
    };
skip_error = true;
Done_this = Matlab2Access_ExecuteSQL(sql_command_str, 'database', [Temp_Grids_Path, Grid_Name, File_suffix, '_files'], '.mdb', skip_error);
end