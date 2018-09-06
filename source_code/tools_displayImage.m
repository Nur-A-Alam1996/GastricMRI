function tools_displayImage(Img,frameRate)

%{

##tools_displayImage:
This is the function for displaying 4D MRI/fMRI images.

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##History:
1.00 - 10/11/2017 - KHLU - create the original file

##Version:
1.00

%}

[~,~,~,nt] = size(Img);
if nt<=1
    disp('Please check how to use tools_displayImage');
    return
end

for itime = 1 : nt
    tools_sliceview(Img(:,:,:,itime));
    pause(frameRate);
end

end
