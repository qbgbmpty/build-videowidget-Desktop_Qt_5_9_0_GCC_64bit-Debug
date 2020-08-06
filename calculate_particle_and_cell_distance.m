function calculate_particle_and_cell_distance(image_num,image_row,image_col,root,CellFullFileName,CellBorderFileName,ParticleFullFileName,ParticleBorderFileName,ParticleBorderFileNameList,CellFileNameList,count)
%test_par = parpool(4);

filename= [root,'/recordParticleandCellDistance/particle_cell_dis.mat'];
load(filename,'particle_cell_dis');

ParticleList = textread(ParticleBorderFileNameList,'%s');
CellList = textread(CellFileNameList,'%s');

%% Calculate the distance between particles and cells
%for image=1:1:image_num
cell_full_coordinate = textread(CellFullFileName); 
particle_full_coordinate = textread(ParticleFullFileName);

[cell_full_row cell_full_col] = size(cell_full_coordinate);  % cell_num = (cell_full_col-1)/2
[particle_full_row particle_full_col] = size(particle_full_coordinate);  % particle_num = (particle_full_col-1)/2
particle_num = particle_full_col/2;
%[num2str(particle_num)]
%[num2str(cell_full_row),' , ',num2str(cell_full_col)]
%[num2str(particle_full_row),' , ',num2str(particle_full_col)]

%fprintf(1,'%d %d',cell_full_row ,cell_full_col);
cell_mark = zeros(image_row,image_col);
particle_mark = zeros(image_row,image_col,particle_num);
overlap_mark = zeros(particle_num);   %record whether particle and cell overlap or not
%% mark cell coordinate into array(1040*1392)
%{
ObjectProcessFileName = [root,'/TrackingProcess/recordObjectProcess/ObjectProcess'];
particle_process = textread([ObjectProcessFileName,'.txt']);
%}
filename_recordObjectProcess= [root,'/TrackingProcess/recordObjectProcess/recordObjectProcess.mat'];
load(filename_recordObjectProcess,'recordObjectProcess');
[obj_num img_num] = size(recordObjectProcess);   %The number of objects in the first image is the standard


tic
for c_row = 1:1:cell_full_row
    for c_col = 1:2:cell_full_col-1
        if cell_full_coordinate(c_row,c_col) ~= 0
            %fprintf(1,'%d %d \n', cell_full_coordinate(c_row,c_col),cell_full_coordinate(c_row,c_col+1));
            cell_mark(cell_full_coordinate(c_row,c_col),cell_full_coordinate(c_row,c_col+1)) = 1;
        end
    end
end
time1=toc

tic
%% mark particle coordinate into array(1040*1392)
for p_row = 1:1:particle_full_row
    for p_col = 1:2:particle_full_col-1
        if particle_full_coordinate(p_row,p_col) ~= 0
            particle_mark(particle_full_coordinate(p_row,p_col),particle_full_coordinate(p_row,p_col+1),(p_col+1)/2) = 1;
        end
    end
end
time2=toc

tic
%% mark cell which have overlapped with particle(output:1*cell_num)
for o = 1:1:particle_num
    area = 0;
    for r = 1:1:image_row
        for c = 1:1:image_col
           if particle_mark(r,c,o) == 1 && cell_mark(r,c) == 1
               area = area + 1;
           end
        end
    end
    if area >= 1
        overlap_mark(o) = 1;
    end
end
%disp(overlap_mark);
time3=toc

%% find miniman distance between cell and particle
cell_border_coordinate = textread(CellBorderFileName); 
particle_border_coordinate = textread(ParticleBorderFileName);

[cell_border_row cell_border_col] = size(cell_border_coordinate);  % cell_num = (cell_border_col-1)/2
[particle_border_row particle_border_col] = size(particle_border_coordinate);  % particle_num = (particle_border_col-1)/2
%[num2str(cell_border_row),' , ',num2str(cell_border_col)]
%[num2str(particle_border_row),' , ',num2str(particle_border_col)]
min_dis = zeros(particle_num);

%fprintf(1,'%d %d %d %d  ',particle_border_col,particle_border_row,cell_border_col,cell_border_row);
tic
for p_col = 1:particle_border_col/2
    %emp=0;
    if overlap_mark(p_col) == 0
        for p_row = 1:1:particle_border_row
            if  particle_border_coordinate(p_row,(p_col*2-1)) ~= 0
                for c_col = 1:2:cell_border_col-1
                    for c_row = 1:1:cell_border_row
                        if cell_border_coordinate(c_row,c_col) ~= 0
                            cx = cell_border_coordinate(c_row,c_col); % cell's x coordinate
                            cy = cell_border_coordinate(c_row,c_col+1); % cell's y coordinate
                            px = particle_border_coordinate(p_row,(p_col*2-1));  % particle's x coordinate
                            py = particle_border_coordinate(p_row,(p_col*2));  %particle's y coordinate
                            dis = norm([px py]-[cx cy]);
                            if p_row == 1 && (c_row == 1 && c_col == 1)
                                %temp=dis;   
                                min_dis(p_col) = dis;                             
                            else
                                if dis < min_dis(p_col)
                                    %temp=dis;
                                    min_dis(p_col) = dis;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    %['p_col ',num2str(p_col), ' finish']
    %min_dis(p_col) = temp;
