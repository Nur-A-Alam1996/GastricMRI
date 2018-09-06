function [Forestomach,Corpus,Antrum] = amri_volume_stomachPartition(Img,Stomach)
%{

##amri_volume_stomachPartition:
Partition the stomach into forestomach, corpus, and the antrum.

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##Usage:
[Forestomach,Corpus,Antrum] = amri_volume_stomachPartition(Img,Stomach)

##Inputs:
Img: 3D image
Stomach: segmented stomach image

##Output:
Forestomach: segmented forestomach
Corpus: segmented corpus
Antrum: segmented antrum

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

%-- retrieve size information
Stomach = Stomach > 0;
[nx,ny,nz] = size(Stomach);

%-- fill holes
stomach_fill = Stomach;
for islice = 1 : nz
    stomach_fill(:,:,islice) = imfill(Stomach(:,:,islice),'holes');
end

%-- partition the stomach into forestomach, corpus and antrum
%-- initialization
Forestomach = zeros(nx,ny,nz);
Corpus = zeros(nx,ny,nz);
Antrum = zeros(nx,ny,nz);
    
%-- maximum intensity projection
stomach_MIP = max(stomach_fill, [], 3);
    
%-- find largest connected component
stomach_MIP = tools_getLargestCc(stomach_MIP,8,1);
  
%-- find largest convex hull
stomach_concave = bwconvhull(stomach_MIP)-stomach_MIP;
stomach_concave = tools_getLargestCc(stomach_concave>0,8,1);
    
%-- find landmarks on the concave part of the stomach
s_inner  = regionprops(stomach_concave,'Extrema');
s_outer = regionprops(stomach_MIP,'Extrema');
centroids_inner = cat(1, s_inner.Extrema);
centroids_outer = cat(1, s_outer.Extrema);

%-- boundary between FORESTOMACH and CORPUS
a=round([centroids_inner(6,1), centroids_inner(6,2)]); % INNER: BOTTOM RIGHT
b=round([centroids_outer(8,1), centroids_outer(8,2)]);% OUTER: BOTTOM LEFT
    
x=[a(1) b(1)];
y=[a(2) b(2)];

nPoints = max(abs(diff(x)), abs(diff(y)))+1;
rIndex = round(linspace(y(1), y(2), nPoints));  % Row indices
cIndex = round(linspace(x(1), x(2), nPoints));  % Column indices
    
index = sub2ind(size(stomach_MIP), rIndex, cIndex);     % Linear indices
stomach_MIP(index) = 0;

%-- boundary between CORPUS and ANTRUM
a=round([centroids_inner(8,1), centroids_inner(8,2)]); % INNER: BOTTOM LEFT
b=round([centroids_outer(1,1), centroids_outer(1,2)]);% OUTER: LEFT BOTTOM

x=[a(1) b(1)];
y=[a(2) b(2)];

nPoints = max(abs(diff(x)), abs(diff(y)))+1;
rIndex = round(linspace(y(1), y(2), nPoints));  % Row indices
cIndex = round(linspace(x(1), x(2), nPoints));  % Column indices

index = sub2ind(size(stomach_MIP), rIndex, cIndex);     % Linear indices
stomach_MIP(index) = 0;

%-- assign different compartments
stomach_label = tools_getLargestCc(stomach_MIP,4,5);
CC = bwconncomp(stomach_label,4);
stomach_label = labelmatrix(CC);

%-- reassign stomach label
label = unique(stomach_label);
count = 0;
for ii = 1 : length(label)
    stomach_label(stomach_label==label(ii)) = count;
    count = count + 1;
end
    
region = zeros(nx,ny,3);
centroid = zeros(1,2,3);
for ii = 1 : 3
    region(:,:,ii) = stomach_label == ii;
    temp = regionprops(region(:,:,ii),'Centroid');
    centroid(:,:,ii) = temp.Centroid;
end
    
%-- forestomach is on the right
index_dummy = [1;2;3];
temp = centroid(1,2,:);
index = find(temp == max(temp));
forestomach_mask = region(:,:,index_dummy(index));
index_dummy(index) = [];

%-- corpus is at the bottom
temp = centroid(1,1,index_dummy);
index = find(temp == min(temp));
corpus_mask = region(:,:,index_dummy(index));
index_dummy(index) = [];

%-- last one is the antrum
antrum_mask = region(:,:,index_dummy);
       
for islice = 1 : nz
    Forestomach(:,:,islice) = Stomach(:,:,islice).*forestomach_mask;
    Corpus(:,:,islice) = Stomach(:,:,islice).*corpus_mask;
    Antrum(:,:,islice) = Stomach(:,:,islice).*antrum_mask;
end

% tools_sliceview(Img,Forestomach*4+Corpus*8+Antrum*12);

end
