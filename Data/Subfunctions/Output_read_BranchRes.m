function Output_read_BranchRes(Path_Output, Path_Input, SinNameBasic, instants_per_grid, num_grids, SinInfo, Settings)
% function read the BranchRes .txt files (one file per Grid) and creates a
% .mat database with chosen Power Flow result
%
% Author(s): P. Gassler, R. Brandalik

%% Import BranchRes Files in Matlab memory

for k_grid = 1 : num_grids
    File_suffix  = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
    BranchRes_Name = [Path_Input, 'BranchRes_', SinNameBasic, File_suffix, '.txt'];
    if k_grid == 1
        ResData   = readtable(BranchRes_Name);
    else
        k_ResData = readtable(BranchRes_Name);
        % Adjust ResTime based on grid number
        k_ResData.ResTime = k_ResData.ResTime + (k_grid - 1) * instants_per_grid;
        ResData = [ResData; k_ResData]; %#ok The size of the file is unknown
        clear k_ResData                 %    To reduce RAM usage
    end
    disp([BranchRes_Name, ' loaded.']);
end
ResData(isnan(ResData.Terminal2_ID),:) = []; % One-Terminal Elements are not of interest (such as loads)

%% Fill missing timesteps (load flow did not converge) and isolated nodes

if isfield(SinInfo,'TwoWindingTransformer')
    Branch_all = [...
        SinInfo.TwoWindingTransformer.Terminal1_ID, SinInfo.TwoWindingTransformer.Terminal2_ID; ...
        SinInfo.Line.                 Terminal1_ID, SinInfo.Line.                 Terminal2_ID];
else
    Branch_all = [...
        SinInfo.Line.                 Terminal1_ID, SinInfo.Line.                 Terminal2_ID];
end
Step_all         = double(1:instants_per_grid * num_grids)'; 
Branch_occur     = unique([ResData.Terminal1_ID, ResData.Terminal2_ID], 'rows');
% No natural couple of numbers with the same sum and product
[~, unique_sum]  = unique(sum(Branch_occur , 2))            ;   
Branch_occur     = Branch_occur(unique_sum , :)             ;
[~, unique_prod] = unique(prod(Branch_occur, 2))            ;
Branch_occur     = Branch_occur(unique_prod, :)             ;
Branch_occur_set = [Branch_occur; fliplr(Branch_occur)]     ;
Step_occur       = unique(ResData.ResTime)                  ;
Branch_lack      = setdiff(Branch_all, Branch_occur, 'rows');
Branch_lack_set  = [Branch_lack; fliplr(Branch_lack)]       ;
Step_lack        = setdiff(Step_all, Step_occur)            ;
% Missing timesteps (load flow did not converge)
NaN_Table_Steps     = array2table(...
    NaN(numel(Step_lack) * size(Branch_occur_set, 1), size(ResData, 2)),...
    'VariableName', ResData.Properties.VariableNames);
NaN_Table_Steps.ResTime      = repelem(Step_lack             , size(Branch_occur_set, 1), 1);
NaN_Table_Steps.Terminal1_ID = repmat (Branch_occur_set(:, 1), numel(Step_lack)         , 1);
NaN_Table_Steps.Terminal2_ID = repmat (Branch_occur_set(:, 2), numel(Step_lack)         , 1);
% Missing branches (isolated in the grid)
NaN_Table_Branches     = array2table(...
    NaN(size(Branch_lack_set, 1) * numel(Step_all), size(ResData,2)),...
    'VariableName', ResData.Properties.VariableNames);
NaN_Table_Branches.ResTime      = repmat (Step_all            , size(Branch_lack_set, 1), 1);
NaN_Table_Branches.Terminal1_ID = repelem(Branch_lack_set(:,1), numel(Step_all)         , 1);
NaN_Table_Branches.Terminal2_ID = repelem(Branch_lack_set(:,2), numel(Step_all)         , 1);

ResData = [ResData; NaN_Table_Steps; NaN_Table_Branches];
ResData = sortrows(ResData,'Terminal2_ID','ascend');
ResData = sortrows(ResData,'Terminal1_ID','ascend');
ResData = sortrows(ResData,'ResTime'     ,'ascend');

%% Add Element Node_IDs, Node_Names, Element_ID and Element_Names

% Initial
ResData.Node1_ID   = zeros(size(ResData, 1), 1);
ResData.Node2_ID   = zeros(size(ResData, 1), 1);
ResData.Element_ID = zeros(size(ResData, 1), 1);

