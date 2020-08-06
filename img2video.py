import cv2
import glob
import sys
import os

imgs_dir=sys.argv[1]
save_name=sys.argv[2]
file_list=sys.argv[3]
f = open(file_list,mode='r')


fps = 1
fourcc = cv2.VideoWriter_fourcc(*'DIVX')
video_writer = cv2.VideoWriter(save_name+'video.avi', fourcc, fps, (1392, 1040))


for i in f:
	imgname=imgs_dir+i.strip('\n')+'.png'
	frame = cv2.imread(imgname)
	video_writer.write(frame)
	
video_writer.release()
f.close()