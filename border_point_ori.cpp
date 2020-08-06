#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <math.h>
#include <malloc.h>
#include <omp.h>
#include <time.h>

#define __line printf("%s : %s (%d)\n",__FILE__,__FUNCTION__,__line__);
#define IMAGE_NUM 1
#define IMAGE_ROW 1041 //1040+1
#define IMAGE_COL 1393 //1392+1
#define OMP_THREAD_NUM 1

typedef struct _item{
	int file_chosen;
    int *obj_num;  //the number of objects in each image
    int *point_num;   //the number of points in each object
    int *obj_index;   //accumulate the index of objects in each image
    int *point_index;   //accumulate the index of points in each object
    int *x_coord;   //all the point of x coordinate from first image to final image
    int *y_coord;   //all the point of y coordinate from first image to final image
}item;

typedef struct _result{
	int *overlap_mark;
	double *min_dis;
}result;


typedef struct _node{
  struct _node* next;
  int value;
  int last_center_obj;
  int start_center_obj;
  int zero_num;
  int end=0;
  float diffX;
  float diffY;
}Node;

typedef struct _list{
  Node* head;
}List;




void initITEM(item* c);
void freeITEM(item* c);
void initRESULT(result* vc);
void freeRESULT(result* vc);
int num2str(int num);
void getFileName(int image, char *CellFullFileName, char *CellBorderFileName, char *VirusFullFileName, char *VirusBorderFileName, char *CellFullDir, char *CellBorderDir, char *VirusFullDir, char *VirusBorderDir);
int countDIR(const char *path);
void readOBJ(char *objectPath, item* c, int image);
void infoITEM(item* c, char *CellFullDir, char *CellBorderDir, char *VirusFullDir, char *VirusBorderDir);
void findOVERLAP(item* v, item* c, result* overlap);
void getSHORTESTDIS(item* v, item* c, result* mindis);
void sup_readOBJ(char *objectPath, item* c, int image, int mode, Node* currentNode);
void sup_infoITEM(item* c, char *CellFullDir, char *CellBorderDir, char *VirusFullDir, char *VirusBorderDir, Node* currentNode);
void sup_findOVERLAP(item* v, item* c, result* overlap, int image, Node* currentNode);
void sup_getSHORTESTDIS(item* v, item* c, result* mindis, int image, Node* currentNode);
Node* create_node(int value);
void remove_list_node(List* list, Node* target);
void dump(List* list);
void supCALCULATION(char *root, char *CellFileListName, char *VirusFileListName, int count);



int main(int argc, char* argv[])
{
	// Timer t[3];
	// t[0].start();
	clock_t w = clock();
	item* cell = (item*)malloc(sizeof(item));
	item* virus = (item*)malloc(sizeof(item));
	item* cell_border = (item*)malloc(sizeof(item));
	item* virus_border = (item*)malloc(sizeof(item));
	result* vc = (result*)malloc(sizeof(result));
	// t[0].start();
	cell->file_chosen = 0;
	infoITEM(cell,argv[1],argv[2],argv[3],argv[4]);
	virus->file_chosen = 2;
	infoITEM(virus,argv[1],argv[2],argv[3],argv[4]);
	//__line
	findOVERLAP(virus, cell, vc);
	//__line
	// t[0].stop(1,"readfile");
	cell_border->file_chosen = 1;
	//__line
	infoITEM(cell_border,argv[1],argv[2],argv[3],argv[4]);
	//__line
	virus_border->file_chosen = 3;
	//__line
	infoITEM(virus_border,argv[1],argv[2],argv[3],argv[4]);
	// t[0].stop(1,"readfile");
	//__line
	// t[1].start();
	printf("read time %.3lf secs\n",(double)(clock() - w)/CLOCKS_PER_SEC);
	double start = omp_get_wtime( );
	getSHORTESTDIS(virus_border, cell_border, vc);
	//__line
	// t[1].stop(1,"compute time");
	FILE *wfile;
	// char divCellandVirusFileName[50], buf[20];
	for(int image = 0; image < IMAGE_NUM; image++){
		char divCellandVirusFileName[200], buf[20];
		sprintf(divCellandVirusFileName,argv[5], image+1);
		wfile = fopen(divCellandVirusFileName, "w");
		for(int vi = 0; vi < virus_border->obj_num[image]; vi++){
			sprintf(buf,"%f",vc->min_dis[vi+virus_border->obj_index[image]]);
			fwrite (buf, strlen(buf), 1, wfile);
		    fwrite ("\n",1,1,wfile);
		}
		fclose(wfile);
	}
	double end = omp_get_wtime( );
	printf("start = %.16g\nend = %.16g\ndiff = %.16g\n", start, end, end - start);
	// t[0].stop(1,"total");
	freeITEM(cell);
	freeITEM(virus);
	freeITEM(cell_border);
	freeITEM(virus_border);
	freeRESULT(vc);
	supCALCULATION(argv[6], argv[7], argv[8], atoi(argv[9]));
	// system("pause");
	return 0;
}


