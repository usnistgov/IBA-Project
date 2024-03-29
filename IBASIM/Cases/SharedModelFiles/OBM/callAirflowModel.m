function [LocalEnvironmentalCondition] = callAirflowModel(OccupantMatrix,ENumInOcc,bcvtbveczone)
if OccupantMatrix.OfficeType == 3
    LocalEnvironmentalCondition = [0.0001*OccupantMatrix.OccPosition(1)+23,...
        ENumInOcc*0.0001+50, bcvtbveczone(1)*0.0001+0.05, 23];
else
    LocalEnvironmentalCondition = [23 50 0.005 23];
end
end