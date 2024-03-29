function [OccupantMatrix] = NullOccupancy(OccupantMatrix)
% NullOccupancy - Sets occupancy state to a pre-determined value that is not 
% 0 or 1 to indicate a time when an occupant cannot be in the office (e.g.,
% holiday, building closed, etc.)

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

%% Set null occupancy value to 255
for n = 1:size(OccupantMatrix,2) 
    OccupantMatrix(n).OccupancyStateVector(:) = 255;
    OccupantMatrix(n).OccupancyStateVectorPrevious(:) = 255;   
    OccupantMatrix(n).InOffice = 0;
end

end