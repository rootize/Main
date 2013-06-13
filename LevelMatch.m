function [ optimal_rect ] = LevelMatch( tmp_Pyramid,src )
%LEVELMATCH Summary of this function goes here
%   Detailed explanation goes here
%   function [ optimal_rect ] = LevelMatch( tmp_Pyramid,src )
%   the optimal_rect at this layer (Only one because if there are two that...
%                                   will be way too slow)
%                                   The first and second are also the
%                                   offset
%   tmp_Pyramid:   the template image pyramid
%   src:            source image

PyLevel=size(tmp_Pyramid,1);
if PyLevel==0
    error('Something wrong with template pyramid, it does not exist!');
end
[src_y_row,src_x_col]=size(src);
boundbox=[];
for idx=1:1:PyLevel
    % Several cases that we don't have to do the matching
    Layered_tmp=tmp_Pyramid{idx};
    [Layered_tmp_y,Layered_tmp_x]=size(Layered_tmp);
    if src_y_row/Layered_tmp_y>80 || src_x_col/Layered_tmp_x>80
        continue;
    end
    if src_y_row/Layered_tmp_y<1|| src_x_col/Layered_tmp_x<1
        continue;
    end
    [~,result_mat,~]=template_matching(Layered_tmp,src);
    [max_result,idxMax]=max(abs(result_mat(:)));
    [ypeak,xpeak]=ind2sub(size(result_mat),idxMax(1));
    x1=max(1,xpeak-round(Layered_tmp_x*0.5));
    y1=max(1,ypeak-round(Layered_tmp_y*0.5));
    x2=max(1,xpeak+round(Layered_tmp_x*0.5));
    y2=max(1,ypeak+round(Layered_tmp_y*0.5));
    Layerd_boundbox=[x1,y1,x2,y2,max_result];
    boundbox=[boundbox;Layerd_boundbox];
end
 
%% Find out the rect with the hight score
if size(boundbox,1)~=0
sort_by=boundbox(:,5);
[~,I]=sort(sort_by,'descend');
optimal_rect=boundbox(I(1),:);
else
    optimal_rect=[0,0,size(src,2),size(src,1),0];

end

