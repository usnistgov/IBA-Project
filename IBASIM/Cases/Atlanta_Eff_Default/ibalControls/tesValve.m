function [v8,pTerms] = tesValve(CtrlSig,Meas)
    persistent PI_tes
    persistent first_call
    
    tsMode = CtrlSig(2,9);
    t_chwst = CtrlSig(2,3);
    ts_out_rtd = Meas(71);
    
    if isempty(first_call)
        % Set PI parameter values and initial values for everything
        % Original Kp and Ki are 3 and 0.01; Changed because I was getting
        % oscillations in TRNSYS
        first_call = 1; 
        PI_tes.kp = 0.5; PI_tes.ki = 0.013; PI_tes.eulow = 0;
        PI_tes.kd = 0; PI_tes.action = -1; PI_tes.euhigh = 9.5;
        PI_tes.sphigh = 65; PI_tes.splow = 30; PI_tes.uBias = 0.5;
        PI_tes.wlb = 1.02; PI_tes.wub = 0.98; PI_tes.ns = 0; % scaling is Default Scaling
        PI_tes.na = 0; PI_tes.dt = 60; PI_tes.accIn = 0; 
        PI_tes.PVPrev = 0; PI_tes.errPrev = 0; PI_tes.resetUsed = 0;
        PI_tes.reset = 0; PI_tes.uBiasReset = 0; PI_tes.uScaled = 0;
        
        PI_tes.errNow = 0; PI_tes.errRate = 0; PI_tes.dTerm = 0;
        PI_tes.pTerm = 0; PI_tes.iTerm = 0; PI_tes.uRaw = 0; 
        PI_tes.cBias = 0; PI_tes.count = 0;       
       
        line = 'tes_v8_26';
        save('callsim.mat','line','PI_tes')   
    else
        first_call = 0;        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % Set PV and SP
    PI_tes.SP = t_chwst*9/5+32; %SP(1);
    PI_tes.PV = ts_out_rtd*9/5+32;    
            line = 'tes_v8_35';
        save('callsim.mat','line','PI_tes')   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    if (tsMode == 1) 
        PI_tes.enablePI = 1;
    else
        PI_tes.enablePI = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Run the PI code
    if PI_tes.enablePI > 0
        PI_tes.init = 0;
        [PI_tes] = PI_v2(PI_tes);
    else
        PI_tes.init = 1;
        [PI_tes] = PI_v2(PI_tes);
    end
            line = 'tes_v8_52';
        save('callsim.mat','line','PI_tes')   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Assign values for output
    if tsMode == 2
        v8 = 1;
    else
        v8 = PI_tes.uScaled/10; %V
    end
    pTerms = PI_tes;
            line = 'tes_v8_62';
        save('callsim.mat','line','PI_tes','v8')   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
end