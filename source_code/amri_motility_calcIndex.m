function [antral_motility] = amri_motility_calcIndex(ts,MRI_resolution)

%{

##amri_motility_calcIndex:
Compute antral contraction frequency/amplitude/velocity from selected
location

##Environment requirement:  
This code was developed under Red Hat Enterprise Linux environment.

##Usage:
[antral_motility] = amri_sparc_motility_analysis(Time_series,MRI_resolution);

##Inputs:
Time series: time_series: 3 contraction time series on antral axis
                    (1 at selected location, 2 at above/below the location with 2 pixels spacing)
MRI_resolution: Acquisition spatial and temporal resolution

##Outputs:
antral_motility: antral contraction frequency/amplitude/velocity

##DISCLAIMER AND CONDITIONS FOR USE:
This software is distributed under the terms of the GNU General Public
License v3, dated 2007/06/29 (see http://www.gnu.org/licenses/gpl.html).
Use of this software is at the user's OWN RISK. Functionality is not
guaranteed by creator nor modifier(s), if any. This software may be freely
copied and distributed. The original header MUST stay part of the file and
modifications MUST be reported in the 'HISTORY'-section,
including the modification date and the name of the modifier.

##CREATED:
Dec. 06, 2017
Kun-Han Lu
Electrical and Computer Engineering
Purdue University

##History:
1.00 - 12/06/2017 - KHLU - create the original file

##Version:
1.00

%}

data = ts(2,:); % take the contraction time series

%-- compute contraction frequency
[data_filt]=tools_filterfft(data,1/MRI_resolution.samp_rate, 0.01,0.2,0); % band-pass filter: [0.01 0.2] Hz
data_filt = data_filt - repmat(mean(data_filt),1,length(data_filt)); % demean
[PSD,fs] = tools_psd(data_filt',1/MRI_resolution.samp_rate);
[~,index] = max(PSD);
antral_motility.frequency = 60*fs(index); % contraction frequency (cpm)

%-- peak/valley detection
[maxtab, mintab] = tools_peakdet(ts(2,:),0.5);

%-- check peak detection result
flag_plot = 0;
if flag_plot > 0
    plot(ts(2,:),'k-');
    hold on;
    scatter(mintab(:,1),mintab(:,2),'r*');
    scatter(maxtab(:,1),maxtab(:,2),'bo');
    hold off;
end

%-- make it the same length
if size(mintab,1) < size(maxtab,1)
    maxtab = maxtab(1:size(mintab,1),:);
else
    mintab = mintab(1:size(maxtab,1),:);
end

%-- compute contraction amplitude
%-- percentage difference between distension & contraction
antral_motility.amplitude = 100*(sum(maxtab(:,2))-sum(mintab(:,2)))/sum(maxtab(:,2)); 

%-- compute contraction velocity
PhDiff = tools_phdiffmeasure(ts(3,:),ts(1,:));
PhDiff = abs(PhDiff*180/pi);

if PhDiff > 180
    PhDiff = 360 - PhDiff; % out of phase
end

%-- save velocity
time = (PhDiff/360)*60/antral_motility.frequency; 
antral_motility.velocity = MRI_resolution.spatial(1)*5/time; % 2 time series are 5 voxels apart 

