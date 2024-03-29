function P_sp = RB_SAP_RESET_ahu2_ajp(W,dA,dB,P_sp_current,Xpsp2)
%% inputs
% W: AHU power [W]
% dA: position of damper in VAV A [V]
% dB: position of damper in VAV B [V]
% P_sp_current: current supply air static pressure setpoint [Pa]
%% outputs
% P_sp: supply air static pressure setpoint[Pa]
%% main program
persistent SP0 N dSumA dSumB n deltaP Low High P_max P_min P_sp_rec psp2Model
if isempty(SP0)
    SP0=398.5;      % Default setpoint; when the system is off it will go to this SP and when it turns on it will start from this setpoint [Pa]
    N=0;            % Count of timesteps between SP changes
    n=14;           % Number of timesteps between supply air change [12min]
    deltaP=50;      % The amount of changing the supply air static pressure [Pa]
    Low=5;          % The threshold indicating the dampers are closed, less cooling [V]
    High=7;         % The threshold indicating the dampers are open, more cooling [V]
    dSumA=0;        % Sum of the damper position in VAV A
    dSumB=0;        % Sum of the damper position in VAV B
    P_max=996;      % The maximum value of the supply air static pressure [Pa]
    P_min=0;        % The minimum value of the supply air static pressure [Pa]
    P_sp_rec=SP0;   % The recording of all supply air static pressure setpoint control signal [Pa]
    psp2Model = load('psp2_3layer.mat');
end

P_sp_current=P_sp_rec(end);
if W>50   % if the fan is on
    N=N+1;
    if N>n
        [P_sp,Xf,Af] = psp_fan2_v2([Xpsp2,P_sp_current]);
        %P_sp = psp2Model.psp2_3layer.predictFcn([Xpsp2,P_sp_current]);
    else
        P_sp=P_sp_current;
    end
else
    P_sp=P_sp_current;
end


P_sp=max(min(P_sp,P_max),P_min);
P_sp_rec=[P_sp_rec; P_sp];
end
