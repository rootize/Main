function DrawPyramid(filehead,PyLevel)
%Convert an image to pyramid (in Cell Format) 
%Input:
%function DrawPyramid(filehead,PyLevel)
%         filehead     if input is number(1 or 2) it's the template
%                      if input is string         it's filename  
%         PyLevel      Number of Pyramid Levels   default: 4
% By ZijunWei@CMU

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Instead of using Absoluate path:
% addpath(['C:\Users\zijun\Documents\MATLAB\Main\',filehead]);
% addpath('C:\Users\zijun\Documents\MATLAB\Main\template');
% Use relative path:
if nargin<2
    PyLevel=4;
end
addpath('.\template');



%Airport&NSH:cpature2   HUNT:capture1

if isa(filehead,'double')
if filehead==1
    if ~exist('capture1.png','file')
        error('template file doesnt exist\n');
    end
    template_img=imread('capture1.png');
elseif filehead==2
    if ~exist('capture2.png','file')
        error('template file doesnt exist\n');
    end
    template_img=imread('capture2.png');
end
template_gray=rgb2gray(template_img);
template_gray=template_gray>100;
template_gray=double(template_gray);
else
    addpath(['.\',filehead]);
    template_img=imread([filehead,'_001.png']);
    template_gray=template_img;
end


%% Convert to binary then comback to double




template_gray_Py=cell(PyLevel,1);  % Use template_gray_level{i} to get every level of template pyramid!
size_tpt=cell(PyLevel,1);



%% Use Matlab native method
template_gray_Py{1}=template_gray;
size_tpt{1}=size(template_gray_Py{1});
for i=2:1:PyLevel
    template_gray_Py{i}=impyramid(template_gray_Py{i-1},'reduce');
    size_tpt{i}=size(template_gray_Py{i});
end

%% Uncomment below to see the pyramid of templates:
for i=1:1:PyLevel
h(i)=subplot(PyLevel,1,i);
imshow(template_gray_Py{i});
end
linkaxes(h);



