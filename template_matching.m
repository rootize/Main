


function [I_SSD,I_NCC,Idata]=template_matching(T,I,IdataIn)
% TEMPLATE_MATCHING is a cpu efficient function which calculates matching 
% score images between template and an (color) 2D or 3D image.
% It calculates:
% - The sum of squared difference (SSD Block Matching), robust template
%   matching.
% - The normalized cross correlation (NCC), independent of illumination,
%   only dependent on texture
% The user can combine the two images, to get template matching which
% works robust with his application. 
% Both measures are implemented using FFT based correlation.
%
%   [I_SSD,I_NCC,Idata]=template_matching(T,I,Idata)
%
% inputs,
%   T : Image Template, can be grayscale or color 2D or 3D.
%   I : Color image, can be grayscale or color 2D or 3D.
%  (optional)
%   Idata : Storage of temporary variables from the image I, to allow 
%           faster search for multiple templates in the same image.
%
% outputs,
%   I_SSD: The sum of squared difference 2D/3D image. The SSD sign is
%          reversed and normalized to range [0 1] 
%   I_NCC: The normalized cross correlation 2D/3D image. The values
%          range between 0 and 1
%   Idata : Storage of temporary variables from the image I, to allow 
%           faster search for multiple templates in the same image.
%
% Example 2D,
%   % Find maximum response
%    I = im2double(imread('lena.jpg'));
%   % Template of Eye Lena
%    T=I(124:140,124:140,:);
%   % Calculate SSD and NCC between Template and Image
%    [I_SSD,I_NCC]=template_matching(T,I);
%   % Find maximum correspondence in I_SDD image
%    [x,y]=find(I_SSD==max(I_SSD(:)));
%   % Show result
%    figure, 
%    subplot(2,2,1), imshow(I); hold on; plot(y,x,'r*'); title('Result')
%    subplot(2,2,2), imshow(T); title('The eye template');
%    subplot(2,2,3), imshow(I_SSD); title('SSD Matching');
%    subplot(2,2,4), imshow(I_NCC); title('Normalized-CC');
%


if(nargin<3), IdataIn=[]; end

% Convert images to double
T=double(T); I=double(I);


    [I_SSD,I_NCC,Idata]=template_matching_gray(T,I,IdataIn);

function [I_SSD,I_NCC,Idata]=template_matching_gray(T,I,IdataIn)
% Calculate correlation output size  = input size + padding template
T_size = size(T); I_size = size(I);
outsize = I_size + T_size-1;

% calculate correlation in frequency domain
if(length(T_size)==2)
    FT = fft2(rot90(T,2),outsize(1),outsize(2));
    if(isempty(IdataIn))
        Idata.FI = fft2(I,outsize(1),outsize(2));
    else
        Idata.FI=IdataIn.FI;
    end
    Icorr = real(ifft2(Idata.FI.* FT));
else
    FT = fftn(rot90_3D(T),outsize);
    FI = fftn(I,outsize);
    Icorr = real(ifftn(FI.* FT));
end

% Calculate Local Quadratic sum of Image and Template
if(isempty(IdataIn))
    Idata.LocalQSumI= local_sum(I.*I,T_size);
else
    Idata.LocalQSumI=IdataIn.LocalQSumI;
end

QSumT = sum(T(:).^2);

% SSD between template and image
I_SSD=Idata.LocalQSumI+QSumT-2*Icorr;

% Normalize to range 0..1
I_SSD=I_SSD-min(I_SSD(:)); 
I_SSD=1-(I_SSD./max(I_SSD(:)));

% Remove padding
I_SSD=unpadarray(I_SSD,size(I));

if (nargout>1)
    % Normalized cross correlation STD
    if(isempty(IdataIn))
        Idata.LocalSumI= local_sum(I,T_size);
    else
        Idata.LocalSumI=IdataIn.LocalSumI;
    end
    
    % Standard deviation
    if(isempty(IdataIn))
        Idata.stdI=sqrt(max(Idata.LocalQSumI-(Idata.LocalSumI.^2)/numel(T),0) );
    else
        Idata.stdI=IdataIn.stdI;
    end
    stdT=sqrt(numel(T)-1)*std(T(:));
    % Mean compensation
    meanIT=Idata.LocalSumI*sum(T (:))/numel(T);
    I_NCC= 0.5+(Icorr-meanIT)./ (2*stdT*max(Idata.stdI,stdT/1e5));

    % Remove padding
    I_NCC=unpadarray(I_NCC,size(I));
end

function T=rot90_3D(T)
T=flipdim(flipdim(flipdim(T,1),2),3);

function B=unpadarray(A,Bsize)
Bstart=ceil((size(A)-Bsize)/2)+1;
Bend=Bstart+Bsize-1;
if(ndims(A)==2)
    B=A(Bstart(1):Bend(1),Bstart(2):Bend(2));
elseif(ndims(A)==3)
    B=A(Bstart(1):Bend(1),Bstart(2):Bend(2),Bstart(3):Bend(3));
end
    
function local_sum_I= local_sum(I,T_size)
% Add padding to the image
B = padarray(I,T_size);

% Calculate for each pixel the sum of the region around it,
% with the region the size of the template.
if(length(T_size)==2)
    % 2D localsum
    s = cumsum(B,1);
    c = s(1+T_size(1):end-1,:)-s(1:end-T_size(1)-1,:);
    s = cumsum(c,2);
    local_sum_I= s(:,1+T_size(2):end-1)-s(:,1:end-T_size(2)-1);
else
    % 3D Localsum
    s = cumsum(B,1);
    c = s(1+T_size(1):end-1,:,:)-s(1:end-T_size(1)-1,:,:);
    s = cumsum(c,2);
    c = s(:,1+T_size(2):end-1,:)-s(:,1:end-T_size(2)-1,:);
    s = cumsum(c,3);
    local_sum_I  = s(:,:,1+T_size(3):end-1)-s(:,:,1:end-T_size(3)-1);
end
