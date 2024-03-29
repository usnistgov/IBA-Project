function [prod] = Productivity(OccMatrix,postpredmat_sens)
% Productivity - Determines an occupant's relative work performance % based
% on the model of Jensen et al (2009)

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
coder.extrinsic('mnrnd');

%% Declare variable
prodmat = zeros(1,7);
prodmatalt = zeros(1,7);
prodsens = zeros(1,7);
sens = 0;
prod = 0;

%% Determine the occupant's current thermal sensation

% Determine occupant's PMV draw
pmvdraw = OccMatrix.PMVdraw;
% Ensure PMV draw is between -3 and 3
if pmvdraw < -3.0    
    pmvdraw = -3;    
elseif pmvdraw > 3.0    
    pmvdraw = 3;
else      
end

% Round the PMV value to 1 decimal place and set appropriate row in the
% postpredmat_sens matrix (defined in 'RunBehavior.m') to use in 
% determining occupant's current thermal sensation based on PMV
r = round((pmvdraw + 3)/(1/10));
rround = round(r);
row = floor(rround);
if (ceil(row) == floor(row)) == 0;        
    fprintf('ROW IS NOT AN INTEGER!\n')
end
if isnan(row) == 1;
    fprintf('ROW IS NOT A NUMBER!\n')
end

% Draw the occupant's current thermal sensation given current PMV, using
% the multinomial distribution
sensmat = [-3 -2 -1 0 1 2 3];
prodmat = postpredmat_sens((row+1),3:size(postpredmat_sens,2));
prodmatalt = [prodmat(1:6) (1-(sum(prodmat(1:6))))];
prodsens = mnrnd(1,prodmatalt);
sens = sensmat((prodsens==1));

%% Given current thermal sensation, calculate relative performance

% Flag absence of sensation value
if (isempty(sens) == 1 || (sens(1)<-3) || (sens(1)>3))
    fprintf('NO VALID SENSATION SAMPLED FOR PRODUCTIVITY!\n')
    prod = NaN;
% Otherwise, use sensation as input to Jensen's relative performance
% equation to generate relative performance output
else
    prod = ((-0.0069*(sens^2))-(0.0123*(sens))+(0.9945));
end

end