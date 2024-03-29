function [ahu1_cc_valve,ahu2_cc_valve] = ahuCCValves_NN(timestep,vav)
    persistent ahu1Model ahu2Model
    if timestep == 0
        ahu1Model = load('E:\EDrive\Tests\TRNSYS\Cases\Atlanta_Eff_Default\ibalControls\cc1Valve3Layer.mat');
        ahu2Model = load('E:\EDrive\Tests\TRNSYS\Cases\Atlanta_Eff_Default\ibalControls\cc2Valve3Layer.mat');
    end
    zoneTable = zoneTablePass([],[],[],'get');
    ctrlTable = ctrlTablePass([],[],[],'get');
    measTable = measTablePass([],[],[],'get');
    zone = zoneTable(timestep+1,:); 
    ctrl = ctrlTable(timestep+1,:);
    meas = measTable(timestep+1,:);
    X1 = [ctrl.T_SA_ahu1,meas.ahu1_out_rtd,vav(3),vav(4),ctrl.T_chwst,...
          zone.Qsen_z1_ahu1+zone.Qlat_z1_ahu1,zone.Qsen_z2_ahu1+zone.Qlat_z2_ahu1];
    X1 = array2table(X1,'VariableNames',{'Tsp1', 'ahu1_out_rtd', 'vav3', 'vav4', 'T_chw_sp', 'q_zs3', 'q_zs4'});
    X2 = [ctrl.T_SA_ahu2,meas.ahu2_out_rtd,vav(1),vav(2),ctrl.T_chwst,...
          zone.Qsen_z1_ahu2+zone.Qlat_z1_ahu2,zone.Qsen_z2_ahu2+zone.Qlat_z2_ahu2];
    ahu1_cc_valve = min(max(ahu1Model.trainedModel1.predictFcn(X1),0),10);
    ahu2_cc_valve = min(max(ahu2Model.trainedModel.predictFcn(X2),0),10);
end