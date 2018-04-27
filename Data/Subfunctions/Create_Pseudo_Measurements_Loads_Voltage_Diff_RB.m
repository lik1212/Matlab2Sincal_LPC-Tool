% function [AAPD_P, AAPD_Q] = Create_Pseudo_Measurements_Loads_Voltage_Diff_RB(Num_Loads, Date_Time, tan_phi)
%
%   % (TODO: Implement in future)
%   Author(s): P. Gassler,
%              R. Brandalik

%% Position vectors

Date_Time_Winter =      ...
    Date_Time   <   datetime('21.03.2015 00:00:00','TimeZone','+02:00') |...
    Date_Time   >=  datetime('31.10.2015 00:00:00','TimeZone','+02:00');
Date_Time_Transition =  ...
    Date_Time   >=  datetime('21.03.2015 00:00:00','TimeZone','+02:00') &...
    Date_Time   <   datetime('15.05.2015 00:00:00','TimeZone','+02:00') |...
    Date_Time   >=  datetime('15.09.2015 00:00:00','TimeZone','+02:00') &...
    Date_Time   <   datetime('31.10.2015 00:00:00','TimeZone','+02:00');
Date_Time_Summer =      ...
    Date_Time   >=  datetime('15.05.2015 00:00:00','TimeZone','+02:00') &...
    Date_Time   <   datetime('15.09.2015 00:00:00','TimeZone','+02:00');

Weekday     = ismember(weekday(Date_Time),2:6);
Saturday    = ismember(weekday(Date_Time),7);
Sunday      = ismember(weekday(Date_Time),1);

%% Initial

AAPD_P    = zeros(Num_Loads,size(Date_Time,2));
Case_pos  = zeros(1,size(Date_Time,2));
num_cases = 12;

%% Get Case position 

% Case 1 -
Case_pos(...
    Date_Time_Summer & ...
    (...
    (Weekday  & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6]    ))  | ...
    (Saturday & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7]  ))  | ...
    (Sunday   & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7,8])))   ...
    ) = 1;

% Case 2 -
Case_pos(...
    Date_Time_Summer & ...
    (...
    (Weekday  & ismember(hour(Date_Time),7:17)))...
    ) = 2;

% Case 3 -
Case_pos(...
    Date_Time_Summer & ...
    (...
    (Weekday  & ismember(hour(Date_Time),18:21)))...
    ) = 3;

% Case 4 -
Case_pos(...
    Date_Time_Summer & ...
    (...
    (Saturday & ismember(hour(Date_Time),8:21                     ))  | ...
    (Sunday   & ismember(hour(Date_Time),[9,10,11,12,13,19,20,21] ))  | ...
    (Sunday   & ismember(hour(Date_Time),14:18                    )))   ...
    ) = 4;

% Case 5 -
Case_pos(...
    Date_Time_Winter & ...
    (...
    (Weekday  & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6]    ))  | ...
    (Saturday & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7]  ))  | ...
    (Sunday   & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7,8])))   ...
    ) = 5;

% Case 6 -
Case_pos(...
    Date_Time_Winter & ...
    (...
    (Weekday  & ismember(hour(Date_Time),7:17)))...
    ) = 6;

% Case 7 -
Case_pos(...
    Date_Time_Winter & ...
    (...
    (Weekday  & ismember(hour(Date_Time),18:21)))...
    ) = 7;

% Case 8 -
Case_pos(...
    Date_Time_Winter & ...
    (...
    (Saturday & ismember(hour(Date_Time),8:21                     ))  | ...
    (Sunday   & ismember(hour(Date_Time),[9,10,11,12,13,19,20,21] ))  | ...
    (Sunday   & ismember(hour(Date_Time),14:18                    )))   ...
    ) = 8;

% Case 9 -
Case_pos(...
    Date_Time_Transition & ...
    (...
    (Weekday  & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6]    ))  | ...
    (Saturday & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7]  ))  | ...
    (Sunday   & ismember(hour(Date_Time),[22,23,0,1,2,3,4,5,6,7,8])))   ...
    ) = 9;

% Case 10 -
Case_pos(...
    Date_Time_Transition & ...
    (...
    (Weekday  & ismember(hour(Date_Time),7:17)))...
    ) = 10;

% Case 11 -
Case_pos(...
    Date_Time_Transition & ...
    (...
    (Weekday  & ismember(hour(Date_Time),18:21)))...
    ) = 11;

