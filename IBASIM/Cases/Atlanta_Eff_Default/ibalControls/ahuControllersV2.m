function [ahu1_vfd,ahu2_vfd,pTerms1,pTerms2] = ahuControllersV2(timestep,ZoneInfo,CtrlSig,P)
    persistent PI_ahu1_fan
    persistent PI_ahu2_fan
    persistent first_call
    
    line = 'ahu_6';
    save('callsim.mat','line')   
    if isempty(first_call)
        % Set PI parameter values and initial values for everything
        first_call = 1; 
        PI_ahu1_fan.kp = 0.25; PI_ahu1_fan.ki = 0.01; PI_ahu1_fan.eulow = 15;
        PI_ahu1_fan.kd = 0; PI_ahu1_fan.action = 1; PI_ahu1_fan.euhigh = 60;
        PI_ahu1_fan.sphigh = 4; PI_ahu1_fan.splow = 0; PI_ahu1_fan.uBias = 0.25;
        PI_ahu1_fan.wlb = 1.02; PI_ahu1_fan.wub = 0.98; PI_ahu1_fan.ns = 0; % scaling is Default Scaling
        PI_ahu1_fan.na = 0; PI_ahu1_fan.dt = 60;PI_ahu1_fan.accIn = 0; 
        PI_ahu1_fan.PVPrev = 0; PI_ahu1_fan.errPrev = 0; PI_ahu1_fan.resetUsed = 0;
        PI_ahu1_fan.reset = 0; PI_ahu1_fan.uBiasReset = 0; PI_ahu1_fan.uScaled = 30;
        
        PI_ahu1_fan.errNow = 0; PI_ahu1_fan.errRate = 0; PI_ahu1_fan.dTerm = 0;
        PI_ahu1_fan.pTerm = 0; PI_ahu1_fan.iTerm = 0; PI_ahu1_fan.uRaw = 0; 
        PI_ahu1_fan.cBias = 0; 
        
        PI_ahu2_fan.kp = 0.25; PI_ahu2_fan.ki = 0.01; PI_ahu2_fan.eulow = 15;
        PI_ahu2_fan.kd = 0; PI_ahu2_fan.action = 1; PI_ahu2_fan.euhigh = 60;
        PI_ahu2_fan.sphigh = 4; PI_ahu2_fan.splow = 0.3; PI_ahu2_fan.uBias = 0.25;
        PI_ahu2_fan.wlb = 1.02; PI_ahu2_fan.wub = 0.98; PI_ahu2_fan.ns = 0; % scaling is No Scaling
        PI_ahu2_fan.na = 0; PI_ahu2_fan.dt = 60;PI_ahu2_fan.accIn = 0; 
        PI_ahu2_fan.PVPrev = 0; PI_ahu2_fan.errPrev = 0; PI_ahu2_fan.resetUsed = 0;
        PI_ahu2_fan.reset = 0; PI_ahu2_fan.uBiasReset = 0; PI_ahu2_fan.uScaled = 30;
        
        PI_ahu2_fan.errNow = 0; PI_ahu2_fan.errRate = 0; PI_ahu2_fan.dTerm = 0;
        PI_ahu2_fan.pTerm = 0; PI_ahu2_fan.iTerm = 0; PI_ahu2_fan.uRaw = 0; 
        PI_ahu2_fan.cBias = 0;         
        line = 'ahu_34';
        save('callsim.mat','line')   
    else
        first_call = 0;        
    end
%     if dt > 0
%         PI_ahu1_fan.dt = dt;
%         PI_ahu2_fan.dt = dt;    
%     end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % Set PV and SP
    PI_ahu1_fan.SP = CtrlSig(2,5)*0.00401865; %SP(1); Convert from Pa to inH2O
    PI_ahu1_fan.PV = P(1);
    
    PI_ahu2_fan.SP = CtrlSig(2,6)*0.00401865; %SP(2);  
    PI_ahu2_fan.PV = P(2);
    
    line = 'ahu_52';
    save('callsim.mat','P')   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if timestep >= 360
        PI_ahu1_fan.enablePI = 1;
        PI_ahu2_fan.enablePI = 1;
    else
        PI_ahu1_fan.enablePI = 0;
        PI_ahu2_fan.enablePI = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Run the PI code
    if PI_ahu1_fan.enablePI > 0
        PI_ahu1_fan.init = 0;
        [PI_ahu1_fan] = PI_v2(PI_ahu1_fan);
    else
        PI_ahu1_fan.init = 1;
        [PI_ahu1_fan] = PI_v2(PI_ahu1_fan);
    end

    if PI_ahu2_fan.enablePI > 0
        PI_ahu2_fan.init = 0;
        [PI_ahu2_fan] = PI_v2(PI_ahu2_fan);
    else
        PI_ahu2_fan.init = 1;
        [PI_ahu2_fan] = PI_v2(PI_ahu2_fan);
    end
    line = 'ahu_79';
    save('callsim.mat','line')  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Assign values for output
    ahu1_vfd = PI_ahu1_fan.uScaled*1800/60; %rpm
    ahu2_vfd = PI_ahu2_fan.uScaled*1800/60; %rpm

    pTerms1 = PI_ahu1_fan;
    pTerms2 = PI_ahu2_fan;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
end