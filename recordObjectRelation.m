function recordObjectRelation(rgbX,FileName,formerFileName,recordRelationFileName,center_coordinate,last_center_coordinate,last_particle_area,root)

[im_row im_col dim] = size(rgbX);
full_coordinate = textread(FileName);
former_full_coordinate = textread(formerFileName);
[full_row full_col] = size(full_coordinate);
object_num = full_col/2;   %current image's object number
ObjectImg = zeros(im_row,im_col,object_num);
[f_full_row f_full_col] = size(former_full_coordinate);
f_object_num = f_full_col / 2;   %former one image's object number



%% Incoming coordinates are marked into the ObjectImg
for i = 1:1:full_row
    for j = 1:2:full_col-1
        if full_coordinate(i,j) ~= 0
	         ObjectImg(full_coordinate(i,j),full_coordinate(i,j+1),(j+1)/2) = 1;
        end
    end
end


%% Look at fomer and back of the image , overlapping parts represent the
%% same object
clear area relation_object_file
area = zeros(f_object_num,object_num);
relation_object_file = fopen([recordRelationFileName,'.txt'],'w');
for i = 1:1:object_num
    clear Xcenter Ycenter
    Xcenter = center_coordinate(i,1);
    Ycenter = center_coordinate(i,2);
    for j = 1:1:f_object_num
        clear f_Xcenter f_Ycenter
        f_Xcenter = last_center_coordinate(j,1);
        f_Ycenter = last_center_coordinate(j,2);

        if last_particle_area(j)<280
            for x = 1:1:f_full_row
                for y = j*2-1:j*2-1
                    if former_full_coordinate(x,y) ~= 0
                        %{
                        if former_full_coordinate(x,y)==1 && former_full_coordinate(x,y+1)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==1 && former_full_coordinate(x,y+1)==im_col
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row && former_full_coordinate(x,y+1)==im_col
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row && former_full_coordinate(x,y+1)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                       
                        elseif former_full_coordinate(x,y)==1 && former_full_coordinate(x,y+1)==2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==1 && former_full_coordinate(x,y+1)==im_col-1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1  
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row && former_full_coordinate(x,y+1)==2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row && former_full_coordinate(x,y+1)==im_col-1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1  
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==2 && former_full_coordinate(x,y+1)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row-1 && former_full_coordinate(x,y+1)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1  
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==2 && former_full_coordinate(x,y+1)==im_col
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row-1 && former_full_coordinate(x,y+1)==im_col
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1  
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end

                        elseif former_full_coordinate(x,y)==2 && former_full_coordinate(x,y+1)==2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==2 && former_full_coordinate(x,y+1)==im_col-1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row-1 && former_full_coordinate(x,y+1)==2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row-1 && former_full_coordinate(x,y+1)==im_col-1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end

                        elseif former_full_coordinate(x,y)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y+1)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y+1)==im_col
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end

                        elseif former_full_coordinate(x,y)==2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y+1)==im_col-1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y+1)==im_col-1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end

                        else
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 
                                fprintf(1,'%d ok \n',j);
                                area(j,i) = area(j,i) + 1;
                            end
                        end
                        %}
                        if former_full_coordinate(x,y)<=3 && former_full_coordinate(x,y+1)<=3
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)<=3 && former_full_coordinate(x,y+1)>=im_col-2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 ||  ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)>=im_row-2 && former_full_coordinate(x,y+1)<=3
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 ||  ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)>=im_row-2 && former_full_coordinate(x,y+1)>=im_col-2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 ||  ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)<=3
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1
                                area(j,i) = area(j,i) + 1;
                            end 
                        elseif former_full_coordinate(x,y+1)<=3
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)>=im_row-2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 ||  ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end    
                        elseif former_full_coordinate(x,y+1)>=im_col-2
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        else
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+3,former_full_coordinate(x,y+1)-3,i) == 1 || ObjectImg(former_full_coordinate(x,y)+3,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+3,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+3,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+3,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+3,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)+3,former_full_coordinate(x,y+1)+3,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)-3,i) == 1 || ObjectImg(former_full_coordinate(x,y)+2,former_full_coordinate(x,y+1)+3,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-3,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+3,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-3,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+3,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-3,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+3,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)-3,i) == 1 || ObjectImg(former_full_coordinate(x,y)-2,former_full_coordinate(x,y+1)+3,i) == 1 || ObjectImg(former_full_coordinate(x,y)-3,former_full_coordinate(x,y+1)-3,i) == 1 || ObjectImg(former_full_coordinate(x,y)-3,former_full_coordinate(x,y+1)-2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-3,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-3,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-3,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-3,former_full_coordinate(x,y+1)+2,i) == 1 || ObjectImg(former_full_coordinate(x,y)-3,former_full_coordinate(x,y+1)+3,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        end
                    end
                end
            end
        elseif last_particle_area(j)<550
            for x = 1:1:f_full_row
                for y = j*2-1:j*2-1
                    if former_full_coordinate(x,y) ~= 0
                        if former_full_coordinate(x,y)==1 && former_full_coordinate(x,y+1)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==1 && former_full_coordinate(x,y+1)==im_col
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 ||  ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row && former_full_coordinate(x,y+1)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 ||  ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row && former_full_coordinate(x,y+1)==im_col
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 ||  ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1
                                area(j,i) = area(j,i) + 1;
                            end 
                        elseif former_full_coordinate(x,y+1)==1
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        elseif former_full_coordinate(x,y)==im_row
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 ||  ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end    
                        elseif former_full_coordinate(x,y+1)==im_col
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        else
                            if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)+1,i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1),i) == 1 || ObjectImg(former_full_coordinate(x,y)-1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y)+1,former_full_coordinate(x,y+1)-1,i) == 1 || ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1)-1,i) == 1 
                                area(j,i) = area(j,i) + 1;
                            end
                        end
                    end
                end
            end
        else
            for x = 1:1:f_full_row
                for y = j*2-1:j*2-1
                    if former_full_coordinate(x,y) ~= 0
                        if ObjectImg(former_full_coordinate(x,y),former_full_coordinate(x,y+1),i) == 1
                            area(j,i) = area(j,i) + 1;
                        end
                    end
                end
            end
        end

        if area(j,i) > 1
            fprintf(relation_object_file,'> %d %d %d %d %d %d\r\n',j,i,round(f_Xcenter),round(f_Ycenter),round(Xcenter),round(Ycenter));
        end
    end
end

fclose('all');
