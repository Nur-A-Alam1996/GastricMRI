function [time_series] = amri_motility_selectTimeseries(profile)

%{

##amri_motility_selectTimeseries:
Extract time series from a row in the motility map.

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##Usage
[time_series] = amri_motility_selectTimeseries(profile)

##Inputs
profile: 2D motility plot (X: time, Y: location along the antral axis)

##Output
time_series: 3 contraction time series on antral axis
                    (1 at selected location, 2 at above/below the location with 2 pixels spacing)

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

profile_for_plotting = profile;

%-- plot spatio-temporal map
FigHandle = figure(1);
set(FigHandle, 'Position', [400, 400,900,360]);
imagesc(profile_for_plotting);
colormap gray
set(gca,'XTickLabel','','YTickLabel','');

%-- select two lines for obtaining the line profile
fprintf('Please click on a location to sample the intensity profile\n');
[xc,yc] = ginput(1);
fprintf('You clicked at (x,y)=(%.1f,%.1f)',xc,yc);
pos = [xc,yc];
index = int16(pos(2));
fprintf(['\nRow: ' num2str(index) ' has been chosen!\n']);

%-- select index from the profile
time_series = zeros(3,size(profile,2));
time_series(1,:) = profile(index-2,:);
time_series(2,:) = profile(index,:);
time_series(3,:) = profile(index+2,:);

%-- plot time series
hold on;
plot(1:size(time_series,2),repmat(index,1,size(time_series,2)),'w-','linewidth',2);

pause(2);
close(FigHandle);

end

