function DB_synth_AAPD = generate_AAPD_LPs(nb_LPs,type,output_type,time_resolution,Date_Time_first,Date_Time__last)
%% Generate load profiles with the Approximate Active Power Distributions (AAPD)  
%
%
% Author(s): P.Gassler

switch type
    case '3P'
        nb_LPs = nb_LPs * 3;
end

if nargin < 3
    output_type = 'PLC_Tool';
end

if nargin < 4
    time_resolution = 10;
end
if nargin < 5
    Date_Time_first =  datetime('01.01.2015 00:00:00','TimeZone','+02:00');
    Date_Time__last =  datetime('31.12.2015 23:50:00','TimeZone','+02:00');
end

Date_Time       = (Date_Time_first:minutes(time_resolution):Date_Time__last);
DB_synth_AAPD = struct;
% AAPD_LP = table;

tan_phi         = tan(acos(0.9)); % cosphi als 0.9 angenommen
% nb_steps = 0;
nb_instants = numel(Date_Time);
% nb_instants = 100;

AAPD_P = zeros(nb_instants,nb_LPs);
AAPD_Q = zeros(nb_instants,nb_LPs);
AAPD_P_buffer = zeros(nb_LPs,nb_instants);
AAPD_Q_buffer = zeros(nb_LPs,nb_instants);
AAPD_P_perm = zeros(nb_LPs);
AAPD_Q_perm = zeros(nb_LPs);

% Generate the AAPDs for nb_LPs load profiles
[AAPD_P_buffer, AAPD_Q_buffer] = Create_Pseudo_Measurements_Loads_Voltage_Diff_RB(nb_LPs, Date_Time, tan_phi);
% Randomly permutate the AAPDs
for k_instant = 1:nb_instants
    perm = randperm(nb_LPs);
    AAPD_P_perm = AAPD_P_buffer(:,k_instant);
    AAPD_Q_perm = AAPD_Q_buffer(:,k_instant);
    AAPD_P(k_instant,:) = AAPD_P_perm(perm);
    AAPD_Q(k_instant,:) = AAPD_Q_perm(perm);
end

% Prepare output
switch output_type
    case 'SCADA'
        disp('TODO');
%         k_LP_3 = 0;
%         for k_LP = 1 : 3 : nb_LPs
%             k_LP_3 = k_LP_3 + 1;
%             AAPD_LP = table;
%             AAPD_LP.P_B_L1_abs = AAPD_P(:,k_LP);
%             AAPD_LP.P_B_L2_abs = AAPD_P(:,k_LP+1);
%             AAPD_LP.P_B_L3_abs = AAPD_P(:,k_LP+2);
%             AAPD_LP.Q_B_L1_abs = AAPD_Q(:,k_LP);
%             AAPD_LP.Q_B_L2_abs = AAPD_Q(:,k_LP+1);
%             AAPD_LP.Q_B_L3_abs = AAPD_Q(:,k_LP+2);
%             AAPD_LP.P_L_L1_abs = zeros(nb_instants,1);
%             AAPD_LP.P_L_L2_abs = zeros(nb_instants,1);
%             AAPD_LP.P_L_L3_abs = zeros(nb_instants,1);
%             AAPD_LP.Q_L_L1_abs = zeros(nb_instants,1);
%             AAPD_LP.Q_L_L2_abs = zeros(nb_instants,1);
%             AAPD_LP.Q_L_L3_abs = zeros(nb_instants,1);
% 
%             fieldname_LP = ['MP_SYNTH_AAPD_',num2str(k_LP_3)];
%             DB_synth_AAPD.(fieldname_LP) = AAPD_LP;
%         end
    case 'PLC_Tool'
        k_LP_3 = 0;
        for k_LP = 1 : nb_LPs
            if ~mod(k_LP-1,3)
                k_LP_3 = k_LP_3 + 1;
                k_L = 1;
            else
                k_L = k_L + 1;
            end
            AAPD_LP = table;
            AAPD_LP.P = AAPD_P(:,k_LP);
            AAPD_LP.Q = AAPD_Q(:,k_LP);
            fieldname_LP = ['MP_AAPD_',num2str(k_LP_3,'%03d'),'L',num2str(k_L)];
            DB_synth_AAPD.(fieldname_LP) = AAPD_LP;
        end
end
end