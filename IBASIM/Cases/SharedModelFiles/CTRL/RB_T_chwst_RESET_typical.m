function [T_chwst] = RB_T_chwst_RESET_typical(To)
%% Inputs
% To:  simulated outdoor air temperature [°C]
%% Outputs
% T_chwst: chilled water temperature setpoint[°C]
%% main program
persistent N n T_chwst0 T_chwst_rec T_out_rec
if isempty(n)
    N=0;            % Count of timesteps between chilled water temperature setpoint changes
    n=14;           % Number of timesteps between the change [15min]
    T_chwst0=max(min((To*(-0.2671)+13.0462)*1.8+32,48),40);    % Initial chilled water temperature setpoint [F]
    T_chwst_rec=T_chwst0;   % The recording of chilled water temperature setpoint
    T_out_rec=zeros(1,n+1); % The recording of all outdoor air temperature
end

N=N+1;
if N<=n
    T_chwst=T_chwst_rec;
    T_out_rec(N)=To;
else
    %% Linear algorithm
    T_out_rec(N)=To;
    To=mean(T_out_rec*1.8+32);  % convert to F
    if To>90
        T_chwst=40;
    elseif To<60
        T_chwst=48;
    else
        T_chwst=(-8/30)*To+64;
    end
    T_chwst_rec=T_chwst;
    N=0;
    T_out_rec=zeros(1,n+1);
end

T_chwst=(T_chwst-32)/1.8
end
