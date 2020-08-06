function trackPath(image_num,objnum,root,count)


%% Confirm that some objects are merged together throughout the process
%%for image = 1:1:image_num-1
Record_file=[root,'/TrackingProcess/trackPath/Record.mat'];
load(Record_file);
filename= [root,'/TrackingProcess/trackPath/ObjectProcess.mat'];
load(filename);
CenterList = textread([root,'/Plist.txt'],'%s');

if count<image_num
	recordRelationFileName = OneOfRelationFileName(count,root);

	clear sym former later fx fy lx ly
	if count == 1
		[sym former later fx fy lx ly] = textread([recordRelationFileName,'.txt'],'%c %d %d %d %d %d %d');
		for i = 1:1:numel(sym)
		    if ObjectProcess(1,count,former(i)) ~= 0 && ObjectProcess(2,count,former(i)) ~= 0
				ObjectProcess(3,count,former(i)) = former(i);
				ObjectProcess(3,count+1,former(i)) = later(i);
				Record(count+1,former(i))=count+1;
				Record(count,former(i))=count;
		    elseif ObjectProcess(1,count,former(i)) ~= 0 && ObjectProcess(2,count,former(i)) == 0
				ObjectProcess(2,count,former(i)) = former(i);
				ObjectProcess(2,count+1,former(i)) = later(i);
				Record(count+1,former(i))=count+1;
				Record(count,former(i))=count;
		    elseif ObjectProcess(1,count,former(i)) == 0
				ObjectProcess(1,count,former(i)) = former(i);
				ObjectProcess(1,count+1,former(i)) = later(i);
				Record(count+1,former(i))=count+1;
				Record(count,former(i))=count;
		    end
		end
	else
		[sym former later fx fy lx ly] = textread([recordRelationFileName,'.txt'],'%c %d %d %d %d %d %d');
		checkData=zeros(numel(sym),1);

		for i = 1:1:numel(sym)
		    for j = 1:1:objnum
				if ObjectProcess(1,count,j) == former(i)
				    if ObjectProcess(1,count+1,j) == 0
				        ObjectProcess(1,count+1,j) = later(i);
				        checkData(i)=1;
				        Record(count+1,j)=count+1;
				    elseif ObjectProcess(1,count+1,j) ~= 0
				        if ObjectProcess(2,count+1,j) == 0 && ObjectProcess(2,count,j) == 0
				            ObjectProcess(2,count+1,j) = later(i);
				            ObjectProcess(2,count,j) = former(i);
				            checkData(i)=1;
				            Record(count+1,j)=count+1;
				            Record(count,j)=count;
				        elseif ObjectProcess(2,count,j) == former(i) && ObjectProcess(2,count+1,j) == 0
				            ObjectProcess(2,count+1,j) = later(i);
				            checkData(i)=1;
				            Record(count+1,j)=count+1;
				        elseif ObjectProcess(2,count+1,j) ~= 0 && ObjectProcess(2,count,j) ~= 0
				            if ObjectProcess(2,count,j) == former(i)
				                ObjectProcess(3,count+1,j) = later(i);
				                ObjectProcess(3,count,j) = former(i);
				                checkData(i)=1;
				                Record(count+1,j)=count+1;
				                Record(count,j)=count;
				            elseif ObjectProcess(2,count,j) ~= former(i)
				                ObjectProcess(3,count+1,j) = ObjectProcess(2,count+1,j);
				                ObjectProcess(3,count,j) = ObjectProcess(2,count,j);
				                ObjectProcess(2,count+1,j) = later(i);
				                ObjectProcess(2,count,j) = former(i);
				                checkData(i)=1;
				                Record(count,j)=count;
				                Record(count+1,j)=count+1;
				            end
				        end
				    end
				elseif ObjectProcess(1,count,j) ~= former(i)
				    if ObjectProcess(2,count,j) == former(i)
				        if ObjectProcess(2,count+1,j) == 0
				            ObjectProcess(2,count+1,j) = later(i);
				            checkData(i)=1;
				            Record(count+1,j)=count+1;
				        elseif ObjectProcess(2,count+1,j) ~= 0
				            if ObjectProcess(3,count,j) == former(i) && ObjectProcess(3,count+1,j) == 0
				                ObjectProcess(3,count+1,j) = later(i);
				                checkData(i)=1;
				                Record(count+1,j)=count+1;
				            elseif ObjectProcess(3,count+1,j) == 0 && ObjectProcess(3,count,j) == 0
				                ObjectProcess(3,count+1,j) = later(i);
				                ObjectProcess(3,count,j) = former(i);
				                checkData(i)=1;
				                Record(count+1,j)=count+1;
				                Record(count,j)=count;
				            end
				        end
				    elseif ObjectProcess(2,count,j) ~= former(i)
				        if ObjectProcess(3,count,j) == former(i)
				            ObjectProcess(3,count+1,j) = later(i);
				            checkData(i)=1;
				            Record(count+1,j)=count+1;
				        end
				    end
				end
	    	end
		end


		fillup=find(Record(count,:)==0);
		findNull=find(ObjectProcess(1,count,:)==0);
		findMatch=find(checkData(:,1)==0);
		m=size(fillup);
		
		if size(fillup)~=0
			
			for i=1:1:m(2)
				Record(count,fillup(i))=Record(count-1,fillup(i));
				%fprintf(1,'ok \n');
			end
		end
		
		particle_center_name=char(CenterList(count+1));
    	particle_center_coordinate = textread([root, '/particle_center', particle_center_name,'.txt']);
    	[particle_center_row particle_center_col] = size(particle_center_coordinate);


		if size(findNull)~=0
			%disp(findNull);
			LogFileName=[root,'/TrackingProcess/trackPath/Log/Log'];
			LogFile= fopen([LogFileName,'.txt'],'a');
			fprintf(LogFile,'The no.%d particle disappears in the no.%d image.\n', findNull, count);
			for i=1:1:size(findNull)
				last_particle_center_name=char(CenterList(Record(count,findNull(i))));
            	last_particle_center_coordinate = textread([root, '/particle_center', last_particle_center_name,'.txt']);
            	[last_particle_center_row last_particle_center_col] = size(last_particle_center_coordinate);
				for j=1:1:size(findMatch)
					if abs(last_particle_center_coordinate(ObjectProcess(1,Record(count,findNull(i)),findNull(i)),1)-lx(findMatch(j)))<=((count-Record(count,findNull(i)))*3) && abs(last_particle_center_coordinate(ObjectProcess(1,Record(count,findNull(i)),findNull(i)),2)-ly(findMatch(j)))<=((count-Record(count,findNull(i)))*3)
						disp('ok');
						ObjectProcess(1,count,findNull(i))=former(findMatch(j));
						fprintf(LogFile,'The no.%d particle is recovered in the no.%d image.\n', findNull(i), count);
						Record(count,findNull(i))=count;
						if ObjectProcess(1,count+1,findNull(i))==0
							ObjectProcess(1,count+1,findNull(i))=later(findMatch(j));
						end
						%{
						for p=1:1:numel(former)
							if ObjectProcess(1,count,findNull(i))==former(p)
								if ObjectProcess(1,count+1,findNull(i))==0
									ObjectProcess(1,count+1,findNull(i))=later(p);
								end
							end
						end
						%}
					end
				end

				if later(numel(sym))<particle_center_row
					for k=later(numel(sym))+1:1:particle_center_row
						if abs(last_particle_center_coordinate(ObjectProcess(1,Record(count,findNull(i)),findNull(i)),1)-particle_center_coordinate(k,1))<=((count-Record(count,findNull(i)))*3) && abs(last_particle_center_coordinate(ObjectProcess(1,Record(count,findNull(i)),findNull(i)),2)-particle_center_coordinate(k,2))<=((count-Record(count,findNull(i)))*3)
							ObjectProcess(1,count+1,findNull(i))=k;
							Record(count+1,findNull(i))=count+1;
							fprintf(LogFile,'The no.%d particle is recovered in the no.%d image.\n', findNull(i), count+1);
						end
					end
				end

			end
		end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%把座標比對的檔改成center檔%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		
	end
