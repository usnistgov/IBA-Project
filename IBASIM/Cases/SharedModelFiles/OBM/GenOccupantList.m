function [occupantlist_final_sim] = GenOccupantList(...
    z,officeoccupantcounts,officecounts)
% GenOccupantList - Establishes a list of occupant agents to simulate, 
% given information about the number of various office
% types and the number of occupants/office for a thermal zone 

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

%%
coder.extrinsic('cell2mat');

%% Build list of occupants based on office type information in Excel setup file

% Build list of offices
officenums = repmat({0},1,length(officecounts));
for y = 1:length(officecounts) 
    officenums{y} = [repmat(y,officecounts(y),1) ...
        repmat(officeoccupantcounts(y),officecounts(y),1)];  
end
% officelist = [officenums{~cellfun(@isempty,officenums)}]; 
hasvalue = false(1,length(officenums));
for i = 1:length(officenums)
    if (~isempty(officenums{i})) 
        hasvalue(i) = 1;
    end
end
officelist = [officenums{hasvalue}]; 
officelistfin = [[1:1:size(officelist,1)]' officelist];   

% Build list of occupants based on number of offices and occupants/office
occupantlist1 = repmat({0},size(officelistfin,1),1);
for v = 1:size(officelistfin,1)
    occupantlist1{v} = [...
        repmat(v,officelistfin(v,3),1) ...
        repmat(officelistfin(v,2),officelistfin(v,3),1)];    
end
occupantlist2 = [1:1:sum(officelistfin(:,3))]';
occupantlistfin = cell2mat(occupantlist1);

%% Output final list of occupants for the zone, recording office type for each
occupantlist_final = [occupantlistfin occupantlist2];
occupantlist_final_sim = [repmat(z,size(occupantlist_final,1),1) ...
    occupantlist_final];

end