function [tSP,simCoolOn,simHeatOn,counts,tFZone,FRmode,TRmode] = thermostat(tCCool,tCHeat,tZSim,counts,ts,simCoolOn,simHeatOn)
    tFCool = 9/5*tCCool+32;
    tFHeat = 9/5*tCHeat+32;
    tFZone = 9/5*tZSim+32;
    if ts > 360 + 2 %12 steps in the lab is 2 minutes in simulation time        
        cool = counts(1);
        heat = counts(2);

        % // Increment the cooling or heating counter
        if ((tFZone > tFCool)) 
             cool = cool + 1;
             heat = 0;
        elseif ((tFZone < tFHeat)) 
             cool = 0;
             heat = heat + 1;
        else 
             cool = 0;
             heat = 0;
        end

        % // Calculate what mode you'd be in right now
        if (cool >= 2) 
             simCoolOn0 = 1;
             simHeatOn0 = 0;
        elseif (heat >= 2) 
             simCoolOn0 = 0;
             simHeatOn0 = 1;
        else 
             simCoolOn0 = 0;
             simHeatOn0 = 0;
        end

        % // If you currenlty aren't in any mode, go ahead and be in the designated mode
        if ((simCoolOn < 1)&&(simHeatOn < 1)) 
             simCoolOn = simCoolOn0;
             simHeatOn = simHeatOn0;   
        elseif ((simCoolOn > 0)&&(simHeatOn0 > 0))  
             % // switch modes -  in cooling, go to heating
             simCoolOn = 0;
             simHeatOn = 1;
        elseif ((simCoolOn0 > 0)&&(simHeatOn > 0))  
             % // switch modes -  in heating, go to cooling
             simCoolOn = 1;
             simHeatOn = 0;
        else 
             % // do nothing
             simCoolOn = simCoolOn;
             simHeatOn = simHeatOn; 
        end

        if (simHeatOn > 0) 
             tSP = tFHeat;
        else 
             tSP = tFCool;
        end

        counts(1) = cool;
        counts(2) = heat;
    else
        tSP = tFCool;
        counts = [0,0];
        simCoolOn = 0;
        simHeatOn = 0;
    end
    
    if simCoolOn > 0
        FRmode = 1;
    else
        FRmode = 0;
    end
    if simHeatOn > 0
        TRmode = 1;
    else
        TRmode = 0;
    end
end