% Case 12 -
Case_pos(...
    Date_Time_Transition & ...
    (...
    (Saturday & ismember(hour(Date_Time),8:21                     ))  | ...
    (Sunday   & ismember(hour(Date_Time),[9,10,11,12,13,19,20,21] ))  | ...
    (Sunday   & ismember(hour(Date_Time),14:18                    )))   ...
    ) = 12;


%% Fill AAPD_P

AAPD_P_one = zeros(Num_Loads,num_cases);

for k = 1:num_cases
    switch k
        case 1
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 500*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.1*Num_Loads),k)     = 200*10^-6;
            last_step                                                   = last_step + ceil(0.1*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.175*Num_Loads),k)	= 100*10^-6;
            last_step                                                   = last_step + ceil(0.175*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.275*Num_Loads),k)  	= 50*10^-6;
        case 2
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                   	= 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)	= 500*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.125*Num_Loads),k)	= 200*10^-6;
            last_step                                                   = last_step + ceil(0.125*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)	= 100*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)  	= 50*10^-6;
        case 3
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                    	= 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k) 	= 1000*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.05*Num_Loads),k)  	= 500*10^-6;
            last_step                                                   = last_step + ceil(0.05*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.2*Num_Loads),k)     = 200*10^-6;
            last_step                                                   = last_step + ceil(0.2*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 100*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.175*Num_Loads),k)   = 50*10^-6;
        case 4
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 1000*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 500*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.175*Num_Loads),k)   = 200*10^-6;
            last_step                                                   = last_step + ceil(0.175*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 100*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.2*Num_Loads),k)     = 50*10^-6;
        case 5
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 1000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 500*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.15*Num_Loads),k)    = 200*10^-6;
            last_step                                                   = last_step + ceil(0.15*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.2*Num_Loads),k)     = 100*10^-6;
            last_step                                                   = last_step + ceil(0.2*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 50*10^-6;
        case 6
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 1000*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 500*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.175*Num_Loads),k)   = 200*10^-6;
            last_step                                                   = last_step + ceil(0.175*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 100*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.175*Num_Loads),k)   = 50*10^-6;
        case 7
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 1500*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 1000*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.1*Num_Loads),k)     = 500*10^-6;
            last_step                                                   = last_step + ceil(0.1*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.275*Num_Loads),k)   = 200*10^-6;
            last_step                                                   = last_step + ceil(0.275*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.2*Num_Loads),k)     = 100*10^-6;
            last_step                                                   = last_step + ceil(0.2*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.125*Num_Loads),k)   = 50*10^-6;
        case 8
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 1000*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.075*Num_Loads),k)   = 500*10^-6;
            last_step                                                   = last_step + ceil(0.075*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 200*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 100*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.15*Num_Loads),k)    = 50*10^-6;
        case 9
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 500*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.125*Num_Loads),k)   = 200*10^-6;
            last_step                                                   = last_step + ceil(0.125*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.2*Num_Loads),k)     = 100*10^-6;
            last_step                                                   = last_step + ceil(0.2*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 50*10^-6;
        case 10
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 500*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.15*Num_Loads),k)    = 200*10^-6;
            last_step                                                   = last_step + ceil(0.15*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 100*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.2*Num_Loads),k)     = 50*10^-6;
        case 11
            AAPD_P_one(1:ceil(0.025*Num_Loads),k) = 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.025*Num_Loads),k)   = 1000*10^-6;
            last_step                                                   = last_step + ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.075*Num_Loads),k)   = 500*10^-6;
            last_step                                                   = last_step + ceil(0.075*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.25*Num_Loads),k)    = 200*10^-6;
            last_step                                                   = last_step + ceil(0.25*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 100*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.15*Num_Loads),k)    = 50*10^-6;
        case 12
            AAPD_P_one(1:ceil(0.025*Num_Loads),k)                       = 2000*10^-6;
            last_step                                                   = ceil(0.025*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.05*Num_Loads),k)    = 500*10^-6;
            last_step                                                   = last_step + ceil(0.05*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.2*Num_Loads),k)     = 200*10^-6;
            last_step                                                   = last_step + ceil(0.2*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.225*Num_Loads),k)   = 100*10^-6;
            last_step                                                   = last_step + ceil(0.225*Num_Loads);
            AAPD_P_one(last_step+1:last_step+ceil(0.175*Num_Loads),k)   = 50*10^-6;
    end
    num_case_occure = sum(Case_pos == k);
    AAPD_P(:,Case_pos == k) = repmat(AAPD_P_one(:,k),1,num_case_occure);    
end

% AAPD_P = AAPD_P*(-10^6);
AAPD_P = AAPD_P*(10^3);
AAPD_Q = AAPD_P.*tan_phi;

end
