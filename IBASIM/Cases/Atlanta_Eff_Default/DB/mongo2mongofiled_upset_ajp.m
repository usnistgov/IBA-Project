%% push data to DB
function field=mongo2mongofiled_upset_ajp(label,data)
% create a sring that indicates which fileds to push to using given label
% load('buildMquery.mat')
% label = MeasLabel;
% data = Meas;
    field = '{"$set":{"';
    for i = 1:length(label)-1
        field = strcat(field,char(label(i)),'":',num2str(data(i)),',"');
    end
    field = strcat(field,char(label(end)),'":',num2str(data(end)),'}}');
end


% for i=1:length(label)
%     if (i==1)
%         field="{$set:{"" char(label(i))"":""num2str(data(i))""}";
%     else
%         field=[field,',"',char(label(i)),...
%         '":',num2str(data(i))];
%     end
% end
% field=[field, '}}'];