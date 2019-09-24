function record_particle_process(image_num,root,img_path,particle_center_path,last_particle_center_path,particle_full_path,last_particle_full_path,first_particle_full_path,last_particle_area_path,count)

CenterFileName = particle_center_path;
LastCenterFileName = last_particle_center_path;
particle_center_coordinate = textread(CenterFileName);
last_particle_center_coordinate = textread(LastCenterFileName);
last_particle_area=textread(last_particle_area_path);

%for image = 1:1:image_num
    % Read File
    
G_RGB = imread(img_path);
G_FullFileName = particle_full_path;
    
    
    % Record Object Relation

if count ~= 1
	formerFileName = [last_particle_full_path];
	if length(num2str(count-1)) == 1 && length(num2str(count)) == 1
            recordRelationFileName = [root,'/TrackingProcess/recordRelation/1`60t0',num2str(count-1),'_0',num2str(count),'c2'];
        elseif length(num2str(count-1)) == 1  && length(num2str(count)) == 2
            recordRelationFileName = [root,'/TrackingProcess/recordRelation/1`60t0',num2str(count-1),'_',num2str(count),'c2'];
        elseif length(num2str(count-1)) == 2 && length(num2str(count)) == 1
            recordRelationFileName = [root,'/TrackingProcess/recordRelation/1`60t',num2str(count-1),'_0',num2str(count),'c2'];
        elseif length(num2str(count-1)) == 2 && length(num2str(count)) == 2
            recordRelationFileName = [root,'/TrackingProcess/recordRelation/1`60t',num2str(count-1),'_',num2str(count),'c2'];
    end

    if count <= image_num
        recordObjectRelation(G_RGB,G_FullFileName,formerFileName,recordRelationFileName,particle_center_coordinate,last_particle_center_coordinate,last_particle_area,root);
    end

    firstFullFileName = [first_particle_full_path];
    particle_full_coordinate = textread(firstFullFileName);
    [full_row full_col] = size(particle_full_coordinate);
    objnum = (full_col) / 2;
    trackPath(image_num,objnum,root,count-1);
    end
end

%% Confirm the number of objects based on the first image