end
time4=toc

tic
ParticleandCellFileName = ['recordParticleandCellDistance/ParticleandCellDistance'];
divParticleandCellFile = fopen([root,'/',ParticleandCellFileName,int2str(count),'.txt'],'w');
for p = 1:1:particle_num
    particle_cell_dis(p,count) = min_dis(p);
    fprintf(divParticleandCellFile,'%s \r\n', num2str(min_dis(p)));
    %['v = ',num2str(p),'min_dis(p) = ',num2str(min_dis(p))]
end


min_dis_filename= [root,'/recordParticleandCellDistance/min_dis_record.mat'];
load(min_dis_filename,'min_dis_record');

%%['image_',count,' finish']
%end

%% Record the distances between particles and cells with process

%if count==image_num
    
    particle_cell_process_dis = zeros(obj_num,image_num);

    ParticleandCellProcessDistanceFileName = ['recordParticleandCellDistance/ParticleandCellProcessDistance'];
    ParticleandCellProcessDistanceFile = fopen([root,'/',ParticleandCellProcessDistanceFileName,'.txt'],'w');

for obj = 1:1:obj_num
    if recordObjectProcess(obj,count)~=0
        search_last_nonzero=count;
        if count~=1 && recordObjectProcess(obj,count-1)==0
            search_last_nonzero=search_last_nonzero-2;
            while recordObjectProcess(obj,search_last_nonzero)==0
                search_last_nonzero=search_last_nonzero-1;
            end
        end
        
        if search_last_nonzero~=0 && search_last_nonzero~=count 
            
            
            particle_center_name=char(ParticleList(count));
            particle_center=textread([root,'/particle_center',particle_center_name,'.txt']);
            last_particle_center_name=char(ParticleList(search_last_nonzero));
            last_particle_center=textread([root,'/particle_center',last_particle_center_name,'.txt']);

            
            particle_center_x=particle_center(recordObjectProcess(obj,count),1);
            particle_center_y=particle_center(recordObjectProcess(obj,count),2);
            last_particle_center_x=last_particle_center(recordObjectProcess(obj,search_last_nonzero),1);
            last_particle_center_y=last_particle_center(recordObjectProcess(obj,search_last_nonzero),2);

            zero_num=count-search_last_nonzero;
            difference_x=round((last_particle_center_x-particle_center_x)/zero_num,3);
            difference_y=round((last_particle_center_y-particle_center_y)/zero_num,3);

            
            
            %record_file_name=[root,'/TrackingProcess/trackPath/Record.mat'];
            %load(record_file_name,'Record');
            last_particle_full_name=char(ParticleList(count));
            last_particle_full_coordinate = textread([root, '/particle_full', last_particle_full_name,'.txt']);
            [last_particle_full_row last_particle_full_col] = size(last_particle_full_coordinate);
            last_particle_mark= zeros(image_row,image_col);

            last_particle_border_name=char(ParticleList(count));
            last_particle_border_coordinate = textread([root, '/particle_border', last_particle_border_name,'.txt']);
            [last_particle_border_row last_particle_border_col] = size(last_particle_border_coordinate);

            for i=1:1:zero_num-1
                if min_dis_record(obj,search_last_nonzero+i)==0
                    %fprintf(1,'obj:%d search_last_nonzero:%d',obj,search_last_nonzero+i);
                    recalculate_CellFullFileName=char(CellList(count-i));
                    recalculate_cell_full_coordinate = textread([root,'/cell_full',recalculate_CellFullFileName,'.txt']);
                    [recalculate_cell_full_row recalculate_cell_full_col] = size(recalculate_cell_full_coordinate);
                    recalculate_cell_mark = zeros(image_row,image_col);


                    for c_row = 1:1:recalculate_cell_full_row
                        for c_col = 1:2:recalculate_cell_full_col-1
                            if recalculate_cell_full_coordinate(c_row,c_col) ~= 0
                                %fprintf(1,'%d %d \n', cell_full_coordinate(c_row,c_col),cell_full_coordinate(c_row,c_col+1));
                                recalculate_cell_mark(recalculate_cell_full_coordinate(c_row,c_col),recalculate_cell_full_coordinate(c_row,c_col+1)) = 1;
                            end
                        end
                    end

                    for p_row = 1:1:last_particle_full_row
                        if last_particle_full_coordinate(p_row,recordObjectProcess(obj,count)*2-1) ~= 0
                            last_particle_mark(last_particle_full_coordinate(p_row,recordObjectProcess(obj,count)*2-1)+round(difference_x*i),last_particle_full_coordinate(p_row,recordObjectProcess(obj,count)*2)+round(difference_y*i)) = 1;
                        end
                    end

                    area = 0;
                    last_overlap_mark=0;
                    for r = 1:1:image_row
                        for c = 1:1:image_col
                           if last_particle_mark(r,c) == 1 && recalculate_cell_mark(r,c) == 1
                               area = area + 1;
                           end
                        end
                    end
                    if area >= 1
                        last_overlap_mark = 1;
                    end

                    recalculate_CellBorderFileName=char(CellList(count-i));
                    recalculate_cell_border_coordinate = textread([root,'/cell_border',recalculate_CellBorderFileName,'.txt']);
                    [recalculate_cell_border_row recalculate_cell_border_col] = size(recalculate_cell_border_coordinate);  % cell_num = (cell_border_col-1)/2

                    
                    if last_overlap_mark == 0
                        for p_row = 1:1:last_particle_border_row
                            if  last_particle_border_coordinate(p_row,recordObjectProcess(obj,count)*2-1) ~= 0
                                for c_col = 1:2:recalculate_cell_border_col-1
                                    for c_row = 1:1:recalculate_cell_border_row
                                        if recalculate_cell_border_coordinate(c_row,c_col) ~= 0
                                            cx = recalculate_cell_border_coordinate(c_row,c_col); % cell's x coordinate
                                            cy = recalculate_cell_border_coordinate(c_row,c_col+1); % cell's y coordinate
                                            px = last_particle_border_coordinate(p_row,recordObjectProcess(obj,count)*2-1)+difference_x*i;  % particle's x coordinate
                                            py = last_particle_border_coordinate(p_row,recordObjectProcess(obj,count)*2)+difference_y*i;  %particle's y coordinate
                                            dis = norm([px py]-[cx cy]);
                                            %disp(dis);
                                            if p_row == 1 && (c_row == 1 && c_col == 1)
                                                min_dis_record(obj,search_last_nonzero+i) = dis;
                                                %disp(dis);
                                                %temp=dis;
                                            else
                                                if dis < min_dis_record(obj,search_last_nonzero+i)
                                                    min_dis_record(obj,search_last_nonzero+i) = dis;
                                                    %disp(dis);
                                                    %temp=dis;
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
        end
    end
