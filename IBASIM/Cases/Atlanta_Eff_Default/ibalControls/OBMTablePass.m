function [obmTable] = OBMTablePass(data,labels,timestep,cases)
persistent obmTable_ tes 

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
    obmTable_ = array2table(zeros(1441,length(labels))); 
    obmTable_.Properties.VariableNames = labels;
elseif strcmp(cases, 'set')
% set
    for i = 1:length(labels)
        obmTable_.(labels{i})(timestep) = data(i);
    end
end
       
obmTable = obmTable_;
end