end
if count==image_num-1
	fillup=find(Record(count+1,:)==0);
	m=size(fillup);
		
	if size(fillup)~=0
		for i=1:1:m(2)
			Record(count+1,fillup(i))=Record(count,fillup(i));
			%fprintf(1,'ok \n');
		end
	end
end

save(Record_file,'Record');
save(filename,'ObjectProcess');

for obj = 1:1:objnum
    if length(num2str(obj)) == 1
        ObjectFileName = [root,'/TrackingProcess/trackPath/Object0',num2str(obj)];
    elseif length(num2str(obj)) == 2
        ObjectFileName = [root,'/TrackingProcess/trackPath/Object',num2str(obj)];
    end
    ObjectFile = fopen([ObjectFileName,'.txt'],'a');
    for i = 1:1:3
        if ObjectProcess(i,count,obj) ~= 0
            fprintf(ObjectFile,'%d ', ObjectProcess(i,count,obj));
        end
    end
    fprintf(ObjectFile,'\n');
end

recordObjectProcess(image_num,objnum,root,count);

if count==image_num-1
    for obj = 1:1:objnum
	    if length(num2str(obj)) == 1
	        ObjectFileName = [root,'/TrackingProcess/trackPath/Object0',num2str(obj)];
	    elseif length(num2str(obj)) == 2
	        ObjectFileName = [root,'/TrackingProcess/trackPath/Object',num2str(obj)];
	    end
    	ObjectFile = fopen([ObjectFileName,'.txt'],'a');
        for i = 1:1:3
            if ObjectProcess(i,count+1,obj) ~= 0
                fprintf(ObjectFile,'%d ', ObjectProcess(i,count+1,obj));
            end
        end
        fprintf(ObjectFile,'\n');
	end
	recordObjectProcess(image_num,objnum,root,count+1);
end


fclose('all');

