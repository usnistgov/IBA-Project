function [PIstruct] = PI_v2(PIstruct)
    cMax = 1;
    cMin = 0;
    if (PIstruct.init == 1) 
         PIstruct.accIn = 0; % integral error
         PIstruct.errNow = 0; % current error
         PIstruct.errRate = 0; % error rate
         PIstruct.errPrev = 0; % prevous error
         PIstruct.dTerm = 0; % derivative term
         PIstruct.pTerm = 0; % proportional term
         PIstruct.iTerm = 0; % integral term
         PIstruct.uScaled = 0; % control signal
    else  
         if (PIstruct.ns > 0) % ns = no scaling
             PIstruct.errNow = (PIstruct.PV - PIstruct.SP); % PV = current value; SP = setpoint
         else % scale the error by the range of the setpoint
             PIstruct.errNow = (PIstruct.PV - PIstruct.SP)/(PIstruct.sphigh - PIstruct.splow); 
         end
         % errRate = (PV - PVPrev)/dt; 
         PIstruct.errRate = (PIstruct.errNow - PIstruct.errPrev)/PIstruct.dt; 
         
         PIstruct.pTerm = PIstruct.errNow * PIstruct.kp;
         PIstruct.iTerm = PIstruct.accIn * PIstruct.ki; %//*(1-na);
         PIstruct.dTerm = PIstruct.errRate * PIstruct.kd; 
         
         % raw control signal (cMin to cMax)
         PIstruct.uRaw = PIstruct.pTerm + PIstruct.iTerm + PIstruct.dTerm;
         % raw signal scaled by a bias term and for the direction; if
         % action is -1, the PID is inverse acting (decrease temperature by
         % increasing signal, for example)
         PIstruct.cBias = PIstruct.uBias - PIstruct.action * PIstruct.uRaw; 
         % Limit to between cMax and cMin
         if (PIstruct.cBias < 0) 
              PIstruct.cBias = 0;
         elseif (PIstruct.cBias > 1) 
              PIstruct.cBias = 1;
         end
         % Calculate slope and intercept to scale the signal to engineering
         % units
         slope = (PIstruct.euhigh - PIstruct.eulow)/(cMax - cMin);
         intercept = PIstruct.euhigh - slope*cMax;
         % scaled control signal
         PIstruct.uScaled = PIstruct.cBias * slope + intercept; 
         PIstruct.PVPrev = PIstruct.PV;
         PIstruct.errPrev = PIstruct.errNow;
         
         %/* Accumulate Error? */
         % Set the lower bound - if below this, don't accumulate error;
         % this is for anti-windup
         if (PIstruct.eulow < 0) 
              lb = PIstruct.eulow - ((PIstruct.wlb-1)*PIstruct.eulow);
         else 
              lb = PIstruct.wlb*max(PIstruct.eulow,PIstruct.euhigh/100);
         end
    
         if (PIstruct.ki ~= 0) 
              s = sign(PIstruct.errNow)*sign(PIstruct.accIn);
              if (PIstruct.na > 0) % na = no accumulation 
                   PIstruct.accIn = PIstruct.accIn;
                   PIstruct.resetUsed = 0;
              elseif ((PIstruct.uScaled <= PIstruct.wub*PIstruct.euhigh) && (PIstruct.uScaled >= lb)) 
                   % if the signal is between the bounds, accumuate the
                   % eror
                   PIstruct.accIn = PIstruct.errNow * PIstruct.dt + PIstruct.accIn;
                   PIstruct.resetUsed = 0;
              elseif ((PIstruct.uScaled > PIstruct.wub*PIstruct.euhigh)) 
                   % signal is above the upper bound
                   if ((PIstruct.reset > 0)&&(PIstruct.resetUsed < 1))
                       % reset is triggered by front panel control
                        PIstruct.accIn = 0;
                        PIstruct.resetUsed = 1; 
                        PIstruct.uBiasReset = (PIstruct.uScaled - intercept)/slope;
                   elseif (s < 0) 
                        % the current error is a different sign from the
                        % current accumulated error; go ahead and
                        % accumulate error again.
                        PIstruct.accIn = PIstruct.errNow * PIstruct.dt + PIstruct.accIn;    
                        PIstruct.resetUsed = PIstruct.resetUsed;
                   else 
                       % Make no change
                        PIstruct.accIn = PIstruct.accIn;
                        PIstruct.resetUsed = PIstruct.resetUsed;
                   end              
               elseif ((PIstruct.uScaled < lb)) 
                   % Same as above, but lower bound
                   if ((PIstruct.reset > 0)&&(PIstruct.resetUsed < 1)) 
                        PIstruct.accIn = 0;
                        PIstruct.resetUsed = 1; 
                        PIstruct.uBiasReset = (PIstruct.uScaled - intercept)/slope;
                   elseif (s < 0) 
                        PIstruct.accIn = PIstruct.errNow * PIstruct.dt + PIstruct.accIn;    
                        PIstruct.resetUsed = PIstruct.resetUsed;
                   else 
                        PIstruct.accIn = PIstruct.accIn;
                        PIstruct.resetUsed = PIstruct.resetUsed;
                   end
              else 
                   PIstruct.accIn = PIstruct.accIn;
                   PIstruct.resetUsed = PIstruct.resetUsed;
              end 
         elseif (PIstruct.ki == 0) 
             % no integral term
              PIstruct.accIn = 0;
              PIstruct.resetUsed = 0;
         else 
              PIstruct.accIn = PIstruct.accIn;
              PIstruct.resetUsed = 0;
         end     
    end
end