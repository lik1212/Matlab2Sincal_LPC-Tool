function Output_read_BranchRes(Save_Path,Sin_Path_Output,SinNameBasic,instants_per_grid,num_grids,SinInfo,Output_Name,Output_options)
%% 
%   Author(s): P. Gassler
%              based on code from R. Brandalik
%

%% Import NodeRes Files in Matlab memory
if ~Output_options.Raw_generated
    for k_grid = 1 : num_grids
        BranchRes_Name = [Sin_Path_Output,'BranchRes_',SinNameBasic,'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'.txt'];
        if k_grid == 1
            k_SimData = readtable(BranchRes_Name);
            k_SimData(isnan(k_SimData.Terminal2_ID),:) = [];        % One-Terminal Elements are not of interest (such as loads)
            Branch_all = [...
                SinInfo.TwoWindingTransformer.Terminal1_ID, SinInfo.TwoWindingTransformer.Terminal2_ID; ...
                SinInfo.Line.                 Terminal1_ID, SinInfo.Line.                 Terminal2_ID];
            Branch_occur = unique([k_SimData.Terminal1_ID,k_SimData.Terminal2_ID],'rows');
            [~, unique_sum] = unique(sum(Branch_occur,2));   % No natural couple of numbers with the same sum and product
            Branch_occur = Branch_occur(unique_sum,:);
            [~, unique_prod] = unique(prod(Branch_occur,2));
            Branch_occur = Branch_occur(unique_prod,:);
            Missing_Steps = setdiff(1:instants_per_grid,k_SimData.ResTime);
            Missing_Branchs = setdiff(Branch_all,Branch_occur,'rows');
            NaN_Steps     = repelem(Missing_Steps',size(Branch_occur,1)*2,1);
            NaN_Table     = array2table(NaN(numel(NaN_Steps),size(k_SimData,2)));
            VarNames   = k_SimData.Properties.VariableNames;
            NaN_Table.Properties.VariableNames = VarNames;
            NaN_Table.ResTime = NaN_Steps;
            Branch_occur_set = repmat([Branch_occur;fliplr(Branch_occur)],numel(Missing_Steps),1);
            NaN_Table.Terminal1_ID = Branch_occur_set(:,1);
            NaN_Table.Terminal2_ID = Branch_occur_set(:,2);
            k_SimData     = [k_SimData; NaN_Table];
            NaN_Table     = array2table(NaN(size(Missing_Branchs,1)* 2 * instants_per_grid,size(k_SimData,2)));
            NaN_Table.Properties.VariableNames = VarNames;
            NaN_Table.ResTime = repmat(1:instants_per_grid,1,size(Missing_Branchs,1)* 2)';
            Missing_Branchs_set = [Missing_Branchs;fliplr(Missing_Branchs)];
            NaN_Table.Terminal1_ID = repelem(Missing_Branchs_set(:,1),instants_per_grid,1);
            NaN_Table.Terminal2_ID = repelem(Missing_Branchs_set(:,2),instants_per_grid,1);
            k_SimData     = [k_SimData; NaN_Table];
            k_SimData = sortrows(k_SimData,'Terminal1_ID','ascend');
            k_SimData = sortrows(k_SimData,'ResTime','ascend');
            num_elements = size(k_SimData,1);
            SimData   = array2table(zeros(...
                num_elements*num_grids,...
                size(k_SimData,2)));
            SimData.Properties.VariableNames = VarNames;
            % Data merging
            SimData(...
                (k_grid - 1) * num_elements + 1 : ...
                k_grid * num_elements,...
                :) = k_SimData;
        else
            k_SimData = readtable(BranchRes_Name);
            k_SimData(isnan(k_SimData.Terminal2_ID),:) = [];        % One-Terminal Elements are not of interest (such as loads)
            Branch_all = [...
                SinInfo.TwoWindingTransformer.Terminal1_ID, SinInfo.TwoWindingTransformer.Terminal2_ID; ...
                SinInfo.Line.                 Terminal1_ID, SinInfo.Line.                 Terminal2_ID];
            Branch_occur = unique([k_SimData.Terminal1_ID,k_SimData.Terminal2_ID],'rows');
            [~, unique_sum] = unique(sum(Branch_occur,2));   % No natural couple of numbers with the same sum and product
            Branch_occur = Branch_occur(unique_sum,:);
            [~, unique_prod] = unique(prod(Branch_occur,2));
            Branch_occur = Branch_occur(unique_prod,:);
            Missing_Steps = setdiff(1:instants_per_grid,k_SimData.ResTime);
            Missing_Branchs = setdiff(Branch_all,Branch_occur,'rows');
            NaN_Steps     = repelem(Missing_Steps',size(Branch_occur,1)*2,1);
            NaN_Table     = array2table(NaN(numel(NaN_Steps),size(k_SimData,2)));
            VarNames   = k_SimData.Properties.VariableNames;
            NaN_Table.Properties.VariableNames = VarNames;
            NaN_Table.ResTime = NaN_Steps;
            Branch_occur_set = repmat([Branch_occur;fliplr(Branch_occur)],numel(Missing_Steps),1);
            NaN_Table.Terminal1_ID = Branch_occur_set(:,1);
            NaN_Table.Terminal2_ID = Branch_occur_set(:,2);
            k_SimData     = [k_SimData; NaN_Table];
            NaN_Table     = array2table(NaN(size(Missing_Branchs,1)* 2 * instants_per_grid,size(k_SimData,2)));
            NaN_Table.Properties.VariableNames = VarNames;
            NaN_Table.ResTime = repmat(1:instants_per_grid,1,size(Missing_Branchs,1)* 2)';
            Missing_Branchs_set = [Missing_Branchs;fliplr(Missing_Branchs)];
            NaN_Table.Terminal1_ID = repelem(Missing_Branchs_set(:,1),instants_per_grid,1);
            NaN_Table.Terminal2_ID = repelem(Missing_Branchs_set(:,2),instants_per_grid,1);
            k_SimData     = [k_SimData; NaN_Table];
            k_SimData = sortrows(k_SimData,'Terminal1_ID','ascend');
            k_SimData = sortrows(k_SimData,'ResTime','ascend');
            % ResTime auf Instanz anpassen
            k_SimData.ResTime = (k_grid-1)*instants_per_grid + (k_SimData.ResTime);
            SimData(...
                (k_grid - 1) * num_elements + 1 : ...
                k_grid * num_elements,...
                :) = k_SimData;
        end
        %     fprintf('Das %d. von %d BranchRes Files ist eingelesen worden.\n',k_grid,num_grids);
        disp([BranchRes_Name,' loaded.']);
    end
    clear k_SimData
    SimData = sortrows(SimData,'Terminal2_ID','ascend');
    SimData = sortrows(SimData,'Terminal1_ID','ascend');
    SimData = sortrows(SimData,'ResTime','ascend');

    %% Saving only RAW data in a file and leaving function
    if Output_options.Raw_only
        Output_Filename = [Output_Name,'_BranchRes_raw.mat'];
        SimData_Filename = [Save_Path,Output_Filename];
        BranchRes_all = SimData;
        SimData = [];
        BranchRes_all_Bytes = whos('BranchRes_all');
        BranchRes_all_Bytes = BranchRes_all_Bytes.bytes; % The variable will just be saved
        if BranchRes_all_Bytes > 2 * 1024^3
            save(SimData_Filename,'BranchRes_all','-v7.3');
        else
            save(SimData_Filename,'BranchRes_all');
        end
        return
    elseif Output_options.Raw
        Output_Filename = [Output_Name,'_BranchRes_raw.mat'];
        SimData_Filename = [Save_Path,Output_Filename];
        BranchRes_all = SimData;
        BranchRes_all_Bytes = whos('BranchRes_all');
        BranchRes_all_Bytes = BranchRes_all_Bytes.bytes; % The variable will just be saved
        if BranchRes_all_Bytes > 2 * 1024^3
            save(SimData_Filename,'BranchRes_all','-v7.3');
        else
            save(SimData_Filename,'BranchRes_all');
        end
    end
else
    if isfield(Output_options,'Input_Filename')
        SimData_Filename = Output_options.Input_Filename;
    else
        Output_Filename = [SinNameBasic,'_BranchRes_raw.mat'];
        SimData_Filename = [Sin_Path_Output,Output_Filename];
    end
    load(SimData_Filename);
    disp([SimData_Filename,' loaded.']);
    SimData = BranchRes_all;
    BranchRes_all = [];
end

%% Deleting ResTime

SimData.ResTime = [];

%% Adapting Current flows

SimData_ID_up = SimData(SimData.Terminal1_ID < SimData.Terminal2_ID,:);
SimData_ID_down = SimData(SimData.Terminal1_ID > SimData.Terminal2_ID,:);

clear SimData;

% Convert Terminal IDs to Node IDs
SimData_ID_up.Node1_ID      = NaN(size(SimData_ID_up,1),1);
SimData_ID_up.Node2_ID      = NaN(size(SimData_ID_up,1),1);
SimData_ID_down.Node1_ID    = NaN(size(SimData_ID_down,1),1);
SimData_ID_down.Node2_ID    = NaN(size(SimData_ID_down,1),1);
Occurred_Terminals            = unique([SimData_ID_up.Terminal1_ID;SimData_ID_up.Terminal2_ID]);

% define Waitbar
BranchRes_waitbar1 = waitbar(0,'Progress','Name','BranchRes');
for k = 1:numel(SinInfo.Terminal.Terminal_ID)               % Very time consuming script
    if ismember(SinInfo.Terminal.Terminal_ID(k),Occurred_Terminals)
        SimData_ID_up.Node1_ID(SimData_ID_up.Terminal1_ID == SinInfo.Terminal.Terminal_ID(k)) = SinInfo.Terminal.Node_ID(k);
        SimData_ID_up.Node2_ID(SimData_ID_up.Terminal2_ID == SinInfo.Terminal.Terminal_ID(k)) = SinInfo.Terminal.Node_ID(k);
        SimData_ID_down.Node1_ID(SimData_ID_down.Terminal1_ID == SinInfo.Terminal.Terminal_ID(k)) = SinInfo.Terminal.Node_ID(k);
        SimData_ID_down.Node2_ID(SimData_ID_down.Terminal2_ID == SinInfo.Terminal.Terminal_ID(k)) = SinInfo.Terminal.Node_ID(k);
    end
    updateWaitbar('update',BranchRes_waitbar1,k/numel(SinInfo.Terminal.Terminal_ID),'Progress');
end
updateWaitbar('delete',BranchRes_waitbar1);

% clear useless data to save space
SimData_ID_up.Terminal1_ID = [];
SimData_ID_up.Terminal2_ID = [];
SimData_ID_down.Terminal1_ID = [];
SimData_ID_down.Terminal2_ID = [];

% determine Name and ID of Line
SinInfo.Line = sortrows(SinInfo.Line,'Element_ID');
LineName       = SinInfo.Line.Name';
if isfield(SinInfo,'TwoWindingTransformer')
    TR2WName       = SinInfo.TwoWindingTransformer.Name';
    TR2WElementID  = SinInfo.TwoWindingTransformer.Element_ID';
else
    TR2WName       = [];
    TR2WElementID  = [];
end
LineElementID  = SinInfo.Line.Element_ID';
ElementID      = 1:numel([LineName,TR2WName]);

BranchNames       = cell(numel([LineName,TR2WName]),1);  % Initialisierung
BranchVarNames    = cell(numel([LineName,TR2WName]),1);
for k = 1 : numel(LineName)
    BranchNames{k} = LineName{k};
    if (BranchNames{k}(2))=='-'
%         BranchNames{k} = [BranchNames{k}(1),'_',BranchNames{k}(3:end)];
        BranchNames{k} = [BranchNames{k}(1),BranchNames{k}(3:end)];
    end
    BranchVarNames{k} = ['ID',num2str(LineElementID(k)),'_',BranchNames{k}];
end
for t = 1 : numel(TR2WName)
    k = t + numel(LineName);
    BranchNames{k} = TR2WName{t};
    if (BranchNames{k}(2))=='-'
%         BranchNames{k} = [BranchNames{k}(1),'_',BranchNames{k}(3:end)];
        BranchNames{k} = [BranchNames{k}(1),BranchNames{k}(3:end)];
    end
    BranchVarNames{k} = ['ID',num2str(TR2WElementID(t)),'_',BranchNames{k}];
end


Branches       = table;
Branches.Element_ID = [LineElementID';TR2WElementID'];
Branches.Names = BranchNames;
Branches.Node1_ID = SimData_ID_down.Node1_ID(1:numel([LineName,TR2WName]));
Branches.Node2_ID = SimData_ID_down.Node2_ID(1:numel([LineName,TR2WName]));
Branches.IDs   = ElementID';


% SimData_ID_up.LineID = NaN(size(SimData_ID_up,1),1);
% SimData_ID_down.LineID = NaN(size(SimData_ID_down,1),1);

SimData_ID_up.LineID = repmat(ElementID',instants_per_grid*num_grids,1);
SimData_ID_down.LineID = repmat(ElementID',instants_per_grid*num_grids,1);

% for k = 1 : numel(LineName)
%     SimData_ID_up.LineID(...
%         all(ismember([SimData_ID_up.Node1_ID,SimData_ID_up.Node2_ID],[SinInfo.Line.Node1_ID(k),SinInfo.Line.Node2_ID(k)]),2)) = ...
%         ElementID(k);
%     SimData_ID_down.LineID(...
%         all(ismember([SimData_ID_down.Node1_ID,SimData_ID_down.Node2_ID],[SinInfo.Line.Node1_ID(k),SinInfo.Line.Node2_ID(k)]),2)) = ...
%         ElementID(k);
% end
% for t = 1 : numel(TR2WName)
%     k = t + numel(LineName);
%     SimData_ID_up.LineID(...
%         all(ismember([SimData_ID_up.Node1_ID,SimData_ID_up.Node2_ID],[SinInfo.TwoWindingTransformer.Node1_ID(t),SinInfo.TwoWindingTransformer.Node2_ID(t)]),2)) = ...
%         ElementID(k);
%     SimData_ID_down.LineID(...
%         all(ismember([SimData_ID_down.Node1_ID,SimData_ID_down.Node2_ID],[SinInfo.TwoWindingTransformer.Node1_ID(t),SinInfo.TwoWindingTransformer.Node2_ID(t)]),2)) = ...
%         ElementID(k);
% end

% clear useless data to save space
SimData_ID_up.Node1_ID = [];
SimData_ID_up.Node2_ID = [];
SimData_ID_down.Node1_ID = [];
SimData_ID_down.Node2_ID = [];

%% Declaration of Database for results classified per Node or per Unit

if Output_options.Node_Branch
    SimResults_Branches_per_branches = struct;
    for k = 1 : numel([LineName,TR2WName])
        SimResults_Branches_per_branches.(BranchNames{k}) = table;
    end
end
if Output_options.Unit
    SimResults_Branches_per_units = struct;
    SimResults_Branches_per_units.Branches = Branches;
    if Output_options.T_vector
%         SimResults_Branches_per_units.Time_Vector = Time_Vector;
    end
    if Output_options.Sin_Info
        SimResults_Branches_per_units.Grid_Info = SinInfo;
    end
end

%% Saving Current Flow L1

if Output_options.I
    
    I_L1_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    I_L1_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        I_L1_up(:,k) = SimData_ID_up.I1(SimData_ID_up.LineID == ElementID(k));
        I_L1_down(:,k) = SimData_ID_down.I1(SimData_ID_down.LineID == ElementID(k));
    end

    I_L1 = zeros(instants_per_grid*num_grids,numel(ElementID));
    I_L1(I_L1_down >= I_L1_up) = I_L1_down(I_L1_down >= I_L1_up);
    I_L1(I_L1_up >= I_L1_down) = I_L1_up(I_L1_up >= I_L1_down);
    
    clear I_L1_up I_L1_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.I_L1 = table;
        SimResults_Branches_per_units.I_L1 = array2table(I_L1,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).I_L1 = I_L1(:,k);
        end
        clear I_L1;
    end
    SimData_ID_up.I1 = [];
    SimData_ID_down.I1 = [];
end

%% Saving Current Flow L2

if Output_options.I
    
    I_L2_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    I_L2_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        I_L2_up(:,k) = SimData_ID_up.I2(SimData_ID_up.LineID == ElementID(k));
        I_L2_down(:,k) = SimData_ID_down.I2(SimData_ID_down.LineID == ElementID(k));
    end

    I_L2 = zeros(instants_per_grid*num_grids,numel(ElementID));
    I_L2(I_L2_down >= I_L2_up) = I_L2_down(I_L2_down >= I_L2_up);
    I_L2(I_L2_up >= I_L2_down) = I_L2_up(I_L2_up >= I_L2_down);
    
    clear I_L2_up I_L2_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.I_L2 = table;
        SimResults_Branches_per_units.I_L2 = array2table(I_L2,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).I_L2 = I_L2(:,k);
        end
        clear I_L2;
    end
    SimData_ID_up.I2 = [];
    SimData_ID_down.I2 = [];
end

%% Saving Current Flow L3

if Output_options.I
    
    I_L3_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    I_L3_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        I_L3_up(:,k) = SimData_ID_up.I3(SimData_ID_up.LineID == ElementID(k));
        I_L3_down(:,k) = SimData_ID_down.I3(SimData_ID_down.LineID == ElementID(k));
    end

    I_L3 = zeros(instants_per_grid*num_grids,numel(ElementID));
    I_L3(I_L3_down >= I_L3_up) = I_L3_down(I_L3_down >= I_L3_up);
    I_L3(I_L3_up >= I_L3_down) = I_L3_up(I_L3_up >= I_L3_down);
    
    clear I_L3_up I_L3_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.I_L3 = table;
        SimResults_Branches_per_units.I_L3 = array2table(I_L3,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).I_L3 = I_L3(:,k);
        end
        clear I_L3;
    end
    SimData_ID_up.I3 = [];
    SimData_ID_down.I3 = [];
end

%% Saving active Power Flow L1

if Output_options.P_flow
    
    P_L1_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    P_L1_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        P_L1_up(:,k) = SimData_ID_up.P1(SimData_ID_up.LineID == ElementID(k));
        P_L1_down(:,k) = SimData_ID_down.P1(SimData_ID_down.LineID == ElementID(k));
    end

    P_L1 = zeros(instants_per_grid*num_grids,numel(ElementID));
    P_L1(P_L1_down >= P_L1_up) = P_L1_down(P_L1_down >= P_L1_up);
    P_L1(P_L1_up >= P_L1_down) = P_L1_up(P_L1_up >= P_L1_down);
    
    clear P_L1_up P_L1_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.P_L1 = table;
        SimResults_Branches_per_units.P_L1 = array2table(P_L1,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).P_L1 = P_L1(:,k);
        end
        clear P_L1;
    end
    SimData_ID_up.P1 = [];
    SimData_ID_down.P1 = [];
end

%% Saving active Power Flow L2

if Output_options.P_flow
    
    P_L2_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    P_L2_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        P_L2_up(:,k) = SimData_ID_up.P2(SimData_ID_up.LineID == ElementID(k));
        P_L2_down(:,k) = SimData_ID_down.P2(SimData_ID_down.LineID == ElementID(k));
    end

    P_L2 = zeros(instants_per_grid*num_grids,numel(ElementID));
    P_L2(P_L2_down >= P_L2_up) = P_L2_down(P_L2_down >= P_L2_up);
    P_L2(P_L2_up >= P_L2_down) = P_L2_up(P_L2_up >= P_L2_down);
    
    clear P_L2_up P_L2_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.P_L2 = table;
        SimResults_Branches_per_units.P_L2 = array2table(P_L2,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).P_L2 = P_L2(:,k);
        end
        clear P_L2;
    end
    SimData_ID_up.P2 = [];
    SimData_ID_down.P2 = [];
end

%% Saving active Power Flow L3

if Output_options.P_flow
    
    P_L3_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    P_L3_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        P_L3_up(:,k) = SimData_ID_up.P3(SimData_ID_up.LineID == ElementID(k));
        P_L3_down(:,k) = SimData_ID_down.P3(SimData_ID_down.LineID == ElementID(k));
    end

    P_L3 = zeros(instants_per_grid*num_grids,numel(ElementID));
    P_L3(P_L3_down >= P_L3_up) = P_L3_down(P_L3_down >= P_L3_up);
    P_L3(P_L3_up >= P_L3_down) = P_L3_up(P_L3_up >= P_L3_down);
    
    clear P_L3_up P_L3_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.P_L3 = table;
        SimResults_Branches_per_units.P_L3 = array2table(P_L3,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).P_L3 = P_L3(:,k);
        end
        clear P_L3;
    end
    SimData_ID_up.P3 = [];
    SimData_ID_down.P3 = [];
end

%% Saving reactive Power Flow L1

if Output_options.Q_flow
    
    Q_L1_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    Q_L1_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        Q_L1_up(:,k) = SimData_ID_up.Q1(SimData_ID_up.LineID == ElementID(k));
        Q_L1_down(:,k) = SimData_ID_down.Q1(SimData_ID_down.LineID == ElementID(k));
    end

    Q_L1 = zeros(instants_per_grid*num_grids,numel(ElementID));
    Q_L1(Q_L1_down >= Q_L1_up) = Q_L1_down(Q_L1_down >= Q_L1_up);
    Q_L1(Q_L1_up >= Q_L1_down) = Q_L1_up(Q_L1_up >= Q_L1_down);
    
    clear Q_L1_up Q_L1_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.Q_L1 = table;
        SimResults_Branches_per_units.Q_L1 = array2table(Q_L1,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).Q_L1 = Q_L1(:,k);
        end
        clear Q_L1;
    end
    SimData_ID_up.Q1 = [];
    SimData_ID_down.Q1 = [];
end

%% Saving reactive Power Flow L2

if Output_options.Q_flow
    
    Q_L2_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    Q_L2_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        Q_L2_up(:,k) = SimData_ID_up.Q2(SimData_ID_up.LineID == ElementID(k));
        Q_L2_down(:,k) = SimData_ID_down.Q2(SimData_ID_down.LineID == ElementID(k));
    end

    Q_L2 = zeros(instants_per_grid*num_grids,numel(ElementID));
    Q_L2(Q_L2_down >= Q_L2_up) = Q_L2_down(Q_L2_down >= Q_L2_up);
    Q_L2(Q_L2_up >= Q_L2_down) = Q_L2_up(Q_L2_up >= Q_L2_down);
    
    clear Q_L2_up Q_L2_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.Q_L2 = table;
        SimResults_Branches_per_units.Q_L2 = array2table(Q_L2,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).Q_L2 = Q_L2(:,k);
        end
        clear Q_L2;
    end
    SimData_ID_up.Q2 = [];
    SimData_ID_down.Q2 = [];
end

%% Saving reactive Power Flow L3

if Output_options.Q_flow
    
    Q_L3_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    Q_L3_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        Q_L3_up(:,k) = SimData_ID_up.Q3(SimData_ID_up.LineID == ElementID(k));
        Q_L3_down(:,k) = SimData_ID_down.Q3(SimData_ID_down.LineID == ElementID(k));
    end

    Q_L3 = zeros(instants_per_grid*num_grids,numel(ElementID));
    Q_L3(Q_L3_down >= Q_L3_up) = Q_L3_down(Q_L3_down >= Q_L3_up);
    Q_L3(Q_L3_up >= Q_L3_down) = Q_L3_up(Q_L3_up >= Q_L3_down);
    
    clear Q_L3_up Q_L3_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.Q_L3 = table;
        SimResults_Branches_per_units.Q_L3 = array2table(Q_L3,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).Q_L3 = Q_L3(:,k);
        end
        clear Q_L3;
    end
    SimData_ID_up.Q3 = [];
    SimData_ID_down.Q3 = [];
end

%% Saving apparent Power Flow L1

if Output_options.S_flow
    
    S_L1_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    S_L1_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        S_L1_up(:,k) = SimData_ID_up.S1(SimData_ID_up.LineID == ElementID(k));
        S_L1_down(:,k) = SimData_ID_down.S1(SimData_ID_down.LineID == ElementID(k));
    end

    S_L1 = zeros(instants_per_grid*num_grids,numel(ElementID));
    S_L1(S_L1_down >= S_L1_up) = S_L1_down(S_L1_down >= S_L1_up);
    S_L1(S_L1_up >= S_L1_down) = S_L1_up(S_L1_up >= S_L1_down);
    
    clear S_L1_up S_L1_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.S_L1 = table;
        SimResults_Branches_per_units.S_L1 = array2table(S_L1,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).S_L1 = S_L1(:,k);
        end
        clear S_L1;
    end
    SimData_ID_up.S1 = [];
    SimData_ID_down.S1 = [];
end

%% Saving apparent Power Flow L2

if Output_options.S_flow
    
    S_L2_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    S_L2_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        S_L2_up(:,k) = SimData_ID_up.S2(SimData_ID_up.LineID == ElementID(k));
        S_L2_down(:,k) = SimData_ID_down.S2(SimData_ID_down.LineID == ElementID(k));
    end

    S_L2 = zeros(instants_per_grid*num_grids,numel(ElementID));
    S_L2(S_L2_down >= S_L2_up) = S_L2_down(S_L2_down >= S_L2_up);
    S_L2(S_L2_up >= S_L2_down) = S_L2_up(S_L2_up >= S_L2_down);
    
    clear S_L2_up S_L2_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.S_L2 = table;
        SimResults_Branches_per_units.S_L2 = array2table(S_L2,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).S_L2 = S_L2(:,k);
        end
        clear S_L2;
    end
    SimData_ID_up.S2 = [];
    SimData_ID_down.S2 = [];
end

%% Saving apparent Power Flow L3

if Output_options.S_flow
    
    S_L3_up = zeros(instants_per_grid*num_grids,numel(ElementID));
    S_L3_down = zeros(instants_per_grid*num_grids,numel(ElementID));

    for k = 1 : numel(ElementID)
        S_L3_up(:,k) = SimData_ID_up.S3(SimData_ID_up.LineID == ElementID(k));
        S_L3_down(:,k) = SimData_ID_down.S3(SimData_ID_down.LineID == ElementID(k));
    end

    S_L3 = zeros(instants_per_grid*num_grids,numel(ElementID));
    S_L3(S_L3_down >= S_L3_up) = S_L3_down(S_L3_down >= S_L3_up);
    S_L3(S_L3_up >= S_L3_down) = S_L3_up(S_L3_up >= S_L3_down);
    
    clear S_L3_up S_L3_down;
    
    if Output_options.Unit
        SimResults_Branches_per_units.S_L3 = table;
        SimResults_Branches_per_units.S_L3 = array2table(S_L3,'VariableNames',BranchVarNames);
    end
    if Output_options.Node_Branch
        for k = 1 : numel(ElementID)
            SimResults_Branches_per_branches.(BranchNames{k}).S_L3 = S_L3(:,k);
        end
        clear S_L3;
    end
    SimData_ID_up.S3 = [];
    SimData_ID_down.S3 = [];
end

%% Saving the results in .mat files

if Output_options.Unit
    Output_Filename = [Output_Name,'_BranchRes_per_units.mat'];
    SimData_Filename = [Save_Path,Output_Filename];
    SimResults_Branches_per_units_Bytes = whos('SimResults_Branches_per_units');
    SimResults_Branches_per_units_Bytes = SimResults_Branches_per_units_Bytes.bytes; % The variable will just be saved
    if SimResults_Branches_per_units_Bytes > 2 * 1024^3
        save(SimData_Filename,'SimResults_Branches_per_units','-v7.3');
    else
        save(SimData_Filename,'SimResults_Branches_per_units');        
    end
    disp([SimData_Filename,' saved.']);
end
if Output_options.Node_Branch
    Output_Filename = [Output_Name,'_BranchRes_per_branches.mat'];
    SimData_Filename = [Save_Path,Output_Filename];
    SimResults_Branches_per_branches_Bytes = whos('SimResults_Branches_per_units');
    SimResults_Branches_per_branches_Bytes = SimResults_Branches_per_branches_Bytes.bytes; % The variable will just be saved    
    if SimResults_Branches_per_branches_Bytes > 2 * 1024^3
        save(SimData_Filename,'SimResults_Branches_per_branches','-v7.3');
    else
        save(SimData_Filename,'SimResults_Branches_per_branches');
    end
    disp([SimData_Filename,' saved.']);
end


end