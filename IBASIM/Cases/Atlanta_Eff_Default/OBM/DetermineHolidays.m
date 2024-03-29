function [HolidayTimes] = DetermineHolidays(Year)
% DetermineHolidays - Determines the dates of major US holidays,
% given the current simulation year 

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

%% Extrinsic Function
eml.extrinsic('num2str');
coder.extrinsic('datenum');
coder.extrinsic('weekday');

%% Declare Variables
dayweek = 0;firstmonthday = 0;lastmonthday = 0;

%% Set simulation year
Year1 = Year;

%% Set reference times for holidays that change dates each year
dayweekmonthmat = [2 3 1;2 3 2;2 1 9;2 2 10;5 4 11;];
referencedtimes = NaN(length(dayweekmonthmat),1);
for v = 1: length(dayweekmonthmat)
    dayweek = dayweekmonthmat(v,1);
    firstmonthday = weekday(datenum([...
        num2str(dayweekmonthmat(v,3)) '/01/' num2str(Year1)]));
    if firstmonthday > dayweek
        firstmonthdaydist = (7 - firstmonthday) + dayweek;
    else
        firstmonthdaydist = (dayweek - firstmonthday);
    end
    daymonthholiday = 1 + firstmonthdaydist + ...
        (((dayweekmonthmat(v,2))-1)*7); 
    holidaystring = [...
        num2str(dayweekmonthmat(v,3)) '/' num2str(daymonthholiday) '/' ...
        num2str(Year1)]; 
    referencedtimes(v) = datenum(holidaystring); 
end

%% Determine holiday times
% New Year's Day
newyears = datenum(['01/01/' num2str(Year1)]);
% Martin Luther King Day
mlkday = referencedtimes(1);
% Presidents Day
presidentsday = referencedtimes(2);
% Memorial Day
dayweekmem = 2;
lastmonthday = weekday(datenum(['05/31/' num2str(Year1)]));
    if lastmonthday > dayweekmem
        lastmonthdaydist = (lastmonthday - dayweekmem);
    else
        lastmonthdaydist = (7 - lastmonthday);
    end
memorialholiday = (31 - lastmonthdaydist); 
memorialday = datenum(['05/' num2str(memorialholiday) '/' num2str(Year1)]);
% Independence Day
independenceday = datenum(['07/04/' num2str(Year1)]);
% Labor Day
laborday = referencedtimes(3);
% Columbus Day
columbusday = referencedtimes(4);
% Veterans Day
veteransday = datenum(['11/11/' num2str(Year1)]);
% Thanksgiving
thanksgiving = referencedtimes(5);
% Christmas
christmas = datenum(['12/25/' num2str(Year1)]);

%% Output holiday simulation times
HolidayTimes = [newyears mlkday presidentsday memorialday ...
    independenceday laborday columbusday veteransday thanksgiving christmas];

end


