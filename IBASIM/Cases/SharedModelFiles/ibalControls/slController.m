function [output] = slController(v12,v13,sys_status,ftotal)
    persistent count v12Sum v13Sum ftotalSum first_call cool
    % v12 = AHU1 cooling coil valve position; 2 to 8 V
    % v13 = AHU2 cooling coil valve position; 2 to 8 V
    % ftotal = Total airflow in cfm
    N = 2; % Lab value is 9; 9/6 = 1.5, so go with 2 for now 
    
    if isempty(first_call)
       count = 1;
       v12Sum = v12;
       v13Sum = v13;
       ftotalSum = ftotal;
       cool = 0;
       first_call = 0;
    end
    
    if sys_status < 1 % system is off, usually because there is no occupancy
       count = 1;
       v12Sum = v12;
       v13Sum = v13;
       ftotalSum = ftotal;
       cool = 0;    
    else
        count = count + 1;
        v12Sum = v12Sum + v12;
        v13Sum = v13Sum + v13;
        ftotalSum = ftotalSum + ftotal;
        
        v12Avg = v12Sum/count;
        v13Avg = v13Sum/count;
        ftotalAvg = ftotalSum/count;
        
        if count >= N
            if (ftotalAvg > 100)&&((v12Avg > 2)||(v13Avg > 2))
                cool = 1;
            else
                cool = 0;
            end
            count = 1;
           v12Sum = v12;
           v13Sum = v13;
           ftotalSum = ftotal;
        else
            cool = cool;
        end
    end  
    output = cool;
end