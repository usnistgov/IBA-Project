% Data passed from / to TRNSYS 
% ---------------------------- 
%
% trnTime (1x1)        : simulation time 
% trnInfo (15x1)       : TRNSYS info array
% trnInputs (nIx1)     : TRNSYS inputs 
% trnStartTime (1x1)   : TRNSYS Simulation Start time
% trnStopTime (1x1)    : TRNSYS Simulation Stop time
% trnTimeStep (1x1)    : TRNSYS Simulation time step
% mFileErrorCode (1x1) : Error code for this m-file. It is set to 1 by TRNSYS and the m-file should set it to 0 at the
%                        end to indicate that the call was successful. Any non-zero value will stop the simulation
% trnOutputs (nOx1)    : TRNSYS outputs  
%
% 
% Notes: 
% ------
% 
% You can use the values of trnInfo(7), trnInfo(8) and trnInfo(13) to identify the call (e.g. first iteration, etc.)
% Real-time controllers (callingMode = 10) will only be called once per time step with trnInfo(13) = 1 (after convergence)
% 
% The number of inputs is given by trnInfo(3)
% The number of expected outputs is given by trnInfo(6)
% WARNING: if multiple units of Type 155 are used, the variables passed from/to TRNSYS will be sized according to  
%          the maximum required by all units. You should cope with that by only using the part of the arrays that is 
%          really used by the current m-File. Example: use "nI = trnInfo(3); myInputs = trnInputs(1:nI);" 
%                                                      rather than "MyInputs = trnInputs;" 
%          Please also note that all m-files share the same workspace in Matlab (they are "scripts", not "functions") so
%          variables like trnInfo, trnTime, etc. will be overwritten at each call. 
%
% ----------------------------------------------------------------------------------------------------------------------
% This file was generated from the example TwoInputs
%
%
% MKu, March 2006
% ----------------------------------------------------------------------------------------------------------------------

%persistent inputs
% TRNSYS sets mFileErrorCode = 1 at the beginning of the M-File for error detection
% This file increments mFileErrorCode at different places. If an error occurs in the m-file the last succesful step will
% be indicated by mFileErrorCode, which is displayed in the TRNSYS error message
% At the very end, the m-file sets mFileErrorCode to 0 to indicate that everything was OK
mFileErrorCode = 100;    % Beginning of the m-file 

% --- Process Inputs and global parameters -----------------------------------------------------------------------------
% ----------------------------------------------------------------------------------------------------------------------
nI = trnInfo(3); % number of inputs
nO = trnInfo(6); % number of outputs

timestep = round(trnTime*60);

