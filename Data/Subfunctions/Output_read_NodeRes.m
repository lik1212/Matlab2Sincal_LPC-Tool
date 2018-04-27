function Output_read_NodeRes(Path_Output, Path_Input, SinNameBasic, instants_per_grid, num_grids, SinInfo, Settings)
% function read the NodeRes .txt files (one file per Grid) and creates a
% .mat database with chosen Power Flow result
%
% Author(s): P. Gassler, R. Brandalik
              
%% Import NodeRes Files in Matlab memory

for k_grid = 1 : num_grids % Read in all NodeRes files
    File_suffix  = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
    NodeRes_Name = [Path_Input, 'NodeRes_', SinNameBasic, File_suffix, '.txt'];
    if k_grid == 1
        ResData   = readtable(NodeRes_Name);
    else
        k_SimData = readtable(NodeRes_Name);
        % Adjust ResTime based on grid number
        k_SimData.ResTime = k_SimData.ResTime + (k_grid - 1) * instants_per_grid;
        ResData = [ResData; k_SimData]; %#ok The size of the file is unknown
        clear k_SimData                 % To reduce RAM usage
    end
    disp([NodeRes_Name, ' loaded.']);
end

%% Fill missing timesteps (load flow did not converge) and isolated nodes

Node_all   = SinInfo.Node.Node_ID;
Step_all   = double(1:instants_per_grid * num_grids)'; 
Node_occur = unique(ResData.Node_ID);
Step_occur = unique(ResData.ResTime);
Node_lack  = setdiff(Node_all, Node_occur);
Step_lack  = setdiff(Step_all, Step_occur);
% Missing timesteps (load flow did not converge)
NaN_Table_Steps = array2table(...
    NaN(numel(Step_lack) * numel(Node_occur), size(ResData, 2)),...
    'VariableName', ResData.Properties.VariableNames);
NaN_Table_Steps.ResTime = repelem(Step_lack , numel(Node_occur), 1);
NaN_Table_Steps.Node_ID = repmat (Node_occur, numel(Step_lack) , 1);
% Missing nodes (isolated in the grid)
NaN_Table_Nodes = array2table(...
    NaN(numel(Node_lack) * numel(Step_all)  , size(ResData, 2)),...
    'VariableName', ResData.Properties.VariableNames);
NaN_Table_Nodes.ResTime = repmat (Step_all , numel(Node_lack), 1);
NaN_Table_Nodes.Node_ID = repelem(Node_lack, numel(Step_all) , 1);

ResData = [ResData; NaN_Table_Steps; NaN_Table_Nodes];
ResData = sortrows(ResData,'Node_ID','ascend');
ResData = sortrows(ResData,'ResTime','ascend');

%% Add Node_Name

for k_Node = 1 : numel(Node_all)
    Node_ID_flag = (ResData.Node_ID == SinInfo.Node.Node_ID(k_Node));
    ResData.Node_Name(Node_ID_flag) =  SinInfo.Node.Name   (k_Node) ;
end

%% Saving only RAW data in a file and leaving function

if Settings.Output_option_raw_only || Settings.Output_option_raw
    SimData_Filename = [Path_Output, SinNameBasic, '_NodeRes_raw.mat'];
    NodeRes_all = ResData; clear ResData; % Change name, the variable will just be saved
    NodeRes_all_Bytes = whos('NodeRes_all');
    NodeRes_all_Bytes = NodeRes_all_Bytes.bytes;
    if NodeRes_all_Bytes > 2 * 1024^3
        save(SimData_Filename,'NodeRes_all','-v7.3');
    else
        save(SimData_Filename,'NodeRes_all');
    end
    if Settings.Output_option_raw_only; return; end
end

%% Read out flag and make column name translator

if Settings.Output_option_U == true
    U_flag = {        ...
        'U1', 'U_L1'; ...
        'U2', 'U_L2'; ...
        'U3', 'U_L3'; ...
        'Ue', 'U_L0'; ...
        };
else; U_flag = {}; 
end
if Settings.Output_option_P == true
    P_flag = {        ...
        'P1', 'P_L1'; ...
        'P2', 'P_L2'; ...
        'P3', 'P_L3'; ...
        };
