function [stomach,intestine] = amri_volume_GIseparation(Img,Mask,kernel_size)
%{

##amri_volume_GIseparation:
Partition GI tract into stomach and intestine

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##Usage:
[stomach,intestine] = amri_volume_GIseparation(Img,Mask,kernel_size)

##Inputs:
Img: 3D image
Mask: segmented GI tract
kernel_size: size of kernel for morphological operations

##Output:
stomach: segmented stomach
intestine: segmented intestine

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

%-- retrieve dimensions
[nx,ny,nz] = size(Img);

%-- fill holes
mask_fill = Mask;
for islice = 1 : nz
    mask_fill(:,:,islice) = imfill(Mask(:,:,islice),'holes');
end

%-- erosion
stomach_erosion = mask_fill;
se = strel('disk',kernel_size);
for islice = 1 : nz
    stomach_erosion(:,:,islice) = imerode(stomach_erosion(:,:,islice),se);
end
    
%-- find largest connected component
stomach_erosion = tools_getLargestCc(stomach_erosion>0,6,1);
       
%-- dilation and take the intesection of the mask and the original
%-- image
se = strel('disk',kernel_size*2); % use a larger kernel size to make sure the original stomach volume is covered
stomach_dilation = imdilate(stomach_erosion,se);
stomach = stomach_dilation.*mask_fill; % extract stomach
    
%-- find largest connected component
stomach = tools_getLargestCc(stomach>0,6,1);
   
%-- extract intestine
intestine = mask_fill - stomach;
    
%--display
%tools_sliceview(Img,stomach+2*intestine,'ocmap','jet');

end
