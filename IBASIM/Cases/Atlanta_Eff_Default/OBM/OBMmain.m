function OBMmain(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the
%   name of your S-function.

%   Copyright 2003-2018 The MathWorks, Inc.

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C MEX counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 1;
block.NumOutputPorts = 1;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
block.InputPort(1).Dimensions        = 67;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;

% Override output port properties
block.OutputPort(1).Dimensions       = 24;
block.OutputPort(1).DatatypeID  = 0; % double
block.OutputPort(1).Complexity  = 'Real';


% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [0 0];

% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

% block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
% block.RegBlockMethod('InitializeConditions', @InitializeConditions);
% block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
% block.RegBlockMethod('Update', @Update);
% block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C MEX counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
% block.NumDworks = 1;
%
%   block.Dwork(1).Name            = 'x1';
%   block.Dwork(1).Dimensions      = 1;
%   block.Dwork(1).DatatypeID      = 0;      % double
%   block.Dwork(1).Complexity      = 'Real'; % real
%   block.Dwork(1).UsedAsDiscState = true;


%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is
%%                      present in an enabled subsystem configured to reset
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C MEX counterpart: mdlInitializeConditions
%%
function InitializeConditions(block)

%end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this
%%                      is the place to do it.
%%   Required         : No
%%   C MEX counterpart: mdlStart
%%
function Start(block)
block.Dwork(1).Data = 0;

%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C MEX counterpart: mdlOutputs
%%
function Outputs(block)
%% Has been set up 'persisten', 'isempty'; comment some code relative with end time; Using a new simulation time method
persistent OccupantMatrix
persistent init
persistent simtimestep simstarttime bldgtype nzones trm
persistent postpredmat_sens postpredmat_accept
persistent mornclo_seasonaldistributions mornclo_regressionparameters
persistent SeasonStart DayPrev holidaytimes daylightsavetimes dstind
persistent randomseedinit randomseed
persistent OuttempNum OuttempDenom
persistent specialdays daylightindex
persistent occtimes occmodel walkchecktimestep ...
    gender closetting metcalcs commutevec controls ...
    RuleVector tc
persistent officecontrolconstraintsfull pcontrolconstraints ...
    persdeviceloc officecontrolconstraintsslice
persistent eplusstdocc eplushtngbase eplusclngbase eplustempoffsets ...
    eplusinfiltration EPlusScheduleVals
persistent group_logisticregression_arrive group_logisticregression_inter
persistent zoneconstraints sharedoptions occupantlist_final_sim
persistent conn CollName BX BXLabel BXFields start_time recv time_recv
persistent BehaviorInterval DayofYear obmTable timestep ctrlTable zLabels zoneTable zoneSPs GEB_case
global sameTzSPs timestepG tes_case

%% Extrinsic Function
coder.extrinsic('xlsread');
coder.extrinsic('csvread');
coder.extrinsic('datevec');
coder.extrinsic('weekday');
coder.extrinsic('num2str');
coder.extrinsic('datenum');
coder.extrinsic('cell');
coder.extrinsic('cell2struct');
coder.extrinsic('cell2mat');
coder.extrinsic('predict');
%% Input
fmu_input=block.InputPort(1).Data;
clock=fmu_input(1);
O=fmu_input(2:3)';
Office1=fmu_input(4:18)';
NumOcc1=round(fmu_input(19));
Office2=fmu_input(20:34)';
NumOcc2=round(fmu_input(35));
Office3=fmu_input(36:50)';
NumOcc3=round(fmu_input(51));
Office4=fmu_input(52:66)';
NumOcc4=round(fmu_input(67));

if isempty(DayofYear)
    DOY_Table=[28 119 189 238; 365 71 197 183; 30 289 191 177; 2 280 228 240; 9 107 170 203];
    Location=xlsread('settings.csv',1, 'K2');
    Season=xlsread('settings.csv',1, 'B2');
    DayofYear=DOY_Table(Location,Season);
end

if clock>= (DayofYear-1)*86400
%% Declare Variables
PHeatFrac=0;PFanFrac=0;TCool=0;THeat=0;WindFrac=0;OccFrac=0;

% % Set initial file directory
timestep = timestepG;
if isempty(init)
    %% Read the corresponding setup file
    settings=readtable('settings.csv');
    occ_dense=settings.occ_dense(1);
    occ_NGRSave=settings.occ_energysaving(1);
    
    % Load in data you want to use to override the current controls
    zoneSPs = load('zoneSPs.mat');
    
    %Set filename of master Excel file (Note: Currently specified for AC building)
    if occ_dense==1
        filename = 'Master_Setup_AC_dense.xlsx';
    else
        filename = 'Master_Setup_AC.xlsx';
    end
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
%     fid = fopen('individual_diagnostics.txt','wt');
%     fclose(fid);
%     diagnosticsformat = [repmat('%f ',1,32) '\n'];
    
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
    
    % Occupants' behavior interval
    infiltrationrange = 'C143';
    BehaviorInterval = 0;
    BehaviorInterval = (xlsread(filename,2,infiltrationrange));
    
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
    %
    % OccInd = 0;
    init=999;
end
% Simulation time following the clock
SimulationTime = 0;
SimulationTime = simstarttime+clock/86400.0;
% Current season based on simulation start time
SeasonMat = DetermineSeason(SimulationTime);
Season = SeasonMat(1);
% Day of the week
WeekTime = 0;
WeekTime = weekday(SimulationTime);
% Time of day
Day = 0;
Day = SimulationTime - mod(SimulationTime,1);
DayTime = 0;
DayTime = mod(SimulationTime, 1);

% % % Check whether there is individual occupant tracking
% % trackingrange = 'C4';
% % [tracking trackingstring] = xlsread(filename,2,trackingrange);
% % if size(trackingstring,2)>0
% %     trackinginfo = transpose(str2num(char(trackingstring)));
% % else
% %     trackinginfo = trackingstring;
% % end

%%
if isempty(OccupantMatrix)
    rrr=repmat({0},1,6);
    vvv2=repmat({[0 0]},1,6);
    vvv4=repmat({[0 0 0 0]},1,6);
    vvv8=repmat({[0 0 0 0 0 0 0 0]},1,6);
    vvvX=repmat({zeros(1,BehaviorInterval)},1,6);
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
        'ProductivityCount',rrr,'OccTimeSteps',rrr,'OccPosition',vvv2,...
        'OccBehaviorInterval',vvvX);
    
    OccupantMatrix=repmat({temp_s},1,nzones);
    
    for i=1:nzones
        temp=size(occupantlist_final_sim{i},1);
        rrr=repmat({0},1,temp);
        vvv2=repmat({[0 0]},1,temp);
        vvv4=repmat({[0 0 0 0]},1,temp);
        vvv8=repmat({[0 0 0 0 0 0 0 0]},1,temp);
        vvvX=repmat({zeros(1,BehaviorInterval)},1,temp);
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
            'ProductivityCount',rrr,'OccTimeSteps',rrr,'OccPosition',vvv2,...
            'OccBehaviorInterval',vvvX);
        
        OccupantMatrix{i}=temp_s;
    end
    
    if occ_dense==0 && occ_NGRSave==0
        load('Fixed_OccupantMatrix.mat');
    elseif occ_dense==0 && occ_NGRSave==1
        load('Fixed_OccupantMatrix_NGRSave.mat');
    elseif occ_dense==1
        load('Fixed_OccupantMatrix_dense.mat');
    end
    
    for z = 1:nzones
        OccupantMatrix{z} = SetConstantParameters(occupantlist_final_sim{z},...
            mornclo_seasonaldistributions,SeasonStart,sharedoptions,...
            zoneconstraints,officecontrolconstraintsfull,occmodel,...
            controls,pcontrolconstraints,commutevec,metcalcs,gender,...
            simstarttime,persdeviceloc,postpredmat_accept,RuleVector,...
            (randomseedinit*z),z,OccupantMatrix{z});
        for N_occ=1:size(occupantlist_final_sim{z},1)
            OccupantMatrix{z}(N_occ).Gender = Fixed_OccupantMatrix{z}(N_occ).Gender;
            OccupantMatrix{z}(N_occ).AcceptabilityVector = Fixed_OccupantMatrix{z}(N_occ).AcceptabilityVector;
            OccupantMatrix{z}(N_occ).PreferenceClass = Fixed_OccupantMatrix{z}(N_occ).PreferenceClass;
            OccupantMatrix{z}(N_occ).PersonalConstraints = Fixed_OccupantMatrix{z}(N_occ).PersonalConstraints;
            OccupantMatrix{z}(N_occ).CommuteMet = Fixed_OccupantMatrix{z}(N_occ).CommuteMet; % set the fixed commute (initial metabolic rate) (YC 2022/02/11)
        end
    end
