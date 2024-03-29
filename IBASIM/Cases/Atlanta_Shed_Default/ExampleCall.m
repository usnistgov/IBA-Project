% Load real test data
filename = 'Atlanta_Shed_TypSum_RB_2004_TypOcc_TypBehav_NoTES_04012022_090349.mat';
old = load(filename);
names = fieldnames(old.Measurements);
names = names(3:end);
names(3) = [];
fNames = {'HardwareTime','Timestep',...
          'm_sup_vav1_ahu1','T_sup_vav1_ahu1','w_sup_vav1_ahu1','T_z1_ahu1','w_z1_ahu1',...
          'm_sup_vav2_ahu1','T_sup_vav2_ahu1','w_sup_vav2_ahu1','T_z2_ahu1','w_z2_ahu1',...
          'm_sup_vav1_ahu2','T_sup_vav1_ahu2','w_sup_vav1_ahu2','T_z1_ahu2','w_z1_ahu2',...
          'm_sup_vav2_ahu2','T_sup_vav2_ahu2','w_sup_vav2_ahu2','T_z2_ahu2','w_z2_ahu2',...
          'W_ahu1','vfd_ahu1','d1_ahu1','d2_ahu1','rh1_ahu1',...
          'rh2_ahu1','P_sp_ahu1_cur','T_SA_ahu1_cur','V_cc_ahu1','Tin_cc_ahu1',...
          'Tout_cc_ahu1','W_ahu2','vfd_ahu2','d1_ahu2','d2_ahu2',...
          'rh1_ahu2','rh2_ahu2','P_sp_ahu2_cur','T_SA_ahu2_cur','V_cc_ahu2',...
          'Tin_cc_ahu2','Tout_cc_ahu2','W_CHW','m_CHW_pm','m_CHW_sl',...
          'T_CHW1','T_CHW2','T_CHW_TS','T_chwst_cur','DP_slSP_cur',...
          'TES_inventory','TES_status','T_out_emulated','T_return_ahu1','T_return_ahu2',...
          'Power_HVAC','ahu1_p_down','ahu2_p_down','ahu1_out_rtd','ahu2_out_rtd',...
          'ch1_power','ch2_power',...
          'ahu1_f_cc','ahu2_f_cc','ahu1_in_rtd','ahu2_in_rtd','ahu1_rh_up','ahu2_rh_up'};
% Initialize inputs table
inputs = zeros(height(old.Measurements),length(fNames));
inputs = array2table(inputs);
inputs.Properties.VariableNames = fNames;
% Set some inputs from real data
for i = 1:length(names)
    inputs.(char(names(i))) = [old.Measurements.(char(names(i)))]';
end

% Load data from previous run of TRNSYS
fromTrnsys = readtable('forMatlab_2023_09_15_v1.txt');
% Set some inputs from TRNSYS data
inputs = inputs(1:height(fromTrnsys),:);
inputs.T_sup_vav1_ahu1 = fromTrnsys.t_sup_z3;
inputs.T_sup_vav2_ahu1 = fromTrnsys.t_sup_z4;
inputs.T_sup_vav1_ahu2 = fromTrnsys.t_sup_z1;
inputs.T_sup_vav2_ahu2 = fromTrnsys.t_sup_z2;
inputs.w_sup_vav1_ahu1 = fromTrnsys.w_sup_z3;
inputs.w_sup_vav2_ahu1 = fromTrnsys.w_sup_z4;
inputs.w_sup_vav1_ahu2 = fromTrnsys.w_sup_z1;
inputs.w_sup_vav2_ahu2 = fromTrnsys.w_sup_z2;
inputs.T_z1_ahu1 = fromTrnsys.t_z3;
inputs.T_z2_ahu1 = fromTrnsys.t_z4;
inputs.T_z1_ahu2 = fromTrnsys.t_z1;
inputs.T_z2_ahu2 = fromTrnsys.t_z2;
inputs.w_z1_ahu1 = fromTrnsys.w_z3;
inputs.w_z2_ahu1 = fromTrnsys.w_z4;
inputs.w_z1_ahu2 = fromTrnsys.w_z1;
inputs.w_z2_ahu2 = fromTrnsys.w_z2;
inputs.Tin_cc_ahu1 = fromTrnsys.tin_cc_ahu1;
inputs.Tin_cc_ahu2 = fromTrnsys.tin_cc_ahu2;
inputs.Tout_cc_ahu1 = fromTrnsys.tout_cc_ahu1;
inputs.Tout_cc_ahu2 = fromTrnsys.tout_cc_ahu2;
inputs.m_CHW_pm = fromTrnsys.m_chw_pm;
inputs.m_CHW_sl = fromTrnsys.m_chw_sl;
inputs.T_CHW1 = fromTrnsys.t_chw1;
inputs.T_CHW2 = fromTrnsys.t_chw2;
inputs.T_CHW_TS = fromTrnsys.t_chw_ts;
inputs.TES_inventory = fromTrnsys.tes_inv;
inputs.TES_status = fromTrnsys.tes_stat;
inputs.T_return_ahu1 = fromTrnsys.t_return_ahu1;
inputs.T_return_ahu2 = fromTrnsys.t_return_ahu2;
inputs.ahu1_p_down = fromTrnsys.ahu1_pressure;
inputs.ahu2_p_down = fromTrnsys.ahu2_pressure;
inputs.ahu1_out_rtd = fromTrnsys.ahu1_out_rtd;
inputs.ahu2_out_rtd = fromTrnsys.ahu2_out_rtd;
inputs.ch1_power = fromTrnsys.ch1_power;
inputs.ch2_power = fromTrnsys.ch2_power;
inputs.ahu1_f_cc = fromTrnsys.ahu1_f_cc;
inputs.ahu2_f_cc = fromTrnsys.ahu2_f_cc;
inputs.ahu1_in_rtd = fromTrnsys.ahu1_in_rtd;
inputs.ahu2_in_rtd = fromTrnsys.ahu2_in_rtd;
inputs.ahu1_rh_up = fromTrnsys.ahu1_rh_up;
inputs.ahu2_rh_up = fromTrnsys.ahu2_rh_up;
inputs.ch1PLR = fromTrnsys.ch1PLR;
inputs.ch2PLR = fromTrnsys.ch2PLR;
inputs.pl_out = fromTrnsys.pl_out;