Occurred_Terminals = unique([ResData.Terminal1_ID; ResData.Terminal2_ID]);
for k_Branch = 1 : numel(SinInfo.Terminal.Terminal_ID) % Very time consuming script
    if ismember(SinInfo.Terminal.Terminal_ID(k_Branch), Occurred_Terminals)
        Terminal1_ID_flag = (ResData.Terminal1_ID == SinInfo.Terminal.Terminal_ID(k_Branch));
        Terminal2_ID_flag = (ResData.Terminal2_ID == SinInfo.Terminal.Terminal_ID(k_Branch));
        ResData.Node1_ID  (Terminal1_ID_flag) = SinInfo.Terminal.Node_ID   (k_Branch)       ;
        ResData.Node2_ID  (Terminal2_ID_flag) = SinInfo.Terminal.Node_ID   (k_Branch)       ;
        ResData.Element_ID(Terminal1_ID_flag) = SinInfo.Terminal.Element_ID(k_Branch)       ;
    end
end

%% Saving only RAW data in a file and leaving function

BranchRes_all = ResData; clear ResData; % Change name, the variable will just be saved
if Settings.Output_option_raw_only || Settings.Output_option_raw
    SimData_Filename = [Path_Output, SinNameBasic, '_BranchRes_raw.mat'];
    BranchRes_all_Bytes = whos('BranchRes_all');
    BranchRes_all_Bytes = BranchRes_all_Bytes.bytes;
    if BranchRes_all_Bytes > 2 * 1024^3
        save(SimData_Filename, 'BranchRes_all', '-v7.3');
    else
        save(SimData_Filename, 'BranchRes_all'         );
    end
    if Settings.Output_option_raw_only; return; end
end

%% Read out flag and make column name translator

if Settings.Output_option_I == true
    U_flag = {        ...
        'I1', 'I_L1'; ...
        'I2', 'I_L2'; ...
        'I3', 'I_L3'; ...
        };
else; U_flag = {}; 
end
if Settings.Output_option_P_flow == true
    P_flag = {        ...
        'P1', 'P_L1'; ...
        'P2', 'P_L2'; ...
        'P3', 'P_L3'; ...
        };
else; P_flag = {}; 
end
if Settings.Output_option_Q_flow == true
    Q_flag = {        ...
        'Q1', 'Q_L1'; ...
        'Q2', 'Q_L2'; ...
        'Q3', 'Q_L3'; ...
        };
else; Q_flag = {}; 
end
if Settings.Output_option_S_flow == true
    S_flag = {          ...
        'S1', 'S_L1'  ; ...
        'S2', 'S_L2'  ; ...
        'S3', 'S_L3'  ; ...
        };
else; S_flag = {}; 
end

all_flag = [U_flag; P_flag; Q_flag; S_flag];


%% Adapting Current flows

% ID_up means the Terminal_ID is smaller, vice-verse for ID_down
SimData_ID_up   = BranchRes_all(BranchRes_all.Terminal1_ID < BranchRes_all.Terminal2_ID,:);
SimData_ID_down = BranchRes_all(BranchRes_all.Terminal1_ID > BranchRes_all.Terminal2_ID,:);

clear BranchRes_all;  % To reduce RAM usage

% clear useless data to save space
SimData_ID_up.  Terminal1_ID = []; SimData_ID_up.  Terminal2_ID = [];
SimData_ID_down.Terminal1_ID = []; SimData_ID_down.Terminal2_ID = [];

%% Name and ID prepeartion
% Column names of tables can not start with numbers or have some special
% characters like '-', this section will try to avoid such problems.

Branch_IDs      = SimData_ID_down.Element_ID(1 : size(Branch_all, 1));
Node1_IDs_up    = SimData_ID_up  .Node1_ID  (1 : size(Branch_all, 1));
Node1_IDs_down  = SimData_ID_down.Node1_ID  (1 : size(Branch_all, 1)); 
BranchNames     = strings(numel(Branch_IDs), 1);  % Initialisierung
Node1_Name_up   = strings(numel(Branch_IDs), 1);  % Initialisierung
Node1_Name_down = strings(numel(Branch_IDs), 1);  % Initialisierung
for k_Branch = 1 : numel(Branch_IDs)
    Element_ID_flag    = (SinInfo.Element.Element_ID == Branch_IDs    (k_Branch));
    Node1_ID_up_flag   = (SinInfo.Node.Node_ID       == Node1_IDs_up  (k_Branch));
    Node1_ID_down_flag = (SinInfo.Node.Node_ID       == Node1_IDs_down(k_Branch));
    BranchNames    (k_Branch) = strrep(SinInfo.Element.Name(Element_ID_flag   ), '-', '');
    Node1_Name_up  (k_Branch) = strrep(SinInfo.Node.   Name(Node1_ID_up_flag  ), '-', '');
    Node1_Name_down(k_Branch) = strrep(SinInfo.Node.   Name(Node1_ID_down_flag), '-', '');
end