void initITEM(item* c){
	c->obj_num = (int*)calloc(IMAGE_NUM,sizeof(int));
	c->point_num = (int*)calloc(IMAGE_NUM*70,sizeof(int));
	c->obj_index = (int*)calloc(IMAGE_NUM,sizeof(int));
	c->point_index = (int*)calloc(IMAGE_NUM*70,sizeof(int));
	c->x_coord = (int*)calloc(IMAGE_ROW*IMAGE_COL*IMAGE_NUM,sizeof(int));
	c->y_coord = (int*)calloc(IMAGE_ROW*IMAGE_COL*IMAGE_NUM,sizeof(int));
}

void freeITEM(item* c){
	free(c->obj_num);
	free(c->point_num);
	free(c->obj_index);
	free(c->point_index);
	free(c->x_coord);
	free(c->y_coord);
}

void initRESULT(result* vc){
	vc->overlap_mark = (int*)calloc(IMAGE_NUM*70,sizeof(int));
	vc->min_dis = (double*)calloc(IMAGE_NUM*70,sizeof(double));
}

void freeRESULT(result* vc){
	free(vc->overlap_mark);
	free(vc->min_dis);
}

int num2str(int num){
	// char *str = (char*)malloc(sizeof(char)*2);
	// int length = sprintf(str,"%d",num);
	// return length;
	if (num/10 <= 0)
		return 1;
	else if (num/10 > 0)
		return 2;
}

void getFileName(int image, char *CellFullFileName, char *CellBorderFileName, char
 *VirusFullFileName, char *VirusBorderFileName, char *CellFullDir, char *CellBorderDir, char *VirusFullDir, char *VirusBorderDir){
	sprintf(CellFullFileName,CellFullDir);
	sprintf(CellBorderFileName,CellBorderDir);
	sprintf(VirusFullFileName,VirusFullDir);
	sprintf(VirusBorderFileName,VirusBorderDir);
}

int countDIR(const char *path){
    struct dirent *entry;
    int dir_num = 0;
    DIR *dir;
    dir = opendir (path);

    while ((entry = readdir (dir)) != NULL) {
		dir_num++;
    }
    dir_num = dir_num - 2;
    return dir_num;
}

void readOBJ(char *objectPath, item* c, int image){
	FILE *rfile;
	int i = 0;
	char objectName[20], objectFileName[180], line[20];
	for(i = c->obj_index[image]; i < c->obj_index[image]+c->obj_num[image]; i++){
		int pointCount = 0;
		
		if(i+c->obj_index[image] > 0){
			c->point_index[i] = c->point_index[i-1] + c->point_num[i-1];
		}
		else{
			c->point_index[i] = 0;
		}
		
		strcpy(objectFileName, objectPath);
		sprintf(objectName, "Object%d.txt", i+1-c->obj_index[image]);
		strcat(objectFileName, objectName);
		rfile = fopen(objectFileName,"r");
		while (fgets(line, 20, rfile) != NULL){
			sscanf(line, "%d %d", &c->x_coord[pointCount+c->point_index[i]], &c->y_coord[pointCount+c->point_index[i]]);
			pointCount++;
		}
		c->point_num[i] = pointCount;
		
		fclose(rfile);
	}
	
}

