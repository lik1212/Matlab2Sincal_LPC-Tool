% function LPC_Tool_GUI_Output(f)
%
%   % (TODO: Implement in future)
%
%

%%
if ishandle(findobj('type','figure','Tag','LPC_Tool_Output'))
    figure(findobj('type','figure','Tag','LPC_Tool_Output'))
    return
end

f.Output_Win.figure = figure(...
    'Name','LPC Tool - Output Power Flow results',...
    'NumberTitle','off','Tag','LPC_Tool_Output',...
    'Toolbar','none',...
    'MenuBar','none',...
    'Resize', 'off',...
    'Units','pixels',...
    'Color',[0.9 0.9 0.9],...
    'Position',[800 600 500 400],...
    'Visible','off');
% set(h.Netze.figure,'CloseRequestFcn',{@CloseRequest_Netze,getappdata(h.Menu.figure,'GUI_Enable'),h})
% movegui(f.Output_Win.figure,'north');


f.Output_Win.uibuttongroup_select_raw_data = ...
    uibuttongroup(...
    'Units',            'normalized',...
    'Position',         [0.02 0.86 0.96 0.12],...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Title',            'Select type of Output (Raw data only or sorted data)',...
    'FontUnits',        'pixels',...
    'FontSize',         12,...
    'TitlePosition',    'lefttop'...
    );

f.Output_Win.radiobutton_raw_data = ...
    uicontrol(f.Output_Win.uibuttongroup_select_raw_data,...
    'style',        'radiobutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.38 0.32 0.4],...
    'String',       'RAW data',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.radiobutton_output_data = ...
    uicontrol(f.Output_Win.uibuttongroup_select_raw_data,...
    'style',        'radiobutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.22 0.38 0.32 0.4],...
    'String',       'Process data',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       0....
    );

f.Output_Win.checkbox_select_raw_only = ...
    uicontrol(f.Output_Win.uibuttongroup_select_raw_data,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.44 0.38 0.32 0.4],...
    'String',       'RAW Only',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       0....
    );

f.Output_Win.uibuttongroup_select_node_branch = ...
    uibuttongroup(...
    'Units',            'normalized',...
    'Position',         [0.02 0.74 0.96 0.12],...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Title',            'Choose data to output',...
    'FontUnits',        'pixels',...
    'FontSize',         12,...
    'TitlePosition',    'lefttop'...
    );

f.Output_Win.radiobutton_generate_nodes = ...
    uicontrol(f.Output_Win.uibuttongroup_select_node_branch,...
    'style',        'radiobutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.3 0.32 0.52],...
    'String',       'Nodes',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       0....
    );

f.Output_Win.radiobutton_generate_branches = ...
    uicontrol(f.Output_Win.uibuttongroup_select_node_branch,...
    'style',        'radiobutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.22 0.3 0.32 0.52],...
    'String',       'Branches',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       0....
    );

