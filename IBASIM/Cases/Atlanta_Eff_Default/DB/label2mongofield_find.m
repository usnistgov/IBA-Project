function field=label2mongofield_find(label)
for i=1:length(label)
    if i==1
        field=['{"' char(label(i)) '":1.0'];
    else
        field=[field ',"' char(label(i)) '":1.0']; 
    end
end
field=[field,'}'];
end