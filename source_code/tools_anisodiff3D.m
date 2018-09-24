%%
% tools_anisodiff3D
%    perform anisotropic diffusion filtering on gray scale images
%
% Usage
%   outV = tools_anisodiff3D(V,lambda,K,n,option)
%
% Inputs:
%   V: gray scale image volume normalized between 0 and 1
%   lambda: numerical stability parameter (usually set to 1/7)
%   K: threshold to shape the g() function
%   n: number of iterations
%   option: either 1 or 2 for the choice of g()
%
% Output
%   outV - anisotropically diffused gray scale image volume, same size as V
%
% Reference:
%   P. Perona and J. Malik.
%   Scale-Space and Edge Detection Using Anisotropic Diffusion.
%   IEEE Transactions on Pattern Analysis and Machine Intelligence,
%   12(7):629-639, July 1990.

% Version
%  1.00
%
% Available from:
% https://www.mathworks.com/matlabcentral/fileexchange/14995-anisotropic-diffusion-perona-malik


function outV = tools_anisodiff3D(V,lambda,K,n,option)

V = mat2gray(V);

[x,y,z] = size(V);  % Get dimension of volume

V = mat2gray(V);    % Convert to gray scale between 0 and 1

diffV = zeros(x,y,z,n+1);   % Preallocate space
diffV(:,:,:,1) = V; % Initial condition to PDE


for i = 1:n
    for l = 1:z
        for j = 1:x
            for k = 1:y
                
                % Check for edges and perform nearest neighbor differences
                if l == 1
                    nablaU = diffV(j,k,l+1,i) - diffV(j,k,l,i);
                    nablaD = -diffV(j,k,l,i);
                    
                    if(j == 1)
                        nablaN = -diffV(j,k,l,i);
                        nablaS = diffV(j+1,k,l,i) - diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    elseif(j == x)
                        nablaN = diffV(j-1,k,l,i) - diffV(j,k,l,i);
                        nablaS = -diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    else
                        nablaN = diffV(j-1,k,l,i) - diffV(j,k,l,i);
                        nablaS = diffV(j+1,k,l,i) - diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    end
                    
                elseif l == z
                    nablaU = -diffV(j,k,l,i);
                    nablaD = diffV(j,k,l-1,i) - diffV(j,k,l,i);
                    
                    if(j == 1)
                        nablaN = -diffV(j,k,l,i);
                        nablaS = diffV(j+1,k,l,i) - diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    elseif(j == x)
                        nablaN = diffV(j-1,k,l,i) - diffV(j,k,l,i);
                        nablaS = -diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    else
                        nablaN = diffV(j-1,k,l,i) - diffV(j,k,l,i);
                        nablaS = diffV(j+1,k,l,i) - diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    end
                    
                else
                    nablaU = diffV(j,k,l+1,i) - diffV(j,k,l,i);
                    nablaD = diffV(j,k,l-1,i) - diffV(j,k,l,i);
                    
                    if(j == 1)
                        nablaN = -diffV(j,k,l,i);
                        nablaS = diffV(j+1,k,l,i) - diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    elseif(j == x)
                        nablaN = diffV(j-1,k,l,i) - diffV(j,k,l,i);
                        nablaS = -diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    else
                        nablaN = diffV(j-1,k,l,i) - diffV(j,k,l,i);
                        nablaS = diffV(j+1,k,l,i) - diffV(j,k,l,i);
                        if(k == 1)
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = -diffV(j,k,l,i);
                        elseif(k == y)
                            nablaE = -diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        else
                            nablaE = diffV(j,k+1,l,i) - diffV(j,k,l,i);
                            nablaW = diffV(j,k-1,l,i) - diffV(j,k,l,i);
                        end
                    end
                end
                
                
                % Two options for g()
                if option == 1
                    cN = exp(-(nablaN/K)^2);
                    cS = exp(-(nablaS/K)^2);
                    cE = exp(-(nablaE/K)^2);
                    cW = exp(-(nablaW/K)^2);
                    cU = exp(-(nablaU/K)^2);
                    cD = exp(-(nablaD/K)^2);
                elseif option == 2
                    cN = 1/(1+(nablaN/K)^2);
                    cS = 1/(1+(nablaS/K)^2);
                    cE = 1/(1+(nablaE/K)^2);
                    cW = 1/(1+(nablaW/K)^2);
                    cU = 1/(1+(nablaU/K)^2);
                    cD = 1/(1+(nablaD/K)^2);
                end
                
                % Compute new volume and repeat
                diffV(j,k,l,i+1) = diffV(j,k,l,i) + lambda*...
                    (cN*nablaN + cS*nablaS + cE*nablaE + cW*nablaW...
                    + cU*nablaU + cD*nablaD);
                
                
            end
        end
    end
end

% Last volume is the output
outV = diffV(:,:,:,end);

%-- convert datatype from double to uint8
outV = uint8(255*double(outV));

end