f.Output_Win.radiobutton_generate_nodes_branches_both = ...
    uicontrol(f.Output_Win.uibuttongroup_select_node_branch,...
    'style',        'radiobutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.44 0.3 0.32 0.52],...
    'String',       'Both',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.uibuttongroup_grid_info = ...
    uibuttongroup(...
    'Units',            'normalized',...
    'Position',         [0.02 0.54 0.96 0.2],...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Title',            'Setup Grid information',...
    'FontUnits',        'pixels',...
    'FontSize',         12,...
    'TitlePosition',    'lefttop'...
    );

f.Output_Win.radiobutton_sim_details = ...
    uicontrol(f.Output_Win.uibuttongroup_grid_info,...
    'style',        'radiobutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.54 0.32 0.26],...
    'String',       'Sim Details',...
    'FontUnits',    'pixels',...
    'FontSize',     12....
    );

f.Output_Win.radiobutton_grid_info_manual = ...
    uicontrol(f.Output_Win.uibuttongroup_grid_info,...
    'style',        'radiobutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.22 0.54 0.32 0.26],...
    'String',       'Manual',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'Value',        0.,...
    'Enable',       'off'...
    );

f.Output_Win.text_grid_info_manual_nb_grids = ...
    uicontrol(f.Output_Win.uibuttongroup_grid_info,...
    'style',        'text',...
    'Units',        'normalized',...
    'BackgroundColor',  f.Output_Win.figure.Color,...
    'Position',     [0.38 0.53 0.18 0.24],...
    'String',       'Num Grids:',...
    'FontUnits',    'pixels',...
    'FontSize',     12....
    );

f.Output_Win.edit_grid_info_manual_nb_grids = ...
    uicontrol(f.Output_Win.uibuttongroup_grid_info,...
    'style',        'edit',...
    'Units',        'normalized',...
    'BackgroundColor',  [1 1 1],...
    'Position',     [0.54 0.53 0.12 0.34],...
    'String',       '10',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'Enable',       'off'...
    );

f.Output_Win.text_grid_info_manual_instants_grid = ...
    uicontrol(f.Output_Win.uibuttongroup_grid_info,...
    'style',        'text',...
    'Units',        'normalized',...
    'BackgroundColor',  f.Output_Win.figure.Color,...
    'Position',     [0.66 0.53 0.14 0.24],...
    'String',       'Instants:',...
    'FontUnits',    'pixels',...
    'FontSize',     12....
    );

f.Output_Win.edit_grid_info_manual_instants_grid = ...
    uicontrol(f.Output_Win.uibuttongroup_grid_info,...
    'style',        'edit',...
    'Units',        'normalized',...
    'Backgroundcolor',  [1 1 1],...
    'Position',     [0.8 0.53 0.16 0.34],...
    'String',       '5256',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'Enable',       'off'...
    );

f.Output_Win.pushbutton_input_path_SimDetails = ...
    uicontrol(f.Output_Win.uibuttongroup_grid_info,...
    'style',        'pushbutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.05 0.28 0.34],...
    'String',       'Select SimDetails',...
    'FontUnits',    'pixels',...
    'FontSize',     12....
    );


f.Output_Win.edit_input_path_SimDetails = ...
    uicontrol(f.Output_Win.uibuttongroup_grid_info,...
    'style',        'edit',...
    'Units',        'normalized',...
    'BackgroundColor',  [1 1 1],...
    'Position',     [0.32 0.05 0.66 0.34],...
    'String',       'select file',...
    'FontUnits',    'pixels',...
    'Value',        1,...
    'FontSize',     12....
    );

f.Output_Win.pushbutton_input_path = ...
    uicontrol(...
    'style',        'pushbutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.46 0.28 0.06],...
    'String',       'Select File/Folder',...
    'FontUnits',    'pixels',...
    'Enable',       'off',...
    'FontSize',     12....
    );

f.Output_Win.edit_input_path = ...
    uicontrol(...
    'style',        'edit',...
    'Units',        'normalized',...
    'BackgroundColor',  [1 1 1],...
    'Position',     [0.32 0.46 0.66 0.06],...
    'String',       'select file',...
    'FontUnits',    'pixels',...
    'Enable',       'off',...
    'FontSize',     12....
    );

f.Output_Win.uipanel_output_data_selection = ...
    uipanel(...
    'Units',            'normalized',...
    'Position',         [0.02 0.18 0.96 0.28],...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Title',            'Select output data',...
    'FontUnits',        'pixels',...
    'FontSize',         12,... 
    'TitlePosition',    'lefttop'...
    );

f.Output_Win.checkbox_output_data_selection_U = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.7 0.1 0.2],...
    'String',       'U',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );


f.Output_Win.checkbox_output_data_selection_P = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.13 0.7 0.1 0.2],...
    'String',       'P',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_Q = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.24 0.7 0.1 0.2],...
    'String',       'Q',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_S = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.35 0.7 0.1 0.2],...
    'String',       'S',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_Phi = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.46 0.7 0.1 0.2],...
    'String',       'Phi',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_Sin_Info = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.6 0.7 0.3 0.2],...
    'String',       'SinInfo',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_raw = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.8 0.7 0.3 0.2],...
    'String',       'RAW data',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_I = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.45 0.1 0.2],...
    'String',       'I',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_P_flow = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.13 0.45 0.2 0.2],...
    'String',       'P_flow',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_Q_flow = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.28 0.45 0.2 0.2],...
    'String',       'Q_flow',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );
f.Output_Win.checkbox_output_data_selection_S_flow = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.43 0.45 0.2 0.2],...
    'String',       'S_flow',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_T_Vector = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.7 0.45 0.3 0.2],...
    'String',       'TimeVector',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_delete_temp_files = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.18 0.4 0.2],...
    'String',       'Delete temp files',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       0....
    );

f.Output_Win.checkbox_output_data_selection_per_node_branch = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.30 0.18 0.6 0.2],...
    'String',       'Results per Node/Branch',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.checkbox_output_data_selection_per_unit = ...
    uicontrol(f.Output_Win.uipanel_output_data_selection,...
    'style',        'checkbox',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.7 0.18 0.4 0.2],...
    'String',       'Results per Unit',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       1....
    );

