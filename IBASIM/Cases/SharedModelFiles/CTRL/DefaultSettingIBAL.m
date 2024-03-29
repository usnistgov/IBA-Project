function [T_chwst,DP_slSP,P_sp_ahu1,P_sp_ahu2,T_SA_ahu1,T_SA_ahu2,Tz_hspt,Tz_cspt]=DefaultSettingIBAL(sys_status,Season_type,Occupied)
% Set the defaut value for IBAL
T_chwst = 4.44;   % [°C] 40°F
DP_slSP = 551.6;  % [kPa] 80psi
P_sp_ahu1 = 398.5; % [Pa] 1.6 inwg
P_sp_ahu2 = 398.5; % [Pa] 1.6 inwg
T_SA_ahu1 = 12.8;   % [°C] 55°F
T_SA_ahu2 = 12.8;   % [°C] 55°F
if Season_type==1
    if sys_status==1
        Tz_hspt = 68;     % [°F]
        Tz_cspt = 78;     % [°F]
    else
        Tz_hspt = 55;     % [°F]
        Tz_cspt = 90;     % [°F]
    end
else
    if sys_status==1 
        Tz_hspt = 68;     % [°F]
        Tz_cspt = 78;     % [°F]
    else
        Tz_hspt = 55;     % [°F]
        Tz_cspt = 90;     % [°F]
    end
end
end