end
%%
% Initialize BCVTB input vector

bcvtbveczones = {zeros(1,size(Office1,2)) 0;zeros(1,size(Office2,2)) 0;...
    zeros(1,size(Office3,2)) 0;zeros(1,size(Office4,2)) 0;};
Office = {Office1; Office2; Office3; Office4};

NumOcc = zeros(1,4);
NumOcc = [NumOcc1 NumOcc2 NumOcc3 NumOcc4];
for i=1:nzones
    bcvtbveczones{i,1}=Office{i};
    bcvtbveczones{i,2}=NumOcc(i);
end

OutdoorCondition = [0 0];
OutdoorCondition = O;

% OccbehaviorBanTime means how long the occupants should wait before
% doing new bahvior. 1 means 10mins, 2 means 9 mins, ...., 10 means 1 means.
BehaviorInterval=size(OccupantMatrix{1}(1).OccBehaviorInterval,2);
for ZoneNum = 1:nzones
    for OccNum = 1:size(OccupantMatrix{ZoneNum},2)
        if any(OccupantMatrix{ZoneNum}(OccNum).OccBehaviorInterval==1)
            OccbehaviorBanTime=find(OccupantMatrix{ZoneNum}(OccNum).OccBehaviorInterval==1);
            OccupantMatrix{ZoneNum}(OccNum).OccBehaviorInterval=zeros(1,BehaviorInterval);
            if OccbehaviorBanTime ~=BehaviorInterval
                OccupantMatrix{ZoneNum}(OccNum).OccBehaviorInterval(OccbehaviorBanTime+1)=1;
            end
        end
    end
