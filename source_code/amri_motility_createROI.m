function [Img_standard,mask,position,final_angle] = amri_motility_createROI(Img)

%{

##amri_motility_createROI:
Reorient GI MRI image and select region of interest.

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##Usage
  [Img_standard,mask,position,final_angle] = amri_motility_createROI(Img)

##Inputs
  Img: 3D/4D matrix

##Output
  Img_standard: reoriented image
  mask: region of interest
  position: coordinates of region of interest
  final_angle: rotation angle between orignal image and final image

##DISCLAIMER AND CONDITIONS FOR USE:
This software is distributed under the terms of the GNU General Public
License v3, dated 2007/06/29 (see http://www.gnu.org/licenses/gpl.html).
Use of this software is at the user's OWN RISK. Functionality is not
guaranteed by creator nor modifier(s), if any. This software may be freely
copied and distributed. The original header MUST stay part of the file and
modifications MUST be reported in the 'HISTORY'-section,
including the modification date and the name of the modifier.

##CREATED:
Oct. 25, 2017
Kun-Han Lu
Electrical and Computer Engineering
Purdue University

##History:
1.00 - 10/25/2017 - KHLU - create the original file

##Version:
1.00

%}

%-- take Maximum Intensity Projection at time 0
if length(size(Img)) == 3
    img_MIP = max(Img, [], 3);
elseif length(size(Img)) == 4
    img_MIP = max(Img(:,:,:,1), [], 3);
else
    disp('Please check the input for amri_motility_createROI');
    return
end

img_MIP = uint8(img_MIP);

%-- show image
FigHandle = figure(1);
set(FigHandle, 'Position', [150, 250, 480,480],'Name','Rotate image & Draw ROI','NumberTitle','off');
imshow(img_MIP,'initialmagnification',400);
hold on;
for ii = [0.25,0.5,0.75]
    L = round(size(img_MIP,1)*ii);
    line([0 size(img_MIP,1)],[L L],'Color',[0.5,0.5,0.5],'LineStyle','--');
    line([L L],[0 size(img_MIP,1)],'Color',[0.5,0.5,0.5],'LineStyle','--');
end
hold off;
title('Please rotate image until the antral axis is vertical');

%-- rotate the MIP image
flag_satisfy = 0;
final_angle = 0;
img_MIP_rotate = img_MIP; % initialization

while flag_satisfy == 0
    x = inputdlg('Please specify the angle for rotation: e.g.  rotate 90 degrees clockwise (-90):','Rotation Angle', [1 50]);
    angle = str2double(x{:});
    final_angle = final_angle + angle;
    
    img_MIP_rotate = imrotate(img_MIP_rotate,angle,'nearest','crop'); % rotate image
    
    imshow(img_MIP_rotate,'initialmagnification',400);
    hold on;
    for ii = [0.25,0.5,0.75]
    L = round(size(img_MIP,1)*ii);
    line([0 size(img_MIP,1)],[L L],'Color',[0.5,0.5,0.5],'LineStyle','--');
    line([L L],[0 size(img_MIP,1)],'Color',[0.5,0.5,0.5],'LineStyle','--');
    end
    hold off;
    
    dlgTitle = '';
    dlgQuestion = 'Are you satisfied?';
    choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
    if strcmp(choice,'Yes')
        flag_satisfy = 1;
    end
end
 
%-- rotate original image
Img_standard = Img; % initialization

if length(size(Img)) == 3
    for islice = 1 : size(Img,3)
        Img_standard(:,:,islice) = imrotate(Img(:,:,islice),final_angle,'nearest','crop');
    end
elseif length(size(Img)) == 4
    for islice = 1 : size(Img,3)
        for itime = 1 : size(Img,4)
            Img_standard(:,:,islice,itime) = imrotate(Img(:,:,islice,itime),final_angle,'nearest','crop');
        end
    end
end

%-- create ROI
title('Please place ROI covering the antrum and double-click');
h = imrect(gca,[size(Img,1)-40,size(Img,2)-40,20,20]);
handle = wait(h); %#ok<NASGU>
mask = h.createMask;
position = h.getPosition; %[xmin ymin width height]
close all;

end