T = 86400; % length of the simulation period 
HardwareTime = 0.0001; % Please assign index number of the hardware data to this variable
% Please refer to the notes in callSim for the meaning of each inputs
Meas(1) = trnInputs(2); % m_sup_vav1_ahu1
Meas(2) = trnInputs(3);% T_sup_vav1_ahu1
Meas(3) = trnInputs(4); % w_sup_vav1_ahu1
Meas(4) = trnInputs(5); % T_z1_ahu1
Meas(5) = trnInputs(6); % w_z1_ahu1
Meas(6) = trnInputs(7); % m_sup_vav2_ahu1
Meas(7) = trnInputs(8); % T_sup_vav2_ahu1
Meas(8) = trnInputs(9); % w_sup_vav2_ahu1
Meas(9) = trnInputs(10); % T_z2_ahu1
Meas(10) = trnInputs(11); % w_z2_ahu1
Meas(11) = trnInputs(12); % m_sup_vav1_ahu2
Meas(12) = trnInputs(13); % T_sup_vav1_ahu2
Meas(13) = trnInputs(14); % w_sup_vav1_ahu2
Meas(14) = trnInputs(15); % T_z1_ahu2
Meas(15) = trnInputs(16); % w_z1_ahu2
Meas(16) = trnInputs(17); % m_sup_vav2_ahu2
Meas(17) = trnInputs(18); % T_sup_vav2_ahu2
Meas(18) = trnInputs(19); % w_sup_vav2_ahu2
Meas(19) = trnInputs(20); % T_z2_ahu2
Meas(20) = trnInputs(21); % w_z2_ahu2
Meas(21) = trnInputs(22); % W_ahu1
Meas(22) = trnInputs(23); % vfd_ahu1
Meas(23) = trnInputs(24); % d1_ahu1
Meas(24) = trnInputs(25); % d2_ahu1
Meas(25) = trnInputs(26); % d2_ahu1
Meas(26) = trnInputs(27); % d2_ahu1
Meas(27) = trnInputs(28); % P_sp_ahu1_cur
Meas(28) = trnInputs(29); % T_SA_ahu1_cur
Meas(29) = trnInputs(30); % V_cc_ahu1
Meas(30) = trnInputs(31); % Tin_cc_ahu1
Meas(31) = trnInputs(32); % Tout_cc_ahu1
Meas(32) = trnInputs(33); % W_ahu2
Meas(33) = trnInputs(34); % vfd_ahu2
Meas(34) = trnInputs(35); % d1_ahu2
Meas(35) = trnInputs(36); % d2_ahu2
Meas(36) = trnInputs(37); % rh1_ahu2
Meas(37) = trnInputs(38); % rh2_ahu2
Meas(38) = trnInputs(39); % P_sp_ahu2_cur
Meas(39) = trnInputs(40); % T_SA_ahu2_cur
Meas(40) = trnInputs(41); % V_cc_ahu2
Meas(41) = trnInputs(42); % Tin_cc_ahu2
Meas(42) = trnInputs(43); % Tout_cc_ahu2
Meas(43) = trnInputs(44); % W_CHW
Meas(44) = trnInputs(45); % m_CHW_pm
Meas(45) = trnInputs(46); % m_CHW_sl
Meas(46) = trnInputs(47); % T_CHW1
Meas(47) = trnInputs(48); % T_CHW2
Meas(48) = trnInputs(49); % T_CHW_TS
Meas(49) = trnInputs(50); % T_chwst_cur
Meas(50) = trnInputs(51); % DP_slSP_cur
Meas(51) = trnInputs(52); % TES_inventory
Meas(52) = trnInputs(53); % TES_status
Meas(53) = trnInputs(54); % T_out_emulated
Meas(54) = trnInputs(55); % T_return_ahu1
Meas(55) = trnInputs(56); % T_return_ahu1
Meas(56) = trnInputs(57); % Power_HVAC_electric
Meas(57) = trnInputs(58); % fan pressure for AHU1
Meas(58) = trnInputs(59); % fan pressure for AHU2
Meas(59) = trnInputs(60); % air temperature out of AHU1
Meas(60) = trnInputs(61); % air temperature out of AHU2
Meas(61) = trnInputs(62); % ch1_power
Meas(62) = trnInputs(63); % ch2_power
Meas(63) = trnInputs(64); % ahu1_f_cc
Meas(64) = trnInputs(65); % ahu2_f_cc
Meas(65) = trnInputs(66); % ahu1_in_rtd
Meas(66) = trnInputs(67); % ahu2_in_rtd
Meas(67) = trnInputs(68); % ahu1_rh_up
Meas(68) = trnInputs(69); % ahu2_rh_up
Meas(69) = trnInputs(70); % ch1PLR
Meas(70) = trnInputs(71); % ch2PLR
Meas(71) = trnInputs(72); % pl_out

mFileErrorCode = 110;    % After processing inputs

