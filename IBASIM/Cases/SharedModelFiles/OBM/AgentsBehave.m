function [OccupantMatrix] = AgentsBehave(OccupantMatrix,...
    postpredmat_sens,controls,SocialMatrix,closetting,Season,trm)
% AgentsBehave - Runs an agent-based behavior routine that determines
% updated behavior states given occupant agent comfort/discomfort, control
% availabilities/existing states, and control constraints

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

%% Declare variable
whichbehavior = zeros(1,10);
zonelevelconstraint = 0;
officelevelconstraint = 0;

temp=1;
rrr=repmat({0},1,temp);
vvv2=repmat({[0 0]},1,temp);
vvv4=repmat({[0 0 0 0]},1,temp);
vvv8=repmat({[0 0 0 0 0 0 0 0]},1,temp);
vvv10=repmat({[0 0 0 0 0 0 0 0 0 0]},1,temp);
mmm22=repmat({zeros(2,2)},1,temp);
mmm25=repmat({zeros(2,5)},1,temp);
mmm105=repmat({zeros(10,5)},1,temp);
mmm110=repmat({zeros(1,10)},1,temp);
mmm210=repmat({zeros(2,10)},1,temp);        
SocialMatSpecific = struct('Zone',rrr,'Validate',rrr,'OfficeNum',rrr,...
    'OfficeType',rrr,'OccupantNum',rrr,'Gender',rrr,'CommuteMet',rrr,...
    'OutWalkMet',rrr,'InWalkMet',rrr,'BaseMet',rrr,...
    'CommuteMetDegrade',rrr,'OutWalkMetDegrade',rrr,...
    'InWalkMetDegrade',rrr,'METevent',rrr,'TimeDecay',rrr,...
    'MetabolicRate',rrr,'OccupancyStateVector',vvv2,...
    'OccupancyStateVectorPrevious',vvv2,'InOffice',rrr,...
    'OutofOffice',rrr,'InSaturday',rrr,'InSundHolidays',rrr,...
    'DayStartTimeBase',rrr,'LunchStartTimeBase',rrr,...
    'LunchEndTimeBase',rrr,'DayEndTimeBase',rrr,'DayStartTime',rrr,...
    'LunchStartTime',rrr, 'LunchEndTime',rrr,'DayEndTime',rrr,...
    'SatDayStartTimeBase',rrr,'SatLunchStartTimeBase',rrr,...
    'SatLunchEndTimeBase',rrr,'SatDayEndTimeBase',rrr,...
    'SatDayStartTime',rrr,'SatLunchStartTime',rrr,...
    'SatLunchEndTime',rrr,'SatDayEndTime',rrr,...
    'SHDayStartTimeBase',rrr,'SHLunchStartTimeBase',rrr,...
    'SHLunchEndTimeBase',rrr,'SHDayEndTimeBase',rrr,...
    'SHDayStartTime',rrr,'SHLunchStartTime',rrr,...
    'SHLunchEndTime',rrr,'SHDayEndTime',rrr,...
    'OfficeWalkProb',rrr,'LeavesLunchProb',rrr,...
    'MorningClothing',rrr,'CurrentClothing',rrr,...
    'PersonalConstraints',mmm25,'AcceptabilityVector',vvv8,...
    'PreferenceClass',vvv4,'BehaviorConstraintsMatrix',mmm210,...
    'InitialBehaviorPossibilitiesMatrix',mmm210,...
    'BehaviorPossibilitiesMatrix',mmm210,...
    'InitialBehaviorHierarchyMatrix',mmm210,...
    'BehaviorHierarchyMatrix',mmm210,...
    'InitialBehaviorStatesVector',mmm110,...
    'BehaviorStatesVector',mmm110,...
    'PreviousBehaviorStatesVector',mmm110,...
    'BehaviorConstraintsState',mmm105,...
    'InitialPersonalDeviceLocation',vvv2,'PersonalDeviceLocation',vvv2,...
    'SharedThermNum',rrr,'SharedDoorNum',rrr,'SharedWindowNum',rrr,...
    'SharedBlindNum',rrr,'IndoorEnvironmentVectorBase',vvv4,...
    'IndoorEnvironmentVector',vvv4,'OutdoorEnvironmentVector',vvv2,...
    'PMVdraw',rrr,'PMVact',rrr,'HumphreysPMVact',rrr,'WhichPMVact',rrr,...
    'ExceedWarm',rrr,'ExceedCold',rrr,'MeanProductivity',rrr,...
    'ProductivityCount',rrr,'OccTimeSteps',rrr,'OccPosition',vvv2,...
    'OccBehaviorInterval',vvv10);