end

% Initialize holiday flag, if necessary
holidayind = 0;
holidayind = find(holidaytimes(1:10)==Day);

if isempty(holidayind) == 0
    cind = 'Yes';
    cind = char(specialdays(holidayind));
    if  strcmpi(cind(1),'Y') == 1
        holiday = 1;
    else
        holiday = 0;
    end
else
    holiday = 0;
end

% Initialize daylight savings flag, if necessary
daylightsaveend = 0;
if strcmpi(daylightindex(1),'Y')
    daylightsaveend = size(find(daylightsavetimes(2)==Day),1);
    if daylightsaveend == 1 && (abs(DayTime - (2/24))<(5/60/24))
        SimulationTime = SimulationTime + (1/24);
        dstind = 1;
    elseif ((dstind == 0 && ...
            ((Day>=daylightsavetimes(1))...
            && (Day < daylightsavetimes(2))))...
            && (abs(DayTime - (2/24))<(5/60/24)))
        SimulationTime = SimulationTime + (1/24);
        dstind = 1;
    elseif ((dstind == 1 && ...
            ((Day<daylightsavetimes(1))...
            ||(Day >= daylightsavetimes(2)))) && ...
            (abs(DayTime - (2/24))<(5/60/24)))
        SimulationTime = SimulationTime - (1/24);
        dstind = 1;
    end
end

