function [Output] = amri_volume_segmentation(Img,para)
%{

##amri_volume_segmentation:
Segment GI tract using fuzzy c-means clustering and localized active contour.

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##Usage:
Output = amri_volume_segmentation(Img,para)

##Inputs:
Img: 3D image

##Output:
Output: segmented GI tract

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

if ~isa(Img,'uint8')
    Img = mat2gray(Img); % convert to intensity image (double, [0,1])
    Img = uint8(255*Img); % convert from double to uint8
end

%-- retrieve dimensions
[nx,ny,nz] = size(Img);
 
%-- run fuzzy-cmeans main function
fuzziness = para.volume_FCMFuzziness;
numClust = para.volume_FCMNumClust;
output_temp = tools_FCM(Img,numClust,fuzziness); % fuzzy c-means main function
if numClust > 3
    img_fuzzy = (output_temp == numClust-1)+(output_temp == numClust); % keep the top 2 brightest class
else
    img_fuzzy = (output_temp == numClust); % only keep the brightest class
end

%-- remove objects smaller than 5 voxels (consider as noise)
img_fuzzy = bwareaopen(img_fuzzy,5,26);

%-- fill holes
img_fuzzy = imfill(img_fuzzy,26,'holes');

%-- run 2D localized active contour
Output = zeros(nx,ny,nz);
winSize = para.volume_ACWinSize;
lengthPenalty = para.volume_ACLengthPenalty;
iteration = para.volume_ACIteration;
epsilon = para.volume_ACEpsilon;

if para.plotFigures == 0;
    ACPlot = figure('visible','off');
    set(ACPlot, 'Position', [200, 200, 1440,400],'color','w','name','VNS Paradigm');
else
    ACPlot = figure('visible','on');
    set(ACPlot, 'Position', [200,200, 1280,600],'color','w','name','VNS Paradigm');
end

for islice = 1 : nz    
    if sum(nnz(img_fuzzy(:,:,islice)))>0
        
        if para.plotFigures == 1
            figure(ACPlot);
            subplot(1,2,1);
        end
        
        Output(:,:,islice) = tools_localActiveContour(double(Img(:,:,islice)),img_fuzzy(:,:,islice),winSize,lengthPenalty,iteration,epsilon,para.plotFigures);
        
        %-- fill hole
        Output(:,:,islice) = imfill(Output(:,:,islice),'holes');
        
        if para.plotFigures == 1
            figure(ACPlot);
            subplot(1,2,2);
            imshowpair(imrotate(squeeze(Img(:,:,islice)),90),imrotate(squeeze(Output(:,:,islice)),90));
            title(['Processing slice: ' num2str(islice)],'fontsize',20);
            pause(0.1);
        end
        
    end
end

close all;
end
