% load('Fixed_OccupantMatrix.mat');
% filedirectory = pwd;
%Set filename of master Excel file (Note: Currently specified for AC building)
filename = 'Master_Setup_AC_1.5.xlsx';
% % Set initial file directory
% Read in general simulation parameters from Excel setup file
simsettingsrange = 'C4:C10';
[simsettings, simsettingsstring] = xlsread(filename, 1,simsettingsrange);
% Time step
simtimestep = 0;
simtimestep = simsettings(1)/60/24;
% Start time
simstarttime = 0;
simstarttime = datenum(simsettingsstring(1));
% Building type
bldgtype = 0;
bldgtype = simsettings(3);
% Total number of zones
nzones = 0;
nzones = simsettings(4);
% Initial running mean temperature (used as window opening constraint)
trm = 0;
trm = simsettings(5);
% Initialized associated running mean temperature update parameters
OuttempNum = 0;
OuttempDenom = 0;

%% Determine appropriate occupant sensation, acceptability, and morning clothing distributions
% Set individual thermal sensation and acceptability distribution matrices
% by building type (AC/NV)
if bldgtype == 1
    %Thermal sensation (AC)
    postpredmat_sens = csvread('postpredsens_AC.csv');
    %Thermal acceptability (AC)
    postpredmat_accept = csvread('postpredaccept_AC.csv');
else
    %Thermal acceptability (NV)
    postpredmat_sens = csvread('postpredsens_NV.csv');
    %Thermal sensation (NV)
    postpredmat_accept = csvread('postpredaccept_NV.csv');
end

%Set individual morning clothing seasonal distributions and regressions parameters
mornclo_seasonaldistributions = csvread('mclodistribs.csv',1,1);
mornclo_regressionparameters = zeros(5,1);
mornclo_regressionparameters = csvread('mclocoefs.csv',1,1);

%% Initialize output file for tracking individual occupant outcomes (optional)
fid = fopen('individual_diagnostics.txt','wt');
fclose(fid);
diagnosticsformat = [repmat('%f ',1,32) '\n'];

% Set random seed
randomseedinit = randi(10000);
randomseed = randi(10000);
% Simulation time following the clock
SimulationTime = 0;
SimulationTime = simstarttime+clock/86400.0;
% Starting season based on simulation start time
SeasonStartMat = DetermineSeason(simstarttime);
SeasonStart = SeasonStartMat(1);
% Starting Day
Day = 0;
Day = SimulationTime - mod(SimulationTime,1);
% Initialize previous day tracker
DayPrev = Day;
% Simulation year (use to define holiday and daylight savings only *ZC)
YearVec = datevec(simstarttime);
Year = 0;
Year = YearVec(1);
% Holiday and daylight savings times
holidaytimes = zeros(10,1);
holidaytimes = DetermineHolidays(Year)';
daylightsavetimes = DetermineDayLightSavings(Year);
% Initialize a daylight savings time flag as zero
dstind = 0;

% Find holidays/daylight savings settings and determine these times for
% given simulation year
holidaysrange = 'C8:C18';
[dummy,specialdays] = xlsread(filename,2,holidaysrange);
daylightindex = 'Yes';
daylightindex = char(specialdays(11));

% Set general occupancy times (across all occupants)
occtimes = zeros(7,2);
occtimesrange = 'C23:D29';
occtimes = xlsread(filename,2,occtimesrange)/24;

% Define which occupancy modeling scheme will be used
occmodelrange = 'C33:E46';
occmodel = zeros(14,3);
occmodel = xlsread(filename,2,occmodelrange);

% Set time step for simple occupancy model where hourly walkabouts are
% accounted for (if necessary)

if occmodel(1) == 1
    if simtimestep < (60/60/24)
        walkchecktimestep = (simtimestep)/(60/60/24);
    else
        walkchecktimestep = 1;
    end
else
    walkchecktimestep = [];
end

% Import gender information
genderrange = 'C50:C51';
gender = zeros(2,1);
gender = (xlsread(filename,2,genderrange))./100;

% Import information needed to update current clothing levels
closettingsrange = 'C55:C56';
closetting = zeros(2,1);
closetting = xlsread(filename,2,closettingsrange);

