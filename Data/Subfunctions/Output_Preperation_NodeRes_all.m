function Output_Preperation_NodeRes_all(Sin_PathOutput,Anzahl_Instanz)
%OUTPUT_PREPERATION Summary of this function goes here
%   Detailed explanation goes here
%% Einstellungen

FolderContent = dir(Sin_PathOutput);
FolderContent = struct2table(FolderContent);

FileNames = FolderContent.name(cellfun(@(x) ~isempty(x), strfind(FolderContent.name,'NodeRes')));
NodeRes_Name = FileNames{1}(1:end-5); % "-5" to delete "1.txt"

Anzahl_Files        = numel(FileNames);

%% NodeRes einlesen

for k = 1 : Anzahl_Files
    if k == 1
        k_NodeRes = readtable([Sin_PathOutput,NodeRes_Name,num2str(k)]);
        VarNames   = k_NodeRes.Properties.VariableNames;
        num_Zeilen = size(k_NodeRes,1);
        NodeRes_all   = array2table(zeros(...
            num_Zeilen*Anzahl_Files,...
            size(k_NodeRes,2)));
        NodeRes_all.Properties.VariableNames = VarNames;
        % Daten zusammenfassen
        NodeRes_all(...
            (k - 1) * num_Zeilen + 1 : ...
            k * num_Zeilen,...
            :) = k_NodeRes;
    else
        k_NodeRes         = readtable([Sin_PathOutput,NodeRes_Name,num2str(k)]);
        % ResTime auf Instanz anpassen
        k_NodeRes.ResTime = (k-1)*Anzahl_Instanz + (k_NodeRes.ResTime);
        NodeRes_all(...
            (k - 1) * num_Zeilen + 1 : ...
            k * num_Zeilen,...
            :) = k_NodeRes;
    end
    fprintf('Das %d. von %d NodeRes Files ist eingelesen worden.\n',k,Anzahl_Files);
end
clear k_SimDaten
NodeRes_all         = sortrows(NodeRes_all,'Node_ID','ascend');
NodeRes_all         = sortrows(NodeRes_all,'ResTime','ascend'); %#ok<NASGU> File to be saved

save([Sin_PathOutput,'NodeRes_all'],'NodeRes_all');

end