void infoITEM(item* c, char *CellFullDir, char *CellBorderDir, char *VirusFullDir, char *VirusBorderDir){
	int image = 0;
	char ItemFileName[180], CellFullFileName[180], CellBorderFileName[180], VirusFullFileName[180], VirusBorderFileName[180];
	
	initITEM(c);
	
	for(image = 0; image < IMAGE_NUM; image++){
		getFileName(image, CellFullFileName, CellBorderFileName, VirusFullFileName, VirusBorderFileName, CellFullDir, CellBorderDir, VirusFullDir, VirusBorderDir);
		
		switch(c->file_chosen){
			case 0:
				strcpy(ItemFileName, CellFullFileName);
				break;
			case 1:
				strcpy(ItemFileName, CellBorderFileName);
				break;
			case 2:
				strcpy(ItemFileName, VirusFullFileName);
				break;
			case 3:
				strcpy(ItemFileName, VirusBorderFileName);
				break;
		}
		c->obj_num[image] = countDIR(ItemFileName);
		
		if(image > 0){
			c->obj_index[image] = c->obj_index[image-1] + c->obj_num[image-1];
		}
		else{
			c->obj_index[image] = 0;
		}
		
		readOBJ(ItemFileName, c, image);
	}
}

void findOVERLAP(item* v, item* c, result* overlap){
	int image = 0, i = 0, j = 0;
	
	initRESULT(overlap);
	for(image = 0; image < IMAGE_NUM; image++){
		int** cellMark = (int**)malloc(sizeof(int*)*IMAGE_COL);
		for(i = 0; i < IMAGE_COL; i++){
			cellMark[i] = (int*)malloc(sizeof(int)*IMAGE_ROW);
			memset(cellMark[i], 0, sizeof(int)*IMAGE_ROW);
		}
		
		for(i = c->obj_index[image]; i < c->obj_index[image]+c->obj_num[image]; i++){
			for(j = c->point_index[i]; j < c->point_index[i]+c->point_num[i]; j++){
				cellMark[c->y_coord[j]][c->x_coord[j]] = 1;
			}
		}
		
		for(i = v->obj_index[image]; i < v->obj_index[image]+v->obj_num[image]; i++){
			for(j = v->point_index[i]; j < v->point_index[i]+v->point_num[i]; j++){
				if(cellMark[v->y_coord[j]][v->x_coord[j]] == 1){
					overlap->overlap_mark[i] = 1; ///// ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!ERROR!
					break;
				}
			}

		}
		
		// for (i = 0; i < IMAGE_COL; i++){
			// free(cellMark[i]);
		// }
		free(cellMark);
	}
}


void getSHORTESTDIS(item* v, item* c, result* mindis){
	// FILE *wfile;
	int image = 0, vi = 0, vj = 0, ci = 0, cj = 0, vx = 0, vy = 0, cx = 0, cy = 0;
	double dis = 0;
	int init_ci = 0, fin_ci = 0, len_ci = 0;
	int threadid = OMP_THREAD_NUM;
	int bug = 0;
	int test = 0;
	int testimg = IMAGE_NUM;
	// char divCellandVirusFileName[50], buf[20];
	printf("image num:%d\nthread num:%d\n", testimg, threadid);
	#pragma omp parallel num_threads(threadid) private(image, test, vi, vj, cj, init_ci, fin_ci, vx, vy, cx, cy, dis)
	{ 
		image = omp_get_thread_num();
		// printf("%d\n", image);
		// threadid = omp_get_num_threads();
		// #pragma omp for 
		for(test = 0; test < testimg; test+=threadid){
			
			// printf("image:%d test:%d\n", image, test);
			// image = omp_get_thread_num();
			if(image+test < testimg){
			// else
				init_ci = c->obj_index[image+test];
				fin_ci = c->obj_num[image+test] + init_ci - 1;
				// //__line
				for(vi = v->obj_index[image+test]; vi < v->obj_index[image+test]+v->obj_num[image+test]; vi++){
					// //__line
					if(mindis->overlap_mark[vi] == 0){
						mindis->min_dis[vi] = 1000;
						for(vj = v->point_index[vi]; vj < v->point_index[vi]+v->point_num[vi]; vj++){
							// //__line
							vx = v->x_coord[vj];
							vy = v->y_coord[vj];
							//for(ci = c->obj_index[image]; ci < c->obj_index[image]+c->obj_num[image]; ci++){
							// init_ci = c->obj_index[image];
							// fin_ci = c->obj_num[image] + init_ci - 1;
							// len_ci
								for(cj = c->point_index[init_ci]; cj < c->point_index[fin_ci]+c->point_num[fin_ci]; cj++){
									// vx = v->x_coord[vj];
									// vy = v->y_coord[vj];
									// //__line
									cx = c->x_coord[cj];
									cy = c->y_coord[cj];
									dis = sqrt((vx-cx)*(vx-cx)+(vy-cy)*(vy-cy));
									// if(vj == v->point_index[vi] && cj == c->point_index[ci])
										// mindis->min_dis[vi] = dis;
									if(dis < mindis->min_dis[vi])
										mindis->min_dis[vi] = dis; 
								}
							//}
						}
						//printf("%d, %d, %f\n", image, vi, mindis->min_dis[vi]);
					}
				}
			}
		// #pragma omp barrier
		}
	}
	// exit(0);
}


