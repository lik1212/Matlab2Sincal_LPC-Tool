function status = Mat2Sin_LPCalc(Fig)
%% Mat2Sin_LPCalc
%   
%   Mat2Sin_LPCalc     - This script demonstrates the work of the load
%                         flow calculation for load profiles (load flow 
%                         calculation for more than one timestamp at once) 
%                         in Sincal managed from Matlab.
%
%                       - Duo to the maximum 2GB database size of Access
%                         databases, the profiles need to be split into
%                         smaller profiles if the load flow results 
%                         exceed 2GB.
%
%   Fig.Inputs (Optional)   Structure with all necessary inputs
%                           Inputs.Grid_Path
%                           Inputs.Grid_Name
%                           Inputs.LP_Type
%                           Inputs.PV_Type
%                           Inputs.LP_Path
%                           Inputs.LP_DB_Name
%                           Inputs.PV_Path
%                           Inputs.PV_DB_Name
%                           Inputs.LP_dist_type
%                           Inputs.LP_dist_path
%                           Inputs.LP_dist_list_name
%                           Inputs.PV_dist_type
%                           Inputs.PV_dist_path
%                           Inputs.PV_dist_list_name
%                           Inputs.TimeSetup_First_Moment
%                           Inputs.TimeSetup_Last_Moment
%                           Inputs.TimeSetup_Time_Step
%                           Inputs.TimeSetup_num_of_instants
%                           Inputs.TimeSetup_instants_per_grid_ratio
%                           Inputs.TimeSetup_First_Moment_PF
%                           Inputs.TimeSetup_Last_Moment_PF
%                           Inputs.Output_option_raw
%                           Inputs.Output_option_raw_only
%                           Inputs.Output_option_per_node_branch
%                           Inputs.Output_option_per_unit
%                           Inputs.Output_option_del_temp_files
%                           Inputs.Output_option_del_temp_files_begin
%                           Inputs.Output_option_preparation
%                           Inputs.Output_option_raw_generated
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
%                           Inputs.Option_debug
%                           
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
%   Author(s): J. Greiner
%              R. Brandalik
%              P. Gassler

%% Default Path definition and directory preparation

Inputs          = Fig.Inputs;
Settings        = struct;
Output_options  = struct;
SimDetails      = struct;