BranchVarNames  = strrep(                                              ...
    strcat('ID',num2str(double(1:numel(Branch_IDs))'),'_',BranchNames)  ...
    ,' ','');

%% Assemble variables per units and branches

BranchRes_all.ResTime = []; % To reduce RAM usage

for k_flag = 1 : size(all_flag, 1) 
    for k_Branch = 1 : numel(Branch_IDs)
        % Variable value from smaller to bigger Terminal_ID    
        Element_flag = (SimData_ID_up.  Element_ID == Branch_IDs(k_Branch));
        Vari_up   = SimData_ID_up.  (all_flag{k_flag, 1})(Element_flag);
        Vari_down = SimData_ID_down.(all_flag{k_flag, 1})(Element_flag);   
        if Settings.Output_option_per_unit
            if k_Branch == 1
                if k_flag == 1
                    SimResults_Branches_per_units_ID_up   = struct; % initial
                    SimResults_Branches_per_units_ID_down = struct; % initial
                end               
                SimResults_Branches_per_units_ID_up.  (all_flag{k_flag, 2}) = table;  % initial as table
                SimResults_Branches_per_units_ID_down.(all_flag{k_flag, 2}) = table;  % initial as table
            end
            SimResults_Branches_per_units_ID_up.  (all_flag{k_flag, 2}).(BranchVarNames{k_Branch}) = Vari_up  ;
            SimResults_Branches_per_units_ID_down.(all_flag{k_flag, 2}).(BranchVarNames{k_Branch}) = Vari_down;
        end
        if Settings.Output_option_per_node_branch
            if k_flag == 1
                if k_Branch == 1
                    SimResults_Branches_per_branches   = struct; % initial
                end
                SimResults_Branches_per_branches.(BranchNames{k_Branch}) = struct; % initial
                SimResults_Branches_per_branches.(BranchNames{k_Branch}).(Node1_Name_up  {k_Branch}) = table; % initial as table
                SimResults_Branches_per_branches.(BranchNames{k_Branch}).(Node1_Name_down{k_Branch}) = table;
            end
            SimResults_Branches_per_branches.(BranchNames{k_Branch}).(Node1_Name_up  {k_Branch}).(all_flag{k_flag, 2}) = Vari_up  ;
            SimResults_Branches_per_branches.(BranchNames{k_Branch}).(Node1_Name_down{k_Branch}).(all_flag{k_flag, 2}) = Vari_down;
        end
    end
    SimData_ID_up.  (all_flag{k_flag, 1}) = []; % To reduce RAM usage
    SimData_ID_down.(all_flag{k_flag, 1}) = []; % To reduce RAM usage
end
clear SimData_ID_down SimData_ID_up % To reduce RAM usage

%% Saving the results in .mat files

if Settings.Output_option_per_unit
    SimData_Filename_ID_up = [Path_Output, SinNameBasic, '_BranchRes_per_units_ID_up.mat'];
    SimResults_Branches_per_units_ID_up_Bytes = whos('SimResults_Branches_per_units_ID_up');
    if ~isempty(SimResults_Branches_per_units_ID_up_Bytes)
        SimResults_Branches_per_units_ID_up_Bytes = SimResults_Branches_per_units_ID_up_Bytes.bytes; % The variable will just be saved
        if SimResults_Branches_per_units_ID_up_Bytes > 2 * 1024^3
            save(SimData_Filename_ID_up, 'SimResults_Branches_per_units_ID_up', '-v7.3');
        else
            save(SimData_Filename_ID_up, 'SimResults_Branches_per_units_ID_up'         );
        end
        disp([SimData_Filename_ID_up, ' (ID_up) saved.']);
    end
    clear SimResults_Branches_per_units_ID_up % To reduce RAM usage
    
    SimData_Filename_ID_down = [Path_Output, SinNameBasic, '_BranchRes_per_units_ID_down.mat'];
    SimResults_Branches_per_units_ID_down_Bytes = whos('SimResults_Branches_per_units_ID_down');
    if ~isempty(SimResults_Branches_per_units_ID_down_Bytes)
        SimResults_Branches_per_units_ID_down_Bytes = SimResults_Branches_per_units_ID_down_Bytes.bytes; % The variable will just be saved
        if SimResults_Branches_per_units_ID_down_Bytes > 2 * 1024^3
            save(SimData_Filename_ID_down, 'SimResults_Branches_per_units_ID_down', '-v7.3');
        else
            save(SimData_Filename_ID_down, 'SimResults_Branches_per_units_ID_down'         );
        end
        disp([SimData_Filename_ID_down, ' (ID_down) saved.']);
    end
    clear SimResults_Branches_per_units_ID_down % To reduce RAM usage
end
if Settings.Output_option_per_node_branch
    SimData_Filename = [Path_Output, SinNameBasic, '_BranchRes_per_branches.mat'];
    SimResults_Branches_per_branches_Bytes = whos('SimResults_Branches_per_branches');
    if ~isempty(SimResults_Branches_per_branches_Bytes)
        SimResults_Branches_per_branches_Bytes = SimResults_Branches_per_branches_Bytes.bytes; % The variable will just be saved
        if SimResults_Branches_per_branches_Bytes > 2 * 1024^3
            save(SimData_Filename, 'SimResults_Branches_per_branches', '-v7.3');
        else
            save(SimData_Filename, 'SimResults_Branches_per_branches'         );
        end
        disp([SimData_Filename, ' saved.']);
    end
end