void sup_readOBJ(char *objectPath, item* c, int image, int mode, Node* currentNode){
	FILE *rfile;
	int i = 0;
	char objectName[20], objectFileName[180], line[20];

	
	if (mode==2 || mode==3){
		for(i = c->obj_index[image]; i < c->obj_index[image]+c->obj_num[image]; i++){
			int pointCount = 0;
			
			if(i+c->obj_index[image] > 0){
				c->point_index[i] = c->point_index[i-1] + c->point_num[i-1];
			}
			else{
				c->point_index[i] = 0;
			}
			
			strcpy(objectFileName, objectPath);
			sprintf(objectName, "Object%d.txt", i+1-c->obj_index[image]);
			strcat(objectFileName, objectName);
			
			rfile = fopen(objectFileName,"r");
			while (fgets(line, 20, rfile) != NULL){
				sscanf(line, "%d %d", &c->x_coord[pointCount+c->point_index[i]], &c->y_coord[pointCount+c->point_index[i]]);
				if ( c->y_coord[pointCount+c->point_index[i]]+currentNode->diffY*(image+1)<IMAGE_COL-1 && c->y_coord[pointCount+c->point_index[i]]+currentNode->diffY*(image+1)>0)
					c->y_coord[pointCount+c->point_index[i]]=c->y_coord[pointCount+c->point_index[i]]+currentNode->diffY*(image+1);
				if ( c->x_coord[pointCount+c->point_index[i]]+currentNode->diffX*(image+1)<IMAGE_ROW-1 && c->x_coord[pointCount+c->point_index[i]]+currentNode->diffX*(image+1)>0)
					c->x_coord[pointCount+c->point_index[i]]=c->x_coord[pointCount+c->point_index[i]]+currentNode->diffX*(image+1);
				
				pointCount++;
			}
			c->point_num[i] = pointCount;
			
			fclose(rfile);
		}
	}
	else{
		
		for(i = c->obj_index[image]; i < c->obj_index[image]+c->obj_num[image]; i++){
			int pointCount = 0;
			
			if(i+c->obj_index[image] > 0){
				c->point_index[i] = c->point_index[i-1] + c->point_num[i-1];
			}
			else{
				c->point_index[i] = 0;
			}
			
			strcpy(objectFileName, objectPath);
			sprintf(objectName, "Object%d.txt", i+1-c->obj_index[image]);
			strcat(objectFileName, objectName);
			
			rfile = fopen(objectFileName,"r");
			while (fgets(line, 20, rfile) != NULL){
				sscanf(line, "%d %d", &c->x_coord[pointCount+c->point_index[i]], &c->y_coord[pointCount+c->point_index[i]]);
				pointCount++;
			}
			c->point_num[i] = pointCount;
			
			fclose(rfile);
		}
	}
	
}

