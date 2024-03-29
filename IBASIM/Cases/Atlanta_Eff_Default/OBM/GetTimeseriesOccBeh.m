clc,clear
load('Atlanta_Eff_TypSum_RB_2004_TypOcc_TypBehav_NoTES_02112022_214114.mat')
%% plot for specific Occupant
for Obj_occ=26
for occ=Obj_occ
    for i=1:1441
        Occ_OccTime(i)=OccupantMatrix(i).OccupantMatrix(occ).InOffice;
    end
    Occ_Time=find(Occ_OccTime);
    OccupancyT=ones(1,length(Occ_Time));
    Occ_OccBeha=[];
    for i=Occ_Time
        Occ_Cof1_OccBeha_temp=OccupantMatrix(i).OccupantMatrix(occ).WhichPMVact;
        Occ_OccBeha=[Occ_OccBeha Occ_Cof1_OccBeha_temp];
    end
end

% Occ_Behavior_Time= find (Occ_Cof1_OccBeha);
Plot_final=cell(7,1);
for behaivor = 1:7
    Occ_Behavior_Num=find(Occ_OccBeha==behaivor);
    size_temp=length(Occ_Behavior_Num);
    plot_occ=zeros(1,size_temp);
    plot_occ(:)=behaivor;
    plot_occ_t=Occ_Time(Occ_Behavior_Num);
    PN_behav=[];
    for behav_record=Occ_Behavior_Num
        PN_behav_temp=OccupantMatrix(Occ_Time(behav_record)).OccupantMatrix(occ).PMVact;
        PN_behav=[PN_behav PN_behav_temp];
    end
    Plot_final{behaivor}=[plot_occ.*PN_behav;plot_occ_t];
    if isempty(Plot_final{behaivor})
        Plot_final{behaivor}=[behaivor -1*behaivor; 1440 1440];
    end
end
str=['g','y','c','k','r','b','m'];
figure
x0 = 0;
y0 = 0;
width = 9;
height = 3;
set(gcf, 'units','inch','position',[x0,y0,width,height]);
bar(Occ_Time, OccupancyT,'EdgeColor',[0 0.4470 0.7410],'LineWidth',1.5); hold on
yticklabels({''})
yyaxis right
for beh=1:7
    if beh==1 || beh==2 || beh==3 || beh==6 % min/maj clothing, water, fan
        scatter(Plot_final{beh,1}(2,find(Plot_final{beh}(1,:)>0)), Plot_final{beh,1}(1,find(Plot_final{beh}(1,:)>0)),40,'filled','v',str(beh));hold on;
        scatter(Plot_final{beh,1}(2,find(Plot_final{beh}(1,:)<0)), -1*Plot_final{beh,1}(1,find(Plot_final{beh}(1,:)<0)),40,'^',str(beh));hold on;
    elseif beh==4  % walk
        scatter(Plot_final{beh,1}(2,:), Plot_final{beh,1}(1,:),40,'filled','o',str(beh));hold on;
    elseif beh==5  % heater
        scatter(Plot_final{beh,1}(2,find(Plot_final{beh}(1,:)>0)), Plot_final{beh,1}(1,find(Plot_final{beh}(1,:)>0)),40,'^',str(beh));hold on;
        scatter(Plot_final{beh,1}(2,find(Plot_final{beh}(1,:)<0)), -1*Plot_final{beh,1}(1,find(Plot_final{beh}(1,:)<0)),40,'filled','v',str(beh));hold on;
    elseif beh==7  % setpoint
        scatter(Plot_final{beh,1}(2,find(Plot_final{beh}(1,:)>0)), Plot_final{beh,1}(1,find(Plot_final{beh}(1,:)>0)),40,'v',str(beh));hold on;
        scatter(Plot_final{beh,1}(2,find(Plot_final{beh}(1,:)<0)), -1*Plot_final{beh,1}(1,find(Plot_final{beh}(1,:)<0)),40,'^',str(beh));
    end
end
ylim([0 8])
yticks([0 1 2 3 4 5 6 7 8])
yticklabels({'','MinClo','MajClo','Drink','Walk','Heater','Fan','Thermostat',''})

xlim([360 1140])
xticks(linspace(360,1140,27))
xticklabels({'6:00','6:30','7:00','7:30','8:00','8:30','9:00','9:30','10:00','10:30',...
    '11:00','11:30','12:00','12:30','13:00','13:30','14:00','14:30','15:00','15:30',...
    '16:00','16:30','17:00','17:30','18:00','18:30','19:00'})
xtickangle(90)
legend({'InOffice','Take off MinClo','Take on MinClo','Take off MajClo','Take on MajClo',...
    'Cold Water','Hot Water','Walking','Heater-off','Heater-on','Fan-on','Fan-off',...
    'Lower Setpoint','Higher Setpoint'},'Location','northeastoutside');

title(['Occ' num2str(roundn(Obj_occ,-2)) '-' 'Behavior'])
end
