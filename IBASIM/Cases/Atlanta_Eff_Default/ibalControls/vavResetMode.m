function [store] = vavResetMode(firstCall,doeMode,Tz,...
                                vavHeatC,vavTIn,TzSP,dbH,fmin,fSP,n_reset,tHMax,...
                                tSP,TRmode,FRmode,store,CtrlSig)

    modeIn = store(1);
    count = store(3);
    TzSPOld = store(4); 
    TRmodeOld = store(5);
    FRmodeOld = store(6);  
    
    Tz = Tz*9/5+32;
    vavTIn = vavTIn*9/5+32;
    %TzSP = TzSP*9/5+32;
    
    %if timestep > 360+0
    if CtrlSig(2,1) > 0 % sys_status > 0
        dT = Tz-TzSP;
        dTVAV = tSP - vavTIn;
        if (firstCall == 1) 
             TzSPOld = TzSP;
        end

        if (doeMode > 0) 
             if (TRmode > 0) 
                  mode = 1;
             elseif (FRmode > 0) 
                  mode = 0;
             else 
                  mode = 2;
             end
        else 
             if ((dT < dbH)&&(fSP < 1.02*fmin)) 
                  mode = 1;
             elseif ((modeIn == 1)&&(dT < dbH)&&( tSP > 0.98*tHMax)) 
                  mode = 1;
             elseif ((modeIn == 1)&&(vavHeatC > 0.001)) 
                  mode = 1;
             elseif ((modeIn == 1)&&(dTVAV > 1.5)) 
                  mode = 1;
             else 
                  mode = 0;
             end

             if (TRmode == 0) % // if not using the heater right now,
                              % // don't let it go into heating mode
                  mode = 0;
             end
        end

        count = count + 1; 
        %// If the mode changes, immediately reset the setpoint
        if ((TRmodeOld < 1)&&(TRmode > 0)) 
             count = n_reset + 1;
        end
        if ((FRmodeOld < 1)&&(FRmode > 0)) 
             count = n_reset + 1;
        end

        if (count > n_reset) 
             count = 0;
             reset = 1;
        else 
             %//mode = 3;
             reset = 0;
        end

        TRmodeOld = TRmode;
        FRmodeOld = FRmode;

        store = [mode; reset; count; TzSP; TRmodeOld; FRmodeOld];
    else
        store = [0;0;0;TzSP;0;0];
    end
end


    
    % % %     if (vavDamper > 0) % // enable the VAV damper
% % %         dMode = 1;  % // set the PI for the damper to Auto
% % %         if (flowDOE > 0) % // sim is sending flow SP
% % %             fSP = cfmDOE; 
% % %             fResetMode = 0;  % // don't use my flow reset controller      
% % %         elseif (startMode > 0) % // use my initial setpoint
% % %             fSP = vavDSP;        
% % %             fResetMode = 0; % // use flow reset based on AirSystemHL decision   
% % %         else 
% % %             fResetMode = frMode; % // just use whatever SP is passed through and 
% % %                                 % // use flow reset based on AirSystemHL decision
% % %         end    
% % %     else 
% % %         dMode = 0;
% % %         fResetMode = 0;
% % %     end
% % % 
% % %     if (startMode > 0) 
% % %         tSP = 40;
% % %         tResetMode = 0;
% % %     else 
% % %         tResetMode = trMode;
% % %     end
% % % 
% % %     if (ventDOE > 0) 
% % %     % // Simulation sets minimum airflow, otherwise use what's set on Host
% % %         fMin = minDOE;
% % %     end
% % %     if (tResetMode > 0) 
% % %         fMin = max(200,fMin);
% % %         fSP = fMin; 
% % %     else 
% % %         tSP = 40;
% % %     end
% % %     if (fResetMode > 0)  % // update the values of SPLow and EULow
% % %                        % // in the flow reset controller
% % %         SPLow = fMin; 
% % %         EULow = fMin;
% % %     end