end

for obj = 1:1:obj_num
    for image = 1:1:count       
        if recordObjectProcess(obj,image)==0 
            %min_dis_test = ['recordParticleandCellDistance/min_dis'];
            %min_dis_testFile = fopen([root,'/',min_dis_test,int2str(count),'.txt'],'w');
            %fprintf(min_dis_testFile,'obj:%d img:%d dis:%f \n',obj,image,min_dis_record(obj,image)); % u is unsighned decimal
            fprintf(ParticleandCellProcessDistanceFile,'%s ', num2str(min_dis_record(obj,image)));
            %fprintf(1,'obj:%d img:%d dis:%f',obj,image,min_dis_record(obj,image));
        else
            particle_cell_process_dis(obj,image) = particle_cell_dis(recordObjectProcess(obj,image),image);
            fprintf(ParticleandCellProcessDistanceFile,'%s ', num2str(particle_cell_process_dis(obj,image))); % u is unsighned decimal
        end
    end
    fprintf(ParticleandCellProcessDistanceFile,'\n');
end


save(filename,'particle_cell_dis');
save(min_dis_filename,'min_dis_record');    
%end

fclose('all')

time5=toc

%{
min_dis_record:紀錄缺失值的補計算
將該張圖片所有obj掃描過一遍，看是否有obj的前一張圖片的ROP為0，若有則從該張圖片往前找該obj上一個非0的ROP在第幾張
確認search_last_nonzero變數不為0或當下的圖片
抓取當下圖片的particle_center檔以及search_last_nonzero的center檔，並從中抓出該obj在當下圖片及上一張圖片的center座標
zero_num:此張圖片與上一個非0圖片中間隔了幾個0
difference_x y:差值
last_particle_full、last_particle_border、、zero_num_cell&border
if min_dis_record(obj,search_last_nonzero+i)==0：確認是否重複計算
%}
