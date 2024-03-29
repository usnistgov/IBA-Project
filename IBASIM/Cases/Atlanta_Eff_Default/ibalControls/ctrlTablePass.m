function [ctrlTable] = ctrlTablePass(data,labels,timestep,cases)
persistent ctrlTable_ tes 

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
    ctrlTable_ = array2table(zeros(N,length(labels))); 
    ctrlTable_.Properties.VariableNames = labels;
elseif strcmp(cases, 'set')
% set
    for i = 1:length(labels)
        ctrlTable_.(labels{i})(timestep) = data(i);
    end
end
       
ctrlTable = ctrlTable_;
end