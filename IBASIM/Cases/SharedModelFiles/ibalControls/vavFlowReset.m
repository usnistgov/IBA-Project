% Specific to DOE testing, where occupancy is between timesteps 360 and
% 1200. FRmode = 1 if in occupied mode, 0 otherwise.

function [N,mode,counts,Tzsp,simOn] = vavFlowReset(N,Tz,Tzcsp,Tzhsp,F,uheat,Tdsp,Tvavin,Fmin,mode,ts,units,counts,simOn)
    [counts,Tzsp,simOn] = thermostat(Tzcsp,Tzhsp,Tz,units,counts,simOn);
    [N,mode] = vavMode(N,Tz,Tzsp,F,uheat,Tdsp,Tvavin,Fmin,mode,ts,simOn);
end

function [N,mode] = vavMode(N,Tz,Tzsp,F,uheat,Tdsp,Tvavin,Fmin,mode,ts,simOn)
% Determine if the mode of operation is cooling or heating 
n = 6; % timesteps between setpoint changes
db = 0; % [F] deadband
Tdmax = 90; % [F] max reheat temperature
N = N+1;


if (ts == 359)
    gr = 1;
end
%if (ts < 360)||(ts >= 1200)
if CtrlSig(2,1) <1 % sys_status < 1
    mode = 2;
elseif (ts >= 360+12)&&(ts < 1200)    
    if N > n
        N = 0;
        if (Tz < Tzsp-db)&&(F < 1.02*Fmin)
            mode = 1*simOn(2);
        elseif (mode == 1)&&(Tz < Tzsp-db)&&(Tdsp > 0.98*Tdmax)
            mode = 1*simOn(2);
        elseif (mode == 1)&&(uheat > 0.001)
            mode = 1*simOn(2);
        elseif (mode == 1)&&(Tdsp > Tvavin+1.5)
            mode = 1*simOn(2);
        else
            mode = 0*simOn(1);           
        end
    else
        mode = mode;
    end
else
    mode = 0;
end
end

function [counts,Tzsp,simOn] = thermostat(Tzcsp,Tzhsp,Tz,units,counts,simOn)
    if strcmp(units,'C')
        Tzcsp = Tzcsp*9/5+32;
        Tzhsp = Tzhsp*9/5+32;
        Tz = Tz*9/5+32;
    end
    cool = counts(1);
    heat = counts(2);
    if Tz > Tzcsp
        cool = cool + 1;
        heat = 0;
    elseif Tz < Tzhsp
        cool = 0;
        heat = 1;
    else
        cool = 0;
        heat = 1;
    end
    
    if cool >= 2
        simCoolOn = 1;
        simHeatOn = 0;
    elseif heat >= 2
        simCoolOn = 0;
        simHeatOn = 1; 
    else
        simCoolOn = 0;
        simHeatOn = 0; 
    end
    
    if (simCoolOn < 1)&&(simHeatOn < 1)
        simCoolOn = simOn(1);
        simHeatOn = simOn(2);
    elseif (simCoolOn > 0)&&(simOn(2) > 0)
         % switch modes -  in cooling, go to heating
         simCoolOn = 0;
         simHeatOn = 1;
    elseif (simOn(1) > 0)&&(simHeatOn > 0)  
         % switch modes -  in heating, go to cooling
         simCoolOn = 1;
         simHeatOn = 0;
    end
    
    if simHeatOn > 0
        Tzsp = Tzhsp;
    else
        Tzsp = Tzcsp;
    end
    counts(1) = cool;
    counts(2) = heat;
    simOn(1) = simCoolOn;
    simOn(2) = simHeatOn;
end


