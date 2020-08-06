function recordObjectProcess(image_num,objnum,root,count)

clear recordObjectProcess recordNum temp
filename= [root,'/TrackingProcess/trackPath/ObjectProcess.mat'];
load(filename,'ObjectProcess');

filename_recordObjectProcess= [root,'/TrackingProcess/recordObjectProcess/recordObjectProcess.mat'];
load(filename_recordObjectProcess,'recordObjectProcess');
FileName_temp=[root,'/TrackingProcess/recordObjectProcess/temp.mat'];
load(FileName_temp,'temp');
%recordObjectProcess = zeros(objnum,image_num);
recordNum = zeros(objnum,image_num);
recordChange = zeros(objnum,image_num);
%temp = ones(objnum);

%% Because the last image which can be merged together , and then the next
%% one are seperated, according to this situation to do the modification

for obj = 1:1:objnum
    for image = 1:1:count
        recordNum(obj,image) = length(find(ObjectProcess(:,image,obj)~=0));
        if recordNum(obj,image) == 2
            if ObjectProcess(1,image,obj) == ObjectProcess(2,image,obj)
                ObjectProcess(2,image,obj) = 0;
                recordNum(obj,image) = length(find(ObjectProcess(:,image,obj)~=0));
            end
        elseif recordNum(obj,image) == 3
            if ObjectProcess(1,image,obj) == ObjectProcess(2,image,obj) && ObjectProcess(2,image,obj) == ObjectProcess(3,image,obj)
                ObjectProcess(2,image,obj) = 0;
                ObjectProcess(3,image,obj) = 0;
                recordNum(obj,image) = length(find(ObjectProcess(:,image,obj)~=0));
            end
        end
    end

end

%% Track the entire process of each object