%% Determine the subset of actions being updated ('too warm' or 'too cold')

% 'Too warm' action
if OccupantMatrix.PMVact == 1;
    rowtemp = 1;
% 'Too cold' action
else
    rowtemp = 2;
end

% 'Too warm' reversal action
if rowtemp == 1;
    reversalrow = 2;
% 'Too cold' reversal action
else
    reversalrow = 1;
end

%% Select specific action to be taken (* can be none)
% If too warm with window open and outdoor temperature is greater than
% the indoor operative temperature, change window state to closed
if ((OccupantMatrix.PMVact == 1) && ...
        (OccupantMatrix.BehaviorStatesVector(9)==-1 && ...
        (OccupantMatrix.OutdoorEnvironmentVector(1) > ...
        ((OccupantMatrix.IndoorEnvironmentVector(1) + ...
        OccupantMatrix.IndoorEnvironmentVector(4))/2))))
    
    % Record a window adjustment action
    OccupantMatrix.WhichPMVact = 9;
    % Update window state to closed and reset the window adjustment
    % behavior possibility to initial state
    OccupantMatrix.BehaviorStatesVector(9) = 0;
    OccupantMatrix.BehaviorPossibilitiesMatrix(1,9) = ...
        OccupantMatrix.InitialBehaviorPossibilitiesMatrix(1,9);

% In all other cases, first determine whether an existing action can be
% reversed to amelerioate the warm/cool discomfort
elseif any(OccupantMatrix.BehaviorStatesVector == OccupantMatrix.PMVact)==1
    
    % Set up a vector of reversal options, and determine their order from
    % user settings in Excel setup file
    reversalrankvector = repmat(99,1,10);
    
    % Cycle through all behaviors to determine reversal action
    for n = 1:10       
        % Case where there is a reversal act available for this behavior 
        % with no existing external constraints on it for this time step           
        if (OccupantMatrix.BehaviorStatesVector(n) == ...
                OccupantMatrix.PMVact) && ...
                (any(OccupantMatrix.BehaviorConstraintsState(n,:)==1)==0)
            % Determine any personal constraints on the reversal behavior
            % (only the personal work disruption constraint is applied for
            % a reversal behavior; it is assumed that other personal
            % constraints don't apply if the behavior has already been 
            % taken once)
            if (controls(n,7) == 1) && ...
                    (OccupantMatrix.PersonalConstraints(1,4) == 1) && ...
                    ((any(...
                    OccupantMatrix.OccupancyStateVectorPrevious(:))==0)==0) 
                % Check for a personal work disruption constraint (e.g.,
                % the occupant values productivity above comfort and is
                % not just returning to the office)
                personaldistractionconstraint = ...
                    binornd(1,OccupantMatrix.PersonalConstraints(2,4));  
                % Update the state of possible behavior constraints based
                % upon the above check 
                OccupantMatrix.BehaviorConstraintsState(n,4) = ...
                    personaldistractionconstraint;
                % If there isn't a personal work disruption constraint,
                % enter the behavior into the list of options according
                % to its user-defined reversal hierarchy; otherwise it
                % is not entered into the list
                if personaldistractionconstraint == 0;         
                    reversalrankvector(n) = controls(n,9);
                end
            else
                % If there is no personal constraint, enter the behavior
                % into the reversal candidates
                reversalrankvector(n) = controls(n,9);
            end  
        end                 
    end
    
    % Thermostat reversal behaivor will be prevented by social constraints
    % (YC)
    if OccupantMatrix.PersonalConstraints(1,2)==1 &&...
            binornd(1,OccupantMatrix.PersonalConstraints(2,2))==1
        reversalrankvector(7)=99;
    end
    
    % Case where there are viable reversal behaviors available as
    % determined above
    if min(reversalrankvector) < 99
        % Find the highest behavior on the reversal hierarchy
        whichbehavior = find(reversalrankvector(:) == ...
            min(reversalrankvector));
        
        % If there is a tie, pick the winning behavior from uniform random
        % distribution
        if length(whichbehavior) > 1 
           rind = randi([1,length(whichbehavior)]);
           OccupantMatrix.WhichPMVact = whichbehavior(rind);
        else
           % change whichbehavior to whichbehavior(1) as it is declared as
           % a vector (ZC)
           OccupantMatrix.WhichPMVact = whichbehavior(1);
        end

        % Update the behavior states and possibilities vectors given the
        % chosen behavior
        OccupantMatrix.BehaviorStatesVector(OccupantMatrix.WhichPMVact) = 0;
        OccupantMatrix.BehaviorPossibilitiesMatrix(...
            reversalrow,OccupantMatrix.WhichPMVact) = ...
            OccupantMatrix.InitialBehaviorPossibilitiesMatrix(...
            reversalrow,OccupantMatrix.WhichPMVact);  
    % Case where there are no viable reversals on the list (no action is
    % taken)
    else 
        OccupantMatrix.WhichPMVact = 0;
    end

