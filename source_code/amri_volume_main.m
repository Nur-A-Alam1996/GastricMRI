%{

##amri_volume_main:
Scripts for processing gastric volume data

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##Reference: 
Lu, K. H., Cao, J., Oleson, S. T., Powley, T. L., & Liu, Z. (2017).
Contrast-Enhanced Magnetic Resonance Imaging of Gastric Emptying and Motility in Rats. 
IEEE Transactions on Biomedical Engineering, 64(11), 2546-2554.

##DISCLAIMER AND CONDITIONS FOR USE:
This software is distributed under the terms of the GNU General Public
License v3, dated 2007/06/29 (see http://www.gnu.org/licenses/gpl.html).
Use of this software is at the user's OWN RISK. Functionality is not
guaranteed by creator nor modifier(s), if any. This software may be freely
copied and distributed. The original header MUST stay part of the file and
modifications MUST be reported in the 'HISTORY'-section,
including the modification date and the name of the modifier.

##CREATED:
Oct. 11, 2017
Kun-Han Lu
Electrical and Computer Engineering
Purdue University
 
##History:
1.00 - 10/11/2017 - KHLU - create the original file

##Version:
1.00

0 - Set global variables
1 - Load data
2 - Anisotropic smoothing 
3 - Image segmentation
4 - Stomach/Intestine Separation
5 - AUTOMATIC PARTITION of STOMACH INTO FORESTOMACH, CORPUS AND ANTRUM
6 - CALCULATE PYLORUS DIAMETER 

%}

%% 0 SET GLOBAL VARIABLES

clc;close all; clear;

cfgMain = global_getcfg;
rootPath= global_path2root;

%% 1 LOAD DATA

%-- load motility data
volume = load([rootPath.volume '/volume/volume_scan_1.mat']);
img = volume.img;

if ~isa(img,'uint8')
    img = mat2gray(img); % convert to intensity image (double, [0,1])
    img = uint8(255*img); % convert from double to uint8
end

%-- retrieve image size
[dim.nx,dim.ny,dim.nz] = size(img);

%% 2 ANISOTROPIC SMOOTHING (OPTIONAL)

%-- default parameters for anisotropic smoothing
% lambda: numerical stability parameter (usually set to 1/7)
% K: threshold to shape the g() function
% n: number of iterations
% option: either 1 or 2 for the choice of g()
lambda = cfgMain.volume_smooth_lambda;
K = cfgMain.volume_smooth_K;
n = cfgMain.volume_smooth_n;
g = cfgMain.volume_smooth_g;

if cfgMain.volume_smooth == 1
    img_smooth = tools_anisodiff3D(img,lambda,K,n,g);
else
    img_smooth = img; % use unsmoothed img
end

%% 3 IMAGE SEGMENTATION 

img_seg = amri_volume_segmentation(img_smooth,cfgMain);

%% 4 STOMACH/INTESTINE SEPARATION

[img_stomach,img_intestine] = amri_volume_GIseparation(img_smooth,img_seg,cfgMain.volume_GIKernel);

%% 5 AUTOMATIC PARTITION of STOMACH INTO FORESTOMACH, CORPUS AND ANTRUM

[img_forestomach,img_corpus,img_antrum] = amri_volume_stomachPartition(img_smooth,img_stomach);

%% 6 CALCULATE PYLORUS DIAMETER 

pylorus_diameter = amri_volume_calcPylorusArea(img_smooth,img_seg,cfgMain.volume_spatial_resolution);
