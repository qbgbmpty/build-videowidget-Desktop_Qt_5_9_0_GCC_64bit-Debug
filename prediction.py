###In[1]###
import os
import sys
import json
import datetime
import numpy as np
import skimage.draw
import time
from matplotlib import pyplot as plt
# Root directory of the project
ROOT_DIR = os.path.abspath("../../")
# Import Mask RCNN
sys.path.append(ROOT_DIR)  # To find local version of the library
from mrcnn.config import Config
from mrcnn import model as modellib, utils
from mrcnn import visualize
import cell_particle
import random
from glob import glob
#import traceback
#traceback.print_exc()
import warnings
warnings.filterwarnings('ignore')
os.environ['TF_CPP_MIN_LOG_LEVEL'] ='3'

start = time.time()
# Directory to save logs and model checkpoints, if not provided
# through the command line argument --logs

PRETRAINED_MODEL_PATH = "/home/ppcb/tensorflow/mask_rcnn/Mask_RCNN-2.1/logs/cell_particle20180927T0400/mask_rcnn_cell_particle_0030.h5"
#IMAGE_DIR = "/home/ppcb/tensorflow/mask_rcnn/dataset/cell_particle/model1/predict"

###In[2]###
class InferenceConfig(cell_particle.Cell_ParticleConfig):
    # Set batch size to 1 since we'll be running inference on
    # one image at a time. Batch size = GPU_COUNT * IMAGES_PER_GPU
    GPU_COUNT = 1
    IMAGES_PER_GPU = 1
config = InferenceConfig()
#config.display()

model = modellib.MaskRCNN(mode="inference", config=config, model_dir='/home/ppcb/tensorflow/mask_rcnn/Mask_RCNN-2.1/logs/cell_particle20180927T0400/')
model_path = PRETRAINED_MODEL_PATH
# or if you want to use the latest trained model, you can use : 
# model_path = model.find_last()[1]
model.load_weights(model_path, by_name=True)

###In[3] Prediction and merge masks###
'''
file_names = sys.argv[1]
masks_prediction = np.zeros((1040, 1392, len(file_names)))

image = skimage.io.imread(file_names)
particle_predictions = model.detect([image],  verbose=1)
p = predictions[0]
masks = p['masks']

#masks.shape[0] = 1040 masks.shape[1] = 1392
merged_mask = np.zeros((masks.shape[0], masks.shape[1]))
    
#masks.shape[2] = number of objects
for j in range(masks.shape[2]):
	merged_mask[masks[:,:,j]==True] = True
masks_prediction= merged_mask
'''


###In[4] Load Annotations###
#PREDICT_DIR = '/home/ppcb/tensorflow/mask_rcnn/dataset/cell_particle/model1'
#dataset = cell_particle.Cell_ParticleDataset()
#dataset.load_VIA(PREDICT_DIR, 'predict')
#dataset.prepare()

particle_img_root=sys.argv[1]
cell_img_root=sys.argv[2]
dir_root=sys.argv[3]
img_num=sys.argv[4]
particle_img_list=dir_root+"/Plist.txt"
cell_img_list=dir_root+"/Clist.txt"

particle_list_name = open(particle_img_list,mode='r')
cell_list_name = open(cell_img_list,mode='r')

particle_img_path=dir_root+"/particle_image"
particle_borderpath=dir_root+"/particle_border"
particle_fullpath=dir_root+"/particle_full"
particle_centerpath=dir_root+"/particle_center"
particle_areapath=dir_root+"/particle_area"
particle_single_mask_path=dir_root+"/particle_image/single_mask/"
cell_img_path=dir_root+"/cell_image"
cell_borderpath=dir_root+"/cell_border"
cell_fullpath=dir_root+"/cell_full"
cell_centerpath=dir_root+"/cell_center"
np.set_printoptions(threshold= np.NaN )
np.set_printoptions(suppress=True) 

