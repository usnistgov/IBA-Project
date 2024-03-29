function [ZoneInfo,CtrlSig,MyCtrl]=callSim(HardwareTime,timestep,Meas)
%% Notes
%% Inputs
% timestep
%   User should put callSim function in a loop, where timestep=0:1:end
% Meas:
%     m_sup_vav1_ahu1 = Meas(1) :       vav discharge air mass flow rate of zone 1 served by AHU1 [kg/s]
%     T_sup_vav1_ahu1 = Meas(2) :       vav discharge air temperature of zone 1 served by AHU1 [°C]
%     w_sup_vav1_ahu1 = Meas(3) :       vav discharge air humidity ratio of zone 1 served by AHU1 [kg/kg]
%     T_z1_ahu1 = Meas(4) :             zone air temperature of zone 1 served by AHU1 [°C]
%     w_z1_ahu1 = Meas(5) :             humidity ratio of zone 1 served by AHU1 [kg/kg]
%     m_sup_vav2_ahu1 = Meas(6) :       vav discharge air mass flow rate of zone 2 served by AHU1 [kg/s]
%     T_sup_vav2_ahu1 = Meas(7) :       vav discharge air temperature of zone 2 served by AHU1 [°C]
%     w_sup_vav2_ahu1 = Meas(8) :       vav humidity ratio of zone 2 served by AHU1 [kg/kg]
%     T_z2_ahu1 = Meas(9) :             zone air temperature of zone 2 served by AHU1 [°C]
%     w_z2_ahu1 = Meas(10) :            humidity ratio of zone 2 served by AHU1 [kg/kg]
%     m_sup_vav1_ahu2 = Meas(11) :      vav discharge air mass flow rate of zone 1 served by AHU2 [kg/s]
%     T_sup_vav1_ahu2 = Meas(12) :      vav discharge air temperature of zone 1 served by AHU2 [°C]
%     w_sup_vav1_ahu2 = Meas(13) :      vav humidity ratio of zone 1 served by AHU2 [kg/kg]
%     T_z1_ahu2 = Meas(14) :            zone air temperature of zone 1 served by AHU2 [°C]
%     w_z1_ahu2 = Meas(15) :            humidity ratio of zone 1 served by AHU2 [kg/kg]
%     m_sup_vav2_ahu2 = Meas(16) :      vav discharge air mass flow rate of zone 2 served by AHU2 [kg/s]
%     T_sup_vav2_ahu2 = Meas(17) :      vav discharge air temperature of zone 2 served by AHU2 [°C]
%     w_sup_vav2_ahu2 = Meas(18) :      vav humidity ratio of zone 2 served by AHU2 [kg/kg]
%     T_z2_ahu2 = Meas(19) :            zone air temperature of zone 2 served by AHU2 [°C]
%     w_z2_ahu2 = Meas(20) :            humidity ratio of zone 2 served by AHU2 [kg/kg]
%     W_ahu1 = Meas(21) :               AHU1 power [W]
%     vfd_ahu1 = Meas(22) :             AHU1 fan speed [Hz]
%     d1_ahu1 = Meas(23) :              vav damper position of zone 1 served by AHU1 [V]
%     d2_ahu1 = Meas(24) :              vav damper position of zone 2 served by AHU1 [V]
%     rh1_ahu1 = Meas(25) :             reheat coil status (0 or 1) of zone 1 served by AHU1
%     rh2_ahu1 = Meas(26) :             reheat coil status (0 or 1) of zone 2 served by AHU1
%     P_sp_ahu1_cur = Meas(27) :        AHU1 current static pressure measurement [Pa]
%     T_SA_ahu1_cur = Meas(28) :        AHU1 current supply air temperature measurement [°C]
%     V_cc_ahu1 = Meas(29) :            AHU1 Cooling coil valve position [V]
%     Tin_cc_ahu1 = Meas(30) :          AHU1 Cooling coil inlet temperature [°C]
%     Tout_cc_ahu1 = Meas(31) :         AHU1 Cooling coil outlet temperature [°C]
%     W_ahu2 = Meas(32) :               AHU2 power [W]
%     vfd_ahu2 = Meas(33) :             AHU2 fan speed [Hz]
%     d1_ahu2 = Meas(34) :              vav damper position of zone 1 served by AHU2 [V]
%     d2_ahu2 = Meas(35) :              vav damper position of zone 2 served by AHU2 [V]
%     rh1_ahu2 = Meas(36) :             reheat coil status (0 or 1) of zone 1 served by AHU2
%     rh2_ahu2 = Meas(37) :             reheat coil status (0 or 1) of zone 2 served by AHU2
%     P_sp_ahu2_cur = Meas(38) :        AHU2 current static pressure measurement [Pa]
%     T_SA_ahu2_cur = Meas(39) :        AHU2 current supply air temperature measurement [°C]
%     V_cc_ahu2 = Meas(40) :            AHU2 Cooling coil valve position [V]
%     Tin_cc_ahu2 = Meas(41) :          AHU2 Cooling coil inlet temperature [°C]
%     Tout_cc_ahu2 = Meas(42) :         AHU2 Cooling coil outlet temperature [°C]
%     W_CHW = Meas(43) :                chiller power [W]
%     m_CHW_pm = Meas(44) :             primary chilled water pump flow rate [kg/s]
%     m_CHW_sl = Meas(45) :             secondary chilled water pump flow rate [kg/s]
%     T_CHW1 = Meas(46) :               chiller1 chilled water supply temperature [°C]
%     T_CHW2 = Meas(47) :               chiller2 chilled water supply temperature [°C]
%     T_CHW_TS = Meas(48) :             ice tank chilled water supply temperature [°C]
%     T_chwst_cur = Meas(49) :          current chilled water temperature measurement[°C]
%     DP_slSP_cur = Meas(50):           current chilled water secondary loop pressure measurement[kPa]
%     TES_inventory = Meas(51):         current ice tank inventory level (0 to 1)
%     TES_status = Meas(52):            current ice tank status (0-charing/discharging,1-fully discharged,2-fully charged)
%     T_out_emulated = Meas(53):        emulated outdoor air temperature [°C]
%     T_return_ahu1 = Meas(54):         return air temperature of AHU1 [°C]
%     T_return_ahu2 = Meas(55):         return air temperature of AHU2 [°C]
%     Power_HVAC_electric = Meas(56):   total electric power of HVAC system including primary/secondary system [kW]
%     AHU1_pressure = Meas(57):         fan pressure for AHU1 [inh2o]
%     AHU2_pressure = Meas(58):         fan pressure for AHU2 [inh2o]
%     AHU1_temp = Meas(59);             temperature at the outlet of AHU1 [°C]
%     AHU2_temp = Meas(60);             temperature at the outlet of AHU2 [°C]
%     ch1Power = Meas(61);              temperature at the outlet of AHU1 [W]
%     ch2Power = Meas(62);              temperature at the outlet of AHU2 [W]
%     ahu1_f_cc = Meas(63);             flow rate of cc in AHU1 [gpm]
%     ahu2_f_cc = Meas(64);             flow rate of cc in AHU2 [gpm]
%     ahu1_in_rtd = Meas(65);           temperature at the inlet of the cc in AHU1 [C]
%     ahu2_in_rtd = Meas(66);           temperature at the inlet of the cc in AHU2 [C]
%     ahu1_rh_up = Meas(67);            RH at the inlet of the cc in AHU1 [%]
%     ahu2_rh_up = Meas(68);            RH at the inlet of the cc in AHU2 [%]
%     ch1PLR = Meas(69);                Part load ratio of chiller1
%     ch2PLR = Meas(70);                Part load ratio of chiller2
%     pl_out = Meas(71);                Temperature of the liquid out of the primary loop
% recv
%   = 0; normal mode
%   = 1; recovery mode (also assign ts_recv in this case)
% ts_recv
%   The timestep to recover to.
%   For example, if recv=1 and ts_recv=20, the simulation will not update
%   inputs to the DB when timestep<=20.
% coll_recv
%   The collection that the user wants to recover, name can be random if
%   recv = 0
%% Outputs
% ZoneInfo
% ={'T_out','Tdp_out','RH_out',...
%         'Qsen_z1_ahu1','Qlat_z1_ahu1','Tz_cspt_z1_ahu1','Tz_hspt_z1_ahu1','T_z1_ahu1','Tdp_z1_ahu1','w_z1_ahu1',...
%         'Qsen_z2_ahu1','Qlat_z2_ahu1','Tz_cspt_z2_ahu1','Tz_hspt_z2_ahu1','T_z2_ahu1','Tdp_z2_ahu1','w_z2_ahu1',...
%         'Qsen_z1_ahu2','Qlat_z1_ahu2','Tz_cspt_z1_ahu2','Tz_hspt_z1_ahu2','T_z1_ahu2','Tdp_z1_ahu2','w_z1_ahu2',...
%         'Qsen_z2_ahu2','Qlat_z2_ahu2','Tz_cspt_z2_ahu2','Tz_hspt_z2_ahu2','T_z2_ahu2','Tdp_z2_ahu2','w_z2_ahu2',...
%         'w_out'};
%   T_out: Outdoor air temperature [C]
%   Tdp_out: Outdoor air dewpoint temperature [C]
%   RH_out: Outdoor air relative humidity [%]
%   Qsen: Sensible load [W], positive = heating, negative = cooling
%   Qlat: Latent load [W], positive = humidify, negative = dehumidify
%   Tz_cspt: Zone cooling setpoint [C]
%   Tz_hspt: Zone heating setpoint [C]
%   T_z: (Simulated) Zone air temperature [C]
%   Tdp_z: Zone dewpoint temperature [C]
%   w_z: Zone humidity ratio [kgwater/kgair]
%   w_out: Outdoor air humidty ration [kgwater/kgair]
% CtrlSig
%   CtrlSig(1,1:17)
%     Only use the CtrlSig(2,i) value when CtrlSig(1,i)==1.
%   CtrlSig(2,1:17) = [sys_status,modulate_PID,T_chwst,DP_slSP,P_sp_ahu1,P_sp_ahu2,T_SA_ahu1,T_SA_ahu2,TS_mode,...
%    Vmin_vav1_ahu1,Vmin_vav2_ahu1,Vmin_vav1_ahu2,Vmin_vav2_ahu2,...																	
%    m_vav1_ahu1_sp,m_vav2_ahu1_sp,m_vav1_ahu2_sp,m_vav2_ahu2_sp]
%     sys_status:       system status (0-off,1-on)
%     modulate_PID:     Activate modulate PID (0-off,1-on)
%     T_chwst:          chilled water temperature setpoint[°C]
%     DP_slSP:          chilled water secondary loop pressure setpoint[kPa]
%     P_sp_ahu1:        AHU1 supply air static pressure setpoint[Pa]
%     P_sp_ahu2:        AHU2 supply air static pressure setpoint[Pa]
%     T_SA_ahu1:        AHU1 supply air temperature setpoint [°C]
%     T_SA_ahu2:        AHU2 supply air temperature setpoint [°C]
%     TS_mode:          ice tank mode (0-bypass,1-discharge, 2-charge)
%     Vmin_vav1_ahu1:   minimum ventilation rate of ahu1-vav1(conference room mide 2) [CFM]
%     Vmin_vav2_ahu1:   minimum ventilation rate of ahu1-vav2(enclosed office mide 2) [CFM]
%     Vmin_vav1_ahu2:   minimum ventilation rate of ahu2-vav1(enclosed office mide 5) [CFM]
%     Vmin_vav2_ahu2:   minimum ventilation rate of ahu2-vav2(open office mide 1) [CFM]
%     m_vav1_ahu1_sp:   mass flow rate setpoint of ahu1-vav1
%     m_vav2_ahu1_sp:   mass flow rate setpoint of ahu1-vav2
%     m_vav1_ahu2_sp:   mass flow rate setpoint of ahu2-vav1
%     m_vav2_ahu2_sp:   mass flow rate setpoint of ahu2-vav2
%% Others
% startTime
%   EPlus simulation start time in seconds
%   For example, if user wants to simulate nth day of the year,
%   startTime = 86400*(n-1)
% stopTime
%   End time of the EPlus simulation.
%   For example, if user wants to simulate nth day of the year,
%   startTime = 86400*n
% stepsize
%   step size of each timestep (in seconds)
%   use to determine the associate time stamp
% GEB_step
%   number of timesteps between two GEB calls
% conn
%   DB connection cursor
% CollName
%   DB collection name. Automatic generated. Name constructed by the folder
%   names of the current and the upper two diectories, and date/time.
% ***Label
%   Label names for the data in DB
% timestep_GEB_start
%   timestep to start GEB computation
% timestep_GEB_read
%   timestep to read supervisory signals computed earlier