% --- First call of the simulation: initial time step (no iterations) --------------------------------------------------
% ----------------------------------------------------------------------------------------------------------------------
% (note that Matlab is initialized before this at the info(7) = -1 call, but the m-file is not called)
if ( (trnInfo(7) == 0) & (trnTime-trnStartTime < 1e-6) )  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Do some initialization stuff, e.g. initialize history of the variables for plotting at the end of the simulation
    % (uncomment lines if you wish to store variables) 
    nTimeSteps = 1441; %(trnStopTime-trnStartTime)/trnTimeStep + 1;
    history.inputs = zeros(nTimeSteps,nI);
    history.outputs = zeros(nTimeSteps,nO);
    history.vavs = [0,0,0,0,0,...
                    0,0,0,0,0,...
                    0,0,0,0];
    history.ahus = [0,0,0,0,0,...
                    0,0,0,0,0];
	history.timing = zeros(nTimeSteps,4);
    history.trnInfo = zeros(nTimeSteps,length(trnInfo));
    history.time = zeros(nTimeSteps,2);
    mFileErrorCode = 118;    
    if timestep > 0
        for i = 0:timestep
            [ZoneInfo,CtrlSig,MyCtrl]=callSim(HardwareTime,i,Meas);  
        end
    else
        mFileErrorCode = 118.1;   
        [ZoneInfo,CtrlSig,MyCtrl]=callSim(HardwareTime,timestep,Meas); 
    end
	mFileErrorCode = 119.1;   
    cSigMod = CtrlSig(1,:).*CtrlSig(2,:);
    if CtrlSig(1,9) == 0
        cSigMod(9) = -1;
    end
	mFileErrorCode = 119.2;   
    temp = [timestep,ZoneInfo,cSigMod,MyCtrl];	

    history.inputs(1,:) = [timestep,Meas];
    temp = [timestep,ZoneInfo,cSigMod,MyCtrl];
    history.outputs(1,1:length(temp)) = temp;
    history.trnInfo(1,:) = trnInfo;
    history.timing(1,1) = timestep;
	history.timing(1,2) = ZoneInfo(1);
	history.timing(1,3) = trnInputs(3);
    history.timing(1,4) = MyCtrl(2);
    history.time(1,:) = [trnTime,trnStartTime];
    % No return, normal calculations are also performed during this call
    mFileErrorCode = 120;   % After initialization call
   
end


% --- Very last call of the simulation (after the user clicks "OK") ----------------------------------------------------
% ----------------------------------------------------------------------------------------------------------------------

if ( trnInfo(8) == -1 )

    mFileErrorCode = 1000;
    
    % Do stuff at the end of the simulation, e.g. calculate stats, draw plots, etc...    
    mFileErrorCode = 0; % Tell TRNSYS that we reached the end of the m-file without errors
    return

end


% --- Post convergence calls: store values -----------------------------------------------------------------------------
% ----------------------------------------------------------------------------------------------------------------------

