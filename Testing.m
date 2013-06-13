% % clear,
% % clc
% % template = .2*ones(11); % Make light gray plus on dark gray background
% % template(6,3:9) = .6;   
% % template(3:9,6) = .6;
% % BW = template > 0.5;      % Make white plus on black background
% % figure, imshow(BW), figure, imshow(template)
% % % Make new image that offsets the template
% % offsetTemplate = .2*ones(21); 
% % offset = [3 5];  % Shift by 3 rows, 5 columns
% % offsetTemplate( (1:size(template,1))+offset(1),...
% %                 (1:size(template,2))+offset(2) ) = template;
% % %figure, imshow(offsetTemplate)
% %     
% % % Cross-correlate BW and offsetTemplate to recover offset  
% % cc = normxcorr2(BW,offsetTemplate); 
% % [max_cc, imax] = max(abs(cc(:)));
% % [ypeak, xpeak] = ind2sub(size(cc),imax(1));
% % corr_offset = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ];
% % isequal(corr_offset,offset); % 1 means offset was recovered
% % 
% % offsetTemplate=DrawRect(offsetTemplate,[corr_offset(2)+1,corr_offset(1)+1,xpeak+1,ypeak+1],1);
% % figure, imshow(offsetTemplate)
% % 
% % 
% % % template1=imread('capture1.png');
% % % template1=rgb2gray(template1);
% % % result_mat=normxcorr2(template1,[template1;template1]);
% % %             [max_result,idxMax]=max(abs(result_mat(:)));
% % %             [ypeak,xpeak]=ind2sub(size(result_mat),idxMax(1));
% % %             %[rectx,recty] = [ (ypeak-size(template,1)) (xpeak-size(template,2)) ]
% % %             rectx=xpeak-size(template1,    2);
% % %             recty=ypeak-size(template1,    1);


 %% Test Offset
 clear;
 clc;
filehead='Hunt_Positive_Sweep';
file_suffix='.png';
addpath(['C:\Users\zijun\Documents\MATLAB\Main\',filehead]);
addpath('C:\Users\zijun\Documents\MATLAB\Main\template');
template_img=imread('capture2.png');
template_gray=rgb2gray(template_img);
template_gray=template_gray>100;
template_gray=double(template_gray);
template_gray=template_gray*255;

img=imread([filehead,'_001',file_suffix]);
img=rgb2gray(img);

img((1+20):(size(template_gray,1)+20),(1+20):(size(template_gray,2)+20))=template_gray;

figure,imshow(img);

result_mat=normxcorr2(template_gray,img);

[max_result,idxMax]=max(abs(result_mat(:)));
[ypeak,xpeak]=ind2sub(size(result_mat),idxMax(1));
offset=[ypeak-size(template_gray,1),xpeak-size(template_gray,2)];

ypeak=ypeak-size(template_gray,1);
xpeak=xpeak-size(template_gray,2);

% [~,result_mat,~]=template_matching(template_gray,img);
%  [max_result,idxMax]=max(abs(result_mat(:)));
%  [ypeak,xpeak]=ind2sub(size(result_mat),idxMax(1));
% % offset=[ypeak-size(template_gray,1),xpeak-size(template_gray,2)];
% Insert Rectangle
shapeInserter = vision.ShapeInserter;
rectangle = int32([xpeak ypeak size(template_gray,2) size(template_gray,1) ]);
img = step(shapeInserter, img, rectangle);
imshow(img); 

%% Test Precision-Recall Function!
%  Area=(Annotation(:,3)-Annotation(:,1)).*(Annotation(:,4)-Annotation(:,2));
%  all_positives=zeros(idx-1,0);
%  precision=zeros(idx-1,0);
%  recall=zeros(idx-1,0);
%  %i=1; % erase when really doing
%  for i=1:1:idx-1
%     temp_rect=rect{i};
%     %% Calculate the precision
%     all_positives(i,1)=size(temp_rect,1);% (rectangles in each image)
%     Ano_perimg=Annotation(i,1:4);
%     Ano_vecMat=repmat(Ano_perimg,[all_positives(i,1),1]); % every row is the annotaiton data (4 coloums)
%     area_anno_mat=(Ano_vecMat(:,3)-Ano_vecMat(:,1)).*(Ano_vecMat(:,4)-Ano_vecMat(:,2));
%     x1_vec_inter=max(temp_rect(:,1),Ano_vecMat(:,1));
%     y1_vec_inter=max(temp_rect(:,2),Ano_vecMat(:,2));
%     x2_vec_inter=min(temp_rect(:,3),Ano_vecMat(:,3));
%     y2_vec_inter=min(temp_rect(:,4),Ano_vecMat(:,4));
%     
%     
%     x1_vec_intra=min(temp_rect(:,1),Ano_vecMat(:,1));
%     y1_vec_intra=min(temp_rect(:,2),Ano_vecMat(:,2));
%     x2_vec_intra=max(temp_rect(:,3),Ano_vecMat(:,3));
%     y2_vec_intra=max(temp_rect(:,4),Ano_vecMat(:,4));
%    % overlap_rects=[x1_vec,y1_vec,x2_vec,y2_vec];
%     %overlap_area=(overlap_rects(:,3)-overlap_rects(:,1)).*(overlap_rects(:,4)-overlap_rects(:,2));
%     w_inter=x2_vec_inter-x1_vec_inter;
%     h_inter=y2_vec_inter-y1_vec_inter;
%     w_inter(w_inter<0)=0;
%     h_inter(h_inter<0)=0;
%     inter=sum(w_inter.*h_inter,2);
%     
%     
%     w_intra=x2_vec_intra-x1_vec_intra;
%     h_intra=y2_vec_intra-y1_vec_intra;
%     w_intra(w_intra<0)=0;
%     h_intra(h_intra<0)=0;
%     intra=sum(w_intra.*h_intra,2);
%     o=inter./intra;  % should be overlap and sum!
%     
%     if(sum(o>0.5)~=0)
%         num_tp(i)=1;
%     else num_tp(i)=0;
%     end
%     precision(i,1)=num_tp(i)/all_positives(i,1);
%     
%     %% do Recall!
%     recall(i,1)=sum(o)/Area(i);
%  end
% % 
% % 
% % 
% % %% Calculate the results and store images.: show later...
% % 
% save([filehead,''],'precision','recall');
% 

%% Test on Template Matching

% filehead='Hunt_Positive_Sweep';
% file_suffix='.png';
% addpath(['C:\Users\zijun\Documents\MATLAB\Main\',filehead]);
% addpath('C:\Users\zijun\Documents\MATLAB\Main\template');
% template_img=imread('capture2.png');
% template_gray=rgb2gray(template_img);
% template_gray=template_gray>100;
% template_gray=double(template_gray);
% %template_gray=template_gray*255;
% 
% img=imread([filehead,'_001',file_suffix]);
% img=rgb2gray(img);
% %img(1:size(template_gray,1),1:size(template_gray,2))=template_gray;
% 
% [~,result_mat,~]=template_matching(template_gray,img);
% % result_mat=normxcorr2(template_gray,img);
% % 
%  [max_result,idxMax]=max(abs(result_mat(:)));
%  [ypeak,xpeak]=ind2sub(size(result_mat),idxMax(1));
% % offset=[ypeak-size(template_gray,1),xpeak-size(template_gray,2)];