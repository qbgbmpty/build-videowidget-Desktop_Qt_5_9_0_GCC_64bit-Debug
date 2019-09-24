function RelationFileName = OneOfRelationFileName(count,root)

if length(num2str(count)) == 1 && length(num2str(count+1)) == 1
    RelationFileName = [root,'/TrackingProcess/recordRelation/1`60t0',num2str(count),'_0',num2str(count+1),'c2'];
elseif length(num2str(count)) == 1  && length(num2str(count+1)) == 2
    RelationFileName = [root,'/TrackingProcess/recordRelation/1`60t0',num2str(count),'_',num2str(count+1),'c2'];
elseif length(num2str(count)) == 2 && length(num2str(count+1)) == 1
    RelationFileName = [root,'/TrackingProcess/recordRelation/1`60t',num2str(count),'_0',num2str(count+1),'c2'];
elseif length(num2str(count)) == 2 && length(num2str(count+1)) == 2
    RelationFileName = [root,'/TrackingProcess/recordRelation/1`60t',num2str(count),'_',num2str(count+1),'c2'];
end
