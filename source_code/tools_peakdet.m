function [maxtab, mintab]=tools_peakdet(v, delta, x)
%{

##tools_peakdet:
Detect peaks in a vector

##Environment requirement:
This code was developed under Red Hat Enterprise Linux environment.

##Usage:
[maxtab, mintab]=tools_peakdet(v, delta, x)

##Inputs:
v: vectorized data
delta: threshold
x: indices in maxtab and mintab are replaced with value "x"

##Output:
MAXTAB and MINTAB consists of two columns. 
Column 1 contains indices in V, and column 2 the found values.

##Available from:
http://www.billauer.co.il/peakdet.html

##History:
1.00 - Eli Billauer 

##Version:
1.00

%}

maxtab = [];
mintab = [];

v = v(:); % Just in case this wasn't a proper vector

if nargin < 3
  x = (1:length(v))';
else 
  x = x(:);
  if length(v)~= length(x)
    error('Input vectors v and x must have same length');
  end
end
  
if (length(delta(:)))>1
  error('Input argument DELTA must be a scalar');
end

if delta <= 0
  error('Input argument DELTA must be positive');
end

mn = Inf; mx = -Inf;
mnpos = NaN; mxpos = NaN;

lookformax = 1;

for i=1:length(v)
  this = v(i);
  if this > mx, mx = this; mxpos = x(i); end
  if this < mn, mn = this; mnpos = x(i); end
  
  if lookformax
    if this < mx-delta
      maxtab = [maxtab ; mxpos mx];
      mn = this; mnpos = x(i);
      lookformax = 0;
    end  
  else
    if this > mn+delta
      mintab = [mintab ; mnpos mn];
      mx = this; mxpos = x(i);
      lookformax = 1;
    end
  end
end
