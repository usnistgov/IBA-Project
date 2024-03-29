function [zoneTable] = zoneTablePass(data,labels,timestep,cases)
persistent zoneTable_ tes 

if isempty(tes)
    if (timestep < 0)
        tes = 1;
        N = 1441+239;
    else
        tes = 0;
        N = 1441;
    end    
end

if tes > 0
    timestep = timestep + 239;
end

if strcmp(cases, 'init')
% initialize
    zoneTable_ = array2table(zeros(N,length(labels))); 
    zoneTable_.Properties.VariableNames = labels;
    zT = [];
elseif strcmp(cases, 'set')
% set
    for i = 1:length(labels)
        zoneTable_.(labels{i})(timestep) = data(i);
    end
    %zT = [zT;zoneTable_];
    %save('zoneTablePass.mat','zT')
end
       
zoneTable = zoneTable_;
end