void sup_infoITEM(item* c, char *CellFullDir, char *CellBorderDir, char *VirusFullDir, char *VirusBorderDir, Node* currentNode){
	int image = 0;
	char ItemFileName[180], CellFullFileName[180], CellBorderFileName[180], VirusFullFileName[180], VirusBorderFileName[180];
	
	initITEM(c);
	
	for(image = 0; image < currentNode->zero_num; image++){
		getFileName(image, CellFullFileName, CellBorderFileName, VirusFullFileName, VirusBorderFileName, CellFullDir, CellBorderDir, VirusFullDir, VirusBorderDir);
		
		switch(c->file_chosen){
			case 0:
				strcpy(ItemFileName, CellFullFileName);
				break;
			case 1:
				strcpy(ItemFileName, CellBorderFileName);
				break;
			case 2:
				strcpy(ItemFileName, VirusFullFileName);
				break;
			case 3:
				strcpy(ItemFileName, VirusBorderFileName);
				break;
		}
		c->obj_num[image] = countDIR(ItemFileName);
		
		if(image > 0){
			c->obj_index[image] = c->obj_index[image-1] + c->obj_num[image-1];
		}
		else{
			c->obj_index[image] = 0;
		}
		
		sup_readOBJ(ItemFileName, c, image, c->file_chosen, currentNode);
	}
}

void sup_findOVERLAP(item* v, item* c, result* overlap, int zero_num_image, Node* currentNode){
	int image = 0, i = 0, j = 0;
	int diffX=0, diffY=0;
	diffY=round(currentNode->diffY*zero_num_image);
	diffX=round(currentNode->diffX*zero_num_image);
	int check_overlap_Y=0, check_overlap_X=0;

	initRESULT(overlap);
	for(image = 0; image < IMAGE_NUM; image++){
		int** cellMark = (int**)malloc(sizeof(int*)*IMAGE_COL);
		for(i = 0; i < IMAGE_COL; i++){
			cellMark[i] = (int*)malloc(sizeof(int)*IMAGE_ROW);
			memset(cellMark[i], 0, sizeof(int)*IMAGE_ROW);
		}
		
		for(i = c->obj_index[image]; i < c->obj_index[image]+c->obj_num[image]; i++){
			for(j = c->point_index[i]; j < c->point_index[i]+c->point_num[i]; j++){
				cellMark[c->y_coord[j]][c->x_coord[j]] = 1;
			}
		}
		
		for(i = v->obj_index[image]; i < v->obj_index[image]+v->obj_num[image]; i++){
			for(j = v->point_index[i]; j < v->point_index[i]+v->point_num[i]; j++){
				if ( v->y_coord[j]+diffY<IMAGE_COL-1 && v->y_coord[j]+diffY>0)
					check_overlap_Y=v->y_coord[j]+diffY;
				else
					check_overlap_Y=v->y_coord[j];
				if ( v->x_coord[j]+diffX<IMAGE_ROW-1 && v->x_coord[j]+diffX>0)
					check_overlap_X=v->x_coord[j]+diffX;
				else
					check_overlap_X=v->x_coord[j];
				if(cellMark[check_overlap_Y][check_overlap_X] == 1){
					//overlap->overlap_mark[i] = 1;
					break;
				}
			}

		}
		
		// for (i = 0; i < IMAGE_COL; i++){
			// free(cellMark[i]);
		// }
		free(cellMark);
	}
}


