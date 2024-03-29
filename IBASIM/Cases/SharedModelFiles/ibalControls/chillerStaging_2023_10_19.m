function [ch1On,ch2On] = chillerStaging(ch1Power,ch2Power,T_chwsp,T_chw,ch1PLR,ch2PLR,timestep,timestep_idx)
    persistent stage trans12 trans21 trans01 trans02 N
    persistent chStaging
    
    if timestep == -239
        chStaging = zeros(1441+239,8);
    else
        chStaging = zeros(1441,8);
    end
    n_viol = 10; % In the lab, with 10 s time step, this is 10;
    n_trans = 1; %2; % In the lab, with 10 s time step, this is 10;
    
    zoneTable = zoneTablePass([],[],[],'get');
    zoneTable = zoneTable(timestep_idx+1,:);
    
    ctrlTable = ctrlTablePass([],[],[],'get');
    ctrlTable = ctrlTable(timestep_idx+1,:);
    sys_status = ctrlTable.sys_status;
    
    if timestep <= 0
        buildLoad = 0;
    else
        buildLoad = abs(zoneTable.Qsen_z1_ahu1+zoneTable.Qlat_z1_ahu1+...
                        zoneTable.Qsen_z2_ahu1+zoneTable.Qlat_z2_ahu1+...
                        zoneTable.Qsen_z1_ahu2+zoneTable.Qlat_z1_ahu2+...
                        zoneTable.Qsen_z2_ahu2+zoneTable.Qlat_z2_ahu2)/1000*sys_status; 
    end
    
                
    line = 'chillerStage_17';
    save('chStaging0.mat','line','timestep','buildLoad','N','sys_status',...
         'trans12','trans21','trans01','trans02','stage')
    
    [stage,narray] = chillerLoadViolation(stage,ch1Power,ch2Power,T_chwsp,T_chw,buildLoad,ch1PLR,ch2PLR,timestep);
    %narray = [n01,n02,n10,n12,n21];
    if timestep <= 0
        stage = 0;
        trans12 = 0;
        trans21 = 0; 
        trans02 = 0;         
        trans01 = 0;
        N = 0;    
    end
    
    if sys_status < 1
        stage = 0;
        trans12 = 0;
        trans21 = 0; 
        trans02 = 0;         
        trans01 = 0;
        N = 0;
    elseif buildLoad <= 0
        stage = 0;
        trans12 = 0;
        trans21 = 0;
        trans02 = 0;         
        trans01 = 0;
        N = 0;
    elseif (trans12 + trans21 + trans01 + trans02) > 0
        stage = stage;
        trans12 = trans12;
        trans21 = trans21;       
        trans01 = trans01;  
        trans02 = trans02;
        N = N + 1;
    elseif (stage == 0)
        if ( narray(2) > n_viol )
          stage = 2;
          trans12 = 0;
          trans21 = 0; 
          trans02 = 1;         
          trans01 = 0;
        elseif ( narray(1) >  n_viol)
          stage = 1;
          trans12 = 0;
          trans21 = 0; 
          trans02 = 0;         
          trans01 = 1;
        else
          stage = 0;
          trans12 = 0;
          trans21 = 0;
          trans02 = 0;         
          trans01 = 0;
        end
    elseif ( stage == 1)
        if ( narray(4) > n_viol )
          stage = 2; 
          trans12 = 1; 
          trans21 = 0; 
          trans02 = 0;         
          trans01 = 0;
        elseif ( narray(3) > n_viol )
          stage = 0;
          trans12 = 0;
          trans21 = 0;
          trans02 = 0;         
          trans01 = 0;
        else
          stage = 1;
          trans12 = 0;
          trans21 = 0;
          trans02 = 0;         
          trans01 = 0;
        end
    elseif ( stage == 2)
        if ( narray(5) > n_viol )
          stage = 1;
          trans12 = 0;
          trans21 = 1;
          trans02 = 0;         
          trans01 = 0;
        else 
          stage = 2;
          trans12 = 0;
          trans21 = 0;
          trans02 = 0;         
          trans01 = 0;
        end
    else
        stage = 0;
        trans12 = 0;
        trans21 = 0;
        trans02 = 0;         
        trans01 = 0;
    end

    if ( N >= n_trans)
         trans12 = 0;
         trans21 = 0;
         N = 0;
         trans02 = 0;         
         trans01 = 0;
    end 
    
    if stage == 1
        ch1On = 1; ch2On = 0;
    elseif stage == 2
        ch1On = 0; ch2On = 1;
    else
        ch1On = 0; ch2On = 0;
    end
    
    if (trans12+trans21 >= 1)
        ch1On = 1; ch2On = 1;
    end

    line = 'chillerStage_135';
    save('chStaging0.mat','line','timestep','buildLoad','N','sys_status',...
         'trans12','trans21','trans01','trans02','narray')
    
% %     if timestep < 1200
        chStaging(timestep_idx+1,:) = [ch1On,ch2On,stage,trans12,trans21,trans02,trans01,buildLoad];
% %     elseif timestep == 1200
% %         chStaging = array2table(chStaging,'VariableNames',...
% %                                 {'ch1On','ch2On','stage','trans12','trans21',...
% %                                  'trans02','trans01','buildLoad'});
        save('chStaging.mat','chStaging')
% %    end
end
        
        
        
        