%% global variable
persistent recv ts_recv coll_recv startTime stopTime
persistent stepsize
persistent conn CollName DBName MeasLabel ZoneInfoLabel ZIFields CtrlSigLabel CSFields
persistent GEB_case Control_method TES Location STD Dense_Occupancy EGRSave_Occupant Season_type SimulinkName
persistent CollName_STD CollName_Location CollName_DenOcc startTime_forEnergyPlus 
persistent measTable ctrlTable zoneTable supvCtrlSig
persistent vavStore inputsK ahuStore fanPowerStore dpStore ahu1FanPower ahu2FanPower

global sameTzSPs timestepG tes_case
%% Initialization
timestep_idx = timestep;
timestepG = timestep;
% if timestep_idx == 0
%     gindex = 1;
% else
%     gindex = timestep_idx + 1;
% end
if isempty(conn)
    % Labels
    line = 173;
    save('callsim.mat','line','timestep','Meas')
    MeasLabel={'m_sup_vav1_ahu1','T_sup_vav1_ahu1','w_sup_vav1_ahu1','T_z1_ahu1','w_z1_ahu1',...
        'm_sup_vav2_ahu1','T_sup_vav2_ahu1','w_sup_vav2_ahu1','T_z2_ahu1','w_z2_ahu1',...
        'm_sup_vav1_ahu2','T_sup_vav1_ahu2','w_sup_vav1_ahu2','T_z1_ahu2','w_z1_ahu2',...
        'm_sup_vav2_ahu2','T_sup_vav2_ahu2','w_sup_vav2_ahu2','T_z2_ahu2','w_z2_ahu2',...
        'W_ahu1','vfd_ahu1','d1_ahu1','d2_ahu1','rh1_ahu1','rh2_ahu1',...
        'P_sp_ahu1_cur','T_SA_ahu1_cur','V_cc_ahu1','Tin_cc_ahu1','Tout_cc_ahu1',...
        'W_ahu2','vfd_ahu2','d1_ahu2','d2_ahu2','rh1_ahu2','rh2_ahu2',...
        'P_sp_ahu2_cur','T_SA_ahu2_cur','V_cc_ahu2','Tin_cc_ahu2','Tout_cc_ahu2',...
        'W_CHW','m_CHW_pm','m_CHW_sl','T_CHW1','T_CHW2','T_CHW_TS','T_chwst_cur','DP_slSP_cur',...
        'TES_inventory','TES_status','T_out_emulated','T_return_ahu1','T_return_ahu2','Power_HVAC',...
        'ahu1_p_down','ahu2_p_down','ahu1_out_rtd','ahu2_out_rtd','ch1_power','ch2_power',...
        'ahu1_f_cc','ahu2_f_cc','ahu1_in_rtd','ahu2_in_rtd','ahu1_rh_up','ahu2_rh_up',...
        'ch1PLR','ch2PLR','pl_out'};
    line = 188;
    save('callsim.mat','line','timestep','Meas','MeasLabel')
    ZoneInfoLabel={'T_out','Tdp_out','RH_out',...
        'Qsen_z1_ahu1','Qlat_z1_ahu1','Tz_cspt_z1_ahu1','Tz_hspt_z1_ahu1','T_z1_ahu1','Tdp_z1_ahu1','w_z1_ahu1',...
        'Qsen_z2_ahu1','Qlat_z2_ahu1','Tz_cspt_z2_ahu1','Tz_hspt_z2_ahu1','T_z2_ahu1','Tdp_z2_ahu1','w_z2_ahu1',...
        'Qsen_z1_ahu2','Qlat_z1_ahu2','Tz_cspt_z1_ahu2','Tz_hspt_z1_ahu2','T_z1_ahu2','Tdp_z1_ahu2','w_z1_ahu2',...
        'Qsen_z2_ahu2','Qlat_z2_ahu2','Tz_cspt_z2_ahu2','Tz_hspt_z2_ahu2','T_z2_ahu2','Tdp_z2_ahu2','w_z2_ahu2',...
        'w_out'};
    %ZIFields=label2mongofield_find(ZoneInfoLabel);
    CtrlSigLabel={'sys_status','modulate_PID','T_chwst','DP_slSP','P_sp_ahu1','P_sp_ahu2','T_SA_ahu1','T_SA_ahu2',...
        'TS_mode','Vmin_vav1_ahu1','Vmin_vav2_ahu1','Vmin_vav1_ahu2','Vmin_vav2_ahu2'....
        'm_vav1_ahu1_sp','m_vav2_ahu1_sp','m_vav1_ahu2_sp','m_vav2_ahu2_sp','Tz_cspt','Tz_hspt'};
    %CSFields=label2mongofield_find(CtrlSigLabel);
    line = 197;
    save('callsim.mat','line','timestep','Meas')
    nMeas = length(MeasLabel);
    sameTzSPs = 0;
    vavStore = zeros(1,56);
    inputsK = zeros(1,nMeas+2);
    ahuStore = zeros(1,13);
    fanPowerStore = zeros(1,16);
    dpStore = zeros(1,12);
    conn = 1;
    % delete any existing parallel pool
    poolobj = gcp('nocreate');
    delete(poolobj);
    % read settings from file
    settings=readtable('settings.csv');
    line = 212;
    save('callsim.mat','line','timestep','Meas','settings')
    recv = settings.recv(1);   % recovery mode
    ts_recv = settings.ts_recv(1); % time step to recover to
    coll_recv = settings.coll_recv{1}; % collection to recover
    if (recv>0.5 && strcmp(coll_recv,'current'))  % if current, use the COLL in DBLoc.mat
        coll_recv=load('DBLoc.mat').CollName;
    end
    line = 220;
    save('callsim.mat','line','timestep','Meas')
    % Test Location (1-Atlanta;2-Buffalo;3-NewYork;4-Tucson;5-ElPaso)
    Location = settings.Location(1);
    % Season type (1-typical winter;2-typical should;3-extreme summer;4-typical summer)
    Season_type = settings.SeasonType(1);
    % Based on location and simulated season type, determine simulation
    % time (day of year)
    DOY_Table=[28 119 189 238; 365 71 197 183; 30 289 191 177; 2 280 228 240; 9 107 170 203];
    DOY = DOY_Table(Location,Season_type);  % day of year
    startTime_forEnergyPlus=86400*(DOY-2);   % EPlus simulation start time in seconds
    startTime=86400*(DOY-1);                 % MongoDB and ControlModel start time in seconds
    stopTime=86400*DOY;     % EPlus simulation end time in seconds
    % GEB scenario to be tested (0-none,1-eff,2-shed,3-shift,4-modulate)
    GEB_case = settings.GEB_case(1);
    % GEB control method (0-rule based, 1-MPC)
    Control_method = settings.Control_method(1);
    % Test TES or not (0-no, 1-yes)
    TES = settings.TES(1);
    % STD (1-STD2004;2-STD2019)
    STD = settings.STD(1);
    % Dense occupancy or not
    Dense_Occupancy= settings.occ_dense(1);
    % Energy-saving occupants or not
    EGRSave_Occupant= settings.occ_energysaving(1);
    % parameters
    stepsize=settings.stepsize(1);    % step size of each timestep (in seconds)
    % directory
    par_dir = fileparts(strcat(pwd,'\callSim.m'));
    % add OBMsubfuntion to path
    addpath(strcat(par_dir,'\OBM'));
    % add Airflow ANN model to path
    addpath(strcat(par_dir,'\OBM\AirflowANNmodel'));
    % add DB function to path
    addpath(strcat(par_dir,'\DB'));
    % add virtual building to path
    addpath(strcat(par_dir,'\VB'));
    % add control models to path
    addpath(strcat(par_dir,'\CTRL'));
    % add ibal control models to path
    addpath(strcat(par_dir,'\ibalControls'));
    % load some models
    % database name
    DBName = 'HILFT';
    % connect to the database (make sure the DB is created first)