addpath                  ([cd,         '\data\Subfunctions'  ]);            % Add Subfunction path
addpath                  ([cd,         '\data\Static_Input' ]);             % Add path for static input (e.q. column names in a database)
Inputs_Path             = [cd,         '\Inputs\'];                         % Path for the simulation's input  files 
Outputs_Path            = [cd,         '\Outputs\'];                        % Path for the simulation's output files
Sin_Path_Data           = [cd,          '\Data\'];                          % Path for the simulation's data   files
Profiles_Path_static    = [Inputs_Path,'Static_Profiles\'];                 % Path for static load and PV profiles like Smart Scada
Settings.LP_Path        = [Inputs_Path,'Load_Profiles\'];                   % Path for load profiles
Settings.PV_Path        = [Inputs_Path,'PV_Profiles\'];                     % Path for PV profiles
Grid_Path               = [Inputs_Path,'Grids\'];                           % Path for input Sincal Grids
Settings.LP_dist_Path   = [Inputs_Path,'Profiles_Distribution\'];           % Path for the L.P. distribution file
Settings.PV_dist_Path   = [Inputs_Path,'Profiles_Distribution\'];           % Path for the PV.P. distribution file
Sin_Path                = [cd,         '\Temp\' ];                          % Path for Sincal Simulation files
Sin_Path_Input          = [Sin_Path,   'InputFiles\'];                      % Path for Sincal Temp Input Files
Sin_Path_Output         = [Sin_Path,   'OutputFiles\'];                     % Path for Sincal Temp Output Files
Sin_Path_Grids          = [Sin_Path,   'Grids\'];                           % Path for Sincal Temp copies of Grids

%% Main progress bar initialisation

% active or desactive waitbar for debugging
% waitbar_activ = true;
% if waitbar_activ
%     main_waitbar = waitbar(0,'Main progress','Name','LPC Tool main progress','CreateCancelBtn',...
%                 'setappdata(gcbf,''canceling'',1)');
%     setappdata(main_waitbar,'canceling',0);
%     main_progress = 0;
%     if updateWaitbar('update',main_waitbar,main_progress,'Initialisation')
%             return
%     end
% % Integrate Waitbar in GUI figure (not working/finished)
% %     main_waitbar = waitbar(0,'Main progress','Visible','off');
% %     child_waitbar = get(main_waitbar,'Children');
% %     set(child_waitbar,'Parent',Fig.Main_Win.figure);
% %     set(child_waitbar,'Units','Normalized','Position',[0.7 0.1 0.2 0.05]);  
% % %     close(main_waitbar);
% %     set(main_waitbar,'Visible','on');
% end

%% Default Names definition

Settings.PV_dist_list_name = 'DCInfeederNameOriginal.txt';
Settings.LP_DB_Name        = 'LP_database.mat';
Settings.PV_DB_Name        = 'PV_database.mat';
SinName                    = 'Wessum-Riete_Netz_170726_empty';

%% Setting up Time Vector and Number of Instants

% Default values
TimeSetup = struct;
% TimeSetup.First_Moment       = datetime('01.01.2015 00:00:00','Format','dd.MM.yyyy HH:mm:ss');
% TimeSetup.Last_Moment        = datetime('31.12.2015 23:50:00','Format','dd.MM.yyyy HH:mm:ss');
% TimeSetup.Time_Step          = 1; % Minutes
% TimeSetup.num_of_instants    = 1440;
% Inputs.TimeSetup_num_of_instants = 1440; % 1440; % Temp, RB
% TimeSetup = Setting_Time_Parameters(TimeSetup,Inputs);
% TimeSetup.instants_per_grid = 1440; % Temp, RB
% Time_Vector = TimeSetup.Time_Vector;
% number of time instants (initial all timestemps are set)
% num_of_instants = size(Profile_DB.(fieldnames_DB{1}),1); % any field
% number of instants per grid (keep access database below 2GB)
% instants_per_grid = TimeSetup.instants_per_grid;

%% Global variables definition and default value assignment
% structure with all settings variables
Settings.del_sim_files          = false;                                    % delete all temporary simulation files after simulation is complete
Settings.del_sim_files_begin    = true;
Settings.del_sim_files_inst     = false;                                	% delete temporary stored simulation files as soon as these are not needed anymore
Settings.output_prepare         = true;
% Settings.txt2db = true;                                                     % to implement
% Settings.simulation = true;                                                 % to implement
% Settings.db2txt = true;                                                     % to implement
Settings.LP_Type                = 'SCADA';                                                          
Settings.PV_Type                = 'SCADA';                                                          
Settings.LP_dist_type           = 'list';                                                  
Settings.PV_dist_type           = 'list';                                   % Struct with all options for the outputed data
Output_options.U = true;
Output_options.P = true;
Output_options.Q = true;
Output_options.S = true;
Output_options.phi = true;
Output_options.I = true;
Output_options.P_flow = true;
Output_options.Q_flow = true;
Output_options.S_flow = true;
Output_options.T_vector = true;
Output_options.Sin_Info = true;
Output_options.Raw = false;
Output_options.Raw_only = false;
Output_options.Node_Branch = true;
Output_options.Unit = true;
Output_options.Raw_generated = false;

%% Overwriting parameters with Inputs
% Options, Paths and Names are been overwritten with Inputs values if some
% exists

if nargin==1
    if isfield(Inputs,'Grid_Path') 
        Grid_Path = Inputs.Grid_Path;
        if Grid_Path(end)~='\'
            Grid_Path = [Grid_Path,'\'];
        end
    end
    if isfield(Inputs,'Grid_Name')
        SinName = Inputs.Grid_Name;
    end
    if isfield(Inputs,'Output_Path')
        Outputs_Path = Inputs.Output_Path;
    end
    Settings = overwritingSettings(Inputs,Settings);
    Output_options = overwritingOptions(Inputs,Output_options);
end

% if ~Settings.output_prepare
%     Settings.del_sim_files = false;
%     Settings.del_sim_files_inst = false;
% end

%% Estimating time for waitbar

% if waitbar_activ
%     main_progress_1 = 0.01;
%     main_progress_2 = 0.03;
%     main_progress_3 = 0.05;
%     main_progress_4 = 0.06;
%     main_progress_5 = 0.07;
%     main_progress_6 = 0.08;
%     main_progress_7 = 0.55;
%     main_progress_8 = 0.8;
%     main_progress_end = 1;
% end

%% Delete all the simulation files at the beginning

if Settings.del_sim_files_begin
    if isfolder(Sin_Path_Input ); rmdir(Sin_Path_Input, 's'); end           % delete input  Files
    if isfolder(Sin_Path_Output); rmdir(Sin_Path_Output,'s'); end           % delete output Files   
    if isfolder(Sin_Path_Grids ); rmdir(Sin_Path_Grids, 's'); end           % delete grids  Files
end

%% Load static input (e.q. column names in a database)

% Column names of Table OpSer, OpSerVal, ULFNodeRes und ULFBranchRes
load([Sin_Path_Data, 'Static_Input\Col_Name_OpSer.mat'          ], 'Col_Name_OpSer'          );
load([Sin_Path_Data, 'Static_Input\Col_Name_OpSerVal.mat'       ], 'Col_Name_OpSerVal'       );
% load([Sin_Path_Data, 'Static_Input\Col_Name_ULFNodeResult.mat'  ], 'Col_Name_ULFNodeResult'  );
% load([Sin_Path_Data, 'Static_Input\Col_Name_ULFBranchResult.mat'], 'Col_Name_ULFBranchResult');
% For some more stable in parfor: (Check why) % TODO
Col_Name_ULFNodeResult             = load('Col_Name_ULFNodeResult.mat');
Col_Name_ULFNodeResult_fieldname   = fieldnames(Col_Name_ULFNodeResult);
Col_Name_ULFNodeResult             = Col_Name_ULFNodeResult.(Col_Name_ULFNodeResult_fieldname{1});
Col_Name_ULFBranchResult           = load('Col_Name_ULFBranchResult.mat');
Col_Name_ULFBranchResult_fieldname = fieldnames(Col_Name_ULFBranchResult);
Col_Name_ULFBranchResult           = Col_Name_ULFBranchResult.(Col_Name_ULFBranchResult_fieldname{1});

NodeVector   = calcNodeOutputVector  (Output_options);
BranchVector = calcBranchOutputVector(Output_options);

%% Prepare the Sincal grid

% % Waitbar Update
% if waitbar_activ
%     if updateWaitbar('update',main_waitbar,main_progress_1,'Preparing Sincal Grid')
%             return
%     end
% end

if strcmp(SinName(end-5:end),'_empty')
    SinNameEmpty = SinName;
else
    SinNameEmpty = [SinName,'_empty'];
end
% SinNameEmpty = 'Wessum-Riete_Netz_170726_empty';        % Sincal Grid Name
SinNameBasic = SinNameEmpty(1:end-6);
SinNameSin   = [Grid_Path,SinName,'.sin'];
SinNameCopy  = [Sin_Path_Input,SinNameEmpty,'.sin'];
DB_Name      = 'database';                              % DB Name
%DB_Path      = [Grid_Path,SinNameEmpty,'_files\'];      % DB Path
DB_Path      = [Grid_Path,SinName,'_files\'];      % DB Path
DB_Path_Copy = [Sin_Path_Input,SinNameEmpty,'_files\'];
DB_Type      = '.mdb';                                  % DB Typ

% Prepare the output file name
if nargin==1
    if ~isfield(Inputs,'Output_Name')
        Output_Name = SinNameBasic;
    else
        Output_Name = Inputs.Output_Name;
    end
else
    Output_Name = SinNameBasic;
end

if ~isfolder(Sin_Path_Input); mkdir(Sin_Path_Input); end
if ~isfolder(Sin_Path_Grids); mkdir(Sin_Path_Grids); end
if ~isfolder(DB_Path_Copy  ); mkdir(DB_Path_Copy  ); end

copyfile(DB_Path   , DB_Path_Copy); % copy the sincal Grid folder with database
copyfile(SinNameSin, SinNameCopy ); % copy the sincal file

% Delete old load profiles (if they exist)
sql_in = {...
    'DELETE FROM OpSer;'   ;...
    'DELETE FROM OpSerVal;' ...
    };  
Done = Matlab2Access_ExecuteSQL(sql_in, DB_Name, DB_Path_Copy, DB_Type);
if ~Done; return; end

% Get Grind basic information (nodes,lines,loads,etc.)
SinInfo = Mat2Sin_GetSinInfo(SinNameEmpty,Sin_Path_Input);            % SinInfo table

%% Load the load and photovoltaic (PV) profiles

% % Waitbar Update
% if waitbar_activ
%     if updateWaitbar('update',main_waitbar,main_progress_2,'Loading Load and PV profiles')
%             return
%     end
% end

% Loading Load Profiles Database
switch Settings.LP_Type
    case 'SCADA'
        % load([Profiles_Path_static,'DB22_10min_res_wo_HP_adjust.mat']);        % Load the load profiles
        disp('TODO');
    case 'AAPD'
        Load_Profiles = generate_AAPD_LPs(numel(SinInfo.Load.Element_ID),'1P','PLC_Tool',TimeSetup.Time_Step);
        Output_Filename = [Output_Name,'_AAPD_LP_DB.mat'];
        SimData_Filename = [Outputs_Path,Output_Filename];
        save(SimData_Filename,'Load_Profiles','-v7.3');
    case 'DB'
        Load_Profiles = load([Settings.LP_Path,Settings.LP_DB_Name]);
        fields_LP = fields(Load_Profiles);
        Load_Profiles = Load_Profiles.(fields_LP{:});
end

% Loading PV Profiles Database
switch Settings.PV_Type
    case 'DB'
        load([Settings.PV_Path,Settings.PV_DB_Name],'PV___Profiles');
    case 'SCADA'    % TODO
        % load([Profiles_Path_static,'DB23_5min_res_adjust.mat' ]);        % Load the PV profiles
        disp('TODO');
end

fields_names_LoP = fields(Load_Profiles);           % LoP - Load profiles
fields_names_PvP = fields(PV___Profiles);           % PvP - PV   profiles

% Loading or Generating the distribution of the Load Profiles on the Grid Loads
switch Settings.LP_dist_type
    case 'list'
        LP2GL_Lo = readtable([Settings.LP_dist_Path, Settings.LP_dist_list_name],'Delimiter',';');
    case 'random'
        LP2GL_Lo = randomDistribution(SinInfo, fields_names_LoP);
        Settings.LP_dist_list_name = 'Load_Distribution_random.txt';
    case 'alphab'
        LP2GL_Lo = alphaDistribution (SinInfo, fields_names_LoP);
        Settings.LP_dist_list_name = 'Load_Distribution_alphabetical_order.txt';
    case 'mean_P' % TODO
%         Scada_DB = load([Profiles_Path_static,'DB22_10min_res_wo_HP_adjust.mat']);
%         LP2GL_Lo = meanPDistribution(SinInfo,[Settings.LP_dist_Path,Settings.LP_dist_list_name],Scada_DB.Load_Profiles,Load_Profiles,'3p_reuse');
%         LP2GL_Lo = meanPDistribution(SinInfo,[Settings.LP_dist_Path,Settings.LP_dist_list_name],Scada_DB.Load_Profiles,Load_Profiles,'1p');
end
writetable(LP2GL_Lo,[Outputs_Path,Output_Name,'_',Settings.LP_dist_list_name],'Delimiter',';');

% Loading or Generating the distribution of the PV Profiles on the Grid PV
switch Settings.PV_dist_type
    case 'list'
        LP2GL_Pv     = readtable([Settings.PV_dist_Path,Settings.PV_dist_list_name],'Delimiter',';');
    case 'random'
        LP2GL_Pv = randomDistributionPV(SinInfo,fields_names_PvP);
        Settings.PV_dist_list_name = 'DCInfeeder_Distribution_random.txt';   % TODO
    case 'mean_P'  
end
writetable(LP2GL_Pv,[Outputs_Path,Output_Name,'_',Settings.PV_dist_list_name],'Delimiter',';');

% Connect the load and PV profiles to one database 
Profile_DB       = struct;                          % Profile_DB - Database with all profiles

% Check if all Profiles have same number of instants
if numel(unique([structfun(@(x) size(x,1),Load_Profiles);structfun(@(x) size(x,1),PV___Profiles)])) > 1
    disp('The number of intants in the load profiles are not same!');
    status = false;
    return;
else
    TimeSetup.num_of_instants = unique([structfun(@(x) size(x,1),Load_Profiles);structfun(@(x) size(x,1),PV___Profiles)]);
end
    
for k = 1:size(LP2GL_Lo,1)
    if ismember(             LP2GL_Lo.Load_Profile(k),fields_names_LoP)
        Profile_DB.(['Load_',LP2GL_Lo.Load_Profile{k}]) = ...
            Load_Profiles.(  LP2GL_Lo.Load_Profile{k})(1:TimeSetup.num_of_instants,:);
    end
end
for k = 1:size(LP2GL_Pv,1)
    if ismember(             LP2GL_Pv.Load_Profile(k),fields_names_PvP)
        Profile_DB.(['PV___',LP2GL_Pv.Load_Profile{k}]) = ...
            PV___Profiles.(  LP2GL_Pv.Load_Profile{k})(1:TimeSetup.num_of_instants,:);
    end
end
% clear Load_Profiles PV___Profiles fields_names_LoP fields_names_PvP k
clear Load_Profiles PV___Profiles k

%% Set instanst number because Access Database has maximum of 2 GB

Needed_MemorySize = 10 + 1.5 * 10^-3 * size(SinInfo.Node,1)...
    * TimeSetup.num_of_instants; % in MB approx. In Future better!
Max_MemorySize    = 2024; % in MB
if Fig.Main_Win.popupmenu_NumelCores.Value * Max_MemorySize > Needed_MemorySize
    TimeSetup.instants_per_grid = ...
        ceil(ceil(TimeSetup.num_of_instants/(ceil(Needed_MemorySize/...
        (Max_MemorySize * Fig.Main_Win.popupmenu_NumelCores.Value))))/...
        Fig.Main_Win.popupmenu_NumelCores.Value);
    instants_per_grid = TimeSetup.instants_per_grid;
else
    TimeSetup.instants_per_grid = ...
        ceil(TimeSetup.num_of_instants/(ceil(Needed_MemorySize/Max_MemorySize)));
    instants_per_grid = TimeSetup.instants_per_grid;
end
if instants_per_grid > 365 * 24
    instants_per_grid = 365 * 24;
end
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

% % Waitbar Update
% if waitbar_activ
%     if updateWaitbar('update',main_waitbar,main_progress_3,'Adding load and PV Profiles to Sincal Grid')
%             return
%     end
% end

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
Matlab2Access_ExecuteSQL(sql_in,'database',[Sin_Path_Input,SinNameEmpty,'_files'],'.mdb');  %TODO
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
Matlab2Access_ExecuteSQL(sql_in,'database',[Sin_Path_Input,SinNameEmpty,'_files'],'.mdb');  %TODO
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
Matlab2Access_ExecuteSQL(sql_in,'database',[Sin_Path_Input,SinNameEmpty,'_files'],'.mdb');

%% Create schema.ini files

create_schema_ini('input' , Sin_Path_Input , num_grids, instants_per_grid              ); % Input  File
create_schema_ini('output', Sin_Path_Output, num_grids, instants_per_grid, SinNameEmpty); % Output File

%% Start parallel pool (for parallel computing) (TODO)

% % Waitbar Update
% if waitbar_activ
%     if updateWaitbar('update',main_waitbar,main_progress_4,'Start Parallel Computing')
%             return
%     end
% end

if Fig.Main_Win.popupmenu_ParrallelCom.Value == 1       % If i only need one Grid, is it faster to do it with one?
    poolobj = gcp('nocreate');      % TODO
    delete(poolobj)                 % TODO
    if num_grids > 1
        poolobj = gcp('nocreate');
        if isempty(poolobj)
%             myCluster = parcluster('local');  % TODO
            poolsize = Fig.Main_Win.popupmenu_NumelCores.Value;
            if poolsize > num_grids
                poolsize = num_grids;
            end
            parpool('local',poolsize);
        else
%             poolsize = poolobj.NumWorkers;    % TODO
        end
    else
        disp('No need for parallel computing, will be faster without.');
        Fig.Main_Win.popupmenu_ParrallelCom.Value  = 2;
        Fig.Main_Win.popupmenu_NumelCores.  Value  = 1; 
        Fig.Main_Win.popupmenu_NumelCores.  Enable = 'off'; 
        drawnow;
    end
end

%% Adjustment of load profiles and create OpSer and OpSerVal txt
% For parallel computing the memory must be kept low, for this reason the
% load profiles need to be adjusted.

% % Waitbar Update
% if waitbar_activ
%     if updateWaitbar('update',main_waitbar,main_progress_5,'Create ObSer und ObSerVal')
%             return
%     end
% end

% parfor k_grid =  1:num_grids % over all grids % parfor only for strong PC (Server)
if Fig.Main_Win.popupmenu_ParrallelCom.Value == 2   % Not parralel
    for k_grid =  1:num_grids % over all grids % parfor only for strong PC (Server)
        prep_txt_input(Profile_DB,fieldnames_DB,num_grids,k_grid,instants_per_grid,instants_per_grid_char,Sin_Path_Input);
    end
else    % Parralel
    parfor k_grid =  1:num_grids % over all grids % parfor only for strong PC (Server)
        prep_txt_input(Profile_DB,fieldnames_DB,num_grids,k_grid,instants_per_grid,instants_per_grid_char,Sin_Path_Input);
    end
end
% delete Profile_DB (for parallel computing the memory must be kept low)
clear Profile_DB Profile_temp

%% Txt2Database
% num_grids = 1;

% % Waitbar Update
% if waitbar_activ
%     if updateWaitbar('update',main_waitbar,main_progress_6,'Loading Sincal DB and performing PF calculation')
%             return
%     end
% end
if Fig.Main_Win.popupmenu_ParrallelCom.Value == 2   % Not parralel
    for k_grid = 1:num_grids % over all grids
        Txt2Database(SinNameBasic,instants_per_grid,k_grid,Sin_Path_Input,SinNameEmpty,Sin_Path_Grids,DB_Name,DB_Type,instants_per_grid_char);
    end
else
    parfor k_grid = 1:num_grids % over all grids
        Txt2Database(SinNameBasic,instants_per_grid,k_grid,Sin_Path_Input,SinNameEmpty,Sin_Path_Grids,DB_Name,DB_Type,instants_per_grid_char);
    end
end

%% Check Sincal Version

SincalVersion = str2double(Fig.Main_Win.edit_VerSincal.String);

%% Load flow calculation with load profiles
if Fig.Main_Win.popupmenu_ParrallelCom.Value == 2   % Not parralel    
    for k_grid = 1:num_grids % over all grids %1:num_grids
        StartLFProfile(SinNameBasic,instants_per_grid,k_grid,Sin_Path_Grids,SincalVersion);
    end
else
    parfor k_grid = 1:num_grids % over all grids %1:num_grids
        StartLFProfile(SinNameBasic,instants_per_grid,k_grid,Sin_Path_Grids,SincalVersion);
    end
end

%% Restart parallel pool (for parallel computing), more stable
% 
% poolobj = gcp('nocreate');
% delete(poolobj)
% parpool('local',poolsize);
% 

%% Database2Txt

% % Waitbar Update
% if waitbar_activ
%     if updateWaitbar('update',main_waitbar,main_progress_7,'Creating NodeRes and BranchRes files')
%             return
%     end
% end


k_grid_input = 1:num_grids;
Done_all = false(num_grids,1);
if Fig.Main_Win.popupmenu_ParrallelCom.Value == 2   % Not parralel
    for k = 1:num_grids % over all grids
        if ~Done_all(k)
            Done_all(k) = prep_txt_output(k_grid_input,k,SinNameBasic,instants_per_grid,Sin_Path_Grids,DB_Name,DB_Type,Col_Name_ULFNodeResult,NodeVector,Sin_Path_Output,Col_Name_ULFBranchResult,BranchVector);
        end
    end
else
    parfor k = 1:num_grids % over all grids
        if ~Done_all(k)
            Done_all(k) = prep_txt_output(k_grid_input,k,SinNameBasic,instants_per_grid,Sin_Path_Grids,DB_Name,DB_Type,Col_Name_ULFNodeResult,NodeVector,Sin_Path_Output,Col_Name_ULFBranchResult,BranchVector);
        end
    end
end
% poolobj = gcp('nocreate');
% delete(poolobj)

%% second try Database2Txt (to improve), not parallel

for k = 1:num_grids % second try ... to improve
    if ~Done_all(k)
        Done_all(k) = prep_txt_output(k_grid_input,k,SinNameBasic,instants_per_grid,Sin_Path_Grids,DB_Name,DB_Type,Col_Name_ULFNodeResult,NodeVector,Sin_Path_Output,Col_Name_ULFBranchResult,BranchVector);
    end
end

%% Output preperation

if Settings.output_prepare

%     % Waitbar Update
%     if waitbar_activ
%         if updateWaitbar('update',main_waitbar,main_progress_8,'Preparing Power Flow results for analysis')
%                 return
%         end
%     end

%     parpool('local',2);
    for k = 1 : 2
        if k == 1
            Output_read_NodeRes(Outputs_Path,Sin_Path_Output,SinNameBasic,instants_per_grid,num_grids,SinInfo,Output_Name,Output_options);
        else
            Output_read_BranchRes(Outputs_Path,Sin_Path_Output,SinNameBasic,instants_per_grid,num_grids,SinInfo,Output_Name,Output_options);
        end
    end

%     if Output_options.T_vector
%         Output_Filename = [Output_Name,'_Time_Vector.mat'];
%         SimData_Filename = [Outputs_Path,Output_Filename];
%         save(SimData_Filename,'Time_Vector','-v7.3');
%     end
    if Output_options.Sin_Info
        Output_Filename = [Output_Name,'_Grid_Info.mat'];
        SimData_Filename = [Outputs_Path,Output_Filename];
        SinInfo_Bytes = whos('SinInfo');
        SinInfo_Bytes = SinInfo_Bytes.bytes;
        if SinInfo_Bytes > 2 * 1024^3
            save(SimData_Filename,'SinInfo','-v7.3');
        else
            save(SimData_Filename,'SinInfo');
        end
    end
else
%     % Waitbar Update
%     if waitbar_activ
%         if updateWaitbar('update',main_waitbar,main_progress_8,'Copying NodeRes and BranchRes files')
%                 return
%         end
%     end
    files = [Sin_Path_Output,'NodeRes*'];
    copyfile(files,Outputs_Path);
    files = [Sin_Path_Output,'BranchRes*'];
    copyfile(files,Outputs_Path);
end

%% Save all Simulation Details (Parameters)

% % Waitbar Update
% if waitbar_activ
%     if updateWaitbar('update',main_waitbar,main_progress_8,'Saving Simulation Details')
%             return
%     end
% end

SimDetails.Grid_Name = SinNameBasic;
SimDetails.instants_per_grid = instants_per_grid;
SimDetails.num_grids = num_grids;
% SimDetails.First_Moment = TimeSetup.First_Moment;
% SimDetails.Last_Moment = TimeSetup.Last_Moment;
% SimDetails.Time_Step = TimeSetup.Time_Step;
% SimDetails.num_of_instants = TimeSetup.num_of_instants;
% SimDetails.Time_Vector = Time_Vector;
SimDetails.SinInfo = SinInfo;
SimDetails.SinNameBasic = SinNameBasic;
SimDetails.Output_Name = Output_Name;
SimDetails.Outputs_Path = Outputs_Path;
SimDetails.LoadProfiles_type = Settings.LP_Type;
SimDetails.PVProfiles_type = Settings.PV_Type;
SimDetails.LoadProfiles_Distrubution_method = Settings.LP_dist_type;
SimDetails.PVProfiles_Distrubution_method = Settings.PV_dist_type;
SimDetails.LoadProfiles_Dist_ListName_Input = Settings.LP_dist_list_name;
SimDetails.PVProfiles_Dist_ListName_Input = Settings.PV_dist_list_name;
SimDetails.LoadProfiles_Distribution_List = LP2GL_Lo;
SimDetails.PVProfiles_Distribution_List = LP2GL_Pv;
SimDetails.LoadProfiles_Database_Name = Settings.LP_DB_Name;
SimDetails.PVProfiles_Database_Name = Settings.PV_DB_Name;
SimDetails.Output_content = Output_options;
SimDetails.SimType = 'PF';   %#ok The variable will just be saved

Output_Filename = [Output_Name,'_Simulation_Details.mat'];
SimData_Filename = [Outputs_Path,Output_Filename];

SimDetails_Bytes = whos('SimDetails');
SimDetails_Bytes = SimDetails_Bytes.bytes;   %#ok The variable will just be saved
if SinInfo_Bytes > 2 * 1024^3
    save(SimData_Filename,'SimDetails','-v7.3');
else
    save(SimData_Filename,'SimDetails');
end


%% Delete all temporary simulation files

if Settings.del_sim_files    
    rmdir(Sin_Path_Input ,'s'); % delete input  Files    
    rmdir(Sin_Path_Output,'s'); % delete output Files    
    rmdir(Sin_Path_Grids ,'s'); % delete grids  Files
end

%% Delete Main Waitbar and finalising simulation process
% if waitbar_activ
%     updateWaitbar('update',main_waitbar,main_progress_end,'Finishing');
%     updateWaitbar('delete',main_waitbar);
% end
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

function Txt2Database(SinNameBasic,instants_per_grid,k_grid,Sin_Path_Input,SinNameEmpty,Sin_Path_Grids,DB_Name,DB_Type,instants_per_grid_char)
% Create copy of Sincal file
SinName = [SinNameBasic,'_',num2str(instants_per_grid),'inst_',num2str(k_grid)];
copyfile([Sin_Path_Input,SinNameEmpty,'.sin'],[Sin_Path_Grids,SinName,'.sin']);

% Create copy of Sincal folder
SinFolName = [SinNameBasic,'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'_files\'];
copyfile([Sin_Path_Input,SinNameEmpty,'_files\'],[Sin_Path_Grids,SinFolName]);
% Adjust database.ini
delete([Sin_Path_Grids,SinFolName,'database.ini']);
% create new database.ini file
fileID = fopen([Sin_Path_Grids,SinFolName,'database.ini'],'at');
fprintf(fileID,'[Config]\nDisableStdDocHandling=0\n[Exclude]\n[Database]\nMODE=JET\n');
fprintf(fileID,strrep(['FILE=',Sin_Path_Grids,SinFolName,'database.mdb'],'\','\\'));
fclose(fileID);

% Read in OpSer and OpSerVal txt files into Access DB
OpSer_suffix = ['_',instants_per_grid_char,'inst_',num2str(k_grid)];
% SQL-Command for reading in the OpSer txt file
sql_in = ['INSERT INTO OpSer SELECT * ',...
    ' FROM [Text;DATABASE=',Sin_Path_Input,'].[OpSer',OpSer_suffix,'.txt]'];
Done = Matlab2Access_ExecuteSQL(sql_in,DB_Name,[Sin_Path_Grids,SinFolName],DB_Type);
if ~Done; return; end
% QL-Command for reading in the OpSerVal txt file
sql_in = ['INSERT INTO OpSerVal SELECT * ',...
    ' FROM [Text;DATABASE=',Sin_Path_Input,'].[OpSerVal',OpSer_suffix,'.txt]'];
Done = Matlab2Access_ExecuteSQL(sql_in,DB_Name,[Sin_Path_Grids,SinFolName],DB_Type);
if ~Done; return; end
end

function StartLFProfile(SinNameBasic,instants_per_grid,k_grid,Sin_Path_Grids,SincalVersion)
SinName   = [SinNameBasic,'_',num2str(instants_per_grid),'inst_',num2str(k_grid)];
disp(['Starting power flow calculation of ',SinName]);
LF_Status = Mat2Sin_StartLFProfile(SinName,Sin_Path_Grids,SincalVersion); % Calculate load flow with load profiles
disp(LF_Status);
%     if ~strcmp('Successful',LF_Status)
%         break;
%     end
end

function Done_this = prep_txt_output(k_grid_input,k,SinNameBasic,instants_per_grid,Sin_Path_Grids,DB_Name,DB_Type,Col_Name_ULFNodeResult,NodeVector,Sin_Path_Output,Col_Name_ULFBranchResult,BranchVector)
k_grid = k_grid_input(k);
SinName         = [SinNameBasic,'_',num2str(instants_per_grid),'inst_',num2str(k_grid)];
SinFolName      = [SinNameBasic,'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'_files\'];
name_txt        = ['NodeRes_',SinName,'.txt'];     % Save load flow results as txt files
table_Name      = 'ULFNodeResult';               % Results from ULFNodeResult
Column_str = strjoin(Col_Name_ULFNodeResult(NodeVector),', ');% Sql command (string) part that contains Column Names
% Sql command for reading from Table FROM ULFNodeResult + writing Table
% ULFNodeResult in a .txt-file
sql_command_str = ['SELECT ' ,Column_str, ' INTO [Text;HDR=YES;DATABASE=',Sin_Path_Output,'].[',name_txt,'] FROM ', table_Name ];
Matlab2Access_ExecuteSQL(sql_command_str, DB_Name,[Sin_Path_Grids,SinFolName],DB_Type);
name_txt        = ['BranchRes_',SinName,'.txt'];
table_Name      = 'ULFBranchResult';        % Results from ULFBranchResult
Column_str = strjoin(Col_Name_ULFBranchResult(BranchVector),', ');% Sql command (string) part that contains Column Names
sql_command_str = ['SELECT ' ,Column_str, ' INTO [Text;HDR=YES;DATABASE=',Sin_Path_Output,'].[',name_txt,'] FROM ', table_Name ];
Done_this = Matlab2Access_ExecuteSQL(sql_command_str, DB_Name,[Sin_Path_Grids,SinFolName],DB_Type);
end