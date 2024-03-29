function [measTable] = measTablePass(data,labels,timestep,cases)
persistent measTable_ tes 

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
    measTable_ = array2table(zeros(N,length(labels))); 
    measTable_.Properties.VariableNames = labels;
elseif strcmp(cases, 'set')
% set
    for i = 1:length(labels)
        measTable_.(labels{i})(timestep) = data(i);
    end
end
       
measTable = measTable_;
end