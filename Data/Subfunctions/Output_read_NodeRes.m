function Output_read_NodeRes(Save_Path,Sin_Path_Output,SinNameBasic,instants_per_grid,num_grids,SinInfo,Output_Name,Settings)
% function read the NodeRes .txt files (one file per Grid) and creates a .mat database 
% with all Power Flow result
%   Author(s): P. Gassler
%              based on code from R. Brandalik
%              

%% Import NodeRes Files in Matlab memory
if ~Settings.Output_option_raw
    for k_grid = 1 : num_grids
        NodeRes_Name = [Sin_Path_Output,'NodeRes_',SinNameBasic,'_',num2str(instants_per_grid),'inst_',num2str(k_grid),'.txt'];
        if k_grid == 1
            k_SimData = readtable(NodeRes_Name);
            Node_all      = SinInfo.Node.Node_ID;
            Node_occur    = unique(k_SimData.Node_ID);
            Missing_Steps = setdiff(1:instants_per_grid,k_SimData.ResTime);
            Missing_Nodes = setdiff(Node_all,Node_occur);
            NaN_Steps     = repelem(Missing_Steps',numel(Node_occur),1);
            NaN_Table     = array2table(NaN(numel(NaN_Steps),size(k_SimData,2)));
            VarNames   = k_SimData.Properties.VariableNames;
            NaN_Table.Properties.VariableNames = VarNames;
            NaN_Table.ResTime = NaN_Steps;                    
            NaN_Table.Node_ID = repmat(Node_occur,numel(Missing_Steps),1);                        
            k_SimData     = [k_SimData; NaN_Table];                       
            NaN_Table     = array2table(NaN(numel(Missing_Nodes) * instants_per_grid,size(k_SimData,2)));
            NaN_Table.Properties.VariableNames = VarNames;                       
            NaN_Table.ResTime = repmat(1:instants_per_grid,1,numel(Missing_Nodes))';          
            NaN_Table.Node_ID = repelem(Missing_Nodes,instants_per_grid,1);
            k_SimData     = [k_SimData; NaN_Table];
            k_SimData = sortrows(k_SimData,'Node_ID','ascend');
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
            k_SimData         = readtable(NodeRes_Name);
            Node_all      = SinInfo.Node.Node_ID;
            Node_occur     = unique(k_SimData.Node_ID);
            Missing_Steps = setdiff(1:instants_per_grid,k_SimData.ResTime);
            Missing_Nodes = setdiff(Node_all,Node_occur);
            NaN_Steps     = repelem(Missing_Steps',numel(Node_occur),1);
            NaN_Table     = array2table(NaN(numel(NaN_Steps),size(k_SimData,2)));
            VarNames   = k_SimData.Properties.VariableNames;
            NaN_Table.Properties.VariableNames = VarNames;
            NaN_Table.ResTime = NaN_Steps;
            NaN_Table.Node_ID = repmat(unique(k_SimData.Node_ID),numel(Missing_Steps),1);
            k_SimData     = [k_SimData; NaN_Table];
            NaN_Table     = array2table(NaN(numel(Missing_Nodes) * instants_per_grid,size(k_SimData,2)));
            NaN_Table.Properties.VariableNames = VarNames;
            NaN_Table.ResTime = repmat(1:instants_per_grid,1,numel(Missing_Nodes))';
            NaN_Table.Node_ID = repelem(Missing_Nodes,instants_per_grid,1);
            k_SimData     = [k_SimData; NaN_Table];
            k_SimData = sortrows(k_SimData,'Node_ID','ascend');
            k_SimData = sortrows(k_SimData,'ResTime','ascend');
            % ResTime auf Instanz anpassen
            k_SimData.ResTime = (k_grid-1)*instants_per_grid + (k_SimData.ResTime);
            SimData(...
                (k_grid - 1) * num_elements + 1 : ...
                k_grid * num_elements,...
                :) = k_SimData;
        end
    %     fprintf('Das %d. von %d NodeRes Files ist eingelesen worden.\n',k_grid,num_grids);
        disp([NodeRes_Name,' loaded.']);
    end
    clear k_SimData
    SimData = sortrows(SimData,'Node_ID','ascend');
    SimData = sortrows(SimData,'ResTime','ascend');
    
    %% Saving only RAW data in a file and leaving function
    if Settings.Output_option_raw
        Output_Filename = [Output_Name,'_NodeRes_raw.mat'];
        SimData_Filename = [Save_Path,Output_Filename];
        NodeRes_all = SimData;
        SimData = [];
        NodeRes_all_Bytes = whos('NodeRes_all');
        NodeRes_all_Bytes = NodeRes_all_Bytes.bytes; % The variable will just be saved
        if NodeRes_all_Bytes > 2 * 1024^3
            save(SimData_Filename,'NodeRes_all','-v7.3');
        else
            save(SimData_Filename,'NodeRes_all');
        end
        return
    % Saving RAW data in a file
    elseif Settings.Output_option_raw
        Output_Filename = [Output_Name,'_NodeRes_raw.mat'];
        SimData_Filename = [Save_Path,Output_Filename];
        NodeRes_all = SimData;
        NodeRes_all_Bytes = whos('NodeRes_all');
        NodeRes_all_Bytes = NodeRes_all_Bytes.bytes; % The variable will just be saved
        if NodeRes_all_Bytes > 2 * 1024^3
            save(SimData_Filename,'NodeRes_all','-v7.3');
        else
            save(SimData_Filename,'NodeRes_all');
        end
        clear NodeRes_all;
    end
    
else
    if isfield(Settings,'Input_Filename')
        SimData_Filename = Settings.Input_Filename;
    else
        Output_Filename = [SinNameBasic,'_NodeRes_raw.mat'];
        SimData_Filename = [Sin_Path_Output,Output_Filename];
    end
    load(SimData_Filename);
    disp([SimData_Filename,' loaded.']);
    SimData = NodeRes_all;
    NodeRes_all = [];
end

%% Deleting ResTime

SimData.ResTime = [];

%% Saving Node Names and IDs

Node_IDs        = unique(SimData.Node_ID);
NodeNames       = cell(numel(Node_IDs),1);  % Initialisierung
NodeVarNames    = cell(numel(Node_IDs),1);
for k = 1 : numel(Node_IDs)
    NodeNames{k} = SinInfo.Node.Name{SinInfo.Node.Node_ID == Node_IDs(k)};
    if (NodeNames{k}(2))=='-'
%         NodeNames{k} = [NodeNames{k}(1),'_',NodeNames{k}(3:end)];
        NodeNames{k} = [NodeNames{k}(1),NodeNames{k}(3:end)];
    end
    NodeVarNames{k} = ['ID',num2str(Node_IDs(k)),'_',NodeNames{k}];
end
Nodes = table;
Nodes.IDs = Node_IDs;
Nodes.Names = NodeNames;

%% Declaration of Database for results classified per Node or per Unit

if Settings.Output_option_per_node_branch
    SimResults_Nodes_per_nodes = struct;
    for k = 1 : numel(Node_IDs)
        SimResults_Nodes_per_nodes.(NodeNames{k}) = table;
    end
end
if Settings.Output_option_per_unit
    SimResults_Nodes_per_units = struct;
    SimResults_Nodes_per_units.Nodes = Nodes;
%     if Settings.T_vector
%         SimResults_Nodes_per_units.Time_Vector = Time_Vector;
%     end
    if Settings.Output_option_Sin_Info
        SimResults_Nodes_per_units.Grid_Info = SinInfo;
    end
end

%% Saving Voltage U_L1

if Settings.Output_option_U
    if Settings.Output_option_per_unit
        U_L1           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            U_L1(:,k) = SimData.U1(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.U_L1 = table;
        SimResults_Nodes_per_units.U_L1 = array2table(U_L1,'VariableNames',NodeVarNames);
        clear U_L1;
    end
    if Settings.Output_option_per_node_branch
        U_L1 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            U_L1 = SimData.U1(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).U_L1 = U_L1;
        end
         clear U_L1;
    end
    SimData.U1 = [];
end

%% Saving Voltage U_L2

if Settings.Output_option_U
    if Settings.Output_option_per_unit
        U_L2           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            U_L2(:,k) = SimData.U2(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.U_L2 = table;
        SimResults_Nodes_per_units.U_L2 = array2table(U_L2,'VariableNames',NodeVarNames);
        clear U_L2;
    end
    if Settings.Output_option_per_node_branch
        U_L2 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            U_L2 = SimData.U2(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).U_L2 = U_L2;
        end
         clear U_L2;
    end
    SimData.U2 = [];
end

%% Saving Voltage U_L3

if Settings.Output_option_U
    if Settings.Output_option_per_unit
        U_L3           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            U_L3(:,k) = SimData.U3(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.U_L3 = table;
        SimResults_Nodes_per_units.U_L3 = array2table(U_L3,'VariableNames',NodeVarNames);
        clear U_L3;
    end
    if Settings.Output_option_per_node_branch
        U_L3 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            U_L3 = SimData.U3(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).U_L3 = U_L3;
        end
         clear U_L3;
    end
    SimData.U3 = [];
end

%% Saving Voltage U_L0

if Settings.Output_option_U
    if Settings.Output_option_per_unit
        U_L0           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            U_L0(:,k) = SimData.Ue(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.U_L0 = table;
        SimResults_Nodes_per_units.U_L0 = array2table(U_L0,'VariableNames',NodeVarNames);
        clear U_L0;
    end
    if Settings.Output_option_per_node_branch
        U_L0 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            U_L0 = SimData.Ue(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).U_L0 = U_L0;
        end
         clear U_L0;
    end
    SimData.Ue = [];
end

%% Saving Power P_L1

if Settings.Output_option_P
    if Settings.Output_option_per_unit
        P_L1           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            P_L1(:,k) = SimData.P1(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.P_L1 = table;
        SimResults_Nodes_per_units.P_L1 = array2table(P_L1,'VariableNames',NodeVarNames);
        clear P_L1;
    end
    if Settings.Output_option_per_node_branch
        P_L1 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            P_L1 = SimData.P1(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).P_L1 = P_L1;
        end
         clear P_L1;
    end
    SimData.P1 = [];
end

%% Saving Power P_L2

if Settings.Output_option_P
    if Settings.Output_option_per_unit
        P_L2           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            P_L2(:,k) = SimData.P2(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.P_L2 = table;
        SimResults_Nodes_per_units.P_L2 = array2table(P_L2,'VariableNames',NodeVarNames);
        clear P_L2;
    end
    if Settings.Output_option_per_node_branch
        P_L2 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            P_L2 = SimData.P2(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).P_L2 = P_L2;
        end
         clear P_L2;
    end
    SimData.P2 = [];
end

%% Saving Power P_L3

if Settings.Output_option_P
    if Settings.Output_option_per_unit
        P_L3           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            P_L3(:,k) = SimData.P3(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.P_L3 = table;
        SimResults_Nodes_per_units.P_L3 = array2table(P_L3,'VariableNames',NodeVarNames);
        clear P_L3;
    end
    if Settings.Output_option_per_node_branch
        P_L3 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            P_L3 = SimData.P3(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).P_L3 = P_L3;
        end
         clear P_L3;
    end
    SimData.P3 = [];
end

%% Saving Power Q_L1

if Settings.Output_option_Q
    if Settings.Output_option_per_unit
        Q_L1           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            Q_L1(:,k) = SimData.Q1(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.Q_L1 = table;
        SimResults_Nodes_per_units.Q_L1 = array2table(Q_L1,'VariableNames',NodeVarNames);
        clear Q_L1;
    end
    if Settings.Output_option_per_node_branch
        Q_L1 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            Q_L1 = SimData.Q1(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).Q_L1 = Q_L1;
        end
         clear Q_L1;
    end
    SimData.Q1 = [];
end

%% Saving Power Q_L2

if Settings.Output_option_Q
    if Settings.Output_option_per_unit
        Q_L2           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            Q_L2(:,k) = SimData.Q2(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.Q_L2 = table;
        SimResults_Nodes_per_units.Q_L2 = array2table(Q_L2,'VariableNames',NodeVarNames);
        clear Q_L2;
    end
    if Settings.Output_option_per_node_branch
        Q_L2 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            Q_L2 = SimData.Q2(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).Q_L2 = Q_L2;
        end
         clear Q_L2;
    end
    SimData.Q2 = [];
end

%% Saving Power Q_L3

if Settings.Output_option_Q
    if Settings.Output_option_per_unit
        Q_L3           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            Q_L3(:,k) = SimData.Q3(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.Q_L3 = table;
        SimResults_Nodes_per_units.Q_L3 = array2table(Q_L3,'VariableNames',NodeVarNames);
        clear Q_L3;
    end
    if Settings.Output_option_per_node_branch
        Q_L3 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            Q_L3 = SimData.Q3(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).Q_L3 = Q_L3;
        end
         clear Q_L3;
    end
    SimData.Q3 = [];
end

%% Saving Power S_L1

if Settings.Output_option_S
    if Settings.Output_option_per_unit
        S_L1           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            S_L1(:,k) = SimData.S1(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.S_L1 = table;
        SimResults_Nodes_per_units.S_L1 = array2table(S_L1,'VariableNames',NodeVarNames);
        clear S_L1;
    end
    if Settings.Output_option_per_node_branch
        S_L1 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            S_L1 = SimData.S1(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).S_L1 = S_L1;
        end
         clear S_L1;
    end
    SimData.S1 = [];
end

%% Saving Power S_L2

if Settings.Output_option_S
    if Settings.Output_option_per_unit
        S_L2           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            S_L2(:,k) = SimData.S2(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.S_L2 = table;
        SimResults_Nodes_per_units.S_L2 = array2table(S_L2,'VariableNames',NodeVarNames);
        clear S_L2;
    end
    if Settings.Output_option_per_node_branch
        S_L2 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            S_L2 = SimData.S2(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).S_L2 = S_L2;
        end
         clear S_L2;
    end
    SimData.S2 = [];
end

%% Saving Power S_L3

if Settings.Output_option_S
    if Settings.Output_option_per_unit
        S_L3           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            S_L3(:,k) = SimData.S3(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.S_L3 = table;
        SimResults_Nodes_per_units.S_L3 = array2table(S_L3,'VariableNames',NodeVarNames);
        clear S_L3;
    end
    if Settings.Output_option_per_node_branch
        S_L3 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            S_L3 = SimData.S3(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).S_L3 = S_L3;
        end
         clear S_L3;
    end
    SimData.S3 = [];
end

%% Saving Power S_L123

if Settings.Output_option_S
    if Settings.Output_option_per_unit
        S_L123           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            S_L123(:,k) = SimData.S(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.S_L123 = table;
        SimResults_Nodes_per_units.S_L123 = array2table(S_L123,'VariableNames',NodeVarNames);
        clear S_L123;
    end
    if Settings.Output_option_per_node_branch
        S_L123 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            S_L123 = SimData.S(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).S_L123 = S_L123;
        end
         clear S_L123;
    end
    SimData.S = [];
end

%% Saving Phi_L1

if Settings.Output_option_phi
    if Settings.Output_option_per_unit
        Phi_L1           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            Phi_L1(:,k) = SimData.phi1(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.Phi_L1 = table;
        SimResults_Nodes_per_units.Phi_L1 = array2table(Phi_L1,'VariableNames',NodeVarNames);
        clear Phi_L1;
    end
    if Settings.Output_option_per_node_branch
        Phi_L1 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            Phi_L1 = SimData.phi1(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).Phi_L1 = Phi_L1;
        end
         clear Phi_L1;
    end
    SimData.phi1 = [];
end

%% Saving Phi_L2

if Settings.Output_option_phi
    if Settings.Output_option_per_unit
        Phi_L2           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            Phi_L2(:,k) = SimData.phi2(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.Phi_L2 = table;
        SimResults_Nodes_per_units.Phi_L2 = array2table(Phi_L2,'VariableNames',NodeVarNames);
        clear Phi_L2;
    end
    if Settings.Output_option_per_node_branch
        Phi_L2 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            Phi_L2 = SimData.phi2(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).Phi_L2 = Phi_L2;
        end
         clear Phi_L2;
    end
    SimData.phi2 = [];
end

%% Saving Phi_L3

if Settings.Output_option_phi
    if Settings.Output_option_per_unit
        Phi_L3           = zeros(instants_per_grid*num_grids,numel(Node_IDs));
        for k = 1 : numel(Node_IDs)
            Phi_L3(:,k) = SimData.phi3(SimData.Node_ID == Node_IDs(k));
        end
        SimResults_Nodes_per_units.Phi_L3 = table;
        SimResults_Nodes_per_units.Phi_L3 = array2table(Phi_L3,'VariableNames',NodeVarNames);
        clear Phi_L3;
    end
    if Settings.Output_option_per_node_branch
        Phi_L3 = zeros(instants_per_grid*num_grids,1);
        for k = 1 : numel(Node_IDs)
            Phi_L3 = SimData.phi3(SimData.Node_ID == Node_IDs(k));
            SimResults_Nodes_per_nodes.(NodeNames{k}).Phi_L3 = Phi_L3;
        end
         clear Phi_L3;
    end
    SimData.phi3 = [];
end

%% Saving the results in .mat files

if Settings.Output_option_per_unit
    Output_Filename = [Output_Name,'_NodeRes_per_units.mat'];
    SimData_Filename = [Save_Path,Output_Filename];
    SimResults_Nodes_per_units_Bytes = whos('SimResults_Nodes_per_units');
    SimResults_Nodes_per_units_Bytes = SimResults_Nodes_per_units_Bytes.bytes; % The variable will just be saved
    if SimResults_Nodes_per_units_Bytes > 2 * 1024^3
        save(SimData_Filename,'SimResults_Nodes_per_units','-v7.3');
    else
        save(SimData_Filename,'SimResults_Nodes_per_units');
    end
    disp([SimData_Filename,' saved.']);
end
if Settings.Output_option_per_node_branch
    Output_Filename = [Output_Name,'_NodeRes_per_nodes.mat'];
    SimData_Filename = [Save_Path,Output_Filename];
    SimResults_Nodes_per_nodes_Bytes = whos('SimResults_Nodes_per_nodes');
    SimResults_Nodes_per_nodes_Bytes = SimResults_Nodes_per_nodes_Bytes.bytes; % The variable will just be saved
    if SimResults_Nodes_per_nodes_Bytes > 2 * 1024^3  
        save(SimData_Filename,'SimResults_Nodes_per_nodes','-v7.3');
    else
        save(SimData_Filename,'SimResults_Nodes_per_nodes');
    end
    disp([SimData_Filename,' saved.']);
end

end