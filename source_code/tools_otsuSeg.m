function [level, em] = tools_otsuSeg(I,mask)
%GRAYTHRESH Global image threshold using Otsu's method.
%
%   [LEVEL, EM] = tools_otsuSeg(I,mask) returns effectiveness metric, EM, as the
%   second output argument. It indicates the effectiveness of thresholding
%   of the input image within the mask and it is in the range [0, 1]. The lower bound is
%   attainable only by images having a single gray level, and the upper
%   bound is attainable only by two-valued images.
%
%   Class Support
%   -------------
%   The input image I can be uint8, uint16, int16, single, or double, and it
%   must be nonsparse.  LEVEL and EM are double scalars. 
%

%   Copyright 1993-2013 The MathWorks, Inc.

% Reference:
% N. Otsu, "A Threshold Selection Method from Gray-Level Histograms,"
% IEEE Transactions on Systems, Man, and Cybernetics, vol. 9, no. 1,
% pp. 62-66, 1979.

% One input argument required.
narginchk(1,2);
validateattributes(I,{'uint8','uint16','double','single','int16'},{'nonsparse'}, ...
              mfilename,'I',1);

if ~isempty(I)
  % Convert all N-D arrays into a single column.  Convert to uint8 for
  % fastest histogram computation.
  I = im2uint8(I(:));
  I(~mask) = [];
  num_bins = 256;
  counts = imhist(I,num_bins);
  
  % Variables names are chosen to be similar to the formulas in
  % the Otsu paper.
  p = counts / sum(counts);
  omega = cumsum(p);
  mu = cumsum(p .* (1:num_bins)');
  mu_t = mu(end);
  
  sigma_b_squared = (mu_t * omega - mu).^2 ./ (omega .* (1 - omega));

  % Find the location of the maximum value of sigma_b_squared.
  % The maximum may extend over several bins, so average together the
  % locations.  If maxval is NaN, meaning that sigma_b_squared is all NaN,
  % then return 0.
  maxval = max(sigma_b_squared);
  isfinite_maxval = isfinite(maxval);
  if isfinite_maxval
    idx = mean(find(sigma_b_squared == maxval));
    % Normalize the threshold to the range [0, 1].
    level = (idx - 1) / (num_bins - 1);
  else
    level = 0.0;
  end
else
  level = 0.0;
  isfinite_maxval = false;
end

% compute the effectiveness metric
if nargout > 1
  if isfinite_maxval
    em = maxval/(sum(p.*((1:num_bins).^2)') - mu_t^2);
  else
    em = 0;
  end
end


