% function Output_read_BranchRes(Path_Output, Path_Input, SinNameBasic, instants_per_grid, num_grids, SinInfo, Settings)
% function read the BranchRes .txt files (one file per Grid) and creates a
% .mat database with chosen Power Flow result
%
% Author(s): P. Gassler, R. Brandalik
%   
%% Temp delete TODO

clear; load('temp1.mat')

%% Import BranchRes Files in Matlab memory

for k_grid = 1 : num_grids
    File_suffix  = ['_', num2str(instants_per_grid), 'inst_', num2str(k_grid)];
    BranchRes_Name = [Path_Input, 'BranchRes_', SinNameBasic, File_suffix, '.txt'];
    if k_grid == 1
        ResData   = readtable(BranchRes_Name);
    else
        k_ResData = readtable(BranchRes_Name);
        % ResTime auf Instanz anpassen
        k_ResData.ResTime = k_ResData.ResTime + (k_grid - 1) * instants_per_grid;
        ResData = [ResData; k_ResData]; %#ok The size of the file is unknown
        clear k_ResData                 %    To reduce RAM usage
    end
    disp([BranchRes_Name, ' loaded.']);
end
ResData(isnan(ResData.Terminal2_ID),:) = []; % One-Terminal Elements are not of interest (such as loads)

%% Temp delete TODO

% ResData(ResData.Terminal1_ID == 3,:) = [];
% ResData(ResData.Terminal1_ID == 4,:) = [];
% ResData(ResData.Terminal1_ID == 7,:) = [];
% ResData(ResData.Terminal1_ID == 8,:) = [];
% ResData(ResData.ResTime == 7,:) = [];
% ResData(ResData.ResTime == 9,:) = [];

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
ResData = sortrows(ResData,'ResTime','ascend');

%% Saving only RAW data in a file and leaving function

if Settings.Output_option_raw_only
    SimData_Filename = [Path_Output, SinNameBasic, '_BranchRes_raw.mat'];
    BranchRes_all = ResData; clear ResData; %#ok Change name, the variable will just be saved
    BranchRes_all_Bytes = whos('BranchRes_all');
    BranchRes_all_Bytes = BranchRes_all_Bytes.bytes;
    if BranchRes_all_Bytes > 2 * 1024^3
        save(SimData_Filename,'BranchRes_all','-v7.3');
    else
        save(SimData_Filename,'BranchRes_all');
    end
    return
elseif Settings.Output_option_raw % Saving RAW data in a file
    SimData_Filename = [Path_Output, SinNameBasic, '_BranchRes_raw.mat'];
    BranchRes_all = ResData; %#ok, the variable will just be saved
    BranchRes_all_Bytes = whos('BranchRes_all');
    BranchRes_all_Bytes = BranchRes_all_Bytes.bytes;
    if BranchRes_all_Bytes > 2 * 1024^3
        save(SimData_Filename,'BranchRes_all','-v7.3');
    else
        save(SimData_Filename,'BranchRes_all');
    end
%     clear BranchRes_all % Temp, TODO
end

%% Adapting Current flows

SimData_ID_up   = ResData(ResData.Terminal1_ID < ResData.Terminal2_ID,:);
SimData_ID_down = ResData(ResData.Terminal1_ID > ResData.Terminal2_ID,:);

clear ResData;  % To reduce RAM usage

% Convert Terminal IDs to Node IDs
SimData_ID_up.  Node1_ID = NaN(size(SimData_ID_up,1),1);
SimData_ID_up.  Node2_ID = NaN(size(SimData_ID_up,1),1);
SimData_ID_down.Node1_ID = NaN(size(SimData_ID_down,1),1);
SimData_ID_down.Node2_ID = NaN(size(SimData_ID_down,1),1);
Occurred_Terminals       = unique([SimData_ID_up.Terminal1_ID; SimData_ID_up.Terminal2_ID]);
for k_Branch = 1 : numel(SinInfo.Terminal.Terminal_ID) % Very time consuming script
    if ismember(SinInfo.Terminal.Terminal_ID(k_Branch), Occurred_Terminals)
        SimData_ID_up.Node1_ID    (SimData_ID_up.Terminal1_ID == SinInfo.Terminal.Terminal_ID(k_Branch)) = SinInfo.Terminal.Node_ID   (k_Branch);
        SimData_ID_up.Node2_ID    (SimData_ID_up.Terminal2_ID == SinInfo.Terminal.Terminal_ID(k_Branch)) = SinInfo.Terminal.Node_ID   (k_Branch);
        SimData_ID_up.Node1_Name  (SimData_ID_up.Terminal1_ID == SinInfo.Terminal.Terminal_ID(k_Branch)) = ...
            SinInfo.Node.Name(SinInfo.Node.Node_ID == SinInfo.Terminal.Node_ID(k_Branch));
        SimData_ID_up.Node2_Name  (SimData_ID_up.Terminal2_ID == SinInfo.Terminal.Terminal_ID(k_Branch)) = ...
            SinInfo.Node.Name(SinInfo.Node.Node_ID == SinInfo.Terminal.Node_ID(k_Branch));        
        SimData_ID_up.Element_ID  (SimData_ID_up.Terminal1_ID == SinInfo.Terminal.Terminal_ID(k_Branch)) = SinInfo.Terminal.Element_ID(k_Branch);
        SimData_ID_up.Element_Name(SimData_ID_up.Terminal1_ID == SinInfo.Terminal.Terminal_ID(k_Branch)) = ...
            SinInfo.Element.Name(ismember(SinInfo.Element.Element_ID, SinInfo.Terminal.Element_ID(k_Branch)));
    end
