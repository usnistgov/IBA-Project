function DataDL
% database location
DBName=load('DBLoc.mat').DBName;
CollName=load('DBLoc.mat').CollName;
% CollName='test';
% connect to the database
conn = mongo('localhost',27017,DBName);
% find data from MongoDB
RecvSettings=find(conn,CollName,'Query',['{"DocType":"RecvSettings"}']);
SimData=find(conn,CollName,'Query',['{"DocType":"SimData"}']);
Measurements=find(conn,CollName,'Query',['{"DocType":"Measurements"}']);
SupvCtrlSig=find(conn,CollName,'Query',['{"DocType":"SupvCtrlSig"}']);
TES_Measurements=find(conn,CollName,'Query',['{"DocType":"TES_Measurements"}']);
TES_SupvCtrlSig=find(conn,CollName,'Query',['{"DocType":"TES_SupvCtrlSig"}']);
OccupantMatrix=find(conn,CollName,'Query',['{"Timestep":',num2str(0)...
        ',"DocType":"OccupantMatrix"}']);
for i=1:1440
    OccupantMatrix_temp=find(conn,CollName,'Query',['{"Timestep":',num2str(i)...
        ',"DocType":"OccupantMatrix"}']);
    OccupantMatrix=[OccupantMatrix OccupantMatrix_temp];
end
% find EPlus output file from the folder
settings=readtable('settings.csv');
% Season type (1-typical winter;2-typical should;3-extreme summer;4-typical summer)
Season_type = settings.SeasonType(1);
% Test Location (1-Atlanta;2-Buffalo;3-NewYork;4-Tucson;5-ElPaso)
Location = settings.Location(1);
% STD (1-STD2004;2-STD2019)
STD = settings.STD(1);
% Dense occupancy or not
Dense_Occupancy= settings.occ_dense(1);
% Simulink file name
CollName_Location={'Atlanta';'Buffalo';'NewYork';'Tucson';'ElPaso'};
CollName_STD={'2004';'2019'};
CollName_DenOcc={'TypOcc';'DenOcc'};
if Location==4  % Tucson
    if Season_type==1 || Season_type==4
        SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
            char(CollName_Location(Location)),'2019Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
    elseif Season_type==2
        SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
            char(CollName_Location(Location)),'2015Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
    elseif Season_type==3
        SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
            char(CollName_Location(Location)),'2017Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
    end
elseif Location==5  % ElPaso
    if Season_type==4
        SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
            char(CollName_Location(Location)),'2015Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
    else
        SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
            char(CollName_Location(Location)),'2013Year_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
    end
else
    SimulinkName=['FourZones_STD',char(CollName_STD(STD)),'_',...
        char(CollName_Location(Location)),'_',char(CollName_DenOcc(Dense_Occupancy+1)),'.slx'];
end

VBuildFileName = strrep(SimulinkName,'.slx','');
EPlusOutputDir = ['\Output_EPExport_' VBuildFileName '\FMU\'];
EPlusOutputFiles = dir(fullfile([pwd EPlusOutputDir],'*.csv'));
for i=1:length(EPlusOutputFiles)
    NameStrLength(i) = strlength(EPlusOutputFiles(i).name);
end
[~,FileLoc] = min(NameStrLength);
EPlusOutput = ...
    readtable([pwd EPlusOutputDir EPlusOutputFiles(FileLoc).name],...
    'PreserveVariableNames',true);
% find hardware data from the folder
HardwareDataFiles = dir(fullfile([pwd '\HardwareData'],'*.csv'));
for i=1:length(HardwareDataFiles)
    file_table =...
        readtable([pwd '\HardwareData\' HardwareDataFiles(i).name],...
        'PreserveVariableNames',true); 
    FileName = strrep(HardwareDataFiles(i).name,'.csv','');
    HardwareData.(FileName) = file_table;
end
% save settings file
settings = readtable('settings.csv','PreserveVariableNames',true);
% save data to mat file
save([CollName '.mat'],'RecvSettings','SimData','Measurements',...
    'SupvCtrlSig','OccupantMatrix','EPlusOutput','HardwareData',...
    'settings','TES_Measurements','TES_SupvCtrlSig');
end