% If no reversal actions are possible, next determine whether there are
% available (non-reversal) actions that do not have constraints on them
elseif any(OccupantMatrix.BehaviorPossibilitiesMatrix(rowtemp,:) > 0) == 1
    
    % Set up a vector of action options, and determine their order from
    % user settings in Excel setup file
    actionrankvector = repmat(99,1,10);
    
    % Cycle through all behaviors to determine non-reversal action
    for b = 1:10
        % Case where the behavior is possible and hasn't already been 
        % constrained for this time step (proceed further)
        if (OccupantMatrix.BehaviorPossibilitiesMatrix(rowtemp,b)~=0) && ...
                (any(OccupantMatrix.BehaviorConstraintsState(b,:)==1)==0);
            
            % Check for a state constraint on the behavior (e.g., a typical
            % office clothing level range)
            if OccupantMatrix.BehaviorPossibilitiesMatrix(rowtemp,b) == 1; 
                stateconstrainttemp = StateConstraints(...
                    OccupantMatrix,b,rowtemp,controls,trm); 
            else
                stateconstrainttemp = 0 ;
            end
            
            % If there are no state constraints on the behavior, check for
            % contextual/personal constraints
            if stateconstrainttemp == 0;
                % Case where there is some kind of contextual/personal 
                % constraint on the behavior
                if ((any(...
                        OccupantMatrix.BehaviorConstraintsMatrix(:,b))>0)...
                        ==1);

                    % Check for zone-level constraint (management forbids
                    % behavior and occupant listens to management)
                    if (OccupantMatrix.BehaviorConstraintsMatrix(1,b) == 1) ...
                            && (OccupantMatrix.PersonalConstraints(1,1) == 1)
                        zonelevelconstraint = binornd(...
                            1,OccupantMatrix.PersonalConstraints(2,1));
                    else
                        zonelevelconstraint = 0;
                    end

                    % Check for office-level constraint (behavior makes 
                    % majority of others uncomfortable and occupant cares
                    % about the comfort of others)
                    if (zonelevelconstraint == 0) && ...
                            (OccupantMatrix.BehaviorConstraintsMatrix(2,b) == 1) ...
                            && (OccupantMatrix.PersonalConstraints(1,2) == 1) ...
                            && (size(SocialMatrix,2)>0)

                        % Define a social constraints matrix for those in 
                        % zone and office type who actually share the 
                        % control with the given occupant
                        
                        % Personal heater (no sharing, but still affects
                        % the comfort of others in the space)
                        if b == 5
                            SocialMatSpecific = SocialMatrix;
                        % Thermostat sharing
                        elseif b == 7
                            % Extract SocialMatrix with for loop (ZC)
                            SharedThermNumExt = ...
                                zeros(1,size(SocialMatrix,2));
                            for i=1:size(SocialMatrix,2)
                                SharedThermNumExt(i)= ...
                                    SocialMatrix(i).SharedThermNum;
                            end
                            SocialMatSpecific = SocialMatrix(...
                                (SharedThermNumExt == ...
                                [OccupantMatrix.SharedThermNum]));    
                        % Door sharing
                        elseif b == 8
                            % Extract SocialMatrix with for loop (ZC)
                            SharedDoorNumExt = ...
                                zeros(1,size(SocialMatrix,2));
                            for i=1:size(SocialMatrix,2)
                                SharedDoorNumExt(i)= ...
                                    SocialMatrix(i).SharedDoorNum;
                            end
                            SocialMatSpecific = SocialMatrix(...
                                (SharedDoorNumExt == ...
                                [OccupantMatrix.SharedDoorNum]));
                        % Window sharing
                        elseif b == 9
                            % Extract SocialMatrix with for loop (ZC)
                            SharedWindowNumExt = ...
                                zeros(1,size(SocialMatrix,2));
                            for i=1:size(SocialMatrix,2)
                                SharedWindowNumExt(i)= ...
                                    SocialMatrix(i).SharedWindowNum;
                            end
                            SocialMatSpecific = SocialMatrix(...
                                (SharedWindowNumExt == ...
                                [OccupantMatrix.SharedWindowNum]));
                        % No sharing
                        else
