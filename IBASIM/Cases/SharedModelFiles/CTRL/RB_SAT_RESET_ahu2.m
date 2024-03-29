function T_SA = RB_SAT_RESET_ahu2(d1,d2,rh1,rh2,V_cc,vfd,T_SA_current)
%% inputs
% d1: position of the damper in the VAV box for zone 1, 2V=<d1=<10V
% d2: position of the damper in the VAV box for zone 2, 2V=<d1=<10V
% rh1: status of reheat for the VAV in zone 1, 0 or 1
% rh2: status of reheat for the VAV in zone 2, 0 or 1
% V_cc: cooling coil valve position, 2V=<V_cc=<6.5V
% vfd: fan speed, 15Hz=<vfd=<60Hz
%% outputs
% T_SA: AHU supply air temperature setpoint [°C]
%% main program
persistent T_design N N_req V Hz n delta n_req Low High T_max T_min T_SA_rec
if isempty(T_design)
    T_design=12.8;  % Supply air temperature design value [C]
    N=0;            % Count of timesteps between SP changes
    n=14;           % Number of timesteps between supply air temperature change [12min]
    N_req=0;        % Number of requests for cooling during the interval 
    n_req=2;        % The number of requests for more cooling 
    V=15;           % Threshold to indicate that the dampers is fully open [V]
    Hz=55;          % Threshold to indicate that the fan is delivering the maximum air vloume [Hz]
    delta=0.1;      % The amount of changing the supply air temperature [C]
    Low=2;          % The minimum position of cooling coil valve [V]
    High=6.5;       % The maximum position of cooling coil valve [V]
    T_max=18.3;     % The maximum supply air temperature [C]
    T_min=10;       % The minimum supply air temperature [C]
    T_SA_rec= T_design;  % The recording of all supply air temperature setpoint control signal [C]
end

N=N+1;
rh=rh1+rh2;
d=d1+d2;

if rh<1 && d>V && vfd>Hz 
    % no reheat coil running, damper position higher than the damper-opening threshold 15V,
    % and fan speed higher than the threshold indicating the the fan is delivering the largest volume 55Hz
    N_req=N_req+1;
end

T_SA_current=T_SA_rec(end);
if N>n
    % time to determine if the setpoint should be reset, the T_SA will be
    % reset every 12 min
    N=0;
    if N_req<1   % In 12 min, there is not more cooling requestment
        T0=T_SA_current+delta;
    elseif N_req>n_req     % In 12 min, there is more then 2 cooling requestment
        T0=T_SA_current-delta;
    else     % In 12 min, there is just 1 or 2 cooling requestment
        T0=T_SA_current;
    end
    N_req=0;
    
    if (V_cc<1.05*Low && T0>T_SA_current) || (V_cc>0.98*High && T0<T_SA_current)
        % if the cooling coil is already in the loweset position, and need
        % a warmer supply air, the supply air will be keep current
        % temperature; Similarly, vice versa
        T0=T_SA_current;
    end
else
    T0=T_SA_current;
end

T_SA=max(min(T0,T_max),T_min);
T_SA_rec=[T_SA_rec;T_SA];
end
