%{

##amri_motility_main:
Scripts for processing gastric motility data

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
1.01 - 11/27/2017 - KHLU - add spatio-temporal map
1.10 - 08/24/2018 - KHLU - add fcm+active contour as an option for segmentation

##Version:
1.10

0 - Set global variables
1 - Load data
2 - Motion correction (rigid registration)
3 - Antrum segmentation
4 - Construct spatio-temporal motility map
5 - Compute motility stat (frequency/amplitude/velocity at selected location)

%}

%% 0 SET GLOBAL VARIABLES

clc;close all; clear;

cfgMain = global_getcfg;
rootPath= global_path2root;

%% 1 LOAD DATA

%-- load motility data
motility = load([rootPath.motility '/motility/motility_scan_1.mat']);
img = motility.img; % 4D (3D+time) image

if ~isa(img,'uint8')
    img = mat2gray(img); % convert to intensity image (double, [0,1])
    img = uint8(255*img); % convert from double to uint8
end

%-- retrieve image size
dimension = size(img);

%-- total scan time
MRI_duration = load([rootPath.motility '/motility/scan_time_1.mat']);
MRI_duration = MRI_duration.MRI_duration;
effective_sampRate = MRI_duration/dimension(4);

%% 2 MOTION CORRECTION (RIGID REGISTRATION)

%-- rigid registration
if cfgMain.motility_motion_correction == 1
    img_mc = tools_MotionCorrection(img);
else
    img_mc = img;
end

%-- check quality
if cfgMain.plotFigures == 1
    disp_frameRate = 0.17;
    tools_displayImage(img_mc,disp_frameRate);
end

%% 3 ANTRUM SEGMENTATION ('otsu': otsu segmentation / 'AC': FCM+localized active contour)

dlgTitle = '';
dlgQuestion = 'Which segmentation method would you like to use?';
cfgMain.motility_seg_option = questdlg(dlgQuestion,dlgTitle,'otsu','AC','otsu');
    
switch cfgMain.motility_seg_option
    
    case 'otsu'
    
    %-- define antrum ROI
    [img_mc_standard,mask,position,final_angle] = amri_motility_createROI(img_mc);
    
    %-- antrum segmentation using otsu thresholding
    img_antrum_seg = zeros(size(img_mc));
    cfgMain.mask = mask;
    for itime = 1 : dimension(4)
        disp(['Processing volume#' num2str(itime)]);
        img_antrum_seg(:,:,:,itime) = amri_motility_segmentation(img_mc_standard(:,:,:,itime),cfgMain);
    end
    
    case 'AC'
    
    %-- GI segmentation using fuzzy c-means clustering followed by
    %-- localized active contour
    img_antrum_seg = zeros(size(img_mc));
    for itime = 1 : dimension(4)
        disp(['Processing volume#' num2str(itime)]);
        img_antrum_seg(:,:,:,itime) = amri_motility_segmentation(img_mc(:,:,:,itime),cfgMain);
    end
    
    %-- define antrum ROI
    [img_antrum_seg,mask,position,final_angle] = amri_motility_createROI(img_antrum_seg*255);
    img_antrum_seg = double(img_antrum_seg > 0);
    
    otherwise
        display('Please input ''otsu'' or ''AC'' as segmentation method');
        
end

%% 4 CONSTRUCT SPATIO-TEMPORAL MOTILITY MAP

%-- compute the spatio-temporal map map
position = uint8(floor(position));
img_ROI_BW = img_antrum_seg(position(2):position(2)+position(4),position(1):position(1)+position(3),:,:);

%-- compute contraction time series along long axis of antrum
profile = squeeze(sum(img_ROI_BW,2));
profile = squeeze(sum(profile,2)); % column: location / row: time series

%-- display motility map
if cfgMain.plotFigures == 1
    FigHandle = figure;
    set(FigHandle, 'Position', [400, 400,900,360]);
    imagesc(profile);
    colormap gray
    set(gca,'XTickLabel','','YTickLabel','');
end

%% 5 COMPUTE MOTILITY STAT (frequency/amplitude/velocity at selected location)

%-- select a row to compute motility indices
time_series = amri_motility_selectTimeseries(profile);

%-- calculate frequency, amplitude, velocity from the 3 time series
MRI_resolution.spatial = cfgMain.motility_spatial_resolution;
MRI_resolution.temporal = effective_sampRate;
MRI_resolution.samp_rate = effective_sampRate;
MRI_resolution.MRI_duration = MRI_duration;

antral_motility = amri_motility_calcIndex(time_series,MRI_resolution);
