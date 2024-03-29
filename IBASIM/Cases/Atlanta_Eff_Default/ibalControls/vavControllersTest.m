function [vav1_d_sp,vav2_d_sp,vav3_d_sp,vav4_d_sp,Tz1SP,Tz2SP,Tz3SP,Tz4SP,ahu1VentAir,ahu2VentAir] = ...
    vavControllersTest(timestep,Tz1SP,Tz2SP,Tz3SP,Tz4SP,T_z1_ahu2,T_z2_ahu2,T_z1_ahu1,T_z2_ahu1)
    persistent PI_vav1_fr
    persistent PI_vav2_fr
    persistent PI_vav3_fr
    persistent PI_vav4_fr
    persistent first_call
    persistent PI_vav2_fr_array

    
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
        
        PI_vav2_fr_array = [0,0,0,0,0,0,0,0];
        counts1 = [0,0]; simCoolOn1 = 0; simHeatOn1 = 0; store1 = [0,0,0,0,0,0];
        counts2 = [0,0]; simCoolOn2 = 0; simHeatOn2 = 0; store2 = [0,0,0,0,0,0];
        counts3 = [0,0]; simCoolOn3 = 0; simHeatOn3 = 0; store3 = [0,0,0,0,0,0];
        counts4 = [0,0]; simCoolOn4 = 0; simHeatOn4 = 0; store4 = [0,0,0,0,0,0];
    else
        first_call = 0;
    end   
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % Set EULow and PV
    PI_vav1_fr.eulow = 200;  % Vmin_vav1_ahu2
    %PI_vav1_fr.SP = ZoneInfo(20)*9/5+32; %Tz_cspt_z1_ahu2*9/5+32;
    PI_vav1_fr.PV = T_z1_ahu2;

    PI_vav2_fr.eulow = 200;  % Vmin_vav2_ahu2
    %PI_vav2_fr.SP = ZoneInfo(27)*9/5+32; %Tz_cspt_z2_ahu2*9/5+32;
    PI_vav2_fr.PV = T_z2_ahu2;

    PI_vav3_fr.eulow = 460;  % Vmin_vav1_ahu1
    %PI_vav3_fr.SP = ZoneInfo(6)*9/5+32; %Tz_cspt_z1_ahu2*9/5+32;
    PI_vav3_fr.PV = T_z1_ahu1;

    PI_vav4_fr.eulow = 200;  % Vmin_vav2_ahu1
    %PI_vav4_fr.SP = ZoneInfo(13)*9/5+32; %Tz_cspt_z2_ahu1*9/5+32;
    PI_vav4_fr.PV = T_z2_ahu1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
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
                            PI_vav2_fr.errNow,PI_vav2_fr.uScaled];
    PI_vav2_fr_array = [PI_vav2_fr_array;temp];
    % Save data to file for troubleshooting
    if timestep == 600
        save('PI_vav2_fromTRNSYS.mat','PI_vav2_fr_array')
    end
end