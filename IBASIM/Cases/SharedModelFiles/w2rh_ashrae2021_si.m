function RH = w2rh_ashrae2021_si(w,T,P)
% Inputs
% w:    Humidity ratio [kg/kg]
% T:    Temperature [C]
% P:    Pressure [kPa]
% Outputs
% RH:   Relative Humidity [%]
%% Main
% saturation pressure
pws = t2pws_ashrae2021_si(T);
% water vapor pressure
pw = w.*P./(0.621945+w);
% relative humidity
RH = 100*pw./pws;
end