% Reset running mean temperature (and comf. temp if necessary for
% Humphrey's algorithm calculation) at beginning of each day
if (Day~=DayPrev)
    OuttempAvgPrev = OuttempNum/OuttempDenom;
    OuttempNum = 0;
    OuttempDenom = 0;
    trm = ((1-0.8)*OuttempAvgPrev) + (0.8*trm);
    %         if any(RuleVector == 3)
    %             if temprm > 10
    %                 tc = (0.33*(trm) + 18.8) + 273;
    %             else
    %                 tc = (0.09*(trm) + 22.6) + 273;
    %             end
    %         else
    tc = [];
    %         end
end

% Determine general occupancy filter for output reporting (general
% occupancy for output purposes is currently between 8 AM and 6 PM)
if (((WeekTime ~= 1)&&(WeekTime~=7)&&...
        (holiday==0)))&&...
        ((DayTime>((8/24)-(5/60/24)))&&...
        (DayTime<((18/24)+(5/60/24))))
    OccInd = 1;
else
    OccInd = 0;
end

% % Determine whether we are in a simulation time where there is
% % possible occupancy (and thus behavior simulation). Simulation
% % proceeds when we are possibly occupied or it is 6 AM (morning
% % clothing update needed). If so, continue further with
% % behavior simulation steps.
% if ((DayTime >= (occtimes(WeekTime,1)+(simtimestep/3))) && ...
%         (DayTime <= (occtimes(WeekTime,2) + (simtimestep/3))))...
%         || (abs(DayTime - (6/24)) < (5/60/24))
if any([NumOcc1 NumOcc2 NumOcc3 NumOcc4])~=0         
    % Initialize EnergyPlus schedule output
    EPlusScheduleMatrix = zeros(nzones,6);
    
    % Run behavior/comfort simulations for each zone across all
    % agents in the zone
    for f = 1:nzones
        
        % Check whether action should be simulated according to
        % the Humphrey's behavior algorithm (if applicable)
        top = 0;
        toporig = 0;
        humphact = 0;
        % Use the method that callAirflow model to get the local environment
        %         toporig = ((bcvtbveczones{f,1}(1,3)+bcvtbveczones{f,1}(1,4))/2);
        % Use the method that zone environment represent occupant ambient
        % environment
        toporig = ((bcvtbveczones{f,1}(1,1)+bcvtbveczones{f,1}(1,3))/2);
        if (any(RuleVector == 3) == 1)
            top = toporig+273;
            if top > (tc + 2)
                humphact = 1;
            elseif top < (tc - 2)
                humphact = -1;
            else
                humphact = 0;
            end
        else
            humphact = 0;
        end
        
        % Update behavior and comfort states for all occupants
        % given relevant inputs for the current time step
        OccupantMatrix{f} = SetDynamicParameters(...
            OccupantMatrix{f},SimulationTime,occmodel,...
            simtimestep,OutdoorCondition,bcvtbveczones{f,1},bcvtbveczones{f,2},closetting,...
            mornclo_regressionparameters,...
            postpredmat_sens,...
            controls,randomseed,Season,DayTime,WeekTime,Day,...
            holiday,group_logisticregression_inter,...
            group_logisticregression_arrive,RuleVector,...
            eplusstdocc,humphact,walkchecktimestep,trm);
        
        % Every 15 min, renew thermostat setpoint status
        if rem(clock,60*15)==0
            for OccNum_UpdatedTC=1:size(OccupantMatrix{f},2)
                OccupantMatrix{f}(OccNum_UpdatedTC).BehaviorStatesVector(7)=0;
            end
        end
        % Record updated behavior states across all occupants in
        % zone
        
        % Clothing heavy/light state (not sent to EnergyPlus)
        checkbehaviorstates = zeros((size(OccupantMatrix{f},2)),10);
        for i=1:(size(OccupantMatrix{f},2))
            checkbehaviorstates(i,1:10)= OccupantMatrix{f}(i).BehaviorStatesVector(1:10);
        end
        % checkbehaviorstates = cat(...
        % 1,OccupantMatrix{f}.BehaviorStatesVector(1:10));
        clostates =zeros((size(OccupantMatrix{f},2)),1);
        for i=1:(size(OccupantMatrix{f},2))
            clostates(i,1)= OccupantMatrix{f}(i).CurrentClothing(1);
        end
        %                 clostates = [OccupantMatrix{f}.CurrentClothing];
        clostatesdown = clostates(clostates<0.5);
        clostatesup = clostates(clostates>0.7);
        CloUpFrac = ((size(clostatesup,2))/(size(occupantlist_final_sim{f},1)));
        CloDownFrac = ((size(clostatesdown,2))/(size(occupantlist_final_sim{f},1)));
        
        % Occupancy state (sent to EnergyPlus via BCVTB)
        checkoccstates = zeros((size(OccupantMatrix{f},2)),2);
        for i=1:(size(OccupantMatrix{f},2))
            checkoccstates(i,1:2)= OccupantMatrix{f}(i).OccupancyStateVector(1:2);
        end
        %                 checkoccstates = cat(...
        %                     1,OccupantMatrix{f}.OccupancyStateVector);
        OccFrac = (sum(checkoccstates(:,1)==1))/...
            (size(occupantlist_final_sim{f},1));
        
        % Heater on state (sent to EnergyPlus via BCVTB)
        if zoneconstraints{f}(4) ~= 0
            PHeatFrac = (...
                sum(checkbehaviorstates(:,5)==1))/...
                (size(occupantlist_final_sim{f},1));
        else
            PHeatFrac = 0;
        end
        
        % Fan on state (sent to EnergyPlus via BCVTB)
        if zoneconstraints{f}(5) ~= 0
            PFanFrac = (sum(checkbehaviorstates(:,6)==-1))/...
                (size(occupantlist_final_sim{f},1));
        else
            PFanFrac = 0;
        end
        
        % Window open state (sent to EnergyPlus via BCVTB)
        
        % Case without an opening constraint
        if zoneconstraints{f}(8) ~= 0
            WindFrac1 = (sum(checkbehaviorstates(:,9)==-1))/...
                (size(occupantlist_final_sim{f},1));
            % Maximum possible infiltration fraction (infiltration
            % is used as a proxy for window opening in Energy Plus)
            maxfrac = 6.25;
            % Read in a baseline infiltration fraction to add current
            % simulated open fraction to
            dayhour = (floor((DayTime)*24));
            if (holiday == 1) || (WeekTime == 1) % Holidays/Sundays
                basefracwind = eplusinfiltration(3,dayhour+1);
            elseif (WeekTime == 7) % Saturdays
                basefracwind = eplusinfiltration(2,dayhour+1);
            else % Weekdays
                basefracwind = eplusinfiltration(1,dayhour+1);
            end
            % Final windows infiltration fraction
            WindFrac = basefracwind + ...
                ((maxfrac-basefracwind)*(WindFrac1));
            % Case with an opening constraint (no change from base
            % infiltration settings)
        else
            WindFrac1 = 0;
            maxfrac = 6.25;
            dayhour = (floor((DayTime)*24));
            if (holiday == 1) || (WeekTime == 1)
                basefracwind = eplusinfiltration(3,dayhour+1); % Holidays/Sundays
            elseif (WeekTime == 7)
                basefracwind = eplusinfiltration(2,dayhour+1); % Saturdays
            else
                basefracwind = eplusinfiltration(1,dayhour+1); % Weekdays
            end
            WindFrac = basefracwind + ...
                ((maxfrac-basefracwind)*(WindFrac1));
        end
        
        % Zone thermostat state (sent to EnergyPlus via BCVTB)
        
        % Case without a thermostat adjustment constraint
        if zoneconstraints{f}(6) ~= 0
            dayhour = (floor((DayTime)*24));
            % Thermostat is turned UP from baseline
            if max(checkbehaviorstates(:,7)==1)
                if (holiday == 1) || (WeekTime == 1) % Holidays/Sundays
                    TCool = eplusclngbase(3,dayhour+1) + ...
                        (eplustempoffsets(Season,2)) + 1;
                    THeat = eplushtngbase(3,dayhour+1) +  ...
                        (eplustempoffsets(Season,1)) + 1;
                elseif (WeekTime == 7) % Saturdays
                    TCool = eplusclngbase(2,dayhour+1) + ...
                        (eplustempoffsets(Season,2)) + 1;
                    THeat = eplushtngbase(2,dayhour+1) + ...
                        (eplustempoffsets(Season,1)) + 1;
                else % Weekdays
                    TCool = eplusclngbase(1,dayhour+1) + ...
                        (eplustempoffsets(Season,2)) + 1;
                    THeat = eplushtngbase(1,dayhour+1) + ...
                        (eplustempoffsets(Season,1)) + 1;
                end
                % Thermostat is turned DOWN from baseline
            elseif min(checkbehaviorstates(:,7)==-1)
                if (holiday == 1) || (WeekTime == 1) % Holidays/Sundays
                    TCool = eplusclngbase(3,dayhour+1) + ...
                        (eplustempoffsets(Season,2)) - 1;
                    THeat = eplushtngbase(3,dayhour+1) + ...
                        (eplustempoffsets(Season,1)) - 1;
                elseif (WeekTime == 7) % Saturdays
                    TCool = eplusclngbase(2,dayhour+1) + ...
                        (eplustempoffsets(Season,2)) - 1;
                    THeat = eplushtngbase(2,dayhour+1) + ...
                        (eplustempoffsets(Season,1)) - 1;
                else % Weekdays
                    TCool = eplusclngbase(1,dayhour+1) + ...
                        (eplustempoffsets(Season,2)) - 1;
                    THeat = eplushtngbase(1,dayhour+1) + ...
                        (eplustempoffsets(Season,1)) - 1;
                end
                % Thermostat is set at the baseline
            else
                if (holiday == 1) || (WeekTime == 1) % Holidays/Sundays
                    TCool = eplusclngbase(3,dayhour+1) + ...
                        (eplustempoffsets(Season,2));
                    THeat = eplushtngbase(3,dayhour+1) + ...
                        (eplustempoffsets(Season,1));
                elseif (WeekTime == 7) % Saturdays
                    TCool = eplusclngbase(2,dayhour+1) + ...
                        (eplustempoffsets(Season,2));
                    THeat = eplushtngbase(2,dayhour+1) + ...
                        (eplustempoffsets(Season,1));
                else % Weekdays
                    TCool = eplusclngbase(1,dayhour+1) + ...
                        (eplustempoffsets(Season,2));
                    THeat = eplushtngbase(1,dayhour+1) + ...
                        (eplustempoffsets(Season,1));
                end
            end
            % Case with a thermostat adjustment constraint (no change
            % from base thermostat settings)
        else
            dayhour = (floor((DayTime)*24));
            if (holiday == 1) || (WeekTime == 1) % Holidays/Sundays
                TCool = eplusclngbase(3,dayhour+1) + ...
                    (eplustempoffsets(Season,2));
                THeat = eplushtngbase(3,dayhour+1) + ...
                    (eplustempoffsets(Season,1));
            elseif (WeekTime == 7) % Saturdays
                TCool = eplusclngbase(2,dayhour+1) + ...
                    (eplustempoffsets(Season,2));
                THeat = eplushtngbase(2,dayhour+1) + ...
                    (eplustempoffsets(Season,1));
            else % Weekdays
                TCool = eplusclngbase(1,dayhour+1) + ...
                    (eplustempoffsets(Season,2));
                THeat = eplushtngbase(1,dayhour+1) + ...
                    (eplustempoffsets(Season,1));
            end
        end
        
        % Vector of updated EnergyPlus schedules to be transferred
        % via BCVTB
        EPlusScheduleMatrix(f,:) = ...
            [PHeatFrac PFanFrac TCool THeat WindFrac1 OccFrac];
        EPlusScheduleVals = ...
            reshape(...
            EPlusScheduleMatrix',1,numel(EPlusScheduleMatrix));
        
        % If occupancy filter on time series output reporting
        % is 1, update time series outputs
        %         if OccInd == 1;
        %             start=(((f-1)*13)+1);
        %             timeseriesmatzone(timeseriesrow,(start:(start+12))) = ...
        %                 [f Season DayTime OccInd OccFrac CloUpFrac ...
        %                 CloDownFrac PHeatFrac PFanFrac TCool THeat ...
        %                 WindFrac1 toporig];
        %             timeseriesmat{f} = timeseriesmatzone(...
        %                 :,(start:(start+12)));
        %         end
    end
    % Not during an occupancy time; no behavior simulation updates
    % required
else
    % Set to null occupancy as well as to baseline EnergyPlus
    % schedule values
    for v = 1:nzones
        OccupantMatrix{v} = NullOccupancy(OccupantMatrix{v});
    end
    EPlusScheduleVals = repmat(...
        ([0 0 (eplusclngbase(1,1) + eplustempoffsets(Season,2))...
        (eplushtngbase(1,1) + eplustempoffsets(Season,1))...
        eplusinfiltration(1,1) eplusstdocc(1,1)]),1,nzones);
end

% Save number of day
DayPrev = Day;
% Update random seed
randomseed = randomseed + 1;
% Update running mean temperature
OuttempBldg = O(1);
OuttempNum = OuttempNum + OuttempBldg;
OuttempDenom = OuttempDenom + 1;

%% initiate DB connection
timestep = timestepG;
if isempty(conn)
    conn = 1;
    settings=readtable('settings.csv');
    GEB_case = settings.GEB_case(1);
    % database location
    DBName=load('DBLoc.mat').DBName;
    CollName=load('DBLoc.mat').CollName;
    % connect to the database
%%%    conn = mongo('localhost',27017,DBName);
    % behavior labels
    BXLabel={'Pheat_z1_ahu1','Pfan_z1_ahu1','Tz_cspt_z1_ahu1','Tz_hspt_z1_ahu1','WinFrac_z1_ahu1','OccFrac_z1_ahu1',...
        'Pheat_z2_ahu1','Pfan_z2_ahu1','Tz_cspt_z2_ahu1','Tz_hspt_z2_ahu1','WinFrac_z2_ahu1','OccFrac_z2_ahu1',...
        'Pheat_z1_ahu2','Pfan_z1_ahu2','Tz_cspt_z1_ahu2','Tz_hspt_z1_ahu2','WinFrac_z1_ahu2','OccFrac_z1_ahu2',...
        'Pheat_z2_ahu2','Pfan_z2_ahu2','Tz_cspt_z2_ahu2','Tz_hspt_z2_ahu2','WinFrac_z2_ahu2','OccFrac_z2_ahu2'};
    zLabels = {'Tz_cspt_z1_ahu1','Tz_hspt_z1_ahu1',...
               'Tz_cspt_z2_ahu1','Tz_hspt_z2_ahu1',...
               'Tz_cspt_z1_ahu2','Tz_hspt_z1_ahu2',...
               'Tz_cspt_z2_ahu2','Tz_hspt_z2_ahu2'};
    % query command
    BXFields=label2mongofield_find(BXLabel);
    % read recovery settings
% % %     RecvSet=find(conn,CollName,'Query','{"DocType":"RecvSettings"}');
% % %     recv=RecvSet.recv;
% % %     time_recv=RecvSet.time_recv;
    recv = 0;
    time_recv = 420;
    % initialze behavior vector
    BX=zeros(1,length(BXLabel));
    obmTable = OBMTablePass([],BXLabel,timestep,'init');
    % obtain Simulink start time
    current_system = get_param(0, 'CurrentSystem');
    start_time_as_str = get_param(current_system, 'StartTime');
    start_time = str2double(start_time_as_str);
else

end

if (GEB_case == 3)&&(~isempty(tes_case))
    timestep_idx = timestep+239;
else
    timestep_idx = timestep;
end
%% Compute final setpoint (ZC 10/04/2021)
%%%SCS=find(conn,CollName,'Query',['{"Time":',num2str(clock),...
%%%    ',"DocType":"SupvCtrlSig"}']);


ctrlTable = ctrlTablePass([],[],timestep,'get');
SCS = ctrlTable(timestep_idx+1,:);

%%if sameTzSPs == 0
    EPlusScheduleVals(3) = EPlusScheduleVals(3)*0.556+SCS.Tz_cspt; %(2);
    EPlusScheduleVals(4) = EPlusScheduleVals(4)*0.556+SCS.Tz_hspt; %(2);  
    EPlusScheduleVals(9) = EPlusScheduleVals(9)*0.556+SCS.Tz_cspt; %(2);
    EPlusScheduleVals(10) = EPlusScheduleVals(10)*0.556+SCS.Tz_hspt; %(2); 
    EPlusScheduleVals(15) = EPlusScheduleVals(15)*0.556+SCS.Tz_cspt; %(2);
    EPlusScheduleVals(16) = EPlusScheduleVals(16)*0.556+SCS.Tz_hspt; %(2); 
    EPlusScheduleVals(21) = EPlusScheduleVals(21)*0.556+SCS.Tz_cspt; %(2);
    EPlusScheduleVals(22) = EPlusScheduleVals(22)*0.556+SCS.Tz_hspt; %(2); 
% % else
% %     EPlusScheduleVals(3) = zoneSPs.zoneSPs(timestep+1,1);
% %     EPlusScheduleVals(4) = zoneSPs.zoneSPs(timestep+1,2);
% %     EPlusScheduleVals(9) = zoneSPs.zoneSPs(timestep+1,3);
% %     EPlusScheduleVals(10) = zoneSPs.zoneSPs(timestep+1,4);
% %     EPlusScheduleVals(15) = zoneSPs.zoneSPs(timestep+1,5);
% %     EPlusScheduleVals(16) = zoneSPs.zoneSPs(timestep+1,6);
% %     EPlusScheduleVals(21) = zoneSPs.zoneSPs(timestep+1,7);
% %     EPlusScheduleVals(22) =  zoneSPs.zoneSPs(timestep+1,8);
% % end

if (clock-86400-start_time)/60.0 > 360
    gr = 1;
end

zSPs = [EPlusScheduleVals(3),EPlusScheduleVals(4),...
        EPlusScheduleVals(9),EPlusScheduleVals(10),...
        EPlusScheduleVals(15),EPlusScheduleVals(16),...
        EPlusScheduleVals(21),EPlusScheduleVals(22)];    
zoneTable = zoneTablePass(zSPs,zLabels,timestep+1,'set');
%%
if (recv<0.5 || clock>time_recv)
    %% normal mode
    % insert OccupantMatrix doc under normal mode
    OccMatDoc.DocType='OccupantMatrix';
    OccMatDoc.Timestep=(clock-86400-start_time)/60.0;
    OccMatDoc.Time=clock;
    OccMatDoc.OccupantMatrix=[OccupantMatrix{1},OccupantMatrix{2},...
        OccupantMatrix{3},OccupantMatrix{4}];
    % update behavior in SimData
    BXquery=mongo2mongofiled_upset(BXLabel,EPlusScheduleVals);
    obmTable = OBMTablePass(EPlusScheduleVals,BXLabel,timestep+1,'set');

    % assign output
    block.OutputPort(1).Data = EPlusScheduleVals;
else
    %% recovery mode
    % obtain stored behavior from DB
    obmTable = OBMTablePass([],[],[],'get');
    ret = obmTable(timestep_idx+1,:);
    for i=1:length(BXLabel)
        BX(i)=ret.(char(BXLabel(i)));
    end
    % recover the OccupantMatrix
    if (clock==time_recv)
        OM_DB=find(conn,CollName,'Query',['{"Time":',num2str(time_recv),...
            ',"DocType":"OccupantMatrix"}']);
        OM_length=zeros(1,nzones);
        for i=1:nzones
            OM_length(i)=length(OccupantMatrix{i});
        end
        cur=[0 cumsum(OM_length)];
        for i=1:nzones
            OccupantMatrix{i}=OM_DB.OccupantMatrix((cur(i)+1):cur(i+1))';
        end
    end
    % assign output
    block.OutputPort(1).Data=BX;
end
else
    block.OutputPort(1).Data=zeros(1,4*6);
end
%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C MEX counterpart: mdlUpdate
%%
function Update(block)

% block.Dwork(1).Data = block.InputPort(1).Data;

%end Update

%%
%% Derivatives:
%%   Functionality    : Called to update derivatives of
%%                      continuous states during simulation step
%%   Required         : No
%%   C MEX counterpart: mdlDerivatives
%%
function Derivatives(block)

%end Derivatives

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

