function [Img_mc] = tools_MotionCorrection(Img)

%{

##tools_MotionCorrection:
This is the function for correcting motion in 4D MRI/fMRI images.
Rigid registration is applied with MATLAB built-in function.

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##Inputs:
Img: 4D image (3D + time)

##Output:
Output: motion corrected images

##History:
1.00 - 10/11/2017 - KHLU - create the original file

##Version:
1.00

%}

[~,~,nz,nt] = size(Img);
if nt<=1
    disp('Please check how to use tools_MotionCorrection');
    return
end

[optimizer, metric] = imregconfig('monomodal');

dummy = waitbar(0,'Please wait...','Name','Running registration...');
tic

Img_mc = Img; % initialization
for itime = 1 : nt
    
    % waitbar
    waitbar(itime/nt, dummy, ['Registering volume #',num2str(itime)]);
     
    if nz <=5
        for islice = 1 : nz
            Img_mc(:,:,islice,itime) = imregister(squeeze(Img(:,:,islice,itime)), squeeze(Img(:,:,islice,1)), 'rigid', optimizer, metric);
        end
    else
        Img_mc(:,:,:,itime) = imregister(squeeze(Img(:,:,:,itime)), squeeze(Img(:,:,:,1)), 'rigid', optimizer, metric);
    end
    
end

waitbar(itime/nt, dummy, 'Done!');
toc

close(dummy);

end