% Import metabolic rate calculation information
metcalcsrange = 'C60:C71';
metcalcs = zeros(12,1);
metcalcs = xlsread(filename,2,metcalcsrange);
metcalcs(2:5) = metcalcs(2:5)./100;
commutevec = metcalcs(6:9);

% Import general controls information, set rules matrix
controlsrange = 'C76:K85';
controls = zeros(10,9);
controls = xlsread(filename,2,controlsrange);
RuleVector = controls(:,4);
% Calculate starting comf temperature for Humphreys algorithm (if needed)
if any(RuleVector == 3)
    if trm > 10
        tc = (0.33*(trm) + 18.8) + 273;
    else
        tc = (0.09*(trm) + 22.6) + 273;
    end
else
    tc = [];
end

% Define control constraints for each office type
officecontrolconstraintsrange = 'D91:M99';
officecontrolconstraints = zeros(9,10);
officecontrolconstraints = xlsread(...
    filename,2,officecontrolconstraintsrange);
officecontrolconstraintsslice = officecontrolconstraints(:,1);
officecontrolconstraintsfull = officecontrolconstraints(:,2:10);

% Define personal control constraints
pcontrolconstraintsrange = 'C104:D108';
pcontrolconstraints = zeros(5,2);
pcontrolconstraints = (xlsread(filename,2,pcontrolconstraintsrange))./100;

% Personal device location
persdevicerange = 'C112:C113';
persdeviceloc = zeros(2,1);
persdeviceloc = (xlsread(filename,2,persdevicerange))./100;

% Setup basline EPlus schedules for zones using behavior model

% Baseline occupancy fraction (if using simple occupancy model)
occbaserange = 'C118:Z120';
eplusstdocc = zeros(3,24);
eplusstdocc = (xlsread(filename,2,occbaserange));

% Baseline heating setpoint
thermheatbaserange = 'C123:Z125';
eplushtngbase = zeros(3,24);
eplushtngbase = (xlsread(filename,2,thermheatbaserange));

% Baseline cooling setpoint
thermcoolbaserange = 'C128:Z130';
eplusclngbase = zeros(3,24);
eplusclngbase = (xlsread(filename,2,thermcoolbaserange));

% Seasonal setpoint offsets
tempoffsetsranges = 'C133:D136';
eplustempoffsets = zeros(4,2);
eplustempoffsets = (xlsread(filename,2,tempoffsetsranges));

% Baseline infiltration fraction (for windows)
infiltrationrange = 'C139:Z141';
eplusinfiltration = zeros(3,24);
eplusinfiltration = (xlsread(filename,2,infiltrationrange));

% Initialize number of inputs coming from BCVTB
nbcvtbinputs = 3;
% Initialize BCVTB input vector
% bcvtbvec = [0 0 repmat(zeros(1,nbcvtbinputs),1,nzones)];

% Initialize bcvtb schedule values
Unitmat = [
    0 0 (eplusclngbase(1,1) + eplustempoffsets(SeasonStart,2))...
    (eplushtngbase(1,1) + eplustempoffsets(SeasonStart,1))...
    eplusinfiltration(1,1) eplusstdocc(1,1)];
InitialEPlusScheduleVals = repmat(Unitmat,1,nzones);
EPlusScheduleVals = InitialEPlusScheduleVals;

% Setup group logistic regression parameters for each behavior if this
% behavior rule option is selected in the Excel setup file
if (any((RuleVector >= 2 & RuleVector <=3)) == 1)
    % Initialize strings to use in searching for relevant data on each
    % behavior for the regression
    behaviorstrings = {'Clothing Up','Clothing Down','Drinks',...
        'Walk','Heaters','Fans','Thermostats','Doors','Windows','Blinds'};
    % Initialize regression parameter vector for arrivals
    group_logisticregression_arrive = NaN(10,3);
    % Initialize regression parameter vecor for intermediate times
    group_logisticregression_inter = NaN(10,3);
    
    % Loop through all behaviors and update associated logistic regression
    % parameters (if available)
    for v = 1:10
        % Determine appropriate file name for the given behavior
        
        % Arrival model file name
        filename1 = [behaviorstrings{v} '_gencoefsarrive'];
        % Intermediate model file name
        filename2 = [behaviorstrings{v} '_gencoefsinter'];
        
        % Update office arrival time regression parameters for behavior (if
        % available)
        if (fopen(filename1))~=-1
            group_logisticregression_arrive(v,:) = csvread(filename1,1,1)';
        else
            group_logisticregression_arrive(v,:) = NaN(1,3);
        end
        % Update office intermediate time regression parameters for
        % behavior (if available)
        if (fopen(filename2))~=-1
            group_logisticregression_inter(v,:) = csvread(filename2,1,1)';
        else
            group_logisticregression_inter(v,:) = NaN(1,3);
        end
    end
    
    % Case where logistic regression behavior rule is not selected
