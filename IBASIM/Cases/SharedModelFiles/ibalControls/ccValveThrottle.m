function [uBias,count] = ccValveThrottle(tIn,PV,SP,high,low,CV,uBias,count)
    % The valves are non linear, so for some ranges there needs to be a
    % step change in the valve position.
    % Made some changes to values due to changes in ype 9031
    % Before 10/12: N = 3; inc = 0.025; thresh = 0.5
    % 10/12: N = 5; inc = 0.01
    N = 5; % 3
    thresh = 0.5;
    %inc = 0.15; lab value
    inc = 0.01; % 0.025 Make smaller to avoid cycling?
    
    %     if ((pump3+mode < 1)||(mode < 1)||(tIn >= PV+2)) 
    if tIn >= PV + 2
         delta = 0;
    else 
         delta = PV - SP; % The pump is on and/or it's PI mode
    end

    if (abs(delta) <= thresh)
        count = 0;
    else
        count = count + 1;
    end

    if (count >= N) 
         count = 0;
         if ((delta > 0)&&(CV < high-1)) % open more
              uBias = uBias + inc;
         elseif ((delta < 0)&&(CV > low+1)) % close more
              uBias = uBias - inc;
         else 
              uBias = uBias;
         end
    else 
         uBias = uBias;
    end 

    uBias = max(min(uBias,1),-1);
end