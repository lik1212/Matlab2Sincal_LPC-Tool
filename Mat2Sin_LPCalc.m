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
    wb_Fig = waitbar(0,'Main progress','Name','LPC Tool main progress');
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

DB_Name      = 'database';                               	% DB Name
DB_Type      = '.mdb';                                      % DB Typ

%% Prepare the Sincal grid

if waitbar_activ; waitbar(wb_stat(2), wb_Fig, 'Preparing Sincal Grid'); end % Waitbar Update

GridNameMain = [Grid_Path       , Grid_Name      , '.sin'   ];
GridNameCopy = [Temp_Input_Path , Grid_NameEmpty , '.sin'   ];
DB__PathMain = [Grid_Path       , Grid_Name      , '_files\'];
DB__PathCopy = [Temp_Input_Path , Grid_NameEmpty , '_files\'];

copyfile(GridNameMain, GridNameCopy); % copy the sincal file
copyfile(DB__PathMain, DB__PathCopy); % copy the sincal Grid folder with database

% Delete old load profiles (if they exist) - TODO: Can be put latter with
% changes in CalcParameter
sql_in = {...
    'DELETE FROM OpSer;'    ;...
    'DELETE FROM OpSerVal;'  ...
    };  
Done = Matlab2Access_ExecuteSQL(sql_in, DB_Name, DB__PathCopy, DB_Type);
if ~Done; return; end

% Get Grind basic information (nodes,lines,loads,etc.)
SinInfo = Mat2Sin_GetSinInfo(Grid_NameEmpty,Temp_Input_Path);   % TODO, better position in Code

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
    error('The number of intants in the load profiles are not same!');
end
TimeSetup.num_of_instants = unique(num_steps_Profiles);

Profile_DB = struct;        % Profile_DB - Database with all profiles    
for k = 1:size(LP2GL_Lo,1)  % Load Profiles
    if ismember(             LP2GL_Lo.Load_Profile(k), fields_names_LoP)
        Profile_DB.(['Load_',LP2GL_Lo.Load_Profile{k}]) = ...
            Load_Profiles.(  LP2GL_Lo.Load_Profile{k})(1:TimeSetup.num_of_instants, :);
    end
end
for k = 1:size(LP2GL_Pv,1)  % DCInfedder Profiles
    if ismember(             LP2GL_Pv.Load_Profile(k), fields_names_PvP)
        Profile_DB.(['PV___',LP2GL_Pv.Load_Profile{k}]) = ...
            PV___Profiles.(  LP2GL_Pv.Load_Profile{k})(1:TimeSetup.num_of_instants, :);
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
        ceil(TimeSetup.num_of_instants/Settings.NumelCores);
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

instants_per_grid_char = num2str(instants_per_grid);
num_grids = ceil(TimeSetup.num_of_instants/instants_per_grid); % Number of necessary grids

%% Link between load profile and load in Sincal grid % TODO, Comments anpassen

fieldnames_DB      = fieldnames(Profile_DB);
OpSer_Name         = cellfun(@(x) x(6:end), fieldnames_DB,'UniformOutput',0);   % Without 'Load_' or 'PV___'
num_of_profiles    = numel(fieldnames(Profile_DB));                             % number of load*3 (phase L1, L2, L3)
LoadProfile_Info   = table;                                                     % LoadProfile_Info table

LoadProfile_Info.ProfileName     = OpSer_Name; 
LoadProfile_Info.Load_Profile_ID = reshape(1:num_of_profiles,num_of_profiles,1);

%% Add Load Profiles to Sincal Database

% Waitbar Update
if waitbar_activ; waitbar(wb_stat(4), wb_Fig, 'Adding load and PV Profiles to Sincal Grid'); end

LP2GL_Lo_IDs = table;           % IDs for the load profile to grid load connection (important for Sincal)
LP2GL_Lo_IDs.Grid_Load_ID    = zeros(size(LP2GL_Lo,1),1);% initial
LP2GL_Lo_IDs.Load_Profile_ID = zeros(size(LP2GL_Lo,1),1);
for k_Load = 1:size(LP2GL_Lo,1)% Names -> IDs
    LP2GL_Lo_IDs.Grid_Load_ID(k_Load)    = SinInfo.Load.Element_ID(strcmp(SinInfo.Load.Name,LP2GL_Lo{k_Load,1}));
    LP2GL_Lo_IDs.Load_Profile_ID(k_Load) = LoadProfile_Info.Load_Profile_ID(strcmp(LoadProfile_Info.ProfileName,LP2GL_Lo{k_Load,2}));
end
if istable(LP2GL_Lo_IDs)% Table2Array for value_in
    LP2GL_Lo_IDs = table2array(LP2GL_Lo_IDs);
end
sql_in = {'UPDATE Load SET DayOpSer_ID = NULL'};    %delete all old values in ColumnToUpdate
sql_offset = size(sql_in,1);
for k_sql = 1 : size(LP2GL_Lo_IDs,1)
    sql_in{sql_offset + k_sql,1} = [...
        'UPDATE Load SET DayOpSer_ID = ', num2str(LP2GL_Lo_IDs(k_sql,2)),...
        ' WHERE Element_ID = ',           num2str(LP2GL_Lo_IDs(k_sql,1))];
end
Matlab2Access_ExecuteSQL(sql_in,'database',[Temp_Input_Path,Grid_NameEmpty,'_files'],'.mdb');  %TODO
clear fields_names_LoP  % TODO

%% Add PV Profiles to Sincal Database

LP2GL_Pv_IDs = table; % IDs for the load profile to grid load connection (important for Sincal)
LP2GL_Pv_IDs.Grid_Load_ID    = zeros(size(LP2GL_Pv,1),1);   % initial
LP2GL_Pv_IDs.Load_Profile_ID = zeros(size(LP2GL_Pv,1),1);
for k_Load = 1:size(LP2GL_Pv,1)% Names -> IDs
    LP2GL_Pv_IDs.Grid_Load_ID(k_Load)    = SinInfo.DCInfeeder.Element_ID(strcmp(SinInfo.DCInfeeder.Name,LP2GL_Pv{k_Load,1}));
    LP2GL_Pv_IDs.Load_Profile_ID(k_Load) = LoadProfile_Info.Load_Profile_ID(strcmp(LoadProfile_Info.ProfileName,LP2GL_Pv{k_Load,2}));
end
if istable(LP2GL_Pv_IDs)% Table2Array for value_in
    LP2GL_Pv_IDs = table2array(LP2GL_Pv_IDs);
end
sql_in = {'UPDATE DCInfeeder SET DayOpSer_ID = NULL'}; %delete all old values in ColumnToUpdate
sql_offset = size(sql_in,1);
for k_sql = 1 : size(LP2GL_Pv_IDs,1)
    sql_in{sql_offset + k_sql,1} = [...
        'UPDATE DCInfeeder SET DayOpSer_ID = ', num2str(LP2GL_Pv_IDs(k_sql,2)),...
        ' WHERE Element_ID = ',                 num2str(LP2GL_Pv_IDs(k_sql,1))];
end
Matlab2Access_ExecuteSQL(sql_in,'database',[Temp_Input_Path,Grid_NameEmpty,'_files'],'.mdb');  %TODO
clear fields_names_PvP % TODO

%% Sincal Setup customization in CalcParameter

instants_in_LC_Duration = instants_per_grid - 1; % Update CalcParameter LC_Duration to equal the number of instans per grid
sql_in = {...
    ('UPDATE CalcParameter SET LC_Duration  = NULL');...                                % delete all old values in ColumnToUpdate
    ['UPDATE CalcParameter SET LC_Duration  = ', num2str(instants_in_LC_Duration)];...  
    ('UPDATE CalcParameter SET LC_StartDate = ''01.01.2014''');...
    ('UPDATE CalcParameter SET LC_StartTime = 1'); ...
    ('UPDATE CalcParameter SET LC_TimeStep  = 1'); ...
    ('UPDATE CalcParameter SET Flag_LC_Incl = 4')  ... % 1 - Store Results Completely, 4 - Only Marked
    };
Matlab2Access_ExecuteSQL(sql_in,'database',[Temp_Input_Path,Grid_NameEmpty,'_files'],'.mdb');

%% Create schema.ini files

create_schema_ini('input' , Temp_Input_Path , num_grids, instants_per_grid                ); % Input  File
create_schema_ini('output', Temp_Output_Path, num_grids, instants_per_grid, Grid_NameEmpty); % Output File

%% Start parallel pool (for parallel computing) (TODO)

% Waitbar Update
if waitbar_activ; waitbar(wb_stat(5), wb_Fig, 'Start Parallel Computing'); end

if Settings.ParrallelCom == true       % If i only need one Grid, is it faster to do it with one?
    poolobj = gcp('nocreate');      % TODO
    delete(poolobj)                 % TODO
    if num_grids > 1
        poolobj = gcp('nocreate');
        if isempty(poolobj)
%             myCluster = parcluster('local');  % TODO
            poolsize = Settings.NumelCores;
            if poolsize > num_grids
                poolsize = num_grids;
            end
            parpool('local',poolsize);
        else
%             poolsize = poolobj.NumWorkers;    % TODO
        end
    else
        disp('No need for parallel computing, will be faster without.');
        Settings.ParrallelCom  = false;
        Settings.NumelCores    = 1;
    end
end

%% Adjustment of load profiles and create OpSer and OpSerVal txt
% For parallel computing the memory must be kept low, for this reason the
% load profiles need to be adjusted.

% Waitbar Update
if waitbar_activ; waitbar(wb_stat(6), wb_Fig, 'Create ObSer und ObSerVal'); end

% parfor k_grid =  1:num_grids % over all grids % parfor only for strong PC (Server)
if Settings.ParrallelCom == false   % Not parralel
    for k_grid =  1:num_grids % over all grids % parfor only for strong PC (Server)
        prep_txt_input(Profile_DB,fieldnames_DB,num_grids,k_grid,instants_per_grid,instants_per_grid_char,Temp_Input_Path);
    end
else    % Parralel
    parfor k_grid =  1:num_grids % over all grids % parfor only for strong PC (Server)
        prep_txt_input(Profile_DB,fieldnames_DB,num_grids,k_grid,instants_per_grid,instants_per_grid_char,Temp_Input_Path);
    end
end
% delete Profile_DB (for parallel computing the memory must be kept low)
clear Profile_DB Profile_temp

%% Txt2Database

% Waitbar Update
if waitbar_activ; waitbar(wb_stat(7), wb_Fig, 'Loading Sincal DB and performing PF calculation'); end
if Settings.ParrallelCom == false   % Not parralel
    for k_grid = 1:num_grids % over all grids
        Txt2Database(Grid_Name,instants_per_grid,k_grid,Temp_Input_Path,Grid_NameEmpty,Temp_Grids_Path,DB_Name,DB_Type,instants_per_grid_char);
    end
else
    parfor k_grid = 1:num_grids % over all grids
        Txt2Database(Grid_Name,instants_per_grid,k_grid,Temp_Input_Path,Grid_NameEmpty,Temp_Grids_Path,DB_Name,DB_Type,instants_per_grid_char);
    end
end

%% Check Sincal Version

SincalVersion = Settings.VerSincal;         % Problem with parfor... TODO;

%% Load flow calculation with load profiles
if Settings.ParrallelCom == false   % Not parralel    
    for k_grid = 1:num_grids % over all grids %1:num_grids
        StartLFProfile(Grid_Name,instants_per_grid,k_grid,Temp_Grids_Path,SincalVersion);
    end
else
    parfor k_grid = 1:num_grids % over all grids %1:num_grids
        StartLFProfile(Grid_Name,instants_per_grid,k_grid,Temp_Grids_Path,SincalVersion);
    end
end

%% Restart parallel pool (for parallel computing), more stable
% 
% poolobj = gcp('nocreate');
% delete(poolobj)
% parpool('local',poolsize);
% 

%% Database2Txt

% Waitbar Update
if waitbar_activ; waitbar(wb_stat(8), wb_Fig, 'Creating NodeRes and BranchRes files'); end

Column_str_Node   = strjoin(Col_Name_ULFNodeResult  (NodeVector  ),', '); % Sql command (string) part that contains Column Names   
Column_str_Branch = strjoin(Col_Name_ULFBranchResult(BranchVector),', '); % Sql command (string) part that contains Column Names
k_grid_input = 1:num_grids;
Done_all = false(num_grids,1);
if Settings.ParrallelCom == false   % Not parralel
    for k = 1:num_grids % over all grids
        if ~Done_all(k)
            Done_all(k) = prep_txt_output(k_grid_input,k,Grid_Name,instants_per_grid,Temp_Grids_Path,DB_Name,DB_Type,Column_str_Node,Column_str_Branch,Temp_Output_Path);
        end
    end
else
    parfor k = 1:num_grids % over all grids
        if ~Done_all(k)
            Done_all(k) = prep_txt_output(k_grid_input,k,Grid_Name,instants_per_grid,Temp_Grids_Path,DB_Name,DB_Type,Column_str_Node,Column_str_Branch,Temp_Output_Path);
        end
    end
end
% poolobj = gcp('nocreate');
% delete(poolobj)

%% second try Database2Txt (to improve), not parallel

for k = 1:num_grids % second try ... to improve
    if ~Done_all(k)
        Done_all(k) = prep_txt_output(k_grid_input,k,Grid_Name,instants_per_grid,Temp_Grids_Path,DB_Name,DB_Type,Column_str_Node,Column_str_Branch,Temp_Output_Path);
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

% Waitbar Update
if waitbar_activ; waitbar(wb_stat(9), wb_Fig, 'Saving Simulation Details'); end

SimDetails                                  = struct                        ;
SimDetails.Grid_Name                        = Grid_Name                  ;
SimDetails.instants_per_grid                = instants_per_grid             ;
SimDetails.num_grids                        = num_grids                     ;
SimDetails.SinInfo                          = SinInfo                       ;
SimDetails.Grid_Name                     = Grid_Name                  ;
SimDetails.Output_Name                      = Grid_Name                   ;
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
SimDetails.Output_content                   = Settings                ;
SimDetails.SimType                          = 'PF'                          ; %#ok % Will be just saved
% SimDetails.First_Moment                   = TimeSetup.First_Moment        ;
% SimDetails.Last_Moment                    = TimeSetup.Last_Moment         ;
% SimDetails.Time_Step                      = TimeSetup.Time_Step           ;
% SimDetails.num_of_instants                = TimeSetup.num_of_instants     ;
% SimDetails.Time_Vector                    = Time_Vector                   ;

Output_Filename  = [Grid_Name,'_Simulation_Details.mat'];
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

function prep_txt_input(Profile_DB,fieldnames_DB,num_grids,k_grid,instants_per_grid,instants_per_grid_char,Sin_Path_Input)
% temporary load profile
Profile_temp = struct;
if k_grid~=num_grids % all grids with full number of instants
    for i_field = 1:numel(fieldnames_DB)
        Profile_temp.(fieldnames_DB{i_field}) = ...
            Profile_DB.(fieldnames_DB{i_field})(((k_grid-1)*instants_per_grid+1):k_grid*instants_per_grid,:);
    end
else % last grid can have a smaller number of instants
    for i_field = 1:numel(fieldnames_DB)
        Profile_temp.(fieldnames_DB{i_field}) = ...
            Profile_DB.(fieldnames_DB{i_field})(((k_grid-1)*instants_per_grid+1):end,:);
    end
end
% Create OpSerVal txt files
OpSer_suffix = ['_',instants_per_grid_char,'inst_',num2str(k_grid)];
create_OpSer_txt   (fieldnames_DB,Sin_Path_Input,OpSer_suffix);
create_OpSerVal_txt(Profile_temp, Sin_Path_Input,OpSer_suffix);
end

function Txt2Database(Grid_Name,instants_per_grid,k_grid,Sin_Path_Input,SinNameEmpty,Grid_Path,DB_Name,DB_Type,instants_per_grid_char)
% Create copy of Sincal file
SinName = [Grid_Name,'_',num2str(instants_per_grid),'inst_',num2str(k_grid)];
copyfile([Sin_Path_Input,SinNameEmpty,'.sin'],[Grid_Path,SinName,'.sin']);

% Create copy of Sincal folder
SinFolName = [Grid_Name,'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'_files\'];
copyfile([Sin_Path_Input,SinNameEmpty,'_files\'],[Grid_Path,SinFolName]);
% Adjust database.ini
delete([Grid_Path,SinFolName,'database.ini']);
% create new database.ini file
fileID = fopen([Grid_Path,SinFolName,'database.ini'],'at');
fprintf(fileID,'[Config]\nDisableStdDocHandling=0\n[Exclude]\n[Database]\nMODE=JET\n');
fprintf(fileID,strrep(['FILE=',Grid_Path,SinFolName,'database.mdb'],'\','\\'));
fclose(fileID);

% Read in OpSer and OpSerVal txt files into Access DB
OpSer_suffix = ['_',instants_per_grid_char,'inst_',num2str(k_grid)];
% SQL-Command for reading in the OpSer txt file
sql_in = ['INSERT INTO OpSer SELECT * ',...
    ' FROM [Text;DATABASE=',Sin_Path_Input,'].[OpSer',OpSer_suffix,'.txt]'];
Done = Matlab2Access_ExecuteSQL(sql_in,DB_Name,[Grid_Path,SinFolName],DB_Type);
if ~Done; return; end
% QL-Command for reading in the OpSerVal txt file
sql_in = ['INSERT INTO OpSerVal SELECT * ',...
    ' FROM [Text;DATABASE=',Sin_Path_Input,'].[OpSerVal',OpSer_suffix,'.txt]'];
Done = Matlab2Access_ExecuteSQL(sql_in,DB_Name,[Grid_Path,SinFolName],DB_Type);
if ~Done; return; end
end

function StartLFProfile(Grid_Name,instants_per_grid,k_grid,Grid_Path,SincalVersion)
SinName   = [Grid_Name,'_',num2str(instants_per_grid),'inst_',num2str(k_grid)];
disp(['Starting power flow calculation of ',SinName]);
LF_Status = Mat2Sin_StartLFProfile(SinName,Grid_Path,SincalVersion); % Calculate load flow with load profiles
disp(LF_Status);
%     if ~strcmp('Successful',LF_Status)
%         break;
%     end
end

function Done_this = prep_txt_output(k_grid_input,k,Grid_Name,instants_per_grid,Temp_Grids_Path,DB_Name,DB_Type,Column_str_Node,Column_str_Branch,Temp_Output_Path)
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
Done_this = Matlab2Access_ExecuteSQL(sql_command_str, DB_Name,[Temp_Grids_Path,SinFolName],DB_Type);
end