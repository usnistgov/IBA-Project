function [MetInfo] = MetabolicRateGenerator(...
    OccupantMatrix,DayTime,simtimestep,RuleVector)
% MetabolicRateGenerator - Determines occupant's metabolic rate based on
% current and recent activities

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

%% Determine metabolic rate based on current and recent activities

% Occupant just entered office from outside the building
if (OccupantMatrix.OccupancyStateVector(2) == 1) && ...
        (OccupantMatrix.OccupancyStateVectorPrevious(1) == 0)
    % If it is morning, use commuting MET rate (except in case where
    % user has specified a constant baseline metabolic rate regardless)
    if (DayTime < 0.4)      
        metevent = 1;
        timedecay = 0;
        if any(RuleVector == 5)
            metrate = OccupantMatrix.BaseMet;
        else
            metrate = OccupantMatrix.CommuteMet;    
        end
    % If late/morning or afternoon, use leisurely walk MET rate (except in
    % case where user has specified a constant baseline metabolic rate
    % regardless)
    else
        metevent = 2;
        timedecay = 0;
        if any(RuleVector == 5)
            metrate = OccupantMatrix.BaseMet;
        else
            metrate = OccupantMatrix.OutWalkMet;    
        end
    end      
% Occupant just entered office from inside another part of the building  
elseif (OccupantMatrix.OccupancyStateVector(2) == 1) && ...
        ((OccupantMatrix.OccupancyStateVectorPrevious(2) == 0) && ...
        (OccupantMatrix.OccupancyStateVectorPrevious(1) == 1))
    metevent = 3;
    timedecay = 0;
    % Set to leisurely indoor walkabout metabolic rate (except in
    % case where user has specified a constant baseline metabolic rate
    % regardless)
    if any(RuleVector == 5)
        metrate = OccupantMatrix.BaseMet;
    else
        metrate = OccupantMatrix.InWalkMet;
    end
% Occupancy state has not changed from previous time step (i.e. occupant has
% been sitting at desk)
else 
    % Determine where we are on decay of an active metabolic rate (e.g., 15
    % minutes after entering building, you will still see effects of an
    % elevated entry MET rate).  If we are still above the baseline office
    % MET, decay the MET in appropriate manner.  Else, METevent = 0 and we
    % set MET to the baseline rate. 
    if OccupantMatrix.MetabolicRate > OccupantMatrix.BaseMet;
        metevent = OccupantMatrix.METevent;
        timedecay = OccupantMatrix.TimeDecay + simtimestep;
        if metevent == 1;
            metrate= OccupantMatrix.BaseMet + (...
                (OccupantMatrix.CommuteMet - OccupantMatrix.BaseMet) * ...
                (OccupantMatrix.CommuteMetDegrade ^(timedecay)));
        elseif metevent == 2;
            metrate = OccupantMatrix.BaseMet + (...
                (OccupantMatrix.OutWalkMet - OccupantMatrix.BaseMet) * ...
                (OccupantMatrix.OutWalkMetDegrade ^(timedecay)));
        else
            metrate = OccupantMatrix.BaseMet + (...
                (OccupantMatrix.InWalkMet - OccupantMatrix.BaseMet) * ...
                (OccupantMatrix.InWalkMetDegrade ^(timedecay))); 
        end
    else
    metevent = 0;
    timedecay = 0;
    metrate = OccupantMatrix.BaseMet;
    end
end 

%% Output calculated metabolic rate
MetInfo = [metevent timedecay metrate];

end