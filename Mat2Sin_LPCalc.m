function status = Mat2Sin_LPCalc(Inputs)
%% Mat2Sin_LPCalc (TODO: adjust Input list)
%   
%   Mat2Sin_LPCalc      - This script demonstrates the work of the load
%                         flow calculation for load profiles (load flow 
%                         calculation for more than one timestamp at once) 
%                         in Sincal managed from Matlab.
%
%                       - Duo to the maximum 2GB database size of Access
%                         databases, the profiles need to be split into
%                         smaller profiles if the load flow results 
%                         exceed 2GB.
%
%   Inputs                Structure with all necessary inputs
%                           Inputs.Grid_Path
%                           Inputs.Grid_Name
%                           Inputs.LP_DB_Type
%                           Inputs.PV_DB_Type
%                           Inputs.LP_DB_Path
%                           Inputs.LP_DB_Name
%                           Inputs.PV_DB_Path
%                           Inputs.PV_DB_Name
%                           Inputs.LP_dist_type
%                           Inputs.LP_dist_path
%                           Inputs.LP_dist_list_name
%                           Inputs.PV_dist_type
%                           Inputs.PV_dist_path
%                           Inputs.PV_dist_list_name
%                           Inputs.TimeSetup_First_Moment       (TODO)
%                           Inputs.TimeSetup_Last_Moment        (TODO)
%                           Inputs.TimeSetup_Time_Step          (TODO)
%                           Inputs.TimeSetup_num_of_instants    (TODO)
%                           Inputs.TimeSetup_First_Moment_PF    (TODO)
%                           Inputs.TimeSetup_Last_Moment_PF     (TODO)
%                           Inputs.Output_option_raw
%                           Inputs.Output_option_raw_only
%                           Inputs.Output_option_per_node_branch
%                           Inputs.Output_option_per_unit
%                           Inputs.Output_option_del_temp_files
%                           Inputs.Output_option_preparation
%                           Inputs.Output_option_U
%                           Inputs.Output_option_P
%                           Inputs.Output_option_Q
%                           Inputs.Output_option_S
%                           Inputs.Output_option_phi
%                           Inputs.Output_option_I
%                           Inputs.Output_option_P_flow
%                           Inputs.Output_option_Q_flow
%                           Inputs.Output_option_S_flow
%                           Inputs.Output_option_T_vector
%                           Inputs.Output_option_Sin_Info
%                           Inputs.Output_Path
%                           Inputs.Output_Name  
%                           Inputs.Data_Path
%                           Inputs.Inputs_Path
%                           Inputs.Outputs_Path
%                           Inputs.VerSincal
%                           Inputs.ParrallelCom
%                           Inputs.NumelCores               (optional)
%                           Inputs.waitbar_activ            (optional)
%   Flowchart:
%
%                   1. Clear start
%                   2. Path and directory preparation
%                   3. Load the load profiles
%                   4. Load static input (e.q. column names in a database)
%                   5. Prepare the Sincal grid
%                   6. Link between load profile and load in Sincal grid
%                   7. Setup customization
%                   8. Create schema.ini file
%                   9. Adjustment of load profiles
%                   10. Start parallel pool (for parallel computing)
%                   11. Load flow calculation with load profiles
%                   12. Delete overhead
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

%% TODO: Not clear

if ~Settings.Output_option_preparation
    Settings.Output_option_del_temp_files = false;
end

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

%% Setting up Time Vector (TODO)

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

%% Load static input (e.q. column names of tables in sincal database)

% Column names of Table ULFNodeRes und ULFBranchRes
load([pwd, '\Data\Static_Input\Col_Name_ULFNodeResult.mat'  ], 'Col_Name_ULFNodeResult'  );
load([pwd, '\Data\Static_Input\Col_Name_ULFBranchResult.mat'], 'Col_Name_ULFBranchResult');
% load([pwd, '\Data\Static_Input\Col_Name_OpSer.mat'          ], 'Col_Name_OpSer'          ); % TODO: Delete this files
% load([pwd, '\Data\Static_Input\Col_Name_OpSerVal.mat'       ], 'Col_Name_OpSerVal'       ); % TODO: Delete this files

NodeVector   = calcNodeOutputVector  (Settings);
BranchVector = calcBranchOutputVector(Settings);

DB_Name = 'database';
DB_Type = '.mdb'    ;

%% Prepare the a copy of sincal grid and get the Info about the grid

if waitbar_activ; waitbar(wb_stat(2), wb_Fig, 'Preparing Sincal Grid'); end % Waitbar Update