void sup_getSHORTESTDIS(item* v, item* c, result* mindis, int zero_num_image, Node* currentNode){
	// FILE *wfile;
	int image = 0, vi = 0, vj = 0, ci = 0, cj = 0, vx = 0, vy = 0, cx = 0, cy = 0;
	double dis = 0;
	int init_ci = 0, fin_ci = 0, len_ci = 0;
	int threadid = OMP_THREAD_NUM;
	int bug = 0;
	int test = 0;
	int testimg = IMAGE_NUM;
	// char divCellandVirusFileName[50], buf[20];
	printf("image num:%d\nthread num:%d\n", testimg, threadid);
	#pragma omp parallel num_threads(threadid) private(image, test, vi, vj, cj, init_ci, fin_ci, vx, vy, cx, cy, dis)
	{ 
		image = omp_get_thread_num();
		// printf("%d\n", image);
		// threadid = omp_get_num_threads();
		// #pragma omp for 
		for(test = 0; test < testimg; test+=threadid){
			
			// printf("image:%d test:%d\n", image, test);
			// image = omp_get_thread_num();
			if(image+test < testimg){
			// else
				init_ci = c->obj_index[image+test];
				fin_ci = c->obj_num[image+test] + init_ci - 1;
				// //__line
				for(vi = v->obj_index[image+test]; vi < v->obj_index[image+test]+v->obj_num[image+test]; vi++){
					// //__line
					if(mindis->overlap_mark[vi] == 0){
						mindis->min_dis[vi] = 1000;
						for(vj = v->point_index[vi]; vj < v->point_index[vi]+v->point_num[vi]; vj++){
							// //__line
							vx = v->x_coord[vj]+currentNode->diffX*zero_num_image;
							vy = v->y_coord[vj]+currentNode->diffY*zero_num_image;
							//for(ci = c->obj_index[image]; ci < c->obj_index[image]+c->obj_num[image]; ci++){
							// init_ci = c->obj_index[image];
							// fin_ci = c->obj_num[image] + init_ci - 1;
							// len_ci
								for(cj = c->point_index[init_ci]; cj < c->point_index[fin_ci]+c->point_num[fin_ci]; cj++){
									// vx = v->x_coord[vj];
									// vy = v->y_coord[vj];
									// //__line
									cx = c->x_coord[cj];
									cy = c->y_coord[cj];
									dis = sqrt((vx-cx)*(vx-cx)+(vy-cy)*(vy-cy));
									// if(vj == v->point_index[vi] && cj == c->point_index[ci])
										// mindis->min_dis[vi] = dis;
									if(dis < mindis->min_dis[vi])
										mindis->min_dis[vi] = dis; 
								}
							//}
						}
						//printf("%d, %d, %f\n", image, vi, mindis->min_dis[vi]);
					}
				}
			}
		// #pragma omp barrier
		}
	}
	// exit(0);
}


Node* create_node(int value){
  Node* node = (Node*)malloc(sizeof(Node));
  node->next = NULL;
  node->value = value;
  node->last_center_obj=0;
  node->end=0;
  node->zero_num=0;
  return node;
}

void Delete(List* list, Node* target){
    // The "indirect" pointer points to the *address* of the thing we'll update.
	Node** indirect = &list->head;

	// Walk the list, looking for the thing that points to the node we want to remove.
	while (*indirect != target)
	indirect = &(*indirect)->next;

	*indirect = target->next;
}

void dump(List* list){
  if (!list || !list->head)
    return;

  printf("obj:%d, zero_num:%d, last_non_zero_img:%d, diffX:%f, diffY:%f, last_center:%d, start_center:%d\n", list->head->value, list->head->zero_num, list->head->end, list->head->diffX, list->head->diffY, list->head->last_center_obj, list->head->start_center_obj);
  Node* node =  list->head->next;
  while (node) {
    printf("obj:%d, zero_num:%d, last_non_zero_img:%d, diffX:%f, diffY:%f, last_center:%d, start_center:%d\n", node->value, node->zero_num, node->end, node->diffX, node->diffY, node->last_center_obj, node->start_center_obj);
    node = node->next;
  }
  printf("\n");
}

void calDIFF(List* list , char PList[][20], char *root, int count, int lastMissOBJ){
	char CenterName[80], CenterFileName[250], line[20];
	Node* node =  list->head;
	FILE *centerfile;
	int count_obj=0;

	
	strcpy(CenterFileName, root);
	sprintf(CenterName, "/particle_center%s.txt", PList[count-1]);
	strcat(CenterFileName,CenterName);
	
	while(node!=NULL){
		centerfile = fopen(CenterFileName,"r");	
		count_obj=0;
		while (fgets(line, 20, centerfile) != NULL){
			if ( count_obj == node->start_center_obj-1){
				sscanf(line, "%f %f", &node->diffX, &node->diffY);
				node=node->next;
				break;
			}
			count_obj++;
		}
		fclose(centerfile);
	}

	node=list->head;
	float tempX, tempY;
	while(node!=NULL){
		count_obj=0;
		strcpy(CenterFileName, root);
		sprintf(CenterName, "/particle_center%s.txt", PList[node->end-1]);
		strcat(CenterFileName,CenterName);		
		centerfile = fopen(CenterFileName,"r");
		while (fgets(line, 20, centerfile) != NULL){
			if ( count_obj == node->last_center_obj-1){
				sscanf(line, "%f %f", &tempX, &tempY);
				node->diffX=(tempX-node->diffX)/(count-node->end);
				node->diffY=(tempY-node->diffY)/(count-node->end);
			}
			count_obj++;
		}
		node=node->next;
		fclose(centerfile);
	}

}