f.Output_Win.pushbutton_start_processing = ...
    uicontrol(...
    'style',        'pushbutton',...
    'Units',        'normalized',...
    'Backgroundcolor',  f.Output_Win.figure.Color,...
    'Position',     [0.02 0.02 0.28 0.08],...
    'String',       'Generate Output',...
    'FontUnits',    'pixels',...
    'FontSize',     12.,...
    'value',       0....
    );


%% Set Callback Functions

set(f.Output_Win.pushbutton_start_processing,'Callback',{@Start_Output_Processing,f});
set(f.Output_Win.pushbutton_input_path,'Callback',{@Select_Input_File,f});
set(f.Output_Win.radiobutton_grid_info_manual,'Callback',{@Set_GridInfo,f});
set(f.Output_Win.radiobutton_sim_details,'Callback',{@Set_GridInfo,f});
set(f.Output_Win.pushbutton_input_path_SimDetails,'Callback',{@Select_SimDetails_File,f});
set(f.Output_Win.radiobutton_output_data,'Callback',{@Set_Output_Typ,f});
set(f.Output_Win.radiobutton_raw_data,'Callback',{@Set_Output_Typ,f});
set(f.Output_Win.checkbox_select_raw_only,'Callback',{@Set_Output_Typ,f});
% set(,'Callback',{@,f});
% set(,'Callback',{@,f});
% set(,'Callback',{@,f});
% set(,'Callback',{@,f});
% set(,'Callback',{@,f});
% set(,'Callback',{@,f});

f.Output_Win.figure.Visible = 'on';


end

%% Definition of Callback Functions

function Set_Output_Typ(~,~,f)

if f.Output_Win.radiobutton_output_data.Value == 1
    f.Output_Win.checkbox_select_raw_only.Enable = 'off';
    f.Output_Win.radiobutton_grid_info_manual.Enable = 'on';
    f.Output_Win.checkbox_output_data_selection_raw.Enable = 'off';
    f.Output_Win.checkbox_output_data_selection_delete_temp_files.Enable = 'off';
    f.Output_Win.checkbox_output_data_selection_T_Vector.Enable = 'on';
    f.Output_Win.checkbox_output_data_selection_per_node_branch.Enable = 'on';
    f.Output_Win.checkbox_output_data_selection_per_unit.Enable = 'on';
    f.Output_Win.checkbox_output_data_selection_Sin_Info.Enable = 'on';
elseif f.Output_Win.radiobutton_raw_data.Value == 1
    f.Output_Win.checkbox_select_raw_only.Enable = 'on';
    f.Output_Win.radiobutton_grid_info_manual.Value = 0;
    f.Output_Win.radiobutton_grid_info_manual.Enable = 'off';
    f.Output_Win.radiobutton_sim_details.Value = 1;
    f.Output_Win.pushbutton_input_path_SimDetails.Enable = 'on';
    f.Output_Win.edit_input_path_SimDetails.Enable = 'on';
    f.Output_Win.edit_grid_info_manual_nb_grids.Enable = 'off';
    f.Output_Win.edit_grid_info_manual_instants_grid.Enable = 'off';
    f.Output_Win.checkbox_output_data_selection_raw.Enable = 'on';
    f.Output_Win.checkbox_output_data_selection_delete_temp_files.Enable = 'on';
    if f.Output_Win.checkbox_select_raw_only.Value == 1
        f.Output_Win.checkbox_output_data_selection_T_Vector.Enable = 'off';
        f.Output_Win.checkbox_output_data_selection_per_node_branch.Enable = 'off';
        f.Output_Win.checkbox_output_data_selection_per_unit.Enable = 'off';
        f.Output_Win.checkbox_output_data_selection_Sin_Info.Enable = 'off';
        f.Output_Win.checkbox_output_data_selection_raw.Enable = 'off';
    else
        f.Output_Win.checkbox_output_data_selection_T_Vector.Enable = 'on';
        f.Output_Win.checkbox_output_data_selection_per_node_branch.Enable = 'on';
        f.Output_Win.checkbox_output_data_selection_per_unit.Enable = 'on';
        f.Output_Win.checkbox_output_data_selection_Sin_Info.Enable = 'on';
        f.Output_Win.checkbox_output_data_selection_raw.Enable = 'on';
    end
end
end

function Set_GridInfo(~,~,f)