GridNameMain = [Grid_Path       , Grid_Name      , '.sin'   ];
GridNameCopy = [Temp_Input_Path , Grid_NameEmpty , '.sin'   ];
DB__PathMain = [Grid_Path       , Grid_Name      , '_files\'];
DB__PathCopy = [Temp_Input_Path , Grid_NameEmpty , '_files\'];

copyfile(GridNameMain, GridNameCopy); % copy the sincal file
copyfile(DB__PathMain, DB__PathCopy); % copy the sincal Grid folder with database

% Get Grind basic information (nodes,lines,loads,etc.)
SinInfo = Mat2Sin_GetSinInfo(Grid_NameEmpty,Temp_Input_Path);   % TODO, maybe better position in Code

%% Load the load and photovoltaic (PV) profiles

if waitbar_activ; waitbar(wb_stat(3), wb_Fig, 'Loading Load and PV profiles'); end % Waitbar Update

switch Settings.LP_DB_Type     % Loading Load Profiles Database
    case 'DB'
        Load_Profiles = load([Settings.LP_DB_Path,Settings.LP_DB_Name]);
        temp_field    = fields(Load_Profiles);
        Load_Profiles = Load_Profiles.(temp_field{:});
    case 'AAPD'
        error('Database Type not yet implemented.');    % TODO
%         Load_Profiles = generate_AAPD_LPs(numel(SinInfo.Load.Element_ID),'1P','PLC_Tool',TimeSetup.Time_Step);
%         Output_Filename = [Grid_Name,'_AAPD_LP_DB.mat'];
%         SimData_Filename = [Outputs_Path,Output_Filename];
%         save(SimData_Filename,'Load_Profiles','-v7.3');
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
        Settings.LP_dist_list_name = 'Load_Distribution_random.txt';
    case 'alphab'
        LP2GL_Lo = create_DistributionList(SinInfo, 'Load' ,fields_names_LoP, Settings.LP_dist_type);
        Settings.LP_dist_list_name = 'Load_Distribution_alphabetical_order.txt';
    case 'DB_order'
        LP2GL_Lo = create_DistributionList(SinInfo, 'Load' ,fields_names_LoP, Settings.LP_dist_type);
        Settings.LP_dist_list_name = 'Load_Distribution_database_order.txt';
    otherwise
        error('Unknown Distribution Type.');
end
% Save distribution list as output
writetable(LP2GL_Lo,[Outputs_Path,Grid_Name,'_',Settings.LP_dist_list_name],'Delimiter',';');

% Loading or Generating the distribution of the PV Profiles on the Grid PV
switch Settings.PV_dist_type
    case 'list'
        LP2GL_Pv     = readtable([Settings.PV_dist_path,Settings.PV_dist_list_name],'Delimiter',';');
    case 'random'
        LP2GL_Pv = create_DistributionList(SinInfo, 'DCInfeeder' ,fields_names_PvP, Settings.PV_dist_type);
        Settings.PV_dist_list_name = 'DCInfeeder_Distribution_random.txt';
    case 'alphab'
        LP2GL_Pv = create_DistributionList(SinInfo, 'DCInfeeder' ,fields_names_PvP, Settings.PV_dist_type);
        Settings.PV_dist_list_name = 'DCInfeeder_Distribution_alphabetical_order.txt';
    case 'DB_order'
        LP2GL_Pv = create_DistributionList(SinInfo, 'DCInfeeder' ,fields_names_PvP, Settings.PV_dist_type);
        Settings.PV_dist_list_name = 'DCInfeeder_Distribution_database_order.txt';
    otherwise
        error('Unknown Distribution Type.');
end
% Save distribution list as output
writetable(LP2GL_Pv,[Outputs_Path,Grid_Name,'_',Settings.PV_dist_list_name],'Delimiter',';');

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
for k = 1:size(LP2GL_Lo,1)  % Load Profiles
    if ismember(           LP2GL_Lo.Load_Profile(k), fields_names_LoP)
        Profile_DB.(       LP2GL_Lo.Load_Profile{k}) = ...
            Load_Profiles.(LP2GL_Lo.Load_Profile{k})(1 : TimeSetup.num_of_instants, :);
    end
end
for k = 1:size(LP2GL_Pv,1)  % DCInfedder Profiles
    if ismember(           LP2GL_Pv.Load_Profile(k), fields_names_PvP)
        Profile_DB.(       LP2GL_Pv.Load_Profile{k}) = ...
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

%% Add Profile ID to the associated grid element (Load/DCInfeeder)

if waitbar_activ; waitbar(wb_stat(4), wb_Fig, 'Add profile IDs to the associated grid element'); end % Waitbar Update

% Add an ID (Primary key) to the profiles (to the LoadProfile_Info table)
LoadProfile_Info = table;              	
LoadProfile_Info.ProfileName    (:) = fieldnames(Profile_DB);
LoadProfile_Info.Load_Profile_ID(:) = 1 : size(LoadProfile_Info,1);

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
        GridNameCopy = [Grid_Name, '_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
        Mat2Sin_StartLFProfile(GridNameCopy, Temp_Grids_Path, VerSincal); % Calculate load flow with load profiles
    end
else
    parfor k_grid = 1 : num_grids % over all grids
        GridNameCopy = [Grid_Name, '_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];       
        Mat2Sin_StartLFProfile(GridNameCopy, Temp_Grids_Path, VerSincal); % Calculate load flow with load profiles
    end
end

% It seems that sometimes it is mor sable to restart parallel pool
% poolobj = gcp('nocreate'); delete(poolobj); parpool('local',Settings.NumelCores);

%% Database2Txt

if waitbar_activ; waitbar(wb_stat(8), wb_Fig, 'Creating NodeRes and BranchRes files'); end % Waitbar Update

Column_str_Node   = strjoin(Col_Name_ULFNodeResult  (NodeVector  ),', '); % Sql command (string) part that contains Column Names   
Column_str_Branch = strjoin(Col_Name_ULFBranchResult(BranchVector),', '); % Sql command (string) part that contains Column Names
k_grid_input = 1:num_grids;
Done_all = false(num_grids,1);
if Settings.ParrallelCom == false   % Not parralel
    for k = 1:num_grids % over all grids
        if ~Done_all(k)
            Done_all(k) = create_txt_output(k_grid_input,k,Grid_Name,instants_per_grid,Temp_Grids_Path,DB_Name,DB_Type,Column_str_Node,Column_str_Branch,Temp_Output_Path);
        end
    end
else
    parfor k = 1:num_grids % over all grids
        if ~Done_all(k)
            Done_all(k) = create_txt_output(k_grid_input,k,Grid_Name,instants_per_grid,Temp_Grids_Path,DB_Name,DB_Type,Column_str_Node,Column_str_Branch,Temp_Output_Path);
        end
    end
end
% poolobj = gcp('nocreate');
% delete(poolobj)

%% second try Database2Txt (to improve), not parallel

for k = 1:num_grids % second try ... to improve
    if ~Done_all(k)
        Done_all(k) = create_txt_output(k_grid_input,k,Grid_Name,instants_per_grid,Temp_Grids_Path,DB_Name,DB_Type,Column_str_Node,Column_str_Branch,Temp_Output_Path);
    end
end

%% Output preperation

if Settings.Output_option_preparation
    % Waitbar Update
    if waitbar_activ; waitbar(wb_stat(9), wb_Fig, 'Preparing Power Flow results for analysis'); end
    for k = 1 : 2   % TODO Made it over parfor?
        if k == 1
            Output_read_NodeRes(Outputs_Path,Temp_Output_Path,Grid_Name,instants_per_grid,num_grids,SinInfo,Grid_Name,Settings);
        else
            Output_read_BranchRes(Outputs_Path,Temp_Output_Path,Grid_Name,instants_per_grid,num_grids,SinInfo,Grid_Name,Settings);
        end
    end
%     if Output_options.T_vector
%         Output_Filename = [Output_Name,'_Time_Vector.mat'];
%         SimData_Filename = [Outputs_Path,Output_Filename];
%         save(SimData_Filename,'Time_Vector','-v7.3');
%     end
    if Settings.Output_option_Sin_Info
        Output_Filename  = [Grid_Name,'_Grid_Info.mat'];
        SimData_Filename = [Outputs_Path,Output_Filename];
        SinInfo_Bytes = whos('SinInfo');
        SinInfo_Bytes = SinInfo_Bytes.bytes;
        if SinInfo_Bytes > 2 * 1024^3 ; save(SimData_Filename,'SinInfo','-v7.3' );
        else                          ; save(SimData_Filename,'SinInfo'         ); end
    end
else
    % Waitbar Update
    if waitbar_activ; waitbar(wb_stat(9), wb_Fig, 'Copying NodeRes and BranchRes files'); end
    files = [Temp_Output_Path,'NodeRes*'  ]; copyfile(files,Outputs_Path);
    files = [Temp_Output_Path,'BranchRes*']; copyfile(files,Outputs_Path);
end

%% Save all Simulation Details (Parameters)

if waitbar_activ; waitbar(wb_stat(9), wb_Fig, 'Saving Simulation Details'); end % Waitbar Update

SimDetails                                  = struct                        ;
SimDetails.Grid_Name                        = Grid_Name                     ;
SimDetails.instants_per_grid                = instants_per_grid             ;
SimDetails.num_grids                        = num_grids                     ;
SimDetails.SinInfo                          = SinInfo                       ;
SimDetails.Grid_Name                        = Grid_Name                     ;
SimDetails.Output_Name                      = Grid_Name                     ;
SimDetails.Outputs_Path                     = Outputs_Path                  ;
SimDetails.LoadProfiles_type                = Settings.LP_DB_Type           ;
SimDetails.PVProfiles_type                  = Settings.PV_DB_Type           ;
SimDetails.LoadProfiles_Distrubution_method = Settings.LP_dist_type         ;
SimDetails.PVProfiles_Distrubution_method   = Settings.PV_dist_type         ;
SimDetails.LoadProfiles_Dist_ListName_Input = Settings.LP_dist_list_name    ;
SimDetails.PVProfiles_Dist_ListName_Input   = Settings.PV_dist_list_name    ;
SimDetails.LoadProfiles_Distribution_List   = LP2GL_Lo                      ;
SimDetails.PVProfiles_Distribution_List     = LP2GL_Pv                      ;
SimDetails.LoadProfiles_Database_Name       = Settings.LP_DB_Name           ;
SimDetails.PVProfiles_Database_Name         = Settings.PV_DB_Name           ;
SimDetails.Output_content                   = Settings                      ;
SimDetails.SimType                          = 'PF'                          ; %#ok % Will be just saved
% SimDetails.First_Moment                   = TimeSetup.First_Moment        ;
% SimDetails.Last_Moment                    = TimeSetup.Last_Moment         ;
% SimDetails.Time_Step                      = TimeSetup.Time_Step           ;
% SimDetails.num_of_instants                = TimeSetup.num_of_instants     ;
% SimDetails.Time_Vector                    = Time_Vector                   ;

Output_Filename  = [Grid_Name, '_Simulation_Details.mat'];
SimData_Filename = [Outputs_Path,Output_Filename];

SimDetails_Bytes = whos('SimDetails');
SimDetails_Bytes = SimDetails_Bytes.bytes;
if   SimDetails_Bytes > 2 * 1024^3; save(SimData_Filename,'SimDetails','-v7.3');
else                              ; save(SimData_Filename,'SimDetails')        ; end

%% Delete all temporary simulation files

if Settings.Output_option_del_temp_files    
    rmdir(Temp_Input_Path ,'s'); % delete input  Files    
    rmdir(Temp_Output_Path,'s'); % delete output Files    
    rmdir(Temp_Grids_Path ,'s'); % delete grids  Files
end

%% Delete Main Waitbar and finalising simulation process

if waitbar_activ
    waitbar(wb_stat(10), wb_Fig, 'Finishing');
    delete(wb_Fig);
end
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

%%

function Done_this = create_txt_output(k_grid_input,k,Grid_Name,instants_per_grid,Temp_Grids_Path,DB_Name,DB_Type,Column_str_Node,Column_str_Branch,Temp_Output_Path)
k_grid = k_grid_input(k);
SinName         = [Grid_Name,'_',num2str(instants_per_grid),'inst_',num2str(k_grid)];
SinFolName      = [Grid_Name,'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'_files\'];
name_txt        = ['NodeRes_',SinName,'.txt'];     % Save load flow results as txt files
table_Name      = 'ULFNodeResult';               % Results from ULFNodeResult
% Sql command for reading from Table FROM ULFNodeResult + writing Table
% ULFNodeResult in a .txt-file
sql_command_str = ['SELECT ' ,Column_str_Node, ' INTO [Text;HDR=YES;DATABASE=',Temp_Output_Path,'].[',name_txt,'] FROM ', table_Name ];
Matlab2Access_ExecuteSQL(sql_command_str, DB_Name,[Temp_Grids_Path,SinFolName],DB_Type);
name_txt        = ['BranchRes_',SinName,'.txt'];
table_Name      = 'ULFBranchResult';        % Results from ULFBranchResult
sql_command_str = ['SELECT ' ,Column_str_Branch, ' INTO [Text;HDR=YES;DATABASE=',Temp_Output_Path,'].[',name_txt,'] FROM ', table_Name ];
Done_this = Matlab2Access_ExecuteSQL(sql_command_str, DB_Name, [Temp_Grids_Path,SinFolName], DB_Type);
end