else; P_flag = {}; 
end
if Settings.Output_option_Q == true
    Q_flag = {        ...
        'Q1', 'Q_L1'; ...
        'Q2', 'Q_L2'; ...
        'Q3', 'Q_L3'; ...
        };
else; Q_flag = {}; 
end
if Settings.Output_option_S == true
    S_flag = {          ...
        'S1', 'S_L1'  ; ...
        'S2', 'S_L2'  ; ...
        'S3', 'S_L3'  ; ...
        'S' , 'S_L123'; ...
        };
else; S_flag = {}; 
end
if Settings.Output_option_phi == true
    phi_flag = {          ...
        'phi1', 'phi_L1'; ...
        'phi2', 'phi_L2'; ...
        'phi3', 'phi_L3'; ...
        };
else; phi_flag = {}; 
end

all_flag = [U_flag; P_flag; Q_flag; S_flag; phi_flag];

%% Name and ID prepeartion
% Column names of tables can not start with numbers or have some special
% characters like '-', this section will try to avoid such problems.

Node_IDs     = SinInfo.Node.Node_ID;
NodeNames    = strrep(SinInfo.Node.Name,'-','');  % Initialisierung, field name without '-'
NodeVarNames = strrep(                                              ...
    strcat('ID',num2str(double(1:numel(Node_IDs))'),'_',NodeNames)  ...
    ,' ','');

%% Assemble variables per units and nodes

NodeRes_all.ResTime = []; % To reduce RAM usage

for k_flag = 1 : size(all_flag, 1)
    for k_Node = 1 : numel(Node_IDs)
        if Settings.Output_option_per_unit || Settings.Output_option_per_node_branch
            Values_flag_Node = ...
                NodeRes_all.((all_flag{k_flag, 1}))(NodeRes_all.Node_ID == Node_IDs(k_Node));
        end
        if Settings.Output_option_per_unit
            if k_flag == 1 && k_Node == 1
                SimResults_Nodes_per_units = struct; % initial
            end
            if k_Node == 1 % initial as table
                SimResults_Nodes_per_units.(all_flag{k_flag, 2}) = table;
            end
            SimResults_Nodes_per_units.(all_flag{k_flag, 2}).(NodeVarNames{k_Node}) = ...
                Values_flag_Node;
        end
        if Settings.Output_option_per_node_branch
            if k_flag == 1 && k_Node == 1
                SimResults_Nodes_per_nodes = struct; % initial
            end
            if k_flag == 1 % initial as table
                SimResults_Nodes_per_nodes.(NodeNames{k_Node}) = table;
            end
            SimResults_Nodes_per_nodes.(NodeNames{k_Node}).(all_flag{k_flag, 2}) = ...
                Values_flag_Node;
        end
    end
    NodeRes_all.((all_flag{k_flag, 1})) = []; % To reduce RAM usage
end

%% Saving the results in .mat files

if Settings.Output_option_per_unit
    SimData_Filename = [Path_Output, SinNameBasic, '_NodeRes_per_units.mat'];
    SimResults_Nodes_per_units_Bytes = whos('SimResults_Nodes_per_units');
    SimResults_Nodes_per_units_Bytes = SimResults_Nodes_per_units_Bytes.bytes; % The variable will just be saved
    if SimResults_Nodes_per_units_Bytes > 2 * 1024^3
        save(SimData_Filename, 'SimResults_Nodes_per_units', '-v7.3');
    else
        save(SimData_Filename, 'SimResults_Nodes_per_units'         );
    end
    disp([SimData_Filename, ' saved.']);
end
if Settings.Output_option_per_node_branch
    SimData_Filename = [Path_Output, SinNameBasic, '_NodeRes_per_nodes.mat'];
    SimResults_Nodes_per_nodes_Bytes = whos('SimResults_Nodes_per_nodes');
    SimResults_Nodes_per_nodes_Bytes = SimResults_Nodes_per_nodes_Bytes.bytes; % The variable will just be saved
    if SimResults_Nodes_per_nodes_Bytes > 2 * 1024^3  
        save(SimData_Filename, 'SimResults_Nodes_per_nodes', '-v7.3');
    else
        save(SimData_Filename, 'SimResults_Nodes_per_nodes'         );
    end
    disp([SimData_Filename, ' saved.']);
end
