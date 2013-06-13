function [ img_pyramid ] = buildPyramid( img,PyLevel )
%BUILDPYRAMID Summary of this function goes here
%   Detailed explanation goes here
%   Input:
%   img:     input image
%   PyLevel: level of Pyramids needed.  default :4

if nargin<2
    PyLevel=4;
end
img_pyramid=cell(PyLevel,1);
img_pyramid{1}=img;

for i=2:1:PyLevel
    img_pyramid{i}=impyramid(img_pyramid{i-1},'reduce');
    
end

end

