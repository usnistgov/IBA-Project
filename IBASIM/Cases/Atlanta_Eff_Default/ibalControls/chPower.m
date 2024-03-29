function [ch1Mean,ch2Mean,count] = chPower(ch1Power,ch2Power,timestep)
    % Won't capture cycling correctly
    persistent count1 count2 ch1hist ch2hist it1 it2
    % Divide count values by 6 because in the lab counts are every 10 s,
    % but in the building model and simualtion they are every 1 minute!
    N1 = 2; %(60 + 12)/6;
    N2 = 2; %(30 + 12)/6;
    
    if timestep == 0
        count1 = 0;
        ch1hist = zeros(12/6,1);
        it1 = 1;
        count2 = 0;
        ch2hist = zeros(12/6,1);
        it2 = 1;
        ch1Mean = -999;
        ch2Mean = -999;
    end
    line = 'chPower_17';
    save('chPower.mat','ch1hist','ch2hist','timestep','line')
    if ch1Power < 100
        count1 = 0;
        ch1hist = zeros(N1,1);
        it1 = 1;
        ch1Mean = -999;
    else
        count1 = count1 + 1;
        ch1hist(it1,1) = ch1Power;        
        if it1 >= N1
            it1 = 1;
        else
            it1 = it1+1;
        end
        if count1 >= N1
            ch1Mean = mean(ch1hist);
        else
            ch1Mean = -999;
        end
    end
    if ch2Power < 100
        count2 = 0;
        ch2hist = zeros(N2,1);
        it2 = 1;
        ch2Mean = -999;
    else
        count2 = count2 + 1;
        ch2hist(it2,1) = ch2Power;        
        if it2 >= N2
            it2 = 1;
        else
            it2 = it2+1;
        end
        if count2 >= N2
            ch2Mean = mean(ch2hist);
        else
            ch2Mean = -999;
        end        
    end 
    count = count1;
    line = 'chPower_58';
    save('chPower.mat','ch1Mean','ch2Mean','ch1hist','ch2hist','line')
end