if f.Output_Win.radiobutton_grid_info_manual.Value == 1
    f.Output_Win.pushbutton_input_path_SimDetails.Enable = 'off';
    f.Output_Win.edit_input_path_SimDetails.Enable = 'off';
    f.Output_Win.edit_grid_info_manual_nb_grids.Enable = 'on';
    f.Output_Win.edit_grid_info_manual_instants_grid.Enable = 'on';
    f.Output_Win.pushbutton_input_path.Enable = 'on';
    f.Output_Win.edit_input_path.Enable = 'on';
elseif f.Output_Win.radiobutton_sim_details.Value == 1
    f.Output_Win.pushbutton_input_path_SimDetails.Enable = 'on';
    f.Output_Win.edit_input_path_SimDetails.Enable = 'on';
    f.Output_Win.edit_grid_info_manual_nb_grids.Enable = 'off';
    f.Output_Win.edit_grid_info_manual_instants_grid.Enable = 'off';
    f.Output_Win.pushbutton_input_path.Enable = 'off';
    f.Output_Win.edit_input_path.Enable = 'off';
end

end

function Select_SimDetails_File(~,~,f)

if isfield(f,'Inputs')
    [filename,path,~] = uigetfile('*.mat','Select SimDetails file',f.Inputs.Outputs_Path);
    if filename
        f.Output_Win.edit_input_path_SimDetails.String = [path,filename];
    end
else
    [filename,path,~] = uigetfile('*.mat','Select SimDetails file');
    if filename
        f.Output_Win.edit_input_path_SimDetails.String = [path,filename];
    end
end

end


function Select_Input_File(~,~,f)

if f.Output_Win.radiobutton_raw_data.Value == 1
    Path = uigetdir('','Select Path for NodeRes/BranchRes .txt files');
    if Path ~= 0
        if Path(end) ~= '\'
        	f.Output_Win.edit_input_path.String = [Path,'\'];
        else
            f.Output_Win.edit_input_path.String = Path;
        end
    end
elseif f.Output_Win.radiobutton_output_data.Value == 1
    [filename,path,~] = uigetfile('*.mat','Select NodeRes and/or BranchRes file');
%         [f.Main_Win.edit_generate_output_select_path.String,'_NodeRes_raw.mat']);
    if filename ~= 0
        f.Output_Win.edit_input_path.String = [path,filename];
    end
end


end

function Start_Output_Processing(~,~,f)

%% Set Output options
Output_options.Output_option_U = logical(f.Output_Win.checkbox_output_data_selection_U.Value);
Output_options.Output_option_P = logical(f.Output_Win.checkbox_output_data_selection_P.Value);
Output_options.Output_option_Q = logical(f.Output_Win.checkbox_output_data_selection_Q.Value);
Output_options.Output_option_S = logical(f.Output_Win.checkbox_output_data_selection_S.Value);
Output_options.Output_option_phi = logical(f.Output_Win.checkbox_output_data_selection_Phi.Value);
Output_options.Output_option_I = logical(f.Output_Win.checkbox_output_data_selection_I.Value);
Output_options.Output_option_P_flow = logical(f.Output_Win.checkbox_output_data_selection_P_flow.Value);
Output_options.Output_option_Q_flow = logical(f.Output_Win.checkbox_output_data_selection_Q_flow.Value);
Output_options.Output_option_S_flow = logical(f.Output_Win.checkbox_output_data_selection_S_flow.Value);
Output_options.Output_option_T_vector = logical(f.Output_Win.checkbox_output_data_selection_T_Vector.Value);
Output_options.Output_option_Sin_Info = logical(f.Output_Win.checkbox_output_data_selection_Sin_Info.Value);
Output_options.Output_option_raw = logical(f.Output_Win.checkbox_output_data_selection_raw.Value);
Output_options.Output_option_raw_only = logical(f.Output_Win.checkbox_select_raw_only.Value);
Output_options.Output_option_per_node_branch = logical(f.Output_Win.checkbox_output_data_selection_per_node_branch.Value);
Output_options.Output_option_per_unit = logical(f.Output_Win.checkbox_output_data_selection_per_unit.Value);
Output_options.Raw_generated = logical(f.Output_Win.radiobutton_output_data.Value);


