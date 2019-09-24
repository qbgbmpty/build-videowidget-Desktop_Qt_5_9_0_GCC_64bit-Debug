###In[1]###
import os
import sys
import json
import datetime
import numpy as np
import skimage.draw
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
import traceback
traceback.print_exc()


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

file_names = sys.argv[1]
masks_prediction = np.zeros((1040, 1392, len(file_names)))

image = skimage.io.imread(file_names)
predictions = model.detect([image],  verbose=1)
p = predictions[0]
masks = p['masks']

#masks.shape[0] = 1040 masks.shape[1] = 1392
merged_mask = np.zeros((masks.shape[0], masks.shape[1]))
    
#masks.shape[2] = number of objects
for j in range(masks.shape[2]):
	merged_mask[masks[:,:,j]==True] = True
masks_prediction= merged_mask



###In[4] Load Annotations###
#PREDICT_DIR = '/home/ppcb/tensorflow/mask_rcnn/dataset/cell_particle/model1'
#dataset = cell_particle.Cell_ParticleDataset()
#dataset.load_VIA(PREDICT_DIR, 'predict')
#dataset.prepare()


file_name = sys.argv[1]
img_path=sys.argv[2]
borderpath=sys.argv[3]
fullpath=sys.argv[4]
centerpath=sys.argv[5]
areapath=sys.argv[6]

x=file_name.split("/")[-1]
img_path+="/"
img_path+=x
borderpath+="/"
borderpath+=x
fullpath+="/"
fullpath+=x
centerpath+="/"
centerpath+=x
areapath+="/"
areapath+=x

class_names = ['BG', 'cell', 'particle']
test_image = skimage.io.imread(file_name)
predictions = model.detect([test_image], verbose=1) # We are replicating the same image to fill up the batch_size
p = predictions[0]
masks = p['masks']
#print(p)

borderfile=borderpath.split('.')[0]
borderfile+=".txt"
fullfile=fullpath.split('.')[0]  
fullfile+=".txt"
centerfile=centerpath.split('.')[0] 
centerfile+=".txt"
areafile=areapath.split('.')[0] 
areafile+=".txt"
savepic=img_path.split('.')[0]  

np.set_printoptions(threshold= np.NaN )
np.set_printoptions(suppress=True) 
#print(p['rois'], file=open(writefile, 'w'))

coordinate=np.zeros( (100, masks.shape[2]*2) )
border=np.zeros( (100, masks.shape[2]*2) )

FullMaxrow=100
BorderMaxrow=100


for i in range(masks.shape[2]):
	Fullrow=0
	Borderrow=0
	for j in range(p['rois'][i][0],p['rois'][i][2],1):
		for k in range(p['rois'][i][1],p['rois'][i][3],1):
			if masks[j][k][i]==True:
				if Fullrow==FullMaxrow:
					temp=np.zeros( (1, masks.shape[2]*2) )
					coordinate=np.row_stack((coordinate,temp))
					FullMaxrow+=1
				coordinate[Fullrow][2*i]=j+1
				coordinate[Fullrow][2*i+1]=k+1
				Fullrow=Fullrow+1				
				

				if j==(masks.shape[0]-1) or j==0 or k==(masks.shape[1]-1) or k==0:
					if Borderrow==BorderMaxrow:
						temp=np.zeros( (1, masks.shape[2]*2) )
						border=np.row_stack((border,temp))
						BorderMaxrow+=1					
					border[Borderrow][2*i]=j+1
					border[Borderrow][2*i+1]=k+1
					Borderrow=Borderrow+1
				elif masks[j-1][k-1][i]==False or masks[j-1][k][i]==False or masks[j-1][k+1][i]==False or masks[j][k-1][i]==False or masks[j][k+1][i]==False or masks[j+1][k-1][i]==False or masks[j+1][k][i]==False or masks[j+1][k+1][i]==False:
					if Borderrow==BorderMaxrow:
						temp=np.zeros( (1, masks.shape[2]*2) )
						border=np.row_stack((border,temp))
						BorderMaxrow+=1					
					border[Borderrow][2*i]=j+1
					border[Borderrow][2*i+1]=k+1
					Borderrow=Borderrow+1
				



np.savetxt(fullfile, coordinate,fmt='%d')
np.savetxt(borderfile, border,fmt='%d')

for i in range(p['rois'].shape[0]):
	print((p['rois'][i][0]+p['rois'][i][2])/2,(p['rois'][i][1]+p['rois'][i][3])/2,file=open(centerfile,'a'))

for i in range(p['rois'].shape[0]):
	print((p['rois'][i][2]-p['rois'][i][0])*(p['rois'][i][3]-p['rois'][i][1]),file=open(areafile,'a'))
	

			

visualize.save_image(test_image, savepic, p['rois'], p['masks'], p['class_ids'],p['scores'],class_names,scores_thresh=0.5,mode=0)

