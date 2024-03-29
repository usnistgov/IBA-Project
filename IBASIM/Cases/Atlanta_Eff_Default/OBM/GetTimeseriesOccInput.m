clc,clear
load('Atlanta_Eff_TypSum_RB_2004_TypOcc_TypBehav_NoTES_02112022_214114.mat');
%%
OccNum=26;
for i=1:1441
    Occ_PMVact(i)=OccupantMatrix(i).OccupantMatrix(OccNum).PMVact;
    Occ_PMV(i)=OccupantMatrix(i).OccupantMatrix(OccNum).PMVdraw;
    Occ_T(i)=OccupantMatrix(i).OccupantMatrix(OccNum).IndoorEnvironmentVector(1);
    Occ_RH(i)=OccupantMatrix(i).OccupantMatrix(OccNum).IndoorEnvironmentVector(2);
    Occ_v(i)=OccupantMatrix(i).OccupantMatrix(OccNum).IndoorEnvironmentVector(3);
    Occ_RT(i)=OccupantMatrix(i).OccupantMatrix(OccNum).IndoorEnvironmentVector(4);
    Occ_clo(i)=OccupantMatrix(i).OccupantMatrix(OccNum).CurrentClothing;
    Occ_meta(i)=OccupantMatrix(i).OccupantMatrix(OccNum).MetabolicRate;
end

figure
x0 = 0;
y0 = 0;
width = 9;
height = 8;
set(gcf, 'units','inch','position',[x0,y0,width,height]);

subplot(8,1,1)
stairs(Occ_PMVact);
xlim([6*60,19*60])
yticks([-1 0 1]);
yticklabels({'cold', 'comfortable', 'hot'});
title(['Occ' num2str(roundn(OccNum,-2)) '-thermal comfort'])

subplot(8,1,2)
stairs(Occ_PMV);
xlim([6*60,19*60])
title(['Occ' num2str(roundn(OccNum,-2)) '-PMV'])

subplot(8,1,3)
stairs(Occ_T);
xlim([6*60,19*60])
ylabel('T [C]');
title(['Occ' num2str(roundn(OccNum,-2)) '-ambient air temperature'])

subplot(8,1,4)
stairs(Occ_RT);
xlim([6*60,19*60])
ylabel('MRT [C]');
title(['Occ' num2str(roundn(OccNum,-2)) '-ambient mean radiant air temperature'])

subplot(8,1,5)
stairs(Occ_RH);
xlim([6*60,19*60])
ylabel('RH [%]');
title(['Occ' num2str(roundn(OccNum,-2)) '-ambient relative humidity'])

subplot(8,1,6)
stairs(Occ_v);
xlim([6*60,19*60])
xlabel('Time [min]');
ylabel('v [m/s]');
title(['Occ' num2str(roundn(OccNum,-2)) '-ambient air velocity'])

subplot(8,1,7)
stairs(Occ_clo);
xlim([6*60,19*60])
ylim([0.3,1.3])
xlabel('Time [min]');
ylabel('clothing level');
title(['Occ' num2str(roundn(OccNum,-2)) '-clothing level'])

subplot(8,1,8)
stairs(Occ_meta);
xlim([6*60,19*60])
legend('Eff','Shed')
xlabel('Time [min]');
ylabel('metabolic rate');
title(['Occ' num2str(roundn(OccNum,-2)) '-metabolic rate'])