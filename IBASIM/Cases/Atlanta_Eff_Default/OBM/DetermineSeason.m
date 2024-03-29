function SeasonMat = DetermineSeason(SimulationTime)
% DetermineSeason - Determines the seasons of the current and previous 
% simulation time steps, given the current simulation time 

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

%% Extrinsic function
coder.extrinsic('datevec');
coder.extrinsic('datenum');
eml.extrinsic('num2str');
%% Variable Declaration
Year1 = 0;datesum = 0;datefall= 0;datewint = 0;datespring = 0;PrevYear = 0;
Season = 0;SeasonPrevious = 0;
%% Determine current time of day
DayTime = mod(SimulationTime,1);

%% Determine current year we are in and the appropriate starting day for each season
YearVec1 = datevec(SimulationTime);
Year1 = YearVec1(1);
datesum = datenum(['06/21/' num2str(Year1)]);
datefall= datenum(['09/21/' num2str(Year1)]);
datewint = datenum(['12/21/' num2str(Year1)]);
datespring = datenum(['03/21/' num2str(Year1)]);
PrevYear = datenum((Year1-1),12,31);
DayofYearSummer = (datesum - PrevYear);
DayofYearFall = (datefall - PrevYear);
DayofYearWinter = (datewint - PrevYear);
DayofYearSpring =(datespring - PrevYear);
DayofYear = floor(SimulationTime - PrevYear);

%% Determine season of current and previous simulation time steps
if (DayofYear >= DayofYearSummer && DayofYear < DayofYearFall)    
    Season = 1;
    SeasonPrevious = 1;
elseif (DayofYear >= DayofYearFall && DayofYear < DayofYearWinter)       
    Season = 2;    
    if ((DayofYear == DayofYearFall) && ...
            (DayTime > (25/60/24) && DayTime < (35/60/24))) 
        SeasonPrevious = 1;
    else
        SeasonPrevious = 2;
    end
elseif (DayofYear >= DayofYearWinter || DayofYear < DayofYearSpring)    
    Season = 3;    
    if (DayofYear == DayofYearWinter) && ...
            (DayTime > (25/60/24) && DayTime < (35/60/24))
        SeasonPrevious = 2;
    else
        SeasonPrevious = 3;
    end    
elseif  (DayofYear >= DayofYearSpring && DayofYear < DayofYearSummer)  
    Season = 4;
    if (DayofYear == DayofYearSpring) && ...
            (DayTime > (25/60/24) && DayTime < (35/60/24))
        SeasonPrevious = 3;
    else
        SeasonPrevious = 4;
    end
end

%% Output current and previous season
SeasonMat = [Season SeasonPrevious];

end