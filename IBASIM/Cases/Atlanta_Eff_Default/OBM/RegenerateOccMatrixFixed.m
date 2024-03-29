clc, clear all
load('Fixed_OccupantMatrix.mat')
a=cell(4,1);
a{1,1}=[2 3 11 14 15];
a{2,1}=[2];
a{3,1}=[];
a{4,1}=[3];
for z=1:4
    for occ=1:size(Fixed_OccupantMatrix{z},2)
        Fixed_OccupantMatrix{z}(occ).PersonalConstraints(1,3)=1;
        Fixed_OccupantMatrix{z}(occ).PersonalConstraints(2,3)=0.9;
    end
end
for z=1:4
    for i=a{z,1}
        Fixed_OccupantMatrix{z}(i).PersonalConstraints(1,3)=0;
    end
end
save('Fixed_OccupantMatrix_1_NGRSave.mat','Fixed_OccupantMatrix')