for i in range(int(img_num)):
	particle_file_name=particle_list_name.readline().strip('\n')
	cell_file_name=cell_list_name.readline().strip('\n')

	particle_img_file_name = particle_img_root+particle_file_name+".tif"
	cell_img_file_name=cell_img_root+cell_file_name+".tif"

	particle_savepic=particle_img_path+particle_file_name
	cell_savepic=cell_img_path+cell_file_name

	particle_centerfile=particle_centerpath+particle_file_name
	particle_centerfile+=".txt"
	particle_areafile=particle_areapath+particle_file_name
	particle_areafile+=".txt"
	particle_savemaskpic=particle_single_mask_path+str(i+1)+particle_file_name	

	cell_centerfile=cell_centerpath+cell_file_name
	cell_centerfile+=".txt"

	class_names = ['BG', 'cell', 'particle']
	particle_test_image = skimage.io.imread(particle_img_file_name)
	particle_predictions = model.detect([particle_test_image], verbose=0) # We are replicating the same image to fill up the batch_size
	particle_p = particle_predictions[0]
	particle_masks = particle_p['masks']

	cell_test_image = skimage.io.imread(cell_img_file_name)
	cell_predictions = model.detect([cell_test_image], verbose=0) # We are replicating the same image to fill up the batch_size
	cell_p = cell_predictions[0]
	cell_masks = cell_p['masks']

	particle_coordinate=np.zeros( (100, particle_masks.shape[2]*2) )
	particle_border=np.zeros( (100, particle_masks.shape[2]*2) )

	particle_FullMaxrow=100
	particle_BorderMaxrow=100

	cell_coordinate=np.zeros( (100, cell_masks.shape[2]*2) )
	cell_border=np.zeros( (100, cell_masks.shape[2]*2) )

	cell_FullMaxrow=100
	cell_BorderMaxrow=100


	for i in range(particle_masks.shape[2]):
		particle_Fullrow=0
		particle_Borderrow=0
		for j in range(particle_p['rois'][i][0],particle_p['rois'][i][2],1):
			for k in range(particle_p['rois'][i][1],particle_p['rois'][i][3],1):
				if particle_masks[j][k][i]==True:
					if particle_Fullrow==particle_FullMaxrow:
						temp=np.zeros( (1, particle_masks.shape[2]*2) )
						particle_coordinate=np.row_stack((particle_coordinate,temp))
						particle_FullMaxrow+=1
					particle_coordinate[particle_Fullrow][2*i]=j+1
					particle_coordinate[particle_Fullrow][2*i+1]=k+1
					#print(j+1,k+1,file=open(particle_fullpath+"/for_dis/"+particle_file_name+"/Object"+str(i+1)+".txt",'a'))
					particle_Fullrow=particle_Fullrow+1				
					

					if j==(particle_masks.shape[0]-1) or j==0 or k==(particle_masks.shape[1]-1) or k==0:
						if particle_Borderrow==particle_BorderMaxrow:
							temp=np.zeros( (1, particle_masks.shape[2]*2) )
							particle_border=np.row_stack((particle_border,temp))
							particle_BorderMaxrow+=1					
						particle_border[particle_Borderrow][2*i]=j+1
						particle_border[particle_Borderrow][2*i+1]=k+1
						print(j+1,k+1,file=open(particle_borderpath+"/for_dis"+particle_file_name+"/Object"+str(i+1)+".txt",'a'))
						particle_Borderrow=particle_Borderrow+1
					elif particle_masks[j-1][k-1][i]==False or particle_masks[j-1][k][i]==False or particle_masks[j-1][k+1][i]==False or particle_masks[j][k-1][i]==False or particle_masks[j][k+1][i]==False or particle_masks[j+1][k-1][i]==False or particle_masks[j+1][k][i]==False or particle_masks[j+1][k+1][i]==False:
						if particle_Borderrow==particle_BorderMaxrow:
							temp=np.zeros( (1, particle_masks.shape[2]*2) )
							particle_border=np.row_stack((particle_border,temp))
							particle_BorderMaxrow+=1					
						particle_border[particle_Borderrow][2*i]=j+1
						particle_border[particle_Borderrow][2*i+1]=k+1
						print(j+1,k+1,file=open(particle_borderpath+"/for_dis"+particle_file_name+"/Object"+str(i+1)+".txt",'a'))
						particle_Borderrow=particle_Borderrow+1

	for i in range(cell_masks.shape[2]):
		cell_Fullrow=0
		cell_Borderrow=0
		for j in range(cell_p['rois'][i][0],cell_p['rois'][i][2],1):
			for k in range(cell_p['rois'][i][1],cell_p['rois'][i][3],1):
				if cell_masks[j][k][i]==True:
					if cell_Fullrow==cell_FullMaxrow:
						temp=np.zeros( (1, cell_masks.shape[2]*2) )
						cell_coordinate=np.row_stack((cell_coordinate,temp))
						cell_FullMaxrow+=1
					cell_coordinate[cell_Fullrow][2*i]=j+1
					cell_coordinate[cell_Fullrow][2*i+1]=k+1
					#print(j+1,k+1,file=open(cell_fullpath+"/for_dis/"+cell_file_name+"/Object"+str(i+1)+".txt",'a'))
					cell_Fullrow=cell_Fullrow+1				
					

					if j==(cell_masks.shape[0]-1) or j==0 or k==(cell_masks.shape[1]-1) or k==0:
						if cell_Borderrow==cell_BorderMaxrow:
							temp=np.zeros( (1, cell_masks.shape[2]*2) )
							cell_border=np.row_stack((cell_border,temp))
							cell_BorderMaxrow+=1					
						cell_border[cell_Borderrow][2*i]=j+1
						cell_border[cell_Borderrow][2*i+1]=k+1
						print(j+1,k+1,file=open(cell_borderpath+"/for_dis"+cell_file_name+"/Object"+str(i+1)+".txt",'a'))
						cell_Borderrow=cell_Borderrow+1
					elif cell_masks[j-1][k-1][i]==False or cell_masks[j-1][k][i]==False or cell_masks[j-1][k+1][i]==False or cell_masks[j][k-1][i]==False or cell_masks[j][k+1][i]==False or cell_masks[j+1][k-1][i]==False or cell_masks[j+1][k][i]==False or cell_masks[j+1][k+1][i]==False:
						if cell_Borderrow==cell_BorderMaxrow:
							temp=np.zeros( (1, cell_masks.shape[2]*2) )
							cell_border=np.row_stack((cell_border,temp))
							cell_BorderMaxrow+=1					
						cell_border[cell_Borderrow][2*i]=j+1
						cell_border[cell_Borderrow][2*i+1]=k+1
						print(j+1,k+1,file=open(cell_borderpath+"/for_dis"+cell_file_name+"/Object"+str(i+1)+".txt",'a'))
						cell_Borderrow=cell_Borderrow+1			

	particle_borderfile=particle_borderpath+particle_file_name
	particle_borderfile+=".txt"
	particle_fullfile=particle_fullpath+particle_file_name
	particle_fullfile+=".txt"

	np.savetxt(particle_fullfile, particle_coordinate,fmt='%d')
	np.savetxt(particle_borderfile, particle_border,fmt='%d')


	for i in range(particle_p['rois'].shape[0]):
		print((particle_p['rois'][i][0]+particle_p['rois'][i][2])/2,(particle_p['rois'][i][1]+particle_p['rois'][i][3])/2,file=open(particle_centerfile,'a'))
		print((particle_p['rois'][i][2]-particle_p['rois'][i][0])*(particle_p['rois'][i][3]-particle_p['rois'][i][1]),file=open(particle_areafile,'a'))

	cell_borderfile=cell_borderpath+cell_file_name
	cell_borderfile+=".txt"
	cell_fullfile=cell_fullpath+cell_file_name
	cell_fullfile+=".txt"

	np.savetxt(cell_fullfile, cell_coordinate,fmt='%d')
	np.savetxt(cell_borderfile, cell_border,fmt='%d')


	for i in range(cell_p['rois'].shape[0]):
		print((cell_p['rois'][i][0]+cell_p['rois'][i][2])/2,(cell_p['rois'][i][1]+cell_p['rois'][i][3])/2,file=open(cell_centerfile,'a'))

	visualize.save_image(particle_test_image, particle_savepic, particle_p['rois'], particle_p['masks'], particle_p['class_ids'],particle_p['scores'],class_names,scores_thresh=0.5,mode=0)
	visualize.save_image(cell_test_image, cell_savepic, cell_p['rois'], cell_p['masks'], cell_p['class_ids'],cell_p['scores'],class_names,scores_thresh=0.5,mode=0)
	visualize.save_single_image(particle_test_image, particle_savemaskpic, particle_p['rois'], particle_p['masks'], particle_p['class_ids'],particle_p['scores'],class_names,scores_thresh=0.5,mode=0)
	print("ok")
	sys.stdout.flush()

