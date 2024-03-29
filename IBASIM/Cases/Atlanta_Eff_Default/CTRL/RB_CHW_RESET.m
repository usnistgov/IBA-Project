function [T_chwst,DP_slSP] = RB_CHW_RESET(chMode,dpMode,T_chwst_current,DP_slSP_current,W,v12,v13)
%% Inputs
% chMode: 1(Manual) – manually set the chiller setpoint; 2(Auto) – automatically set the chiller setpoint; requires that the chiller is on
% dpMode: 1(Manual) – manually set the secondary loop DP setpoint; 2(Auto) – automatically set the secondary loop DP setpoint; requires that the pump is on
% T_chwset_current: chilled water temperature setpoint [°C]
% DP_slSP_current: chilled water secondary loop pressure setpoint[kPa]
% W: AHU voltage? [V]
% v12: cooling coil valve position in AHU1 [V]
% v13: cooling coil valve position in AHU2 [V]
%% Outputs
% T_chwst: chilled water temperature setpoint[°C]
% DP_slSP: chilled water static pressure setpoint[kPa]
%% Parameters
persistent T_min T_max N_chwst N_chwsp v12Sum v13Sum n_chwst n_chwsp High Low deltaT deltaP DP_max DP_min CHW_control_rec
if isempty(T_min)
    T_min=4.4;       % Minimum chiller setpoint [C]
    T_max=21.1;      % Maximum chiller setpoint [C]
    N_chwst=0;       % Count of timesteps between chilled water temerature changes
    n_chwst=14;      % Number of timesteps between chilled water temperature changes [18min]
    deltaT=0.28;     % The amount by which to change chilled water temperature [C]
    N_chwsp=0;       % Count of timesteps between chilled water static pressure changes
    n_chwsp=14;      % Number of timesteps between chilled water static pressure changes [12min]
    deltaP=13.8;     % The amount by which to change chilled water static pressure [kPa]
    DP_max=551.6;      % The maximum value of the chilled water static pressure [kPa]
    DP_min=103.4;    % The minimum value of the chilled water static pressure [kPa]
    v12Sum=0;        % sum of the cooling coil valve position in AHU1
    v13Sum=0;        % sum of the cooling coil valve position in AHU2
    High=6;          % Threshold to indicate that the valves are open, indicating more cooling is needed [V]
    Low=3.1;         % Threshold to indicate that the valves are closed, indicating less cooling is needed [V]   
    CHW_control_rec=[10,551.6]; % The recording of all chilled water control signal, chilled water temperature [C] and chilled water static pressure [kPa]
end
%% Mode determination
if chMode==2 && dpMode==2    % both controllers are in auto mode and the chiller and secondary loop pump are on
    if T_chwst_current>T_min && T_chwst_current<T_max
        mode=1;      % vary the chiller setpoint
    else
        mode=2;      % vary the damper setpoint
    end
elseif chMode==2 && dpMpde==1
    mode=1;
else
    mode=2;
end

T_chwst_current=CHW_control_rec(end,1);
DP_slSP_current=CHW_control_rec(end,2);
T_chwst=T_chwst_current;
DP_slSP=DP_slSP_current;

%% Reset
if W>100 && mode==1   % The chiller is on and the mode is CHWST
    N_chwst=N_chwst+1;
    v12Sum=v12Sum+v12;
    v13Sum=v13Sum+v13;
    if N_chwst>n_chwst
        if (v12Sum/N_chwst)>High || (v13Sum/N_chwst)>High  % more cooling is needed
            T_chwst=T_chwst_current-deltaT;
        elseif (v12Sum/N_chwst)<Low && (v13Sum/N_chwst)<Low
            T_chwst=T_chwst_current+deltaT;
        end
        N_chwst=0;
        v12Sum=0;
        v13Sum=0;
    end
    T_chwst=max(min(T_chwst,T_max),T_min);  
elseif W>50 && mode==2    % the pump is on and the mode is DP
    N_chwsp=N_chwsp+1;
    v12Sum=v12Sum+v12;
    v13Sum=v13Sum+v13;
    if N_chwsp>n_chwsp
        if (v12Sum/N_chwsp)>High || (v13Sum/N_chwsp)>High  % more cooling is needed
            DP_slSP=DP_slSP_current+deltaP;
        elseif (v12Sum/N_chwsp)<Low && (v13Sum/N_chwsp)<Low
            DP_slSP=DP_slSP_current-deltaP;
        end
        N_chwsp=0;
        v12Sum=0;
        v13Sum=0;
    end
    DP_slSP=max(min(DP_slSP,DP_max),DP_min);
end
CHW_control=[T_chwst,DP_slSP];
CHW_control_rec=[CHW_control_rec;CHW_control];
end