else
    group_logisticregression_arrive = [];
    group_logisticregression_inter = [];
end

% Set up static information for individual thermal zones (things that
% don't change or need to be reset at the beginning of each loop)
officecounts = repmat({zeros(1,9)},1,nzones);
officeoccupantcounts = officecontrolconstraintsslice;
zoneconstraints = repmat({zeros(1,9)},1,nzones);
sharedoptions = repmat({zeros(1,3)},1,nzones);
occupantlist_final_sim = repmat({0},1,nzones);

% Loop through each zone to update static information
for z = 1:nzones
    % Import zone by zone information from REQUIRED tab in Excel
    % spreadsheet
    zonesrange1 = [...
        'D' num2str(18+((z-1)*4)) ':' 'U' num2str(18+((z-1)*4))];
    zonesettings = zeros(1,17);
    zonesettings = xlsread(filename, 1,zonesrange1);
    zonesrange2 = [...
        'M' num2str(16+((z-1)*4)) ':' 'U' num2str(16+((z-1)*4))];
    zonesettings2 = zeros(1,9);
    zonesettings2 = xlsread(filename, 1,zonesrange2);
    % Set up office/occupant counts and zone constraints based on
    % information for each zone in REQUIRED tab in Excel
    officecounts{z} = zonesettings(1:9);
    sharedoptions{z}  = zonesettings(15:17);
    zoneconstraints{z} = zonesettings2(1:9);
    % Generate occupant lists for given zone (if there are occupants to
    % generate)
    % occupantlist_final_sim{z} dimension declared (ZC)
    % only one type of room is allowed (ZC)
    occupantlist_final_sim{z} = zeros(max(officecounts{z}),4);
    if max(officecounts{z})>0
        occupantlist_final_sim{z} = GenOccupantList(...
            z,officeoccupantcounts,officecounts{z});
    else
        occupantlist_final_sim{z} = [];
    end
end


%%

rrr=repmat({0},1,6);
vvv2=repmat({[0 0]},1,6);
vvv4=repmat({[0 0 0 0]},1,6);
vvv8=repmat({[0 0 0 0 0 0 0 0]},1,6);
mmm22=repmat({zeros(2,2)},1,6);
mmm25=repmat({zeros(2,5)},1,6);
mmm105=repmat({zeros(10,5)},1,6);
mmm110=repmat({zeros(1,10)},1,6);
mmm210=repmat({zeros(2,10)},1,6);
temp_s = struct('Zone',rrr,'Validate',rrr,'OfficeNum',rrr,...
    'OfficeType',rrr,'OccupantNum',rrr,'Gender',rrr,'CommuteMet',rrr,...
    'OutWalkMet',rrr,'InWalkMet',rrr,'BaseMet',rrr,...
    'CommuteMetDegrade',rrr,'OutWalkMetDegrade',rrr,...
    'InWalkMetDegrade',rrr,'METevent',rrr,'TimeDecay',rrr,...
    'MetabolicRate',rrr,'OccupancyStateVector',vvv2,...
    'OccupancyStateVectorPrevious',vvv2,'InOffice',rrr,...
    'OutofOffice',rrr,'InSaturday',rrr,'InSundHolidays',rrr,...
    'DayStartTimeBase',rrr,'LunchStartTimeBase',rrr,...
    'LunchEndTimeBase',rrr,'DayEndTimeBase',rrr,'DayStartTime',rrr,...
    'LunchStartTime',rrr, 'LunchEndTime',rrr,'DayEndTime',rrr,...
    'SatDayStartTimeBase',rrr,'SatLunchStartTimeBase',rrr,...
    'SatLunchEndTimeBase',rrr,'SatDayEndTimeBase',rrr,...
    'SatDayStartTime',rrr,'SatLunchStartTime',rrr,...
    'SatLunchEndTime',rrr,'SatDayEndTime',rrr,...
    'SHDayStartTimeBase',rrr,'SHLunchStartTimeBase',rrr,...
    'SHLunchEndTimeBase',rrr,'SHDayEndTimeBase',rrr,...
    'SHDayStartTime',rrr,'SHLunchStartTime',rrr,...
    'SHLunchEndTime',rrr,'SHDayEndTime',rrr,...
    'OfficeWalkProb',rrr,'LeavesLunchProb',rrr,...
    'MorningClothing',rrr,'CurrentClothing',rrr,...
    'PersonalConstraints',mmm25,'AcceptabilityVector',vvv8,...
    'PreferenceClass',vvv4,'BehaviorConstraintsMatrix',mmm210,...
    'InitialBehaviorPossibilitiesMatrix',mmm210,...
    'BehaviorPossibilitiesMatrix',mmm210,...
    'InitialBehaviorHierarchyMatrix',mmm210,...
    'BehaviorHierarchyMatrix',mmm210,...
    'InitialBehaviorStatesVector',mmm110,...
    'BehaviorStatesVector',mmm110,...
    'PreviousBehaviorStatesVector',mmm110,...
    'BehaviorConstraintsState',mmm105,...
    'InitialPersonalDeviceLocation',vvv2,'PersonalDeviceLocation',vvv2,...
    'SharedThermNum',rrr,'SharedDoorNum',rrr,'SharedWindowNum',rrr,...
    'SharedBlindNum',rrr,'IndoorEnvironmentVectorBase',vvv4,...
    'IndoorEnvironmentVector',vvv4,'OutdoorEnvironmentVector',vvv2,...
    'PMVdraw',rrr,'PMVact',rrr,'HumphreysPMVact',rrr,'WhichPMVact',rrr,...
    'ExceedWarm',rrr,'ExceedCold',rrr,'MeanProductivity',rrr,...
    'ProductivityCount',rrr,'OccTimeSteps',rrr,'OccPosition',vvv2);

OccupantMatrix=repmat({temp_s},1,nzones);

for i=1:nzones
    temp=size(occupantlist_final_sim{i},1);
    rrr=repmat({0},1,temp);
    vvv2=repmat({[0 0]},1,temp);
    vvv4=repmat({[0 0 0 0]},1,temp);
    vvv8=repmat({[0 0 0 0 0 0 0 0]},1,temp);
    mmm22=repmat({zeros(2,2)},1,temp);
    mmm25=repmat({zeros(2,5)},1,temp);
    mmm105=repmat({zeros(10,5)},1,temp);
    mmm110=repmat({zeros(1,10)},1,temp);
    mmm210=repmat({zeros(2,10)},1,temp);
    
    temp_s = struct('Zone',rrr,'Validate',rrr,'OfficeNum',rrr,...
        'OfficeType',rrr,'OccupantNum',rrr,'Gender',rrr,'CommuteMet',rrr,...
        'OutWalkMet',rrr,'InWalkMet',rrr,'BaseMet',rrr,...
        'CommuteMetDegrade',rrr,'OutWalkMetDegrade',rrr,...
        'InWalkMetDegrade',rrr,'METevent',rrr,'TimeDecay',rrr,...
        'MetabolicRate',rrr,'OccupancyStateVector',vvv2,...
        'OccupancyStateVectorPrevious',vvv2,'InOffice',rrr,...
        'OutofOffice',rrr,'InSaturday',rrr,'InSundHolidays',rrr,...
        'DayStartTimeBase',rrr,'LunchStartTimeBase',rrr,...
        'LunchEndTimeBase',rrr,'DayEndTimeBase',rrr,'DayStartTime',rrr,...
        'LunchStartTime',rrr, 'LunchEndTime',rrr,'DayEndTime',rrr,...
        'SatDayStartTimeBase',rrr,'SatLunchStartTimeBase',rrr,...
        'SatLunchEndTimeBase',rrr,'SatDayEndTimeBase',rrr,...
        'SatDayStartTime',rrr,'SatLunchStartTime',rrr,...
        'SatLunchEndTime',rrr,'SatDayEndTime',rrr,...
        'SHDayStartTimeBase',rrr,'SHLunchStartTimeBase',rrr,...
        'SHLunchEndTimeBase',rrr,'SHDayEndTimeBase',rrr,...
        'SHDayStartTime',rrr,'SHLunchStartTime',rrr,...
        'SHLunchEndTime',rrr,'SHDayEndTime',rrr,...
        'OfficeWalkProb',rrr,'LeavesLunchProb',rrr,...
        'MorningClothing',rrr,'CurrentClothing',rrr,...
        'PersonalConstraints',mmm25,'AcceptabilityVector',vvv8,...
        'PreferenceClass',vvv4,'BehaviorConstraintsMatrix',mmm210,...
        'InitialBehaviorPossibilitiesMatrix',mmm210,...
        'BehaviorPossibilitiesMatrix',mmm210,...
        'InitialBehaviorHierarchyMatrix',mmm210,...
        'BehaviorHierarchyMatrix',mmm210,...
        'InitialBehaviorStatesVector',mmm110,...
        'BehaviorStatesVector',mmm110,...
        'PreviousBehaviorStatesVector',mmm110,...
        'BehaviorConstraintsState',mmm105,...
        'InitialPersonalDeviceLocation',vvv2,'PersonalDeviceLocation',vvv2,...
        'SharedThermNum',rrr,'SharedDoorNum',rrr,'SharedWindowNum',rrr,...
        'SharedBlindNum',rrr,'IndoorEnvironmentVectorBase',vvv4,...
        'IndoorEnvironmentVector',vvv4,'OutdoorEnvironmentVector',vvv2,...
        'PMVdraw',rrr,'PMVact',rrr,'HumphreysPMVact',rrr,'WhichPMVact',rrr,...
        'ExceedWarm',rrr,'ExceedCold',rrr,'MeanProductivity',rrr,...
        'ProductivityCount',rrr,'OccTimeSteps',rrr,'OccPosition',vvv2);
    
    OccupantMatrix{i}=temp_s;
end

for z = 1:nzones
    OccupantMatrix{z} = SetConstantParameters(occupantlist_final_sim{z},...
        mornclo_seasonaldistributions,SeasonStart,sharedoptions,...
        zoneconstraints,officecontrolconstraintsfull,occmodel,...
        controls,pcontrolconstraints,commutevec,metcalcs,gender,...
        simstarttime,persdeviceloc,postpredmat_accept,RuleVector,...
        (randomseedinit*z),z,OccupantMatrix{z});
end

Acc_filename = 'AcceptabilityRangeSummary.xlsx';
simsettingsrange = 'B3:I9';
[simsettings] = xlsread(Acc_filename, 1,simsettingsrange);
fixedZoneRange={[]};
fixedZoneRange{1}(:,1)=simsettings((1:7),1);
fixedZoneRange{1}(:,(2:3))=simsettings((1:7),(2:3));
fixedZoneRange{1}(:,(4:5))=simsettings((1:7),(4:5));
fixedZoneRange{1}(:,(6:7))=simsettings((1:7),(4:5));


for z=1:nzones
    for occ=1:size(occupantlist_final_sim{z},1)
        OccupantMatrix{z}(occ).Gender=fixedZoneRange{z}(occ,1);
        OccupantMatrix{z}(occ).AcceptabilityVector=fixedZoneRange{z}(occ,(2:9));
        OccupantMatrix{z}(occ).PersonalConstraints(1,(1:3))=fixedZoneRange{z}(occ,(10:12));
        for s = 1:4
            if median(OccupantMatrix{z}(occ).AcceptabilityVector(...
                    ((s*2)-1)):1:...
                    OccupantMatrix{z}(occ).AcceptabilityVector(s*2)) <= 0
                OccupantMatrix{z}(occ).PreferenceClass(s) = 0;
            else
                OccupantMatrix{z}(occ).PreferenceClass(s) = 1;
            end
        end
    end
end
Fixed_OccupantMatrix=OccupantMatrix;
% save('Fixed_OccupantMatrix.mat','Fixed_OccupantMatrix')