end
SimData_ID_down.Node1_ID     = SimData_ID_up.Node2_ID    ;
SimData_ID_down.Node2_ID     = SimData_ID_up.Node1_ID    ;
SimData_ID_down.Node1_Name   = SimData_ID_up.Node2_Name  ;
SimData_ID_down.Node2_Name   = SimData_ID_up.Node1_Name  ;
SimData_ID_down.Element_ID   = SimData_ID_up.Element_ID  ; 
SimData_ID_down.Element_Name = SimData_ID_up.Element_Name; 
% clear useless data to save space
SimData_ID_up.  Terminal1_ID = []; SimData_ID_up.  Terminal2_ID = [];
SimData_ID_down.Terminal1_ID = []; SimData_ID_down.Terminal2_ID = [];

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

%% Name and ID prepeartion
% Column names of tables can not start with numbers or have some special
% characters like '-', this section will try to avoid such problems.

Branch_IDs  = SimData_ID_down.Element_ID(1:size(Branch_all, 1));
BranchNames = strrep(...
    SimData_ID_down.Element_Name(1:numel(Branch_IDs)),'-','');  % Initialisierung
Node1_Name  = strrep(...
    SimData_ID_down.  Node1_Name(1:numel(Branch_IDs)),'-','');  % Initialisierung
Node2_Name  = strrep(...
    SimData_ID_down.  Node2_Name(1:numel(Branch_IDs)),'-','');  % Initialisierung
BranchVarNames = strrep(                                              ...
    strcat('ID',num2str(double(1:numel(Branch_IDs))'),'_',BranchNames)  ...
    ,' ','');

%% Assemble variables per units and branches

ResData.ResTime = []; % To reduce RAM usage

if Settings.Output_option_per_node_branch
    SimResults_Branches_per_branches = struct;
    for k_Branch = 1 : size(BranchNames,1)
        SimResults_Branches_per_branches.(BranchNames{k_Branch}) = struct;
        SimResults_Branches_per_branches.(BranchNames{k_Branch}).(Node1_Name{k_Branch}) = table;
        SimResults_Branches_per_branches.(BranchNames{k_Branch}).(Node2_Name{k_Branch}) = table;
    end
end
if Settings.Output_option_per_unit
    SimResults_Branches_per_units = struct;
end
for k_flag = 1 : size(all_flag, 1)   
    Vari_up   = zeros(numel(Step_all), numel(Branch_IDs));
    Vari_down = zeros(numel(Step_all), numel(Branch_IDs));

    for k_Branch = 1 : numel(Branch_IDs)
        Vari_up  (:, k_Branch) = SimData_ID_up.  (all_flag{k_flag, 1})(SimData_ID_up.  Element_ID == Branch_IDs(k_Branch));
        Vari_down(:, k_Branch) = SimData_ID_down.(all_flag{k_flag, 1})(SimData_ID_down.Element_ID == Branch_IDs(k_Branch));
    end

    Vari = zeros(numel(Step_all), numel(Branch_IDs));
    Vari(Vari_down >= Vari_up  ) = Vari_down(Vari_down >= Vari_up  );
    Vari(Vari_up   >= Vari_down) = Vari_up  (Vari_up   >= Vari_down);
    
%     clear Vari_up Vari_down; % Temp, TODO
    
    if Settings.Output_option_per_unit
        SimResults_Branches_per_units.(all_flag{k_flag, 2}) = table;
        SimResults_Branches_per_units.(all_flag{k_flag, 2}) = array2table(Vari, 'VariableNames', BranchVarNames);
    end
    if Settings.Output_option_per_node_branch
        for k_Branch = 1 : numel(Branch_IDs)
%             SimResults_Branches_per_branches.(BranchNames{k_Branch}).(all_flag{k_flag, 2}) = Vari(:,k_Branch);
            SimResults_Branches_per_branches.(BranchNames{k_Branch}).(Node1_Name{k_Branch}).(all_flag{k_flag, 2}) = Vari_up  (:,k_Branch);
            SimResults_Branches_per_branches.(BranchNames{k_Branch}).(Node2_Name{k_Branch}).(all_flag{k_flag, 2}) = Vari_down(:,k_Branch);
        end
%         clear Vari; % Temp, TODO
    end
%     SimData_ID_up.  (all_flag{k_flag, 1}) = []; % Temp, TODO
%     SimData_ID_down.(all_flag{k_flag, 1}) = []; % Temp, TODO
end

%% Saving the results in .mat files

if Settings.Output_option_per_unit
    SimData_Filename = [Path_Output, SinNameBasic, '_BranchRes_per_units.mat'];
    SimResults_Branches_per_units_Bytes = whos('SimResults_Branches_per_units');
    SimResults_Branches_per_units_Bytes = SimResults_Branches_per_units_Bytes.bytes; % The variable will just be saved
    if SimResults_Branches_per_units_Bytes > 2 * 1024^3
        save(SimData_Filename, 'SimResults_Branches_per_units','-v7.3');
    else
        save(SimData_Filename, 'SimResults_Branches_per_units'        );        
    end
    disp([SimData_Filename, ' saved.']);
end
if Settings.Output_option_per_node_branch
    SimData_Filename = [Path_Output, SinNameBasic, '_BranchRes_per_branches.mat'];
    SimResults_Branches_per_branches_Bytes = whos('SimResults_Branches_per_units');
    SimResults_Branches_per_branches_Bytes = SimResults_Branches_per_branches_Bytes.bytes; % The variable will just be saved    
    if SimResults_Branches_per_branches_Bytes > 2 * 1024^3
        save(SimData_Filename, 'SimResults_Branches_per_branches','-v7.3');
    else
        save(SimData_Filename, 'SimResults_Branches_per_branches'        );
    end
    disp([SimData_Filename, ' saved.']);
end
