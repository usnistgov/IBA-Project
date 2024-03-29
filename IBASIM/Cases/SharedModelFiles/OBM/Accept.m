function [AcceptableRange] = Accept(...
    postpredmat_accept,random_seed,seas,startinit)
% Accept - Determines range of acceptable thermal sensations for 
% an occupant agent in each of four seasons

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
startl = 0;
acceptc = 0;
starth = 0;
acceptw = 0;
acceptlow = 0;
accepthigh = 0;

%% Set random seed    
rng(random_seed);    
    
%% Determine cold acceptability range limit

% Initialize low acceptability sensation
startl = startinit;
acceptc = 1;

% Walk down towards sensation = -3 (Cold extreme) until sensation is 
% sampled as "unacceptable" for given season
while (acceptc == 1 && startl > -3)    
    startl = startl - 1;
    if seas == 1
    acceptc = binornd(1,postpredmat_accept((startl+4)+7,4));
    else
    acceptc = binornd(1,postpredmat_accept((startl+4),4));
    end
end

% Determine whether last cold sensation  was acceptable, if so, low limit =
% last sampled sensation, else low limit = one above last sampled sensation 
if acceptc == 1
    acceptlow = startl;   
else
    acceptlow = (startl + 1);
end

%% Determine warm acceptability range limit

% Initialize warm acceptability threshold
starth = startinit;
acceptw = 1;

% Walk up towards sensation = +3 (Hot extreme) until sensation is sampled
% as "unacceptable" for given season
while (acceptw == 1 && starth<3)
        starth = starth + 1;
        if seas == 1
        acceptw = binornd(1,postpredmat_accept((starth+4)+7,4));
        else
        acceptw = binornd(1,postpredmat_accept((starth+4),4));
        end
end

% Determine whether last warm sensation was acceptable, if so, high limit 
% = last sampled sensation, else high limit = one below last sampled
% sensation
if acceptw == 1
    accepthigh = starth;
else
    accepthigh = (starth - 1);
end
  
%% Output acceptable range 
AcceptableRange = [acceptlow accepthigh];
end