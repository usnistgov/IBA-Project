function [ SocialMatrix ] = PMVsocial(SocialMatrix,closetting,b,tempconditions)
% PMVsocial - Calculate Fanger's Predicted Mean Vote (PMV) for all occupants 
% affected by the actions of the individual occupant currently being
% updated in the routine (also see PMV function)

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

%% Set relevant PMV inputs based on SocialMatrix variable states
% Air temperature and mean radiant temperature (dependent on behavior b)
if (b == 5 || b == 7)
    TA = tempconditions(1);
    MRT = tempconditions(2);
else
    TA = SocialMatrix.IndoorEnvironmentVector(1);
    MRT = SocialMatrix.IndoorEnvironmentVector(4);
end
% Relative humidity
RH = SocialMatrix.IndoorEnvironmentVector(2);
% Air velocity
if (b == 9)
    AV = tempconditions(3);
else
    AV = SocialMatrix.IndoorEnvironmentVector(3);
end
% Clothing level
Clo = SocialMatrix.CurrentClothing;
% Metabolic rate
Met = SocialMatrix.MetabolicRate;

%% Determine whether to adjust clothing for moving occupant and for chair
% Occupant is moving (move air movement through the clothing)
if closetting(2) == 1 && ((SocialMatrix.MetabolicRate > 2) && Clo < 0.7) 
    Clo = Clo * (0.6 + 0.4/Met);    
end
% Chair insulation addition
if closetting(1) == 1    
    Clo = Clo + 0.1;    
end

%% Calculate PMV using ISO 7730 PMV-PPD computer code outline
WME = 0;
FNPSTA = exp ( 16.6536 - 4030.183 / (TA + 235) );
PA= RH * 10 * FNPSTA;
ICL = .155 * Clo;
M=Met * 58.15;
W=WME * 58.15;
MW=M - W;
  
if ICL < 0.078
  FCL = 1 + 1.29 * ICL;
else
  FCL = 1.05 + 0.645 * ICL;
end

HCF = 12.1 * sqrt(AV);
TAA = TA + 273;
TRA = MRT + 273;
TCLA = TAA + ((35.5 - TA) / (3.5 * (6.45 * ICL + 0.1)));
P1 = ICL * FCL;
P2 = P1 * 3.96;
P3 =P1 * 100;
P4 =P1 * TAA;
P5 =308.7 - (0.028 * MW) + (P2 * ((TRA / 100) ^ 4));
XN =TCLA / 100;
XF =XN;
Num =0;
EPS =0.00015;
XF =(XF + XN) / 2;
HCN =2.38 * abs(100 * XF - TAA) ^ .25;

if HCF > HCN
    HC = HCF;
else
    HC = HCN;
end

XN =(P5 + P4 * HC - P2 * XF ^ 4) / (100 + P3 * HC);
Num = Num + 1;
  
while (abs(XN - XF) > EPS) && (Num <= 150);
    XF = (XF + XN) / 2;
    HCN= 2.38 * abs(100 * XF - TAA) ^ .25;

    if HCF > HCN
      HC = HCF;
    else 
      HC=HCN;
    end

    XN = (P5 + P4 * HC - P2 * XF ^ 4) / (100 + P3 * HC);
    Num = Num + 1;
end
  
  
if Num > 150 
    SocialMatrix.PMVdraw = 9999999;
else
    TCL = 100 * XN - 273;
    HL1 = 3.05 * 0.001 * (5733 - 6.99 * MW - PA);
    
    if MW > 58.15
        HL2 = 0.42 * (MW - 58.15);
    else
        HL2= 0;
    end
    
    HL3 = 1.7 * 0.00001 * M * (5867 - PA);
    HL4 = 0.0014 * M * (34 - TA);
    HL5 = 3.96 * FCL * ((XN ^ 4) - ((TRA / 100) ^ 4));
    HL6 = FCL * HC * (TCL - TA);
    TS = .303 * exp (-0.036 * M) + 0.028;
    predictedmean = TS * (MW - HL1 - HL2 - HL3 - HL4 - HL5 - HL6);
    SocialMatrix.PMVdraw  = predictedmean;
end
   
%% Flag NAN result
if isnan(SocialMatrix.PMVdraw)==1
    error('PMVSocial draw yielded NAN!')
    %TA
    %RH
    %AV
    %MRT
    %Clo
end

end