int findZeroNum(char *root, int count, List *list, int obj_num, int lastMissOBJ){
	
	Node* currentNode=list->head;
	int templastMissOBJ=lastMissOBJ;
	char objectName[80], ObjectProcessFileName[250], line[10];
	FILE *rfile;
	strcpy(ObjectProcessFileName, root);
	sprintf(objectName, "/TrackingProcess/recordObjectProcess/ObjectProcess%d.txt", count);
	strcat(ObjectProcessFileName, objectName);

	rfile = fopen(ObjectProcessFileName,"r");
	for (int i=0; i<=templastMissOBJ; i++){
		fgets(line, 20, rfile);			
		if ( i==currentNode->value){	
			if (atoi(line)==0 ){
				currentNode->zero_num++;
				lastMissOBJ=currentNode->value;
				currentNode=currentNode->next;	
			}
			else{
				if (currentNode->end==0){
					currentNode->end=count;
					currentNode->last_center_obj=atoi(line);
				}
				obj_num--;
				currentNode=currentNode->next;
			}

		}

	}	

	return obj_num, lastMissOBJ;
}


void supCALCULATION(char *root, char *CellFileListName, char *VirusFileListName, int count){

	char objectName[80], ObjectProcessFileName[250], line[10];
	List miss_list;
	char *temp;
	int count_obj=0;
	int lastMissOBJ=-1;
	FILE *rfile;
	Node* currentNode = miss_list.head= create_node(-1);

	strcpy(ObjectProcessFileName, root);
	sprintf(objectName, "/TrackingProcess/recordObjectProcess/ObjectProcess%d.txt", count-1);
	strcat(ObjectProcessFileName, objectName);

	rfile = fopen(ObjectProcessFileName,"r");
	while (fgets(line, 10, rfile) != NULL){
		if (atoi(line)==0){
			if (lastMissOBJ==-1){
				currentNode->value=count_obj;
				currentNode->zero_num=1;
			}
			else{
				currentNode->next = create_node(count_obj);
    			currentNode = currentNode->next;
    			currentNode->zero_num=1;
			}	
			lastMissOBJ=currentNode->value;	
		}
		count_obj++;
	}
	fclose(rfile);

	currentNode=miss_list.head;
	int obj_num=0;
	if (lastMissOBJ!=-1){
		int templastMissOBJ=lastMissOBJ;
		strcpy(ObjectProcessFileName, root);
		sprintf(objectName, "/TrackingProcess/recordObjectProcess/ObjectProcess%d.txt", count);
		strcat(ObjectProcessFileName, objectName);
		rfile = fopen(ObjectProcessFileName,"r");
		for (int i=0; i<=templastMissOBJ; i++){
			fgets(line, 10, rfile);		
			if ( i==currentNode->value){	
				if (atoi(line)==0 ){
					Delete(&miss_list,currentNode);
					currentNode=currentNode->next;	
				}
				else{
					obj_num++;
					lastMissOBJ=currentNode->value;
					currentNode->start_center_obj=atoi(line);
					currentNode=currentNode->next;
				}
			}
		}	
		fclose(rfile);
	}
	else
		Delete(&miss_list,currentNode);
	
	
	if (miss_list.head!=NULL){
		for ( int i=count-2; i>0; i--){
			obj_num, lastMissOBJ=findZeroNum(root, i, &miss_list, obj_num, lastMissOBJ);
			if ( obj_num==0)
				break;
		}
	}
	//dump(&miss_list);
	

	char CList[count][20], PList[count][20];

	FILE *cfile, *pfile;
	cfile = fopen(CellFileListName,"r");
	pfile = fopen(VirusFileListName,"r");
	for (int i=0; i<count; i++){
		fgets(CList[i], 20, cfile);
		fgets(PList[i], 20, pfile);
		CList[i][strlen(CList[i])-1]=0;
		PList[i][strlen(PList[i])-1]=0;
	}
	fclose(cfile);
	fclose(pfile);


	calDIFF(&miss_list , PList, root, count, lastMissOBJ);
	dump(&miss_list);

	currentNode=miss_list.head;
	clock_t w = clock();
	while (currentNode!=NULL){
		for ( int i=0; i<currentNode->zero_num; i++){
			item* sup_cell = (item*)malloc(sizeof(item));
			item* sup_cell_border = (item*)malloc(sizeof(item));
			item* sup_virus = (item*)malloc(sizeof(item));
			item* sup_virus_border = (item*)malloc(sizeof(item));
			result* sup_vc = (result*)malloc(sizeof(result));
			//char *CellFullDir, char *CellBorderDir, char *VirusFullDir, char *VirusBorderDir, int sup_img_num
			// t[0].start();
			sup_cell->file_chosen = 0;
			strcpy(ObjectProcessFileName, root);
			sprintf(objectName, "/cell_full/for_dis%s/", CList[count-2-i]);
			strcat(ObjectProcessFileName, objectName);
			infoITEM(sup_cell,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName);
			//sup_infoITEM(sup_cell,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,currentNode);

			sup_virus->file_chosen = 2;
			strcpy(ObjectProcessFileName, root);
			sprintf(objectName, "/particle_full/for_dis%s/", PList[count-1]);
			strcat(ObjectProcessFileName, objectName);
			infoITEM(sup_virus,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName);
			//sup_infoITEM(sup_virus,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,currentNode);
			//__line
			//findOVERLAP(sup_virus, sup_cell, sup_vc);
			sup_findOVERLAP(sup_virus, sup_cell, sup_vc, i+1, currentNode);
			//__line
			// t[0].stop(1,"readfile");
			sup_cell_border->file_chosen = 1;
			strcpy(ObjectProcessFileName, root);
			sprintf(objectName, "/cell_border/for_dis%s/", CList[count-2-i]);
			strcat(ObjectProcessFileName, objectName);
			//__line
			//sup_infoITEM(sup_cell_border,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,currentNode);
			infoITEM(sup_cell_border,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName);
			//__line
			sup_virus_border->file_chosen = 3;
			strcpy(ObjectProcessFileName, root);
			sprintf(objectName, "/particle_border/for_dis%s/", PList[count-1]);
			strcat(ObjectProcessFileName, objectName);
			//__line
			//sup_infoITEM(sup_virus_border,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,currentNode);
			infoITEM(sup_virus_border,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName,ObjectProcessFileName);
			// t[0].stop(1,"readfile");
			//__line
			// t[1].start();
			printf("read time %.3lf secs\n",(double)(clock() - w)/CLOCKS_PER_SEC);
			double start = omp_get_wtime( );
			//getSHORTESTDIS(sup_virus_border, sup_cell_border, sup_vc);
			sup_getSHORTESTDIS(sup_virus_border, sup_cell_border, sup_vc, i+1, currentNode);
			//__line
			// t[1].stop(1,"compute time");
			FILE *wfile;
			// char divCellandVirusFileName[50], buf[20];
			
			char divCellandVirusFileName[200], buf[20];
			strcpy(divCellandVirusFileName, root);
			sprintf(objectName, "/recordParticleandCellDistance%s_%d.txt", PList[count-2-i], currentNode->value);
			strcat(divCellandVirusFileName, objectName);
			wfile = fopen(divCellandVirusFileName, "w");
			sprintf(buf,"%d",currentNode->start_center_obj);
			fwrite (buf, strlen(buf), 1, wfile);
			fwrite ("\n",1,1,wfile);
			for(int vi = 0; vi < sup_virus_border->obj_num[0]; vi++){
				sprintf(buf,"%f",sup_vc->min_dis[vi+sup_virus_border->obj_index[0]]);
				fwrite (buf, strlen(buf), 1, wfile);
			    fwrite ("\n",1,1,wfile);
			}
			fclose(wfile);
			
			double end = omp_get_wtime( );
			printf("start = %.16g\nend = %.16g\ndiff = %.16g\n", start, end, end - start);
			// t[0].stop(1,"total");

			freeITEM(sup_cell);
			freeITEM(sup_virus);
			freeITEM(sup_cell_border);
			freeITEM(sup_virus_border);
			freeRESULT(sup_vc);
		}
		currentNode=currentNode->next;
	}

}