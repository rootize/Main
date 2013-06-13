function [ Image_toDraw ] = DrawRect( Image_toDraw,rect_infor,confid )
%DRAWRECT Summary of this function goes here
%   Detailed explanation goes here
%   Input:
%   Image_toDraw: RGB Iamge to draw rectangles on
%   rect_infor: the information contained in the Annotaiton file and the
%   rect matrix(first 4 columns)
%   x1_col, y1_row: rectangle topleft
%   x2_col, y2_row: rectangle rightbottom
%   confid: confidence of rectangle: later will be used to determine the
%   color
global threshC;
if nargin<3
    confid=1;
end
textColor=[0,0,0];

confid_color=(confid-threshC)/(1-threshC);
x1_col=rect_infor(1,1);
x2_col=rect_infor(1,3);
y1_row=rect_infor(1,2);
y2_row=rect_infor(1,4);
if confid~=1
    Image_toDraw(y1_row-1:y2_row+1,                  x1_col-1:x1_col+1,                         1:2)=0;
    Image_toDraw(y1_row-1:y2_row+1,                  x2_col-1:x2_col+1,                         1:2)=0;
    Image_toDraw(y1_row-1:y1_row+1,                         x1_col-1:x2_col+1,                  1:2)=0;
    Image_toDraw(y2_row-1:y2_row+1,                         x1_col-1:x2_col+1,                  1:2)=0;
    Image_toDraw(y1_row-1:y2_row+1,                  x1_col-1:x1_col+1,                         3)=255;
    Image_toDraw(y1_row-1:y2_row+1,                  x2_col-1:x2_col+1,                         3)=255;
    Image_toDraw(y1_row-1:y1_row+1,                         x1_col-1:x2_col+1,                  3)=255;
    Image_toDraw(y2_row-1:y2_row+1,                         x1_col-1:x2_col+1,                  3)=255;
    
else
    
    Image_toDraw(y1_row-1:y2_row+1,                  x1_col-1:x1_col+1,                         1)=0;
    Image_toDraw(y1_row-1:y2_row+1,                  x2_col-1:x2_col+1,                         1)=0;
    Image_toDraw(y1_row-1:y1_row+1,                         x1_col-1:x2_col+1,                  1)=0;
    Image_toDraw(y2_row-1:y2_row+1,                         x1_col-1:x2_col+1,                  1)=0;
    
    Image_toDraw(y1_row-1:y2_row+1,                  x1_col-1:x1_col+1,                         3)=0;
    Image_toDraw(y1_row-1:y2_row+1,                  x2_col-1:x2_col+1,                         3)=0;
    Image_toDraw(y1_row-1:y1_row+1,                         x1_col-1:x2_col+1,                  3)=0;
    Image_toDraw(y2_row-1:y2_row+1,                         x1_col-1:x2_col+1,                  3)=0;
    Image_toDraw(y1_row-1:y2_row+1,                  x1_col-1:x1_col+1,                         2)=255;
    Image_toDraw(y1_row-1:y2_row+1,                  x2_col-1:x2_col+1,                         2)=255;
    Image_toDraw(y1_row-1:y1_row+1,                         x1_col-1:x2_col+1,                  2)=255;
    Image_toDraw(y2_row-1:y2_row+1,                         x1_col-1:x2_col+1,                  2)=255;
    %Draw text on the image
%     textLocation=[x1_col,y1_row];
%     textInserter=vision.TextInserter(num2str(confid,'%04f'),'Color',textColor,'Location',textLocation);
%     Image_toDraw=step(textInserter,Image_toDraw);
end
end

