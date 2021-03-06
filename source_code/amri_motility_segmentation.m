function [Output] = amri_motility_segmentation(Img,para)
%{

##amri_motility_segmentation:
Segment image using "otsu" or "fuzzy c-means clustering + localized active contour" method.

##Environment requirement:
This code was developed under Red Hat Enterprise Linux environment.

##Usage:
Output = amri_motility_segmentation(Img,para)

##Inputs:
Img: 3D image
para: a structure contains parameters for image segmentation 

##Output:
Output: segmented image

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

%-- initialization
Output = zeros(nx,ny,nz);
        
switch para.motility_seg_option
    
    case 'otsu'
                   
        if isfield(para,'mask')
            mask = para.mask; % take ROI
        else
            mask = (zeros(size(Img))+1)>0; % take whole image
        end
        
        %-- first mask
        img_ROI = Img;
        img_mask = zeros(nx,ny,nz);
        for islice = 1 : nz
            img_ROI(:,:,islice) = img_ROI(:,:,islice).*uint8(mask);
            img_mask(:,:,islice) = mask;
        end
        
        %-- otsu segmentation
        img_ROI_reshape = reshape(img_ROI,nx*ny*nz,1);
        img_mask_reshape = reshape(img_mask,nx*ny*nz,1);
        level = tools_otsuSeg(img_ROI_reshape,img_mask_reshape);
        img_ROI_BW = im2bw(img_ROI_reshape,level);
        img_ROI_BW = reshape(img_ROI_BW,nx,ny,nz);
                
        %-- fill a 'hole' with leakage
        for islice = 1 : nz
            temp_img = img_ROI_BW(:,:,islice);
            temp_img_close = imclose(temp_img , strel('disk', 2));
            temp_img_close = imfill(temp_img_close,'holes');
            holes = (temp_img_close - temp_img)>0;
            if nnz(holes) > 0
                [largest_hole,~] = tools_getLargestCc(holes, 4, 1);
                img_ROI_BW(:,:,islice) =  temp_img + largest_hole;
            else
                img_ROI_BW(:,:,islice) =  temp_img;
            end
            
            img_ROI_BW(:,:,islice) = imfill(img_ROI_BW(:,:,islice),'holes');
            
        end
        
        %-- extract the largest connected component
        img_ROI_BW_erode = img_ROI_BW;
        se = strel('disk',1);
        for islice = 1 : nz
            img_ROI_BW_erode(:,:,islice) = imerode(img_ROI_BW(:,:,islice),se); % erosion
        end
        
        [img_ROI_BW_LCC,~] = tools_getLargestCc(img_ROI_BW_erode, 6, 1); % 3D connected component check
        
        
        for islice = 1 : nz
            img_ROI_BW_LCC(:,:,islice) = imdilate(img_ROI_BW_LCC(:,:,islice),se); %dilation
        end
        
        
        %-- assign to output
        Output = img_ROI_BW_LCC;
        

    case 'AC'
        
        %-- run fuzzy-cmeans main function
        fuzziness = para.motility_FCMFuzziness;
        numClust = para.motility_FCMNumClust;
        output_temp = tools_FCM(Img,numClust,fuzziness); % fuzzy c-means main function
        img_fuzzy = (output_temp == numClust); % only keep the brightest class
        
        %-- remove objects smaller than 30 voxels (consider as noise)
        img_fuzzy = bwareaopen(img_fuzzy,30,8);
        
        %-- fill holes
        img_fuzzy = imfill(img_fuzzy,26,'holes');
        
        %-- get largest component
        img_fuzzy = tools_getLargestCc(img_fuzzy, 26, 1);
        
        %-- run 2D localized active contour
        Output = zeros(nx,ny,nz);
        winSize = para.motility_ACWinSize;
        lengthPenalty = para.motility_ACLengthPenalty;
        iteration = para.motility_ACIteration;
        epsilon = para.motility_ACEpsilon;
        
        if para.plotFigures == 0;
            ACPlot = figure('visible','off');
            set(ACPlot, 'Position', [200, 200, 1440,400],'color','w','name','Localized Active Contour');
        else
            ACPlot = figure('visible','on');
            set(ACPlot, 'Position', [200,200, 1280,600],'color','w','name','Localized Active Contour');
        end
        
        for islice = 1 : nz
            if sum(nnz(img_fuzzy(:,:,islice)))>0
                
                if para.plotFigures == 1
                    figure(ACPlot);
                    subplot(1,2,1);
                end
                
                % localized active contour main function
                Output(:,:,islice) = tools_localActiveContour(double(Img(:,:,islice)),img_fuzzy(:,:,islice),winSize,lengthPenalty,iteration,epsilon,para.plotFigures);
                
                %-- fill hole
                Output(:,:,islice) = imfill(Output(:,:,islice),'holes');
                
                if para.plotFigures == 1
                    figure(ACPlot);
                    subplot(1,2,2);
                    imshowpair(imrotate(squeeze(Img(:,:,islice)),90),imrotate(squeeze(Output(:,:,islice)),90));
                    title(['Slice: ' num2str(islice)],'fontsize',20);
                    pause(0.1);
                end
 
            end
        end
        
        close all;
        
        
end
