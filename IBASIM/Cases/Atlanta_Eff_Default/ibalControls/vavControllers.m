function [vav1_d_sp,vav2_d_sp,vav3_d_sp,vav4_d_sp,Tz1SP,Tz2SP,Tz3SP,Tz4SP,ahu1VentAir,ahu2VentAir] = vavControllers(timestep,ZoneInfo,CtrlSig,Meas)
    persistent PI_vav1_fr
    persistent PI_vav2_fr
    persistent PI_vav3_fr
    persistent PI_vav4_fr
    persistent first_call
    persistent PI_vav2_fr_array
    persistent simCoolOn1 simHeatOn1 counts1 store1 
    persistent simCoolOn2 simHeatOn2 counts2 store2 
    persistent simCoolOn3 simHeatOn3 counts3 store3 
    persistent simCoolOn4 simHeatOn4 counts4 store4 
    
    vavHeatC = 0;
    doeMode = 1; n_reset = 0; dbH = 0; tHMax = 90;
    
    if isempty(first_call)
        % Set PI parameter values and initial values for everything
        first_call = 1; 
        PI_vav1_fr.kp = 0.5; PI_vav1_fr.ki = 0.0001;
        PI_vav1_fr.kd = 0; PI_vav1_fr.action = -1; PI_vav1_fr.euhigh = 930;
        PI_vav1_fr.sphigh = 90; PI_vav1_fr.splow = 50; PI_vav1_fr.uBias = 0;
        PI_vav1_fr.wlb = 1.05; PI_vav1_fr.wub = 0.95; PI_vav1_fr.ns = 1; % scaling is No Scaling
        PI_vav1_fr.na = 0; PI_vav1_fr.dt = 60;PI_vav1_fr.accIn = 0; 
        PI_vav1_fr.PVPrev = 0; PI_vav1_fr.errPrev = 0; PI_vav1_fr.resetUsed = 0;
        PI_vav1_fr.reset = 0; PI_vav1_fr.uBiasReset = 0; PI_vav1_fr.uScaled = 200;

        PI_vav2_fr.kp = 0.5; PI_vav2_fr.ki = 0.0001;
        PI_vav2_fr.kd = 0; PI_vav2_fr.action = -1; PI_vav2_fr.euhigh = 930;
        PI_vav2_fr.sphigh = 90; PI_vav2_fr.splow = 50; PI_vav2_fr.uBias = 0;
        PI_vav2_fr.wlb = 1.05; PI_vav2_fr.wub = 0.95; PI_vav2_fr.ns = 1; % scaling is No Scaling
        PI_vav2_fr.na = 0; PI_vav2_fr.dt = 60;PI_vav2_fr.accIn = 0; 
        PI_vav2_fr.PVPrev = 0; PI_vav2_fr.errPrev = 0; PI_vav2_fr.resetUsed = 0;
        PI_vav2_fr.reset = 0; PI_vav2_fr.uBiasReset = 0; PI_vav2_fr.uScaled = 200;

        PI_vav3_fr.kp = 0.5; PI_vav3_fr.ki = 0.0001;
        PI_vav3_fr.kd = 0; PI_vav3_fr.action = -1; PI_vav3_fr.euhigh = 930;
        PI_vav3_fr.sphigh = 90; PI_vav3_fr.splow = 50; PI_vav3_fr.uBias = 0;
        PI_vav3_fr.wlb = 1.05; PI_vav3_fr.wub = 0.95; PI_vav3_fr.ns = 1; % scaling is No Scaling
        PI_vav3_fr.na = 0; PI_vav3_fr.dt = 60;PI_vav3_fr.accIn = 0; 
        PI_vav3_fr.PVPrev = 0; PI_vav3_fr.errPrev = 0; PI_vav3_fr.resetUsed = 0;
        PI_vav3_fr.reset = 0; PI_vav3_fr.uBiasReset = 0; PI_vav3_fr.uScaled = 200;

        PI_vav4_fr.kp = 0.5; PI_vav4_fr.ki = 0.0001;
        PI_vav4_fr.kd = 0; PI_vav4_fr.action = -1; PI_vav4_fr.euhigh = 930;
        PI_vav4_fr.sphigh = 90; PI_vav4_fr.splow = 50; PI_vav4_fr.uBias = 0;
        PI_vav4_fr.wlb = 1.05; PI_vav4_fr.wub = 0.95; PI_vav4_fr.ns = 1; % scaling is No Scaling
        PI_vav4_fr.na = 0; PI_vav4_fr.dt = 60;PI_vav4_fr.accIn = 0; 
        PI_vav4_fr.PVPrev = 0; PI_vav4_fr.errPrev = 0; PI_vav4_fr.resetUsed = 0;
        PI_vav4_fr.reset = 0; PI_vav4_fr.uBiasReset = 0; PI_vav4_fr.uScaled = 200;
        
        PI_vav2_fr_array = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
        counts1 = [0,0]; simCoolOn1 = 0; simHeatOn1 = 0; store1 = [0,0,0,0,0,0];
        counts2 = [0,0]; simCoolOn2 = 0; simHeatOn2 = 0; store2 = [0,0,0,0,0,0];
        counts3 = [0,0]; simCoolOn3 = 0; simHeatOn3 = 0; store3 = [0,0,0,0,0,0];
        counts4 = [0,0]; simCoolOn4 = 0; simHeatOn4 = 0; store4 = [0,0,0,0,0,0];
    else
        first_call = 0;
    end   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % Set EULow and PV
    PI_vav1_fr.eulow = max(200,CtrlSig(2,12));  % Vmin_vav1_ahu2
    %PI_vav1_fr.SP = ZoneInfo(20)*9/5+32; %Tz_cspt_z1_ahu2*9/5+32;
    PI_vav1_fr.PV = ZoneInfo(22)*9/5+32; %T_z1_ahu2*9/5+32;

    PI_vav2_fr.eulow = max(200,CtrlSig(2,13));  % Vmin_vav2_ahu2
    %PI_vav2_fr.SP = ZoneInfo(27)*9/5+32; %Tz_cspt_z2_ahu2*9/5+32;
    PI_vav2_fr.PV = ZoneInfo(29)*9/5+32; %T_z2_ahu2*9/5+32;

    PI_vav3_fr.eulow = max(200,CtrlSig(2,10));  % Vmin_vav1_ahu1
    %PI_vav3_fr.SP = ZoneInfo(6)*9/5+32; %Tz_cspt_z1_ahu2*9/5+32;
    PI_vav3_fr.PV = ZoneInfo(8)*9/5+32; %T_z1_ahu2*9/5+32;

    PI_vav4_fr.eulow = max(200,CtrlSig(2,11));  % Vmin_vav2_ahu1
    %PI_vav4_fr.SP = ZoneInfo(13)*9/5+32; %Tz_cspt_z2_ahu1*9/5+32;
    PI_vav4_fr.PV = ZoneInfo(15)*9/5+32; %T_z2_ahu2*9/5+32;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    % Run the thermostat to get the zone temperature setpoint
    tCCool = ZoneInfo(20); tCHeat = ZoneInfo(21); tZSim = ZoneInfo(22);
    vavTIn = Meas(12); fmin = PI_vav1_fr.eulow; fSP = PI_vav1_fr.uScaled;
    [Tz1SP,simCoolOn1,simHeatOn1,counts1,tFZone,FRmode1,TRmode1] = thermostat(tCCool,...
                                tCHeat,tZSim,counts1,timestep,simCoolOn1,simHeatOn1);
    % Run the code to decide if flow reset mode or temperature reset mode
    % are enabled
    [store1] = vavResetMode(first_call,doeMode,tZSim,vavHeatC,vavTIn,Tz1SP,dbH,...
                           fmin,fSP,n_reset,tHMax,Tz1SP,TRmode1,FRmode1,store1,...
                           CtrlSig);                            
    enableFRPI1 = store1(2); 
    
    % Run the thermostat to get the zone temperature setpoint
    tCCool = ZoneInfo(27); tCHeat = ZoneInfo(28); tZSim = ZoneInfo(29);
    vavTIn = Meas(17); fmin = PI_vav2_fr.eulow; fSP = PI_vav2_fr.uScaled;
    [Tz2SP,simCoolOn2,simHeatOn2,counts2,tFZone,FRmode2,TRmode2] = thermostat(tCCool,...
                                tCHeat,tZSim,counts2,timestep,simCoolOn2,simHeatOn2);
    % Run the code to decide if flow reset mode or temperature reset mode
    % are enabled
    [store2] = vavResetMode(first_call,doeMode,tZSim,vavHeatC,vavTIn,Tz2SP,dbH,...
                           fmin,fSP,n_reset,tHMax,Tz2SP,TRmode2,FRmode2,store2,...
                           CtrlSig);                            
    enableFRPI2 = store2(2); 
    
    % Run the thermostat to get the zone temperature setpoint
    tCCool = ZoneInfo(6); tCHeat = ZoneInfo(7); tZSim = ZoneInfo(8);
    vavTIn = Meas(2); fmin = PI_vav3_fr.eulow; fSP = PI_vav3_fr.uScaled;
    [Tz3SP,simCoolOn3,simHeatOn3,counts3,tFZone,FRmode3,TRmode3] = thermostat(tCCool,...
                                tCHeat,tZSim,counts3,timestep,simCoolOn3,simHeatOn3);
    % Run the code to decide if flow reset mode or temperature reset mode
    % are enabled
    [store3] = vavResetMode(first_call,doeMode,tZSim,vavHeatC,vavTIn,Tz3SP,dbH,...
                           fmin,fSP,n_reset,tHMax,Tz3SP,TRmode3,FRmode3,store3,...
                           CtrlSig);                            
    enableFRPI3 = store3(2); 
    
    % Run the thermostat to get the zone temperature setpoint
    tCCool = ZoneInfo(13); tCHeat = ZoneInfo(14); tZSim = ZoneInfo(15);
    vavTIn = Meas(7); fmin = PI_vav4_fr.eulow; fSP = PI_vav4_fr.uScaled;
    [Tz4SP,simCoolOn4,simHeatOn4,counts4,tFZone,FRmode4,TRmode4] = thermostat(tCCool,...
                                tCHeat,tZSim,counts4,timestep,simCoolOn4,simHeatOn4);
    % Run the code to decide if flow reset mode or temperature reset mode
    % are enabled
    [store4] = vavResetMode(first_call,doeMode,tZSim,vavHeatC,vavTIn,Tz4SP,dbH,...
                           fmin,fSP,n_reset,tHMax,Tz4SP,TRmode4,FRmode4,store4,...
                           CtrlSig);                            
    enableFRPI4 = store4(2); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Set the enablePI variable for the PI controllers for flow reset
    PI_vav1_fr.enablePI = enableFRPI1; %pData.vav2_fr_reset_mode;
    PI_vav2_fr.enablePI = enableFRPI2; %pData.vav2_fr_reset_mode;
    PI_vav3_fr.enablePI = enableFRPI3; %pData.vav2_fr_reset_mode;
    PI_vav4_fr.enablePI = enableFRPI4; %pData.vav2_fr_reset_mode;
    
    PI_vav1_fr.SP = Tz1SP; %Tz_cspt_z1_ahu2*9/5+32;
    PI_vav2_fr.SP = Tz2SP; %Tz_cspt_z2_ahu2*9/5+32;
    PI_vav3_fr.SP = Tz3SP; %Tz_cspt_z1_ahu1*9/5+32;
    PI_vav4_fr.SP = Tz4SP; %Tz_cspt_z2_ahu1*9/5+32;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Run the PI code
    if PI_vav1_fr.enablePI > 0
        PI_vav1_fr.init = 0;
        [PI_vav1_fr] = PI_v2(PI_vav1_fr);
    else
        PI_vav1_fr.init = 1;
        [PI_vav1_fr] = PI_v2(PI_vav1_fr);
    end

    if PI_vav2_fr.enablePI > 0
        PI_vav2_fr.init = 0;
        [PI_vav2_fr] = PI_v2(PI_vav2_fr);
    else
        PI_vav2_fr.init = 1;
        [PI_vav2_fr] = PI_v2(PI_vav2_fr);
    end

    if PI_vav3_fr.enablePI > 0
        PI_vav3_fr.init = 0;
        [PI_vav3_fr] = PI_v2(PI_vav3_fr);
    else
        PI_vav3_fr.init = 1;
        [PI_vav3_fr] = PI_v2(PI_vav3_fr);
    end

    if PI_vav4_fr.enablePI > 0
        PI_vav4_fr.init = 0;
        [PI_vav4_fr] = PI_v2(PI_vav4_fr);
    else
        PI_vav4_fr.init = 1;
        [PI_vav4_fr] = PI_v2(PI_vav4_fr);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Assign values for output
    vav1_d_sp = PI_vav1_fr.uScaled;
    vav2_d_sp = PI_vav2_fr.uScaled;
    vav3_d_sp = PI_vav3_fr.uScaled;
    vav4_d_sp = PI_vav4_fr.uScaled;
    
    Tz1SP = (Tz1SP-32)*5/9;
    Tz2SP = (Tz2SP-32)*5/9;
    Tz3SP = (Tz3SP-32)*5/9;
    Tz4SP = (Tz4SP-32)*5/9;
    
    ahu1VentAir = CtrlSig(2,10)+CtrlSig(2,11);
    ahu2VentAir = CtrlSig(2,12)+CtrlSig(2,13);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    % Save variables for troubleshooting
    temp = [PI_vav2_fr.accIn,PI_vav2_fr.pTerm,PI_vav2_fr.iTerm,...
                            PI_vav2_fr.eulow,PI_vav2_fr.SP,PI_vav2_fr.PV,...
                            PI_vav2_fr.errNow,PI_vav2_fr.uScaled,...
            PI_vav1_fr.accIn,PI_vav1_fr.pTerm,PI_vav1_fr.iTerm,...
                            PI_vav1_fr.eulow,PI_vav1_fr.SP,PI_vav1_fr.PV,...
                            PI_vav1_fr.errNow,PI_vav1_fr.uScaled];
    PI_vav2_fr_array = [PI_vav2_fr_array;temp];
    % Save data to file for troubleshooting
    if timestep == 960
        save('PI_vav2_fromTRNSYS.mat','PI_vav2_fr_array')
    end
end