function [constraint] = StateConstraints(OccupantMatrix,b,rowtemp,...
    controls,runningmean)
% StateConstraints - Determines whether candidate behavioral action is 
% constrained by an external (but not social) factor

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

%% Determine state constraints based on behavior in question

% Clothing action (can be constrained to a range of acceptable office
% attire)
if (b==1||b==2)         
    % Occupant needs downward clothing adjustment: restriction is that
    % clothing can't be adjusted below 0.4 AND major adjustment downward
    % can't be made if morning clothing is < 0.5 (i.e. in the bottom of
    % three typical clothing bins).
    if rowtemp == 1;                
        if  ((OccupantMatrix.MorningClothing  - controls(b,3)) < 0.4)
            constraint = 1;            
        else           
            constraint = 0;            
        end        
    % Occupant needs upward clothing adjustment: restriction is that clothing
    % can't be adjusted above 1.05 AND minor adjustment upward can't be made
    % if morning clothing is < 0.7 (these minor upward adjustments tend to
    % be things like scarfs, gloves, etc. only used at a high existing
    % level of clothing)    
    else
        if  ((b==1) || ((OccupantMatrix.MorningClothing  + ...
                controls(b,3)) > 1.3))       
            constraint = 1;            
        else           
            constraint = 0;            
        end         
    end
    
% Window action (can be constrained by running mean outdoor temperature,
% where occupant won't open window if running mean outdoor temperature is
% warmer than the indoor operative temperature (no perceived cooling
% benefit of the action)
elseif (b==9);
    if (runningmean > (...
            (OccupantMatrix.IndoorEnvironmentVector(1)+...
            OccupantMatrix.IndoorEnvironmentVector(4))/2))  
        constraint = 1;
    else
        constraint = 0;
    end    
else        
    constraint = 0;
end
    
end