if f.Output_Win.radiobutton_sim_details.Value == 1
    load(f.Output_Win.edit_input_path_SimDetails.String);
    instants_per_grid = SimDetails.instants_per_grid;
    num_grids = SimDetails.num_grids;
    Time_Vector = SimDetails.Time_Vector;
    SinInfo = SimDetails.SinInfo;
    Output_Name = SimDetails.Output_Name;
    [Sin_Path_Output,~,~] = fileparts(f.Output_Win.edit_input_path_SimDetails.String);
    if Sin_Path_Output(end) ~= '\'
        Sin_Path_Output = [Sin_Path_Output,'\'];
    end
    Save_Path = Sin_Path_Output;
    if isfield(SimDetails,'Output_content')
        Output_options.U = Output_options.U & SimDetails.Output_content.U;
        Output_options.P = Output_options.P & SimDetails.Output_content.P;
        Output_options.Q = Output_options.Q & SimDetails.Output_content.Q;
        Output_options.S = Output_options.S & SimDetails.Output_content.S;
        Output_options.phi = Output_options.phi & SimDetails.Output_content.phi;
        Output_options.I = Output_options.I & SimDetails.Output_content.I;
        Output_options.P_flow = Output_options.P_flow & SimDetails.Output_content.P_flow;
        Output_options.Q_flow = Output_options.Q_flow & SimDetails.Output_content.Q_flow;
        Output_options.S_flow = Output_options.S_flow & SimDetails.Output_content.S_flow;
%         Output_options.T_vector = Output_options.T_vector & SimDetails.Output_content.T_vector;
%         Output_options.Output_option_Sin_Info = Output_options.Sin_Info & SimDetails.Output_content.Sin_Info;
%         Output_options.Raw = 
%         Output_options.Raw_only =
%         Output_options.Output_option_per_node_branch = 
%         Output_options.Unit =
%         Output_options.Raw_generated = Output_options.U & SimDetails.Output_content.U;
    end
elseif f.Output_Win.radiobutton_grid_info_manual.Value == 1
    instants_per_grid = str2num(f.Output_Win.edit_grid_info_manual_instants_grid.String);
    num_grids = str2num(f.Output_Win.edit_grid_info_manual_nb_grids.String);
    Time_Vector = [];
%     SinInfo = SimDetails.SinInfo;
    load('SinInfo.mat');
    [Path,Filename,ext] = fileparts(f.Output_Win.edit_input_path.String);
    if Path(end) ~= '\'
        Path = [Path,'\'];
    end
    Output_options.Input_Filename = f.Output_Win.edit_input_path.String;
    Save_Path = Path;
    Sin_Path_Output = Path;
    Output_Name = Filename;
end

if f.Output_Win.radiobutton_generate_nodes.Value == 1
    %Start the Output process of data
    Output_read_NodeRes(Save_Path,Sin_Path_Output,Output_Name,instants_per_grid,num_grids,Time_Vector,SinInfo,Output_Name,Output_options);
elseif f.Output_Win.radiobutton_generate_branches.Value == 1
    %Start the Output process of data
    Output_read_BranchRes(Save_Path,Sin_Path_Output,Output_Name,instants_per_grid,num_grids,Time_Vector,SinInfo,Output_Name,Output_options);
elseif f.Output_Win.radiobutton_generate_nodes_branches_both.Value == 1
    %Start the Output process of data
    Output_read_NodeRes(Save_Path,Sin_Path_Output,Output_Name,instants_per_grid,num_grids,Time_Vector,SinInfo,Output_Name,Output_options);
    Output_read_BranchRes(Save_Path,Sin_Path_Output,Output_Name,instants_per_grid,num_grids,Time_Vector,SinInfo,Output_Name,Output_options);
end

if ~Output_options.Raw_generated && logical(f.Output_Win.checkbox_output_data_selection_delete_temp_files.Value)
    if logical(f.Output_Win.radiobutton_generate_nodes.Value) || logical(f.Output_Win.radiobutton_generate_nodes_branches_both.Value)
        for k = 1: num_grids
            NodeRes_Name = [Sin_Path_Output,'NodeRes_',Output_Name,'_',num2str(instants_per_grid),'inst_',num2str(k),'.txt'];
            delete(NodeRes_Name);
            disp([NodeRes_Name,' file removed']);
        end
    end
    if logical(f.Output_Win.radiobutton_generate_branches.Value) || logical(f.Output_Win.radiobutton_generate_nodes_branches_both.Value)
        for k = 1: num_grids
            BranchRes_Name = [Sin_Path_Output,'BranchRes_',Output_Name,'_',num2str(instants_per_grid),'inst_',num2str(k),'.txt'];
            delete(BranchRes_Name);
            disp([BranchRes_Name,' file removed']);
        end
    end
end
disp('Processing of output data successfully done!');

end