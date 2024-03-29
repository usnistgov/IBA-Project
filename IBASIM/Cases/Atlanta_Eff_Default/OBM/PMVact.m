function [PMVact] = PMVact(Season,OccMatrix,postpredmat_sens)
% PMVact - Determines whether an occupant is too cool, too warm, or
% comfortable given the currently determined PMV value, the most probable 
% thermal sensation the individual occupant experiences at that PMV, and 
% the occupant's range of acceptable thermal sensations for the current 
% season in the simulation

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
coder.extrinsic('mnrnd');
%% Establish the current PMV draw and min/max acceptable sensations
pmvdraw = OccMatrix.PMVdraw;
% Ensure PMV is between -3 and 3
if pmvdraw < -3.0    
    pmvdraw = -3;    
elseif pmvdraw > 3.0    
    pmvdraw = 3;
else      
end
minpref = OccMatrix.AcceptabilityVector((Season*2)-1);
maxpref = OccMatrix.AcceptabilityVector((Season*2));

%% Given the above information, establish discomfort probabilities

% Round the PMV value to 1 decimal place and set appropriate row in the
% postpredmat_sens matrix (defined in 'RunBehavior.m')
r = round((pmvdraw + 3)/(1/10));
rround = round(r);
row = floor(rround);
if (ceil(row) == floor(row)) == 0;        
    fprintf('ROW IS NOT AN INTEGER!\n')
end
if isnan(row) == 1;
    fprintf('ROW IS NOT A NUMBER!\n')
end
% Set the probability of being cooler than coolest acceptable sensation
if minpref == -3    
    lowprob = 0;        
else        
    colmax = minpref + 5;
    if (ceil(colmax) == floor(colmax)) == 0;        
    end
    lowprobm = postpredmat_sens((row+1),3:colmax);
    lowprob = sum(lowprobm);                
end
% Set the probability of being warmer than warmest acceptable sensation
if maxpref == 3    
    highprob = 0;        
else        
    colmin = maxpref + 7;
    if (ceil(colmin) == floor(colmin)) == 0;        
    fprintf('ROW IS NOT AN INTEGER!\n');
    end
    highprobm = postpredmat_sens((row+1),colmin:9);
    highprob = sum(highprobm);               
end
% Set probability of comfort
comfprob = (1 - (lowprob + highprob));
% Put probabilities of being too cold, comfortable, and too warm in vector
probs = [lowprob comfprob highprob];

%% Given comfort/discomfort probabilities, determine current comfort state
% Sample from multinomial draw to determine state (eventually informs
% associated behavior)
pmvactmat= zeros(3,1);
pmvactmat = mnrnd(1,probs);
% Too cool
if pmvactmat(1) == 1        
    PMVact = -1;        
% Comfortable
elseif pmvactmat (2) == 1       
    PMVact = 0;        
% Too warm
else        
    PMVact = 1;        
end
    
end    