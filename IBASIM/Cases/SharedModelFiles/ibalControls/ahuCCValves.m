function [ahu1_cc_valve,ahu2_cc_valve,pTerms1,pTerms2] = ahuCCValves(timestep,ZoneInfo,CtrlSig,Meas,T)
    persistent PI_ahu1_cc
    persistent PI_ahu2_cc
    persistent first_call
       
    line = 'ahu_cc_6';
    save('callsim.mat','line')   
    if isempty(first_call)
        % Set PI parameter values and initial values for everything
        % Original Kp and Ki are 3 and 0.01; Changed because I was getting
        % oscillations in TRNSYS
        % Changes are due to changes in type 9031; see dates in that type
        % to see where parameter values were changed.
        % Before 10/12: kp = 1, ki = 0.001
        % 10/12 values: kp = 0.15, ki = 0.001
        % 10/13 values: kp = 0.05, ki = 0.001
        first_call = 1; 
        PI_ahu1_cc.kp = 0.15; PI_ahu1_cc.ki = 0.001; PI_ahu1_cc.eulow = 2;
        PI_ahu1_cc.kd = 0; PI_ahu1_cc.action = -1; PI_ahu1_cc.euhigh = 8;
        PI_ahu1_cc.sphigh = 70; PI_ahu1_cc.splow = 30; PI_ahu1_cc.uBias = 0;
        PI_ahu1_cc.wlb = 1.02; PI_ahu1_cc.wub = 0.98; PI_ahu1_cc.ns = 0; % scaling is Default Scaling
        PI_ahu1_cc.na = 0; PI_ahu1_cc.dt = 60; PI_ahu1_cc.accIn = 0; 
        PI_ahu1_cc.PVPrev = 0; PI_ahu1_cc.errPrev = 0; PI_ahu1_cc.resetUsed = 0;
        PI_ahu1_cc.reset = 0; PI_ahu1_cc.uBiasReset = 0; PI_ahu1_cc.uScaled = 3;
        
        PI_ahu1_cc.errNow = 0; PI_ahu1_cc.errRate = 0; PI_ahu1_cc.dTerm = 0;
        PI_ahu1_cc.pTerm = 0; PI_ahu1_cc.iTerm = 0; PI_ahu1_cc.uRaw = 0; 
        PI_ahu1_cc.cBias = 0; PI_ahu1_cc.count = 0;
        
        PI_ahu2_cc.kp = 0.15; PI_ahu2_cc.ki = 0.001; PI_ahu2_cc.eulow = 2;
        PI_ahu2_cc.kd = 0; PI_ahu2_cc.action = -1; PI_ahu2_cc.euhigh = 8;
        PI_ahu2_cc.sphigh = 70; PI_ahu2_cc.splow = 30; PI_ahu2_cc.uBias = 0;
        PI_ahu2_cc.wlb = 1.02; PI_ahu2_cc.wub = 0.98; PI_ahu2_cc.ns = 0; % scaling is Default Scaling
        PI_ahu2_cc.na = 0; PI_ahu2_cc.dt = 60; PI_ahu2_cc.accIn = 0; 
        PI_ahu2_cc.PVPrev = 0; PI_ahu2_cc.errPrev = 0; PI_ahu2_cc.resetUsed = 0;
        PI_ahu2_cc.reset = 0; PI_ahu2_cc.uBiasReset = 0; PI_ahu2_cc.uScaled = 3;
        
        PI_ahu2_cc.errNow = 0; PI_ahu2_cc.errRate = 0; PI_ahu2_cc.dTerm = 0;
        PI_ahu2_cc.pTerm = 0; PI_ahu2_cc.iTerm = 0; PI_ahu2_cc.uRaw = 0; 
        PI_ahu2_cc.cBias = 0; PI_ahu2_cc.count = 0;
        
        
        line = 'ahu_cc_34';
        save('callsim.mat','line')   
    else
        first_call = 0;        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % Set PV and SP
    PI_ahu1_cc.SP = CtrlSig(2,7)*9/5+32; %SP(1);
    PI_ahu1_cc.PV = T(1)*9/5+32;
    
    PI_ahu2_cc.SP = CtrlSig(2,8)*9/5+32; %SP(2);  
    PI_ahu2_cc.PV = T(2)*9/5+32;
    
    line = 'ahu_cc_52';
    save('callsim.mat','T')   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%     % Move valve to get a faster response
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    %if ((timestep >= 360) && (timestep<=1200))
    if CtrlSig(2,1) > 0 % sys_status > 0
        PI_ahu1_cc.enablePI = 1;
        [PI_ahu1_cc.uBias,PI_ahu1_cc.count] = ccValveThrottle(Meas(49)*9/5+32,...
        PI_ahu1_cc.PV,PI_ahu1_cc.SP,PI_ahu1_cc.euhigh,PI_ahu1_cc.eulow,...
        PI_ahu1_cc.uScaled,PI_ahu1_cc.uBias,PI_ahu1_cc.count);
    
        PI_ahu2_cc.enablePI = 1;
        [PI_ahu2_cc.uBias,PI_ahu2_cc.count] = ccValveThrottle(Meas(49)*5/9+32,...
        PI_ahu2_cc.PV,PI_ahu2_cc.SP,PI_ahu2_cc.euhigh,PI_ahu2_cc.eulow,...
        PI_ahu2_cc.uScaled,PI_ahu2_cc.uBias,PI_ahu2_cc.count);
    else
        PI_ahu1_cc.enablePI = 0;
        PI_ahu2_cc.enablePI = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Run the PI code
    if PI_ahu1_cc.enablePI > 0
        PI_ahu1_cc.init = 0;
        [PI_ahu1_cc] = PI_v2(PI_ahu1_cc);
    else
        PI_ahu1_cc.init = 1;
        [PI_ahu1_cc] = PI_v2(PI_ahu1_cc);
    end

    if PI_ahu2_cc.enablePI > 0
        PI_ahu2_cc.init = 0;
        [PI_ahu2_cc] = PI_v2(PI_ahu2_cc);
    else
        PI_ahu2_cc.init = 1;
        [PI_ahu2_cc] = PI_v2(PI_ahu2_cc);
    end
    line = 'ahu_cc_79';
    save('callsim.mat','line')  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Assign values for output
    ahu1_cc_valve = PI_ahu1_cc.uScaled; %V
    ahu2_cc_valve = PI_ahu2_cc.uScaled; %V
	
	ahu1_cc_valve = min(max(ahu1_cc_valve,2),8)*1/6-1/3; %min(max(0,ahu1_cc_valve),10)/10; %
	ahu2_cc_valve = min(max(ahu2_cc_valve,2),8)*1/6-1/3; %min(max(0,ahu2_cc_valve),10)/10; %

    pTerms1 = PI_ahu1_cc;
    pTerms2 = PI_ahu2_cc;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
end