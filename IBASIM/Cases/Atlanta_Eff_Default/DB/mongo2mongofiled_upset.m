%% push data to DB
function field=mongo2mongofiled_upset(label,data)
% create a sring that indicates which fileds to push to using given label
for i=1:length(label)
    if (i==1)
        field=['{$set:{"' char(label(i)),...
        '":',num2str(data(i))];
    else
        field=[field,',"',char(label(i)),...
        '":',num2str(data(i))];
    end
end
field=[field, '}}'];
end