T = 86400; % length of the simulation period in seconds
ntimestep=T/60; % total number of time steps
% Initialize storage arrays
MyCtrlk = zeros(ntimestep+1,29);
ZoneInfoK = zeros(ntimestep+1,32);
for timestep=0:ntimestep
    %% At every iteration,update measurements
    timestep
    HardwareTime = table2array(inputs(timestep+1,1)); 
    Meas = table2array(inputs(timestep+1,3:end));
    if timestep > 0
        % convert VAV airflows from cfm to kg/s
        Meas(11) = MyCtrl(1)*1.2*0.00047; 
        Meas(16) = MyCtrl(2)*1.2*0.00047;
        Meas(1) = MyCtrl(3)*1.2*0.00047;
        Meas(6) = MyCtrl(4)*1.2*0.00047;
    end
    %% Call Simulation
    [ZoneInfo,CtrlSig,MyCtrl]=callSim(HardwareTime,timestep,Meas);
    % Store data
    MyCtrlk(timestep+1,:) = MyCtrl;
    ZoneInfoK(timestep+1,:) = ZoneInfo;
end
[measTable] = measTablePass([],[],[],'get');
[zoneTable] = zoneTablePass([],[],[],'get');
[obmTable] = OBMTablePass([],[],[],'get');
[ctrlTable] = ctrlTablePass([],[],[],'get');

% Plot some comparisons between the simulation output and the real data
x = 0:1440;
figure(1)
subplot(2,2,1)
plot(old.HardwareData.processData2.comms_timestep,old.HardwareData.scaledData2.ahu1_fan_power), hold on
plot(x,MyCtrlk(:,14)), hold off
legend('Data','Sim')
title('AHU1 Power')
subplot(2,2,2)
plot(old.HardwareData.processData2.comms_timestep,old.HardwareData.scaledData2.ahu2_fan_power), hold on
plot(x,MyCtrlk(:,13)), hold off
legend('Data','Sim')
title('AHU2 Power')
subplot(2,2,3)
plot(old.HardwareData.processData2.comms_timestep,old.HardwareData.processData2.ahu1_fan_sp_inh2o), hold on
plot(x,ctrlTable.P_sp_ahu1*0.00401865), hold off
legend('Data','Sim')
title('P_{sp_ahu1}')
subplot(2,2,4)
plot(old.HardwareData.processData2.comms_timestep,old.HardwareData.processData2.ahu2_fan_sp_inh2o), hold on
plot(x,ctrlTable.P_sp_ahu2*0.00401865), hold off
legend('Data','Sim')
title('P_{sp_ahu2}')

figure(2)
subplot(2,2,1)
plot([old.SimData.T_z1_ahu1]-[old.SimData.Tz_cspt_z1_ahu1]), hold on
plot(x,zoneTable.T_z1_ahu1-zoneTable.Tz_cspt_z1_ahu1), hold off
legend('data','sim')
title('3')
subplot(2,2,2)
plot([old.SimData.T_z2_ahu1]-[old.SimData.Tz_cspt_z2_ahu1]), hold on
plot(x,zoneTable.T_z2_ahu1-zoneTable.Tz_cspt_z2_ahu1), hold off
legend('data','sim')
title('4')
subplot(2,2,3)
plot([old.SimData.T_z1_ahu2]-[old.SimData.Tz_cspt_z1_ahu2]), hold on
plot(x,zoneTable.T_z1_ahu2-zoneTable.Tz_cspt_z1_ahu2), hold off
legend('data','sim')
title('1')
subplot(2,2,4)
plot([old.SimData.T_z2_ahu2]-[old.SimData.Tz_cspt_z2_ahu2]), hold on
plot(x,zoneTable.T_z2_ahu2-zoneTable.Tz_cspt_z2_ahu2), hold off
legend('data','sim')
title('2')

figure(3)
subplot(2,2,1)
plot(old.HardwareData.processData2.comms_timestep,old.HardwareData.processData2.vav1_d_sp), hold on
plot(x,MyCtrlk(:,1)), hold off
legend('data','sim')
grid on
title('VAV1')
subplot(2,2,2)
plot(old.HardwareData.processData2.comms_timestep,old.HardwareData.processData2.vav2_d_sp), hold on
plot(x,MyCtrlk(:,2)), hold off
legend('data','sim')
grid on
title('VAV2')
subplot(2,2,3)
plot(old.HardwareData.processData2.comms_timestep,old.HardwareData.processData2.vav3_d_sp), hold on
plot(x,MyCtrlk(:,3)), hold off
legend('data','sim')
grid on
title('VAV3')
subplot(2,2,4)
plot(old.HardwareData.processData2.comms_timestep,old.HardwareData.processData2.vav4_d_sp), hold on
plot(x,MyCtrlk(:,4)), hold off
legend('data','sim')
grid on
title('VAV4')