% % %     conn = mongo('localhost',27017,DBName);
    % collection name
    CollName_Location={'Atlanta';'Buffalo';'NewYork';'Tucson';'ElPaso'};
    CollName_GEBCase={'None';'Eff';'Shed';'Shif';'Modu'};
    CollName_Season={'TypWin';'TypShou';'ExtrmSum';'TypSum'};
    CollName_GEBControl={'RB';'MPC'};
    CollName_STD={'2004';'2019'};
    CollName_DenOcc={'TypOcc';'DenOcc'};
    CollName_EGROcc={'TypBehav';'EGRBehav'};
    CollName_TES={'NoTES';'TES'};
    %     parts=strsplit(par_dir, '\');
    %     CollName=[char(parts(end)),'_',char(datestr(now,'mmddyyyy')),...
    %         '_',char(datestr(now,'HHMMSS'))];
    CollName=[char(CollName_Location(Location)),...
        '_',char(CollName_GEBCase(GEB_case+1)),'_',char( CollName_Season(Season_type)),'_',...
        char(CollName_GEBControl(Control_method+1)),'_',char(CollName_STD(STD)),'_',...
        char(CollName_DenOcc(Dense_Occupancy+1)),'_',char(CollName_EGROcc(EGRSave_Occupant+1)),...
        '_',char(CollName_TES(TES+1)),'_',...
        char(datestr(now,'mmddyyyy')),'_',char(datestr(now,'HHMMSS'))];
    % recovery of an existing collection
    if (recv>0.5)
        CollName=coll_recv;
    end
    % save DBName and CollName to share with other models
    save DBLoc.mat DBName CollName
    

    zoneTable = zoneTablePass([],ZoneInfoLabel,timestep,'init');
    line = 303;
    save('callsim.mat','line','timestep','Meas')
    ctrlTable = ctrlTablePass([],CtrlSigLabel,timestep,'init');
    line = 306;
    save('callsim.mat','line','timestep','Meas')
    measTable = measTablePass([],MeasLabel,timestep,'init');
    line = 308;
    save('callsim.mat','line','timestep','Meas')
    RecvDoc.DocType="RecvSettings";
    RecvDoc.recv=recv;
    RecvDoc.time_recv=startTime+ts_recv*60;
    
    % Load in models for AHU fan power
    ahu1FanPower = load('tree1_2022_09_28.mat');
    ahu2FanPower = load('tree2_2022_09_28.mat');
end
line = 283;
save('callsim.mat','line','timestep')
if timestep<0
    %% for thie period before the tested day (YC 02/18/2022)
    % only storage the Measurement and ControlSignal with TES_Measurements
    % and TES_SupvCtrlSig as DocType
	tes_case = 1;
    MeasDoc.DocType='TES_Measurements';
    MeasDoc.HardwareTime = HardwareTime;
    MeasDoc.Timestep=timestep;
    MeasDoc.Time=startTime+timestep*60;
    Mquery=mongo2mongofiled_upset(MeasLabel,...
        Meas);
    TES_inventory=Meas(51);
    TS_mode = 0;
    if TES_inventory<85.0
        TS_mode=2;
    end
    CtrlSig=zeros(2,19);
    CtrlSig(1,9)=1;
    CtrlSig(2,9)=TS_mode;
    CtrlSigDoc.DocType='TES_SupvCtrlSig';
    CtrlSigDoc.HardwareTime = HardwareTime;
    CtrlSigDoc.Timestep=timestep;
    CtrlSigDoc.Time=startTime+timestep*60;
    CtrlSigDoc.TS_mode = CtrlSig(:,9);
    % make a blank metrix to output ZoneInfo
    ZoneInfo=zeros(1,length(ZoneInfoLabel));
    line = 323;
    save('callsim.mat','line')
    if TS_mode == 2
        ch2On = 1;
        CtrlSig(1,3) = 1;
        CtrlSig(2,3) = -5; % Chiller setpoint is 20 F, but real T is usually around 24 F
        v8 = 1;
    else
        ch2On = 0;
        % Note: If the discharge case ever occurs outside the building
        % model, this must change
        v8 = 0;
    end
    MyCtrl = [0,0,0,0,0,0,0,0,...
              0,0,0,0,0,0,...
              0,0,0,0,0,0,0,ch2On,...
              0,0,0,0,0,...
              Meas(51),v8];
else
    %% Push data to DB
    if (recv<0.5 || timestep>ts_recv)
        % remove all existing doc for the current timestep in recovery mode
        % create doc for crucial simulated data
        DataDoc.DocType='SimData';
        DataDoc.Timestep=timestep;
        DataDoc.Time=startTime+timestep*60;
        % push Meas to DB
        MeasDoc.DocType='Measurements';
        MeasDoc.HardwareTime = HardwareTime;
        MeasDoc.Timestep=timestep;
        MeasDoc.Time=startTime+timestep*60;
        % run GEB control module
        line = 348;
        save('callsim.mat','line','Meas','MeasLabel')
        measTable = measTablePass(Meas,MeasLabel,timestep+1,'set');
        CtrlSig = Control_Model(startTime,timestep,Season_type,GEB_case,Control_method,TES,Meas,STD,Dense_Occupancy,conn,CollName);
        temp = CtrlSig(1,:).*CtrlSig(2,:); %[CtrlSig(1,1)*CtrlSig(2,1), CtrlSig(1,2:end).*CtrlSig(2,2:end),32,10];
        line = 353;
        save('callsim.mat','line','temp')
        ctrlTable = ctrlTablePass(temp,CtrlSigLabel(1:end),timestep+1,'set');
    else
        % Get CtrlSig from DB in recovery mode
        line = 358;
        save('callsim.mat','line','Meas')
        CtrlSig=zeros(2,length(CtrlSigLabel));
        for i=1:length(CtrlSigLabel)
            CtrlSig(:,i)=ret_CS.(char(CtrlSigLabel(i)));
        end
    end
line = 352;
save('callsim.mat','line')      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% run virtual building model
    if timestep==0
        % open Simulink
        % Simulink file name
        if Location==4  % Tucson
            if Season_type==1 || Season_type==4
                SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
                    char(CollName_Location(Location)),'2019Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
            elseif Season_type==2
                SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
                    char(CollName_Location(Location)),'2015Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
            elseif Season_type==3
                SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
                    char(CollName_Location(Location)),'2017Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
            end
        elseif Location==5  % ElPaso
            if Season_type==4
                SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
                    char(CollName_Location(Location)),'2015Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
            else
                SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
                    char(CollName_Location(Location)),'2013Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
            end
        else
            SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
                char(CollName_Location(Location)),'_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
        end
        open_system(SimulinkName);
        % set Simulink start time and stop time at the initial call
        set_param(bdroot,'StartTime',string(startTime_forEnergyPlus),'StopTime',string(stopTime));
        % start Simulink
        set_param(bdroot,'SimulationCommand','start');
        for i_firstday=0:(1440-1)
            set_param(bdroot,'SimulationCommand','pause');
            set_param(bdroot,'SimulationCommand','continue');
        end
		line = 391;
        save('callsim.mat','line')  
        ZoneInfo=zeros(1,length(ZoneInfoLabel));
        zoneTable = zoneTablePass(ZoneInfo,ZoneInfoLabel,timestep+1,'set');
    else
        % continue Simulink
        set_param(bdroot,'SimulationCommand','continue');
    end
    % pause Simulink
    set_param(bdroot,'SimulationCommand','pause');
    %% Get ZoneInfo from DB
    zoneTable = zoneTablePass([],[],[],'get');
    for i=1:length(ZoneInfoLabel)
        ZoneInfo(i)=table2array(zoneTable(timestep_idx+1,ZoneInfoLabel(i)));
    end
    line = 409;
    save('callsim.mat','line')    
    %% Finalization
    if (timestep==86400/stepsize)
        set_param(bdroot,'SimulationCommand','stop');
        save_system(SimulinkName);
        close_system(SimulinkName);
        poolobj = gcp('nocreate');
        delete(poolobj);
    end
line = 420;
save('callsim.mat','line')    
%% Run new controllers
    %%%%%%%%%%%%%%%%%%% Timing discussion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % When coupled to the lab, the measured values are the current timestep
    % are input to the building model. The building model returns new
    % setpoints to the lab. The controllers in the lab use the new
    % setpoints for their calculations. So any controller that is in the
    % lab should be located AFTER the virtual building model does its
    % thing.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Chillers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [ch1On,ch2On] = chillerStaging(Meas(61),Meas(62),Meas(49),min(Meas(46),Meas(47)),Meas(69),Meas(70),timestep,timestep_idx);   
    if CtrlSig(2,9) == 2
       ch2On = 1; 
       CtrlSig(1,3) = 1;
       CtrlSig(2,3) = -5; % Chiller setpoint is 20 F, but real T is usually around 24 F
    elseif CtrlSig(2,9) == 1
       ch2On = 0;
       ch1On = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [v8,pTerms] = tesValve(CtrlSig,Meas);
    %v8 = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% VAV codes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Call the code to calculate the VAV flow setpoints                      
    [vav1_d_sp,vav2_d_sp,vav3_d_sp,vav4_d_sp,Tz1SP,Tz2SP,Tz3SP,Tz4SP,ahu1VentAir,ahu2VentAir] = vavControllers(timestep,ZoneInfo,CtrlSig,Meas);      
    line = 426;
    save('callsim.mat','line','Meas','timestep','ZoneInfo','CtrlSig','vav1_d_sp','vav2_d_sp','vav3_d_sp','vav4_d_sp','inputsK')    
    % Put together data to store for troubleshooting
    temp = [timestep,ZoneInfo,CtrlSig(2,:),vav1_d_sp,vav2_d_sp,vav3_d_sp,vav4_d_sp];
    vavStore = [vavStore;temp];
    inputsK = [inputsK;HardwareTime,timestep,Meas];
    line = 432;
    save('callsim.mat','line')        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% CC Valve codes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     [ahu1_cc_valve,ahu2_cc_valve,pTerms1,pTerms2] = ahuCCValves(timestep,ZoneInfo,CtrlSig,Meas,[Meas(59),Meas(60)]);
     temp = [timestep,ahu1_cc_valve,pTerms1.SP,pTerms1.PV,pTerms1.pTerm,pTerms1.iTerm,pTerms1.uBias,...
                      ahu2_cc_valve,pTerms1.SP,pTerms2.PV,pTerms2.pTerm,pTerms2.iTerm,pTerms2.uBias];
    ahuStore = [ahuStore;temp];            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Secondary Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [slOn] = slController((ahu1_cc_valve+1/3)*6,...
                          (ahu2_cc_valve+1/3)*6,...
                          CtrlSig(2,1),...
                          vav1_d_sp+vav2_d_sp+vav3_d_sp+vav4_d_sp);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% AHU2 Fan Power %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Psp, Vmin,vav1_f,vav2_f,Tz1-Tz1SP,Tz2-Tz2SP
        X2 = [CtrlSig(2,6),CtrlSig(2,12)+CtrlSig(2,13),vav1_d_sp,vav2_d_sp,...
             ZoneInfo(22)-Tz1SP,ZoneInfo(29)-Tz2SP];
        X1 = [CtrlSig(2,5),CtrlSig(2,10)+CtrlSig(2,11),vav3_d_sp,vav4_d_sp,...
             ZoneInfo(8)-Tz3SP,ZoneInfo(15)-Tz4SP];
        if CtrlSig(2,1) > 0        
            line = 437;
            save('callsim.mat','line','X2')
            ahu2_fan_power = ahu2FanPower.tree2_2023_09_28.predictFcn(X2);
            Q = vav1_d_sp+vav2_d_sp; SP = CtrlSig(2,6);
            a = [178.9,-0.5842,0.001143,-2.795e-7,-0.9368,0.06065];
            %ahu2_fan_power = a(1)+a(2)*Q+a(3)*(Q).^2+a(4)*(Q).^3+a(5)*(SP)+a(6)*(SP).^(1.5);            
            line = 449;
            save('callsim.mat','line','X1','X2','Meas')
            ahu1_fan_power = ahu1FanPower.tree1_2023_09_28.predictFcn(X1);
            Q = vav3_d_sp+vav4_d_sp; SP = CtrlSig(2,5);
            a = [151.6,-1.252,0.001908,-5.353e-7,0.6325,0.01405];
            %ahu1_fan_power = a(1)+a(2)*Q+a(3)*(Q).^2+a(4)*(Q).^3+a(5)*(SP)+a(6)*(SP).^(1.5); 
            line = 488;
            save('callsim.mat','line','X1','X2','Meas')
        else
            ahu2_fan_power = 0;
            ahu1_fan_power = 0;
        end
        fanPowerStore = [fanPowerStore;[X1,X2,0,0,0,0]]; 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        ahu1VentAir = max(0,0.99*ahu1VentAir-367.35);
        ahu2VentAir = max(0,0.88*ahu2VentAir-90.71);
        MyCtrl = [vav1_d_sp,vav2_d_sp,vav3_d_sp,vav4_d_sp,Tz1SP,...
                  Tz2SP,Tz3SP,Tz4SP,ahu1VentAir,ahu2VentAir,...
                  0,0,ahu2_fan_power,ahu1_fan_power,0,...
                  0,0,0,ahu1_cc_valve,ahu2_cc_valve,...
                  ch1On,ch2On,0,0,0,...
                  0,slOn,Meas(51),v8];%,...
    line = 500;
    save('callsim.mat','line','Meas') 						  
end
% If the system is off, set DP set point for SL to 0
if CtrlSig(2,1) == 0
    CtrlSig(2,4) = 0;
end
if CtrlSig(2,9) == 2
    CtrlSig(2,3) = -5;
end
end