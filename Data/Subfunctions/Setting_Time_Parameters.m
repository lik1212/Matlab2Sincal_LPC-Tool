function TimeSetup = Setting_Time_Parameters(TimeSetup,Inputs)
%%
%
%
% Author(s): P.Gassler

% cases = [false false false false];
instants_per_grid_max = 5256;
cases(1) = isfield(Inputs,'TimeSetup_First_Moment');
cases(2) = isfield(Inputs,'TimeSetup_Last_Moment');
cases(3) = isfield(Inputs,'TimeSetup_Time_Step');
cases(4) = isfield(Inputs,'TimeSetup_num_of_instants');

if cases == [1 1 1 0]
    TimeSetup.First_Moment = Inputs.TimeSetup_First_Moment;
    TimeSetup.Last_Moment = Inputs.TimeSetup_Last_Moment;
    TimeSetup.Time_Step = Inputs.TimeSetup_Time_Step;
    TimeSetup.Time_Vector(:,1) = TimeSetup.First_Moment :...
        minutes(TimeSetup.Time_Step) : TimeSetup.Last_Moment;
    TimeSetup.num_of_instants = size(TimeSetup.Time_Vector,1);
elseif cases == [1 1 0 1]
    TimeSetup.First_Moment = Inputs.TimeSetup_First_Moment;
    TimeSetup.Last_Moment = Inputs.TimeSetup_Last_Moment;
    TimeSetup.num_of_instants = Inputs.TimeSetup_num_of_instants;
    TimeSetup.Time_Step = 60 / (TimeSetup.num_of_instants / (365*24)); % Minutes
    TimeSetup.Time_Vector(:,1) = TimeSetup.First_Moment :...
        minutes(TimeSetup.Time_Step) : TimeSetup.Last_Moment;
elseif cases ==  [1 0 1 1]
    TimeSetup.First_Moment = Inputs.TimeSetup_First_Moment;
    TimeSetup.num_of_instants = Inputs.TimeSetup_num_of_instants;
    TimeSetup.Time_Step = Inputs.TimeSetup_Time_Step;
    TimeSetup.Last_Moment = TimeSetup.First_Moment + minutes(TimeSetup.Time_Step) * (TimeSetup.num_of_instants-1);
    TimeSetup.Time_Vector(:,1) = TimeSetup.First_Moment :...
        minutes(TimeSetup.Time_Step) : TimeSetup.Last_Moment;
elseif cases ==  [0 1 1 1]
    TimeSetup.Last_Moment = Inputs.TimeSetup_Last_Moment;
    TimeSetup.num_of_instants = Inputs.TimeSetup_num_of_instants;
    TimeSetup.Time_Step = Inputs.TimeSetup_Time_Step;
    TimeSetup.First_Moment = TimeSetup.Last_Moment - minutes(TimeSetup.Time_Step) * (TimeSetup.num_of_instants-1);
    TimeSetup.Time_Vector(:,1) = TimeSetup.First_Moment :...
        minutes(TimeSetup.Time_Step) : TimeSetup.Last_Moment;
end

if isfield(Inputs,'TimeSetup_instants_per_grid_ratio')
    TimeSetup.instants_per_grid = ceil(instants_per_grid_max * Inputs.TimeSetup_instants_per_grid_ratio);
else
    TimeSetup.instants_per_grid = instants_per_grid_max;
end


% TimeSetup_Output = TimeSetup;

end