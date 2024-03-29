function [acceptrangevector] = AcceptRangeGenerator(postpredmat_accept)
% AcceptRangeGenerator - Assembles an occupant's acceptable ranges
% thermal sensations across all four seasons

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
random_seed = 0;
startinit = 0;
acceptsum = 0;
acceptwint = 0;

%% Set random seed to use in generating acceptability ranges    
random_seed = randi([0,1000000],1);    

%% Randomly sample initial sensation to use in generating acceptability ranges

% Sample initial sensation
startinit = round(normrnd(0,1));
while startinit <-3 || startinit > 3
    startinit = round(normrnd(0,1));
end
% Determine initial sensation's acceptability for summer
acceptsum = binornd(1,postpredmat_accept((startinit+4)+7,4));
% Determine initial sensation's acceptability for winter
acceptwint = binornd(1,postpredmat_accept((startinit+4),4));
% Resample initial sensation if it is determined to be unacceptable in
% in either season
while acceptsum == 0 || acceptwint == 0
    startinit = round(normrnd(0,1));
    while startinit <-3 || startinit > 3
        startinit = round(normrnd(0,1));
    end        
    acceptsum = binornd(1,postpredmat_accept((startinit+4)+7,4));
    acceptwint = binornd(1,postpredmat_accept((startinit+4),4));
end 

%% Sample Warm/Cool season acceptability ranges
WarmSeasonAcceptableRange = Accept(...
    postpredmat_accept,random_seed,1,startinit);
ColdSeasonAcceptableRange = Accept(...
    postpredmat_accept,random_seed,0,startinit);

%% Output the ranges for each season 
% (for now, 'Fall/Winter' are cold seasons and 'Spring/Summer' are 
% warm seasons)
acceptrangevector = [...
    WarmSeasonAcceptableRange ColdSeasonAcceptableRange ...
    ColdSeasonAcceptableRange WarmSeasonAcceptableRange];
    
end