for obj = 1:1:objnum
    %for image = 1:1:image_num-1
    if count~=1
        %clear distance1 distance2 distance3 s1 s2 s3
        recordRelationFileName = OneOfRelationFileName(count-1,root);
        
        if recordNum(obj,count-1) == recordNum(obj,count)
            if recordNum(obj,count-1) == 3 && (ObjectProcess(1,count-1,obj) == ObjectProcess(2,count-1,obj) || ObjectProcess(2,count-1,obj) == ObjectProcess(3,count-1,obj) || ObjectProcess(1,count-1,obj) == ObjectProcess(3,count-1,obj))
                recordChange(obj,count) = 1;
                recordObjectProcess(obj,count-1) = ObjectProcess(temp(obj),count-1,obj);
                if obj==45
                    fprintf(1,'%d %d %d\n',count-1,temp(obj),ObjectProcess(temp(obj),count-1,obj));
                end
                % find previous image that recordNum(obj, image) only have
                % one
                temp_image = count-1;
                while recordNum(obj,temp_image) ~= 1
                     temp_image = temp_image - 1;
                end
                f_recordRelationFileName = OneOfRelationFileName(temp_image,root);
                [f_sym f_former f_later f_fx f_fy f_lx f_ly] = textread([f_recordRelationFileName,'.txt'],'%c %d %d %d %d %d %d');
                [sym former later fx fy lx ly] = textread([recordRelationFileName,'.txt'],'%c %d %d %d %d %d %d');
                % find minimun distance between temp_image and image+1
                for i = 1:1:numel(f_sym)
                    if f_former(i) == recordObjectProcess(obj,temp_image)
                        t = i;
                    end
                end
                for k = 1:1:numel(sym)
                    if later(k) == ObjectProcess(1,count,obj)
                        s1 = k;
                    end
                    if later(k) == ObjectProcess(2,count,obj)
                        s2 = k;
                    end
                    if later(k) == ObjectProcess(3,count,obj)
                        s3 = k;
                    end
                end
                distance1 = norm([lx(s1) ly(s1)]-[f_fx(t) f_fy(t)]);
                distance2 = norm([lx(s2) ly(s2)]-[f_fx(t) f_fy(t)]);
                distance3 = norm([lx(s3) ly(s3)]-[f_fx(t) f_fy(t)]);
                if distance1 <= distance2 && distance1 <= distance3
                    temp(obj) = 1;
                    recordObjectProcess(obj,count) = later(s1);
                elseif distance2 < distance1 && distance2 <= distance3
                    temp(obj) = 2;
                    recordObjectProcess(obj,count) = later(s2);
                elseif distance3 < distance1 && distance3 <= distance2
                    temp(obj) = 3;
                    recordObjectProcess(obj,count) = later(s3);
                end
                if obj==45
                    fprintf(1,'%d %d %d %d %d %d\n',count-1,distance1,distance2,distance3, recordObjectProcess(obj,count-1), temp(obj));
                end
            else
                temp(obj) = 1;
                if ObjectProcess(temp(obj),count-1,obj) == 0 && ObjectProcess(temp(obj),count,obj) == 0
                    temp(obj) = 2;
                end
                recordObjectProcess(obj,count-1) = ObjectProcess(temp(obj),count-1,obj);
                recordObjectProcess(obj,count) = ObjectProcess(temp(obj),count,obj);
                if obj==45
                    fprintf(1,'%d %d %d\n',count-1,temp(obj),recordObjectProcess(obj,count-1));
                end
            end

        elseif (recordNum(obj,count-1) == 1 || recordNum(obj,count-1) == 3) && recordNum(obj,count) == 2
            recordChange(obj,count) = 1;
            recordObjectProcess(obj,count-1) = ObjectProcess(temp(obj),count-1,obj);
            % find previous image that recordNum(obj, image) only have
            % one
            temp_image = count-1;
            while recordNum(obj,temp_image) ~= 1
                 temp_image = temp_image - 1;
            end
            f_recordRelationFileName = OneOfRelationFileName(temp_image,root);
            [f_sym f_former f_later f_fx f_fy f_lx f_ly] = textread([f_recordRelationFileName,'.txt'],'%c %d %d %d %d %d %d');
            [sym former later fx fy lx ly] = textread([recordRelationFileName,'.txt'],'%c %d %d %d %d %d %d');
            % find minimun distance between temp_image and image+1
            for i = 1:1:numel(f_sym)
                if f_former(i) == recordObjectProcess(obj,temp_image)
                    t = i;
                end
            end
            if recordNum(obj,count-1) == 3 && ObjectProcess(2,count,obj) == 0
                for k = 1:1:numel(sym)
                    if later(k) == ObjectProcess(1,count,obj)
                        s1 = k;
                    end
                    if later(k) == ObjectProcess(3,count,obj)
                        s3 = k;
                    end
                end
                distance1 = norm([lx(s1) ly(s1)]-[f_fx(t) f_fy(t)]);
                distance3 = norm([lx(s3) ly(s3)]-[f_fx(t) f_fy(t)]);
                if distance1 <= distance3
                    temp(obj) = 1;
                    recordObjectProcess(obj,count) = later(s1);
                elseif distance3 < distance1
                    temp(obj) = 3;
                    recordObjectProcess(obj,count) = later(s3);
                end
            else
                for k = 1:1:numel(sym)
                    if later(k) == ObjectProcess(1,count,obj)
                        s1 = k;
                    end
                    if later(k) == ObjectProcess(2,count,obj)
                        s2 = k;
                    end
                end
                distance1 = norm([lx(s1) ly(s1)]-[f_fx(t) f_fy(t)]);
                distance2 = norm([lx(s2) ly(s2)]-[f_fx(t) f_fy(t)]);
                if distance1 <= distance2
                    temp(obj) = 1;
                    recordObjectProcess(obj,count) = later(s1);
                elseif distance2 < distance1
                    temp(obj) = 2;
                    recordObjectProcess(obj,count) = later(s2);
                end
            end
        elseif recordNum(obj,count-1) == 2 && recordNum(obj,count) == 1
            temp(obj) = 1;
            if ObjectProcess(temp(obj),count,obj) == 0
                temp(obj) = 2;
            end
            recordObjectProcess(obj,count) = ObjectProcess(temp(obj),count,obj);
        elseif (recordNum(obj,count-1) == 1 || recordNum(obj,count-1) == 2) && recordNum(obj,count) == 3
            recordChange(obj,count) = 1;
            recordObjectProcess(obj,count-1) = ObjectProcess(temp(obj),count-1,obj);
            % find previous image that recordNum(obj, image) only have
            % one
            temp_image = count-1;
            while recordNum(obj,temp_image) ~= 1
                 temp_image = temp_image - 1;
            end
            f_recordRelationFileName = OneOfRelationFileName(temp_image,root);
            [f_sym f_former f_later f_fx f_fy f_lx f_ly] = textread([f_recordRelationFileName,'.txt'],'%c %d %d %d %d %d %d');
            [sym former later fx fy lx ly] = textread([recordRelationFileName,'.txt'],'%c %d %d %d %d %d %d');
            % find minimun distance between temp_image and image+1
            for i = 1:1:numel(f_sym)
                if f_former(i) == recordObjectProcess(obj,1)
                    t = i;
                end
            end
            for k = 1:1:numel(sym)
                if later(k) == ObjectProcess(1,count,obj)
                    s1 = k;
                end
                if later(k) == ObjectProcess(2,count,obj)
                    s2 = k;
                end
                if later(k) == ObjectProcess(3,count,obj)
                    s3 = k;
                end
            end
            distance1 = norm([lx(s1) ly(s1)]-[f_fx(t) f_fy(t)]);
            distance2 = norm([lx(s2) ly(s2)]-[f_fx(t) f_fy(t)]);
            distance3 = norm([lx(s3) ly(s3)]-[f_fx(t) f_fy(t)]);
            if distance1 <= distance2 && distance1 <= distance3
                temp(obj) = 1;
                recordObjectProcess(obj,count) = later(s1);
            elseif distance2 < distance1 && distance2 <= distance3
                temp(obj) = 2;
                recordObjectProcess(obj,count) = later(s2);
            elseif distance3 < distance1 && distance3 <= distance2
                temp(obj) = 3;
                recordObjectProcess(obj,count) = later(s3);
            end
        elseif recordNum(obj,count-1) == 3 && recordNum(obj,count) == 1
            temp(obj) = 1;
            recordObjectProcess(obj,count) = ObjectProcess(temp(obj),count,obj);
        elseif recordNum(obj,count-1) == 0 && recordNum(obj,count) == 1
            recordObjectProcess(obj,count) = ObjectProcess(1,count,obj);
        end
    end

    %end
end

save(filename_recordObjectProcess,'recordObjectProcess');
save(FileName_temp,'temp');

if count>1
    ObjectFileName = [root,'/TrackingProcess/recordObjectProcess/ObjectProcess',num2str(count-1)];
    ObjectFile = fopen([ObjectFileName,'.txt'],'w');
    for obj = 1:1:objnum
            fprintf(ObjectFile,'%d\n', recordObjectProcess(obj,count-1));
    end
end

if count==image_num
    ObjectFileName_2 = [root,'/TrackingProcess/recordObjectProcess/ObjectProcess',num2str(count)];
    ObjectFile_2 = fopen([ObjectFileName_2,'.txt'],'w');
    for obj = 1:1:objnum
        fprintf(ObjectFile_2,'%d\n', recordObjectProcess(obj,count));
    end
end

fclose('all');
