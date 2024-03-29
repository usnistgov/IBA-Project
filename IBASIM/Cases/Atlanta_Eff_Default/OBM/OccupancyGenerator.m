function [OccupantMatrix] = OccupancyGenerator(...
    OccupantMatrix,SimulationTime,occmodel,walkchecktimestep,...
    holiday,WeekTime) 
% OccupancyGenerator - Determines whether an occupant is in or out of the
% office for the simple user-defined occupancy modeling option in the Excel
% setup file

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

%% Generate occupancy state for simple occupant modeling approach in Excel setup file
if (occmodel(1) == 1); 
    % Set occupancy state for holiday/Sunday if occupant comes in on these
    % days
    if ((holiday==1)||(WeekTime == 1))&&(OccupantMatrix.InSundHolidays==1);        
        if ((SimulationTime >= (...
                OccupantMatrix.SHDayStartTime - (5/60/24)) && ...
                SimulationTime < (OccupantMatrix.SHLunchStartTime - ...
                (5/60/24))) || (SimulationTime >= (...
                OccupantMatrix.SHLunchEndTime - (5/60/24)) && ...
                SimulationTime <= (...
                OccupantMatrix.SHDayEndTime - (5/60/24))));        
            if OccupantMatrix.OutofOffice == 0;                 
                walkingtime = binornd(1,walkchecktimestep);
                if walkingtime == 1;                    
                   OccupantMatrix.OccupancyStateVector(1) = 1;
                   OccupantMatrix.OccupancyStateVector(2) = ...
                       binornd(1,(1-OccupantMatrix.OfficeWalkProb));
                else
                OccupantMatrix.OccupancyStateVector(:) = 1;
                end            
            else
            OccupantMatrix.OccupancyStateVector(:) = 255;    
            end
        elseif (SimulationTime >= (...
                OccupantMatrix.SHLunchStartTime - (5/60/24)) && ...
                SimulationTime < (OccupantMatrix.SHLunchEndTime -...
                (5/60/24)))
            if OccupantMatrix.OutofOffice == 0               
               OccupantMatrix.OccupancyStateVector(:) = ...
                   binornd(1,(1-OccupantMatrix.LeavesLunchProb));                                
            else
            OccupantMatrix.OccupancyStateVector(:) = 255;            
            end            
        else
            OccupantMatrix.OccupancyStateVector(:) = 0;
        end    
   
    % Set occupancy state for Saturday if occupant comes in on this day
    elseif (WeekTime == 7)&&(OccupantMatrix.InSaturday==1)      
        if ((SimulationTime >= (...
                OccupantMatrix.SatDayStartTime - (5/60/24)) && ...
                SimulationTime < (...
                OccupantMatrix.SatLunchStartTime - (5/60/24))) || ...
                (SimulationTime >= (...
                OccupantMatrix.SatLunchEndTime - (5/60/24)) && ...
                SimulationTime <= (...
                OccupantMatrix.SatDayEndTime - (5/60/24))));        
            if OccupantMatrix.OutofOffice == 0;                 
                walkingtime = binornd(1,walkchecktimestep);
                if walkingtime == 1;                    
                   OccupantMatrix.OccupancyStateVector(1) = 1;
                   OccupantMatrix.OccupancyStateVector(2) = ...
                       binornd(1,(1-OccupantMatrix.OfficeWalkProb));
                else
                OccupantMatrix.OccupancyStateVector(:) = 1;
                end            
            else
            OccupantMatrix.OccupancyStateVector(:) = 255;    
            end
        elseif (SimulationTime >= (...
                OccupantMatrix.SatLunchStartTime - (5/60/24)) && ...
                SimulationTime < (...
                OccupantMatrix.SatLunchEndTime -(5/60/24)))
            if OccupantMatrix.OutofOffice == 0               
               OccupantMatrix.OccupancyStateVector(:) = ...
                   binornd(1,(1-OccupantMatrix.LeavesLunchProb));                                
            else
            OccupantMatrix.OccupancyStateVector(:) = 255;            
            end            
        else
            OccupantMatrix.OccupancyStateVector(:) = 0;
        end
        
    % Set occupancy state for weekdays/non-holidays   
    elseif (WeekTime>1 && WeekTime <7 && holiday == 0);            
        if ((SimulationTime >= (...
                OccupantMatrix.DayStartTime - (5/60/24)) && ...
                SimulationTime < (...
                OccupantMatrix.LunchStartTime - (5/60/24))) || ...
                (SimulationTime >= (...
                OccupantMatrix.LunchEndTime - (5/60/24)) && ...
                SimulationTime <= (OccupantMatrix.DayEndTime - ...
                (5/60/24))));        
            if OccupantMatrix.OutofOffice == 0;                 
                walkingtime = binornd(1,walkchecktimestep);
                if walkingtime == 1;                    
                   OccupantMatrix.OccupancyStateVector(1) = 1;
                   OccupantMatrix.OccupancyStateVector(2) = ...
                       binornd(1,(1-OccupantMatrix.OfficeWalkProb));
                else
                OccupantMatrix.OccupancyStateVector(:) = 1;
                end            
            else
            OccupantMatrix.OccupancyStateVector(:) = 255;    
            end
        elseif (SimulationTime >= (...
                OccupantMatrix.LunchStartTime - (5/60/24)) && ...
                SimulationTime < (OccupantMatrix.LunchEndTime -(5/60/24)))
            if OccupantMatrix.OutofOffice == 0               
               OccupantMatrix.OccupancyStateVector(:) = ...
                   binornd(1,(1-OccupantMatrix.LeavesLunchProb));                                
            else
            OccupantMatrix.OccupancyStateVector(:) = 255;            
            end            
        else
            OccupantMatrix.OccupancyStateVector(:) = 0;
        end       
    else
        OccupantMatrix.OccupancyStateVector(:) = 0;        
    end
%% Generate occupancy state for a more advanced occupancy modeling option (not currently available)
else
    % Eventually insert more advanced occupancy modeling program 
    % capabilities here; for now, instruct user to select either simple
    % probabilistic occupancy modeling option
    error('Advanced occupancy models currently unavailable (change Excel setup file)!')
end
end