%                             SocialMatSpecific = []; 
                            SocialMatSpecific = SocialMatrix([0 0]&[0 0]);
                        end
                        
                        % Determine if there is a social constraint for 
                        % those sharing or affected by a behavior
                        if size(SocialMatSpecific,2)>0
                            socialbarrier = ...
                                SocialConstraint(SocialMatSpecific,b,...
                                Season,postpredmat_sens,controls,...
                                closetting,rowtemp);
                        else
                            socialbarrier = 0;
                        end
                        if socialbarrier == 1
                           officelevelconstraint = binornd(...
                               1,OccupantMatrix.PersonalConstraints(2,2)); 
                        else
                           officelevelconstraint = 0;
                        end
                    else 
                        officelevelconstraint = 0;
                    end
                end

                % Check for personal constraint (occupant doesn't choose
                % actions that use too much energy OR occupant doesn't 
                % choose actions that are disruptive to their work flow OR
                % occupant doesn't choose actions that are unfamiliar to 
                % them)
                
                % Check energy saver constraint
                if (zonelevelconstraint == 0) && ...
                        (officelevelconstraint == 0) && ...
                        (controls(b,6)==1) && ...
                        (OccupantMatrix.PersonalConstraints(1,3) == 1)        
                    personalenergyconstraint = binornd(...
                        1,OccupantMatrix.PersonalConstraints(2,3));   
                else
                    personalenergyconstraint = 0;  
                end


                % Check work disruption constraint (for heaters and fans, 
                % check if device is in drawer); for all behaviors, check
                % to see if occupant has just arrived at the office, if so 
                % no constraint 
                if (controls(b,7)==1) && ...
                        (OccupantMatrix.PersonalConstraints(1,4) == 1) ...
                        && (((b~=5 && b~=6)) || ...
                        ((b==5 && ...
                        OccupantMatrix.PersonalDeviceLocation(1) == 0)||...
                        (b==6 && ...
                        OccupantMatrix.PersonalDeviceLocation(2) == 0)))...
                        &&...
                        ((any(...
                        OccupantMatrix.OccupancyStateVectorPrevious(:))...
                        ==0)==0)        
                    personaldistractionconstraint = binornd(...
                    1,OccupantMatrix.PersonalConstraints(2,4));   
                else
                    personaldistractionconstraint = 0;  
                end

                % Check for lack of controls knowledge constraint
                if (controls(b,8)==1) && ...
                        (OccupantMatrix.PersonalConstraints(1,5) == 1)        
                    personalknowledgeconstraint = ...
                        binornd(1,OccupantMatrix.PersonalConstraints(2,5));   
                else
                    personalknowledgeconstraint = 0;  
                end
                
                % Update the state of possible behavior constraints based
                % upon the above checks
                OccupantMatrix.BehaviorConstraintsState(b,:) = [...
                    zonelevelconstraint officelevelconstraint ...
                    personalenergyconstraint ...
                    personaldistractionconstraint ...
                    personalknowledgeconstraint];

                % If no constraints on the given behavior, determine its
                % order in the controls hierarchy
                if any(OccupantMatrix.BehaviorConstraintsState(b,:)...
                        == 1) == 0;
                    actionrankvector(b) = controls(b,8);
                end
            end
        end            
    end          
    
    % Case where there are viable non-reversal behaviors available as
    % determined above
    if  min(actionrankvector) < 99;
        
        % Find which action comes first on user-defined hierarchy
        whichbehavior = find(actionrankvector(:) == min(actionrankvector));

        % If there is a tie, pick the winning behavior from uniform random
        % distribution
        if length(whichbehavior) > 1;
           rind = randi([1,length(whichbehavior)]);
           OccupantMatrix.WhichPMVact = whichbehavior(rind);
        else
           % change whichbehavior to whichbehavior(1) as it is declared as
           % a vector (ZC)
           OccupantMatrix.WhichPMVact = whichbehavior(1);
        end
        
        % Update the behavior states and possibilities vectors given the
        % chosen behavior
        if rowtemp == 1; 
            OccupantMatrix.BehaviorStatesVector(...
                OccupantMatrix.WhichPMVact) = -1;
        else
            OccupantMatrix.BehaviorStatesVector(...
                OccupantMatrix.WhichPMVact) = 1;
        end
        if OccupantMatrix.WhichPMVact ~= 3 % for drinking, it is always possiable to do (YC 2022/02/11)
        OccupantMatrix.BehaviorPossibilitiesMatrix(...
            rowtemp,OccupantMatrix.WhichPMVact) = 0;
        end
    % Case where there are no viable actions on the list (no action is
    % taken)
    else
        % Set an exceedance if there are no reversals or actions available
        
        % Warm Exceedance
        if rowtemp == 1; 
            OccupantMatrix.ExceedWarm = OccupantMatrix.ExceedWarm + 1;
        % Cold Exceedance
        else
            OccupantMatrix.ExceedCold = OccupantMatrix.ExceedCold + 1;
        end
        
        % No action is taken
        OccupantMatrix.WhichPMVact = 0;

    end
