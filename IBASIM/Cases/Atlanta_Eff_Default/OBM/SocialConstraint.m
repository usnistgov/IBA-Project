function [socconstraint] = SocialConstraint(SocialMatrix,b,Season,...
    postpredmat_sens,controls,closetting,rowtemp)
% SocialConstraint - Determines whether an occupant's behavioral action
% causes discomfort for a majority of the other occupants in the zone, in
% which case there is a social constraint on performing the action

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

%% Initialize projected comfort states of other occupants in zone
tempconditions_actions = zeros(length(SocialMatrix),4);

%% Populate Social Matrix with projected comfort states given occupant's behavior
% Applies to personal heaters, thermostats, doors and windows

for s = 1:length(SocialMatrix);
    % Personal heater action
    if b == 5
        % Ambient and radiant temperature change
        tempconditions_actions(s,1) = ...
            SocialMatrix(s).IndoorEnvironmentVector(1) + controls(b,3);  
        tempconditions_actions(s,2) = tempconditions_actions(s,1);
        % Draw PMV and comfort given the changes, set current comfort/PMV
        % action condition
        SocialMatrix(s) = ...
            PMVsocial(...
            SocialMatrix(s),closetting,b,tempconditions_actions(s,1:3));
        SocialMatrix(s).PMVact = ...
            PMVact(Season,SocialMatrix(s),postpredmat_sens);
        tempconditions_actions(s,4) = SocialMatrix(s).PMVact;    
    % Thermostat action
    elseif b == 7;       
        % Ambient and radiant temperature change
        if rowtemp == 1; % Cooling action
        tempconditions_actions(s,1) = ...
            SocialMatrix(s).IndoorEnvironmentVector(1) - 1;
        else % Warming action
        tempconditions_actions(s,1) = ...
            SocialMatrix(s).IndoorEnvironmentVector(1) + 1;
        end
        tempconditions_actions(s,2) = tempconditions_actions(s,1);
        % Draw PMV and comfort given the changes, set current comfort/PMV
        % action condition
        SocialMatrix(s) = PMVsocial(...
            SocialMatrix(s),closetting,b,tempconditions_actions(s,1:3));    
        SocialMatrix(s).PMVact = PMVact(...
            Season,SocialMatrix(s),postpredmat_sens);        
        tempconditions_actions(s,4) = SocialMatrix(s).PMVact;
    % Door action
    elseif b == 8;        
        %AV change
        tempconditions_actions(s,3) = ...
            SocialMatrix(s).IndoorEnvironmentVector(3) + controls(b,3);
        % Draw PMV and comfort given the changes, set current comfort/PMV 
        % action condition        
        SocialMatrix(s) = PMVsocial(...
            SocialMatrix(s),closetting,b,tempconditions_actions(s,1:3));
        SocialMatrix(s).PMVact = PMVact(...
            Season,SocialMatrix(s),postpredmat_sens);        
        tempconditions_actions(s,4) = SocialMatrix(s).PMVact;            
    % Window action
    elseif b == 9;        
        %AV change
        tempconditions_actions(s,3) = ...
            SocialMatrix(s).IndoorEnvironmentVector(3) + controls(b,3);
        % Draw PMV and comfort given the changes, set current comfort/PMV
        % action condition        
        SocialMatrix(s) = PMVsocial(...
            SocialMatrix(s),closetting,b,tempconditions_actions(s,1:3));
        SocialMatrix(s).PMVact = PMVact(...
            Season,SocialMatrix(s),postpredmat_sens);        
        tempconditions_actions(s,4) = SocialMatrix(s).PMVact;        
    end
end

%% Determine whether there is a social constraint on the action
% Create vector that filters all the occupants WITHOUT discomfort out
% tempconditionsbar = tempconditions_actions(...
%     abs(tempconditions_actions(:,4))==1);    
counter_temp = 0;
counter_temp = sum(abs(tempconditions_actions(:,4)));

% If the length of the temporary vector/original number of occupants in
% Social Matrix > 0.5 (e.g., the occupant's action will result in a
% majority of surrounding occupants being uncomfortable/requiring
% action), impose the social constraint on the action.

% if (length(tempconditionsbar)/length(tempconditions_actions))> 0.5

if (SocialMatrix(1).OfficeType==3)&&((counter_temp/size(tempconditions_actions,1))> 0)...
        ||(SocialMatrix(1).OfficeType==6)&&((counter_temp/size(tempconditions_actions,1))> 0.2)...
        ||(SocialMatrix(1).OfficeType==2)&&((counter_temp/size(tempconditions_actions,1))> 0)
    socconstraint = 1; 
else    
    socconstraint = 0; 
end


end