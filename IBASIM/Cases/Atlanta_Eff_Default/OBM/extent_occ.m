clc,clear
% load('Fixed_OccupantMatrix.mat')
% occM_temp=Fixed_OccupantMatrix;
load('Fixed_OccupantMatrix_1.5_typ.mat')
% Fixed_OccupantMatrix{1}(1:23)=occM_temp{1};
% Fixed_OccupantMatrix{2}(1:2)=occM_temp{2};
% Fixed_OccupantMatrix{3}(1:2)=occM_temp{3};
% Fixed_OccupantMatrix{4}(1:10)=occM_temp{4};
Acc_filename = 'AcceptabilityRangeSummary.xlsx';
simsettings=cell(4,1);
simsettingsrange_1 = 'B3:I14';
[simsettings{1}] = xlsread(Acc_filename, 1,simsettingsrange_1);
simsettingsrange_2 = 'B3:I3';
[simsettings{2}] = xlsread(Acc_filename, 2,simsettingsrange_2);
simsettingsrange_3 = 'B3:I3';
[simsettings{3}] = xlsread(Acc_filename, 3,simsettingsrange_3);
simsettingsrange_4 = 'B3:I7';
[simsettings{4}] = xlsread(Acc_filename, 4,simsettingsrange_4);
for z=1:4
    if z==1
        for occ=24:35
            Fixed_OccupantMatrix{z}(occ).Gender=simsettings{z}(occ-23,1);
            Fixed_OccupantMatrix{z}(occ).AcceptabilityVector=[simsettings{z}(occ-23,2:5),simsettings{z}(occ-23,4:5),simsettings{z}(occ-23,2:3)];
            for s = 1:4
                if median(Fixed_OccupantMatrix{z}(occ).AcceptabilityVector(...
                        ((s*2)-1)):1:...
                        Fixed_OccupantMatrix{z}(occ).AcceptabilityVector(s*2)) <= 0
                    Fixed_OccupantMatrix{z}(occ).PreferenceClass(s) = 0;
                else
                    Fixed_OccupantMatrix{z}(occ).PreferenceClass(s) = 1;
                end
            end
            Fixed_OccupantMatrix{z}(occ).PersonalConstraints(1,(1:3))=simsettings{z}(occ-23,6:8);
            Fixed_OccupantMatrix{z}(occ).PersonalConstraints(2,(1:3))=[0.8 1 0.8];
        end
    end
    if z==2
        for occ=3
            Fixed_OccupantMatrix{z}(occ).Gender=simsettings{z}(occ-2,1);
            Fixed_OccupantMatrix{z}(occ).AcceptabilityVector=[simsettings{z}(occ-2,2:5),simsettings{z}(occ-2,4:5),simsettings{z}(occ-2,2:3)];
            for s = 1:4
                if median(Fixed_OccupantMatrix{z}(occ).AcceptabilityVector(...
                        ((s*2)-1)):1:...
                        Fixed_OccupantMatrix{z}(occ).AcceptabilityVector(s*2)) <= 0
                    Fixed_OccupantMatrix{z}(occ).PreferenceClass(s) = 0;
                else
                    Fixed_OccupantMatrix{z}(occ).PreferenceClass(s) = 1;
                end
            end
            Fixed_OccupantMatrix{z}(occ).PersonalConstraints(1,(1:3))=simsettings{z}(occ-2,6:8);
            Fixed_OccupantMatrix{z}(occ).PersonalConstraints(2,(1:3))=[0.8 1 0.8];
        end
    end
    
    if z==3
        for occ=3
            Fixed_OccupantMatrix{z}(occ).Gender=simsettings{z}(occ-2,1);
            Fixed_OccupantMatrix{z}(occ).AcceptabilityVector=[simsettings{z}(occ-2,2:5),simsettings{z}(occ-2,4:5),simsettings{z}(occ-2,2:3)];
            for s = 1:4
                if median(Fixed_OccupantMatrix{z}(occ).AcceptabilityVector(...
                        ((s*2)-1)):1:...
                        Fixed_OccupantMatrix{z}(occ).AcceptabilityVector(s*2)) <= 0
                    Fixed_OccupantMatrix{z}(occ).PreferenceClass(s) = 0;
                else
                    Fixed_OccupantMatrix{z}(occ).PreferenceClass(s) = 1;
                end
            end
            Fixed_OccupantMatrix{z}(occ).PersonalConstraints(1,(1:3))=simsettings{z}(occ-2,6:8);
            Fixed_OccupantMatrix{z}(occ).PersonalConstraints(2,(1:3))=[0.8 1 0.8];
        end
    end
    
    if z==4
        for occ=11:15
            Fixed_OccupantMatrix{z}(occ).Gender=simsettings{z}(occ-10,1);
            Fixed_OccupantMatrix{z}(occ).AcceptabilityVector=[simsettings{z}(occ-10,2:5),simsettings{z}(occ-10,4:5),simsettings{z}(occ-10,2:3)];
            for s = 1:4
                if median(Fixed_OccupantMatrix{z}(occ).AcceptabilityVector(...
                        ((s*2)-1)):1:...
                        Fixed_OccupantMatrix{z}(occ).AcceptabilityVector(s*2)) <= 0
                    Fixed_OccupantMatrix{z}(occ).PreferenceClass(s) = 0;
                else
                    Fixed_OccupantMatrix{z}(occ).PreferenceClass(s) = 1;
                end
            end
            Fixed_OccupantMatrix{z}(occ).PersonalConstraints(1,(1:3))=simsettings{z}(occ-10,6:8);
            Fixed_OccupantMatrix{z}(occ).PersonalConstraints(2,(1:3))=[0.8 1 0.8];
        end
    end
    
end
save('Fixed_OccupantMatrix_1.5_typ.mat','Fixed_OccupantMatrix')