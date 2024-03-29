function field=label2mongofield_find_ajp(label)

field = '{"';
for i = 1:length(label)-1
    field = strcat(field,char(label(i)),'":',num2str(1.0),',"');
end
field = strcat(field,char(label(end)),'":',num2str(1.0),'"}');

end


% for i=1:length(label)
%     if i==1
%         field=['{"' char(label(i)) '":1.0'];
%     else
%         field=[field ',"' char(label(i)) '":1.0']; 
%     end
% end
% field=[field,'}'];