end

if OccupantMatrix.WhichPMVact ~= 0
    BehaviorInterval=size(OccupantMatrix(1).OccBehaviorInterval,2);
    OccupantMatrix.OccBehaviorInterval=zeros(1,BehaviorInterval);
    OccupantMatrix.OccBehaviorInterval(1)=1;
end

%% Evaluate the effects of chosen action (if any) 
% If no action is chosen, do not update PMV and PMVact - nothing happens 
% and the behavior loop will be exited;
% if OccupantMatrix.WhichPMVact ~= 0;
%     
%     % Calculate effects of action on PMV inputs
%     ControlStates = ChangeEffects(OccupantMatrix,controls);
%     % Update PMV inputs based on calculated effects of action
%     OccupantMatrix.CurrentClothing = ControlStates(1);
%     OccupantMatrix.BehaviorStatesVector(1) = ControlStates(2);
%     OccupantMatrix.MetabolicRate = ControlStates(3);
%     OccupantMatrix.IndoorEnvironmentVector(1) = ControlStates(4);
%     OccupantMatrix.IndoorEnvironmentVector(3) = ControlStates(6);
%     OccupantMatrix.IndoorEnvironmentVector(4) = ControlStates(5);
%     % Update PMV and PMVact agent variables 
%     OccupantMatrix.PMVdraw = PMV(OccupantMatrix,closetting);
%     OccupantMatrix.PMVact = PMVact(Season,OccupantMatrix,postpredmat_sens);
%     
% end
end
