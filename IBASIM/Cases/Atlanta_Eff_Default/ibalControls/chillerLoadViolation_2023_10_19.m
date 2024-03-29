function [stage,n] = chillerLoadViolation(stage,ch1Power,ch2Power,T_chwsp,~,buildLoad,ch1PLR,ch2PLR,timestep)
    persistent n01 n02 n12 n10 n21 
    persistent chillerLoadViol
    
    if timestep == 0
        chillerLoadViol = zeros(1440,12);
        stage = 0;
    end
      
    q2_min = 25;
    q1_min = 2;   
    q1_sd = 1;
    
    [ch1Mean,ch2Mean,count1] = chPower(ch1Power,ch2Power,timestep); % Chiller Power is in W
    ch1Mean = ch1Power;
    ch2Mean = ch2Power;
    
    if timestep <= 0
        n02 = 0;
        n01 = 0;
        n12 = 0;
        n10 = 0;
        n21 = 0; 
    end
    
    if stage == 0
        if buildLoad > q2_min
            n02 = n02 + 1;
            n01 = 0;
            n12 = 0;
            n10 = 0;
            n21 = 0;
        elseif buildLoad > q1_min
            n01 = n01 + 1;
            n02 = 0;
            n12 = 0;
            n10 = 0;
            n21 = 0;
        else
            n01 = 0;
            n02 = 0;
            n12 = n12;
            n10 = n10;
            n21 = n21;
        end
    elseif stage == 1
%         if ch1PLR >= 0.85 % change to Chiller2
%             n12 = n12 + 1;
%             n01 = 0;
%             n02 = 0;
%             n10 = 0;
%             n21 = 0; 
        if (ch1Mean >= 7000)||(ch1PLR >= 0.95)
       % if ch1PLR >= 0.95
            n12 = n12 + 1;
            n01 = 0;
            n02 = 0;
            n10 = 0;
            n21 = 0;
%         elseif ((ch1Mean >= 5500)&&(T_chw >= T_chwsp+1*5/9))
%             n12 = n12 + 1;
%             n01 = 0;
%             n02 = 0;
%             n10 = 0;
%             n21 = 0;
        elseif ((ch1Mean >= 8500)&&(count1 >= 10))
            n12 = n12 + 1;
            n01 = 0;
            n02 = 0;
            n10 = 0;
            n21 = 0;
% %         if ((ch1Mean >= 8500)&&(T_chw >= T_chwsp+0.3*5/9))
% %             n12 = n12 + 1;
% %             n01 = 0;
% %             n02 = 0;
% %             n10 = 0;
% %             n21 = 0;
% %         elseif ((ch1Mean >= 8000)&&(T_chw >= T_chwsp+1*5/9))
% %             n12 = n12 + 1;
% %             n01 = 0;
% %             n02 = 0;
% %             n10 = 0;
% %             n21 = 0;
% %         elseif ((ch1Mean >= 7500)&&(count1 >= 10))
% %             n12 = n12 + 1;
% %             n01 = 0;
% %             n02 = 0;
% %             n10 = 0;
% %             n21 = 0;
        elseif (buildLoad < q1_sd)
            n10 = n10 + 1;
            n01 = 0;
            n02 = 0;
            n12 = 0;
            n21 = 0;
        else
            n01 = n01;
            n02 = n02;
            n12 = 0;
            n10 = 0;
            n21 = n21;
        end
    else
        if ch2PLR <= 0.2
%%        if ((ch2Mean < 3000)&&(ch2Mean > 0))
            n21 = n21 + 1;
            n01 = 0;
            n02 = 0;
            n12 = 0;
            n10 = 0;
        else
            n21 = 0;
            n01 = n01;
            n02 =  n02;
            n12 =n12;
            n10 = n10;
        end
    end
    n = [n01,n02,n10,n12,n21];
    
% %     if timestep < 1200
        chillerLoadViol(timestep+1,:) = [ch1Power,ch2Power,ch1Mean,ch2Mean,count1,...
                                     stage,buildLoad,n01,n02,n12,n10,n21];
% %     elseif timestep == 1200
% %         chillerLoadViol = array2table(chillerLoadViol,'VariableNames',...
% %                                    {'ch1Power','ch2Power','ch1Mean','ch2Mean','count1',...
% %                                     'stage','buildLoad','n01','n02','n12','n10','n21'});
        save('chillerLoadViol.mat','chillerLoadViol')
% %     end
    
    save('chLoadviol.mat','timestep','n','buildLoad','ch1Mean')
end