#PorC=sys.argv[8]
'''

px=particle_file_name.split("/")[-1]
particle_img_path+="/"
particle_img_path+=px

particle_centerpath+="/"
particle_centerpath+=px
particle_areapath+="/"
particle_areapath+=px
particle_single_mask_path+="/"
particle_single_mask_path+=px

cell_file_name = sys.argv[8]



cx=cell_file_name.split("/")[-1]
cell_img_path+="/"
cell_img_path+=cx

cell_centerpath+="/"
cell_centerpath+=cx



#print(p)


particle_centerfile=particle_centerpath.split('.')[0] 
particle_centerfile+=".txt"
particle_areafile=particle_areapath.split('.')[0] 
particle_areafile+=".txt"
particle_savepic=particle_img_path.split('.')[0]  
particle_savemaskpic=particle_single_mask_path.split('.')[0]  

cell_centerfile=cell_centerpath.split('.')[0] 
cell_centerfile+=".txt"
cell_savepic=cell_img_path.split('.')[0]  


np.set_printoptions(threshold= np.NaN )
np.set_printoptions(suppress=True) 
#print(p['rois'], file=open(writefile, 'w'))

particle_coordinate=np.zeros( (100, particle_masks.shape[2]*2) )
particle_border=np.zeros( (100, particle_masks.shape[2]*2) )

particle_FullMaxrow=100
particle_BorderMaxrow=100

cell_coordinate=np.zeros( (100, cell_masks.shape[2]*2) )
cell_border=np.zeros( (100, cell_masks.shape[2]*2) )

cell_FullMaxrow=100
cell_BorderMaxrow=100


for i in range(particle_masks.shape[2]):
	particle_Fullrow=0
	particle_Borderrow=0
	for j in range(particle_p['rois'][i][0],particle_p['rois'][i][2],1):
		for k in range(particle_p['rois'][i][1],particle_p['rois'][i][3],1):
			if particle_masks[j][k][i]==True:
				if particle_Fullrow==particle_FullMaxrow:
					temp=np.zeros( (1, particle_masks.shape[2]*2) )
					particle_coordinate=np.row_stack((particle_coordinate,temp))
					particle_FullMaxrow+=1
				particle_coordinate[particle_Fullrow][2*i]=j+1
				particle_coordinate[particle_Fullrow][2*i+1]=k+1
				#print(j+1,k+1,file=open(particle_fullpath+"/for_dis/"+px.split('.')[0]+"/Object"+str(i+1)+".txt",'a'))
				particle_Fullrow=particle_Fullrow+1				
				

				if j==(particle_masks.shape[0]-1) or j==0 or k==(particle_masks.shape[1]-1) or k==0:
					if particle_Borderrow==particle_BorderMaxrow:
						temp=np.zeros( (1, particle_masks.shape[2]*2) )
						particle_border=np.row_stack((particle_border,temp))
						particle_BorderMaxrow+=1					
					particle_border[particle_Borderrow][2*i]=j+1
					particle_border[particle_Borderrow][2*i+1]=k+1
					print(j+1,k+1,file=open(particle_borderpath+"/for_dis/"+px.split('.')[0]+"/Object"+str(i+1)+".txt",'a'))
					particle_Borderrow=particle_Borderrow+1
				elif particle_masks[j-1][k-1][i]==False or particle_masks[j-1][k][i]==False or particle_masks[j-1][k+1][i]==False or particle_masks[j][k-1][i]==False or particle_masks[j][k+1][i]==False or particle_masks[j+1][k-1][i]==False or particle_masks[j+1][k][i]==False or particle_masks[j+1][k+1][i]==False:
					if particle_Borderrow==particle_BorderMaxrow:
						temp=np.zeros( (1, particle_masks.shape[2]*2) )
						particle_border=np.row_stack((particle_border,temp))
						particle_BorderMaxrow+=1					
					particle_border[particle_Borderrow][2*i]=j+1
					particle_border[particle_Borderrow][2*i+1]=k+1
					print(j+1,k+1,file=open(particle_borderpath+"/for_dis/"+px.split('.')[0]+"/Object"+str(i+1)+".txt",'a'))
					particle_Borderrow=particle_Borderrow+1

for i in range(cell_masks.shape[2]):
	cell_Fullrow=0
	cell_Borderrow=0
	for j in range(cell_p['rois'][i][0],cell_p['rois'][i][2],1):
		for k in range(cell_p['rois'][i][1],cell_p['rois'][i][3],1):
			if cell_masks[j][k][i]==True:
				if cell_Fullrow==cell_FullMaxrow:
					temp=np.zeros( (1, cell_masks.shape[2]*2) )
					cell_coordinate=np.row_stack((cell_coordinate,temp))
					cell_FullMaxrow+=1
				cell_coordinate[cell_Fullrow][2*i]=j+1
				cell_coordinate[cell_Fullrow][2*i+1]=k+1
				#print(j+1,k+1,file=open(cell_fullpath+"/for_dis/"+cx.split('.')[0]+"/Object"+str(i+1)+".txt",'a'))
				cell_Fullrow=cell_Fullrow+1				
				

				if j==(cell_masks.shape[0]-1) or j==0 or k==(cell_masks.shape[1]-1) or k==0:
					if cell_Borderrow==cell_BorderMaxrow:
						temp=np.zeros( (1, cell_masks.shape[2]*2) )
						cell_border=np.row_stack((cell_border,temp))
						cell_BorderMaxrow+=1					
					cell_border[cell_Borderrow][2*i]=j+1
					cell_border[cell_Borderrow][2*i+1]=k+1
					print(j+1,k+1,file=open(cell_borderpath+"/for_dis/"+cx.split('.')[0]+"/Object"+str(i+1)+".txt",'a'))
					cell_Borderrow=cell_Borderrow+1
				elif cell_masks[j-1][k-1][i]==False or cell_masks[j-1][k][i]==False or cell_masks[j-1][k+1][i]==False or cell_masks[j][k-1][i]==False or cell_masks[j][k+1][i]==False or cell_masks[j+1][k-1][i]==False or cell_masks[j+1][k][i]==False or cell_masks[j+1][k+1][i]==False:
					if cell_Borderrow==cell_BorderMaxrow:
						temp=np.zeros( (1, cell_masks.shape[2]*2) )
						cell_border=np.row_stack((cell_border,temp))
						cell_BorderMaxrow+=1					
					cell_border[cell_Borderrow][2*i]=j+1
					cell_border[cell_Borderrow][2*i+1]=k+1
					print(j+1,k+1,file=open(cell_borderpath+"/for_dis/"+cx.split('.')[0]+"/Object"+str(i+1)+".txt",'a'))
					cell_Borderrow=cell_Borderrow+1


particle_borderpath+="/"
particle_borderpath+=px
particle_fullpath+="/"
particle_fullpath+=px				

particle_borderfile=particle_borderpath.split('.')[0]
particle_borderfile+=".txt"
particle_fullfile=particle_fullpath.split('.')[0]  
particle_fullfile+=".txt"

np.savetxt(particle_fullfile, particle_coordinate,fmt='%d')
np.savetxt(particle_borderfile, particle_border,fmt='%d')


for i in range(particle_p['rois'].shape[0]):
	print((particle_p['rois'][i][0]+particle_p['rois'][i][2])/2,(particle_p['rois'][i][1]+particle_p['rois'][i][3])/2,file=open(particle_centerfile,'a'))
	print((particle_p['rois'][i][2]-particle_p['rois'][i][0])*(particle_p['rois'][i][3]-particle_p['rois'][i][1]),file=open(particle_areafile,'a'))

cell_borderpath+="/"
cell_borderpath+=cx
cell_fullpath+="/"
cell_fullpath+=cx				

cell_borderfile=cell_borderpath.split('.')[0]
cell_borderfile+=".txt"
cell_fullfile=cell_fullpath.split('.')[0]  
cell_fullfile+=".txt"

np.savetxt(cell_fullfile, cell_coordinate,fmt='%d')
np.savetxt(cell_borderfile, cell_border,fmt='%d')


for i in range(cell_p['rois'].shape[0]):
	print((cell_p['rois'][i][0]+cell_p['rois'][i][2])/2,(cell_p['rois'][i][1]+cell_p['rois'][i][3])/2,file=open(cell_centerfile,'a'))


visualize.save_image(particle_test_image, particle_savepic, particle_p['rois'], particle_p['masks'], particle_p['class_ids'],particle_p['scores'],class_names,scores_thresh=0.5,mode=0)
visualize.save_image(cell_test_image, cell_savepic, cell_p['rois'], cell_p['masks'], cell_p['class_ids'],cell_p['scores'],class_names,scores_thresh=0.5,mode=0)
visualize.save_single_image(particle_test_image, particle_savemaskpic, particle_p['rois'], particle_p['masks'], particle_p['class_ids'],particle_p['scores'],class_names,scores_thresh=0.5,mode=0)

'''
end = time.time()
print (end-start)