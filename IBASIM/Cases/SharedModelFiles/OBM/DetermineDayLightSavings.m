function [DayLightTimes] = DetermineDayLightSavings(Year)
% DetermineDayLightSavings - Determines the starting and ending times for 
% daylight savings, given the current simulation year

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

%% extrinsic function
eml.extrinsic('num2str');
coder.extrinsic('datenum');
coder.extrinsic('weekday');

%% Declare variables
firstmonthdaylightstart = 0;
firstmonthdaylightstartdist = 0;
daylightstart = 0;
lastmonthdaylightend = 0;
lastmonthdaylightenddist = 0;
daylightend = 0;

%% Set the simulation year
Year1 = Year;

%% Set the starting date for daylight savings 
daylightstartday = 1;
firstmonthdaylightstart = weekday(datenum(['04/01/' num2str(Year1)]));
    if firstmonthdaylightstart > daylightstartday
        firstmonthdaylightstartdist = (7 - firstmonthdaylightstart) + ...
            daylightstartday;
    else
        firstmonthdaylightstartdist = (firstmonthdaylightstart - ...
            firstmonthdaylightstart);
    end
daylightstart = 1 + firstmonthdaylightstartdist; 
daylightstartday = datenum(['04/' num2str(daylightstart) '/' ...
    num2str(Year1)]); 

%% Set the ending date for daylight savings
daylightendday = 1;
lastmonthdaylightend = weekday(datenum(['10/31/' num2str(Year1)]));
    if lastmonthdaylightend > daylightendday
        lastmonthdaylightenddist = (lastmonthdaylightend - daylightendday);
    else
        lastmonthdaylightenddist = (7 - lastmonthdaylightend);
    end
daylightend = (31 - lastmonthdaylightenddist);
daylightendday = datenum(['10/' num2str(daylightend) '/' num2str(Year1)]);
 
%% Output starting and ending times for daylight savings for given year
DayLightTimes = [daylightstartday daylightendday];

end