if (trnInfo(13) == 1)
    if timestep > -240
        mFileErrorCode = 200;   % Beginning of a post-convergence call 

        % This is the extra call that indicates that all Units have converged. You should do things like: 
        % - calculate control signal that should be applied at next time step
        % - Store history of variables
        mFileErrorCode = timestep+0.1;   

        % Use stored values as the inputs for the current timestep. In the
        % real syste, these values would have been setpoints for the lab in
        % the last timestep, so this assumes that the hardware gets to
        % setpoint in one timestep
        Meas(1) = history.vavs(3); % m_sup_vav1_ahu1
        Meas(6) = history.vavs(4); % m_sup_vav2_ahu1
        Meas(11) = history.vavs(1); % m_sup_vav1_ahu2
        Meas(16) = history.vavs(2); % m_sup_vav2_ahu2

        Meas(4) = history.vavs(7); % T_z1_ahu1
        Meas(9) = history.vavs(8); % T_z2_ahu1
        Meas(14) = history.vavs(5); % T_z1_ahu2
        Meas(19) = history.vavs(6); % T_z2_ahu2

        Meas(5) = history.vavs(11); % w_z1_ahu1
        Meas(10) = history.vavs(12); % w_z2_ahu1
        Meas(15) = history.vavs(9); % w_z1_ahu2
        Meas(20) = history.vavs(10); % w_z2_ahu2 
         
        Meas(29) = history.vavs(13); % V_cc_ahu1
        Meas(40) = history.vavs(14); % V_cc_ahu2
        
        % read in output of last timestep - MATLAB indexing starts at 1,
        % but the simulation starts at timestep = 0, so reading the data
        % at index timestep actually grabs the data from the last timestep
        Meas(49) = history.outputs(timestep,36); % T_chwst_cur
        Meas(50) = history.outputs(timestep,37); % DP_slSP_cur
        Meas(53) = history.outputs(timestep,2); % T_out_emulated 

        [ZoneInfo,CtrlSig,MyCtrl]=callSim(HardwareTime,timestep,Meas);  

        cSigMod = CtrlSig(1,:).*CtrlSig(2,:);
        if CtrlSig(1,9) == 0
            cSigMod(9) = -1;
        end

        mFileErrorCode = timestep+0.5;   % Beginning of a post-convergence call 
        history.inputs(timestep+1,:) = [timestep,Meas];
        temp = [timestep,ZoneInfo,cSigMod,MyCtrl];
        if timestep < -230
            MyCtrl(28) = 40; % Initial ice inventory is 40 %
        end
        
        % Store results
        history.outputs(timestep+1,1:length(temp)) = [timestep,ZoneInfo,cSigMod,MyCtrl];
        history.timing(timestep+1,1) = timestep;
        history.timing(timestep+1,2) = ZoneInfo(1);
        history.timing(timestep+1,3) = trnInputs(3);
        history.timing(timestep+1,4) = MyCtrl(2);
    end
    
    % Calculate specific volume from temperature and humidity ratio
    tC = Meas(12); w = Meas(13);
    v1 = 0.2870422*(tC+273.15)*(1+1.61*w)/(14.6*6895)*1000;
    
    tC = Meas(17); w = Meas(18);
    v2 = 0.2870422*(tC+273.15)*(1+1.61*w)/(14.6*6895)*1000;
    
    tC = Meas(2); w = Meas(3);
    v3 = 0.2870422*(tC+273.15)*(1+1.61*w)/(14.6*6895)*1000;
    
    tC = Meas(7); w = Meas(8);
    v4 = 0.2870422*(tC+273.15)*(1+1.61*w)/(14.6*6895)*1000;
    
    % Store variables that will become inputs to the next timestep
    history.vavs(1) = MyCtrl(1)*0.000472/v1;    % VAV1 - m_sup_vav1_ahu2
    history.vavs(2) = MyCtrl(2)*0.000472/v2;    % VAV2 - m_sup_vav2_ahu2
    history.vavs(3) = MyCtrl(3)*0.000472/v3;    % VAV3 - m_sup_vav1_ahu1
    history.vavs(4) = MyCtrl(4)*0.000472/v4;    % VAV4 - m_sup_vav2_ahu1     
    history.vavs(7) = ZoneInfo(8); % T_z1_ahu1
    history.vavs(8) = ZoneInfo(15); % T_z2_ahu1
    history.vavs(5) = ZoneInfo(22); % T_z1_ahu2
    history.vavs(6) = ZoneInfo(29); % T_z2_ahu2
    history.vavs(11) = ZoneInfo(10); % w_z1_ahu1
    history.vavs(12) = ZoneInfo(17); % w_z2_ahu1
    history.vavs(9) = ZoneInfo(24); % w_z1_ahu2
    history.vavs(10) = ZoneInfo(31); % w_z2_ahu2    
    history.vavs(13) = (MyCtrl(19)+1/3)*6; % V_cc_ahu1
    history.vavs(14) = (MyCtrl(20)+1/3)*6; % V_cc_ahu2
	       
    mFileErrorCode = timestep+0.75;   % Beginning of a post-convergence call 
    % Note: If Calling Mode is set to 10, Matlab will not be called during iterative calls.
    % In that case only this loop will be executed and things like incrementing the "iStep" counter should be done here
    trnOutputs = history.outputs(timestep+1,:);

    mFileErrorCode = 0; % Tell TRNSYS that we reached the end of the m-file without errors
    return  % Do not update outputs at this call

end

% --- All iterative calls ----------------------------------------------------------------------------------------------
% ----------------------------------------------------------------------------------------------------------------------

% --- If this is a first call in the time step, do things like incrementing step counters ---

if ( trnInfo(7) == 0 )
    mFileErrorCode = 130;   
    % Nothing to do here    
end

% --- Process Inputs ---
mFileErrorCode = 140;   

% --- Set outputs ---
mFileErrorCode = 150;  

trnOutputs = history.outputs(timestep+1,:);
history.time(timestep+1,:) = [trnTime,trnStartTime];
history.trnInfo(timestep+1,:) = trnInfo;
mFileErrorCode = 0; % Tell TRNSYS that we reached the end of the m-file without errors
return
