function init(root,image_num,first_particle_full_path)

firstFullFileName = [first_particle_full_path];
particle_full_coordinate = textread(firstFullFileName);
[full_row full_col] = size(particle_full_coordinate);
objnum = full_col / 2;

dos(['mkdir ',root,'/TrackingProcess']);
dos(['mkdir ',root,'/TrackingProcess/recordRelation']);
dos(['mkdir ',root,'/TrackingProcess/trackPath']);
dos(['mkdir ',root,'/TrackingProcess/recordObjectProcess']);
dos(['mkdir ',root,'/recordParticleandCellDistance']);
dos(['mkdir ',root,'/TrackingProcess/trackPath/Log']);


ObjectProcess = zeros(3,image_num,objnum);   %this example has three objects that are merged together
Record=zeros(image_num,objnum); 
recordObjectProcess = zeros(objnum,image_num);
temp = ones(objnum);
particle_cell_dis = zeros(objnum,image_num);
min_dis_record= zeros(objnum,image_num);

FileName_ObjectProcess = [root,'/TrackingProcess/trackPath/ObjectProcess.mat'];
save(FileName_ObjectProcess,'ObjectProcess');

FileName_Record = [root,'/TrackingProcess/trackPath/Record.mat'];
save(FileName_Record,'Record');

FileName_recordObjectProcess=[root,'/TrackingProcess/recordObjectProcess/recordObjectProcess.mat'];
save(FileName_recordObjectProcess,'recordObjectProcess');

FileName_temp=[root,'/TrackingProcess/recordObjectProcess/temp.mat'];
save(FileName_temp,'temp');

FileName_particle_cell_dis = [root,'/recordParticleandCellDistance/particle_cell_dis.mat'];
save(FileName_particle_cell_dis,'particle_cell_dis');

FileName_min_dis = [root,'/recordParticleandCellDistance/min_dis_record.mat'];
save(FileName_min_dis,'min_dis_record');

