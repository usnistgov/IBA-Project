function [controlsinfo] = ChangeEffects(OccupantMatrix,controls)
% ChangeEffects - Represents the LOCAL effects of a simulated behavior state 
% change, as determined by Controls Information section in the 'OPTIONAL
% ENTRY' tab of the Excel setup file. Note: thermostats are considered not
% to have a local effect (only zone-level), so they are not represented here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                          %
%    Copyright 2016 Jared Langevin                                         %
%                                                                          %
%    Licensed under the Apache License, Version 2.0 (the "License");       %
%    you may not use this file except in compliance with the License.      %
%    You may obtain a copy of the License at                               %
%                                                                          %
%        http://www.apache.org/licenses/LICENSE-2.0                        %
%                                                                          %
%    Unless required by applicable law or agreed to in writing, software   %
%    distributed under the License is distributed on an "AS IS" BASIS,     %
%    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or       %
%    implied. See the License for the specific language governing          %
%    permissions and limitations under the License.                        %
%                                                                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Represent clothing up/down local change   
if (OccupantMatrix.BehaviorStatesVector(1) == 1) && ...
        (OccupantMatrix.BehaviorStatesVector(2) == 1);
   minadjuststate = 1;
   clothing = OccupantMatrix.MorningClothing + controls(1,3) + ...
       controls(2,3);
elseif (OccupantMatrix.BehaviorStatesVector(1) == 1) && ...
        (OccupantMatrix.BehaviorStatesVector(2) == 0);
   minadjuststate = 1;
   clothing = OccupantMatrix.MorningClothing + controls(1,3);
elseif (OccupantMatrix.BehaviorStatesVector(1) == 0) && ...
        (OccupantMatrix.BehaviorStatesVector(2) == 1);
   minadjuststate = 0;
   clothing = OccupantMatrix.MorningClothing + controls(2,3);
elseif (OccupantMatrix.BehaviorStatesVector(1) == -1) && ...
        (OccupantMatrix.BehaviorStatesVector(2) == 0);
   minadjuststate = -1;
   clothing = OccupantMatrix.MorningClothing - controls(1,3);
elseif (OccupantMatrix.BehaviorStatesVector(1) == 0) && ...
        (OccupantMatrix.BehaviorStatesVector(2) == -1); 
   minadjuststate = 0;
   clothing = OccupantMatrix.MorningClothing - controls(2,3);
   % elseif (OccupantMatrix.BehaviorStatesVector(1) == -1) && ...
%         (OccupantMatrix.BehaviorStatesVector(2) == 1);
%     minadjuststate = -1;
%     clothing = OccupantMatrix.MorningClothing + controls(1,3) - ...
%         controls(2,3);
% elseif (OccupantMatrix.BehaviorStatesVector(1) == 1) && ...
%         (OccupantMatrix.BehaviorStatesVector(2) == -1);
%     minadjuststate = 1;
%     clothing = OccupantMatrix.MorningClothing - controls(1,3) + ...
%         controls(2,3);
% elseif (OccupantMatrix.BehaviorStatesVector(1) == -1) && ...
%         (OccupantMatrix.BehaviorStatesVector(2) == -1);
%     minadjuststate = 0;
%     clothing = OccupantMatrix.MorningClothing - controls(2,3);
% Calculation bug? (YC 2022/02/11)
elseif (OccupantMatrix.BehaviorStatesVector(1) == -1) && ...
        (OccupantMatrix.BehaviorStatesVector(2) == 1); 
   minadjuststate = -1;
   clothing = OccupantMatrix.MorningClothing - controls(1,3) + ...
       controls(2,3);
elseif (OccupantMatrix.BehaviorStatesVector(1) == 1) && ...
        (OccupantMatrix.BehaviorStatesVector(2) == -1); 
   minadjuststate = 1;
   clothing = OccupantMatrix.MorningClothing + controls(1,3) - ...
       controls(2,3);
elseif (OccupantMatrix.BehaviorStatesVector(1) == -1) && ...
        (OccupantMatrix.BehaviorStatesVector(2) == -1); 
   minadjuststate = 0;
   clothing = OccupantMatrix.MorningClothing - controls(1,3) - controls(2,3);       
else
   minadjuststate = 0; 
   clothing = OccupantMatrix.MorningClothing;
end

%% Represent consumption of warm/cool drinks   
if OccupantMatrix.BehaviorStatesVector(3) == 1;
    metrate = OccupantMatrix.MetabolicRate + controls(3,3);
elseif OccupantMatrix.BehaviorStatesVector(3) == -1;
    metrate = OccupantMatrix.MetabolicRate - controls(3,3);
else  
    metrate = OccupantMatrix.MetabolicRate;
end

%% Represent getting up to go for a walkabout
if (OccupantMatrix.BehaviorStatesVector(4) == 1);
   metrate = metrate + controls(4,3);
end

%% Represent turning on a local heater
if (OccupantMatrix.BehaviorStatesVector(5) == 1);       
  ambienttemp = OccupantMatrix.IndoorEnvironmentVectorBase(1) + ...
      controls(5,3);
  radianttemp = ambienttemp;
else
  ambienttemp = OccupantMatrix.IndoorEnvironmentVectorBase(1); 
  radianttemp = OccupantMatrix.IndoorEnvironmentVectorBase(4);
end

%% Represent turning on a local fan
if (OccupantMatrix.BehaviorStatesVector(6) == -1);       
  airvelocity = OccupantMatrix.IndoorEnvironmentVectorBase(3) + ...
      controls(6,3);
else
  airvelocity = OccupantMatrix.IndoorEnvironmentVectorBase(3); 
end

%% Represent opening a door
if (abs(OccupantMatrix.BehaviorStatesVector(8)) == 1); 
  airvelocity = airvelocity + controls(8,3);  
end

%% Represent opening a window
if (abs(OccupantMatrix.BehaviorStatesVector(9)) == 1); 
  airvelocity = airvelocity + controls(9,3);  
end

%% Output updated controls information
controlsinfo = [...
    clothing minadjuststate metrate ambienttemp radianttemp airvelocity];    
end
           
           
           
          