function Main(filehead,captureno,set_thres,overlap,PyLevel,method_no)
%Input:
% Main(filehead,captureno,set_thres,overlap,PyLevel,method_no)
%
%
% filehead: folder&writefile&image file header string
% captureno: template number:(important) default     1
%            Airport&NSH:cpature 2   HUNT:capture    1
% set_thres: threshold                   default     0.8
% overlap: define region of overlap      default:    0.5
% PyLevel: Levels of Pyramid!            default     4
% method_no: choose number of method:    default     1
%            1. Naive method
%            2. Coarse to fine
% By Zijun Wei@CMU
if nargin<2
    captureno=1;
end
if nargin<3
    set_thres=0.8;
end
if nargin<4
    PyLevel=4;
end

if nargin<5
    overlap=0.5;
end

if nargin<6 
   method_no=1; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Resize the image (both the template and the source image)
halfSize=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PyLevel=4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global threshC
threshC=set_thres;
file_suffix='.png';
annotation_suffix='.txt';

%Instead of using Absoluate path:
% addpath(['C:\Users\zijun\Documents\MATLAB\Main\',filehead]);
% addpath('C:\Users\zijun\Documents\MATLAB\Main\template');
% Use relative path:
addpath(['.\',filehead]);
addpath('.\template');

%Airport&NSH:cpature2   HUNT:capture1

if captureno==1
    if ~exist('capture1.png','file')
        error('template file doesnt exist\n');
    end
    template_img=imread('capture1.png');
elseif captureno==2
    if ~exist('capture2.png','file')
        error('template file doesnt exist\n');
    end
    template_img=imread('capture2.png');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Try to resize the image!
template_img=imresize(template_img,halfSize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Convert to binary then comback to double
template_gray=rgb2gray(template_img);
template_gray=template_gray>100;
template_gray=double(template_gray);


%% Set the threshold! && Overlap

strthreshC=num2str(threshC);
%savedir=['C:\Users\zijun\Documents\MATLAB\Main\',['T',strthreshC]];
savedir=['.\',['T',strthreshC]];
if exist(savedir,'dir')==0
    mkdir(savedir);
end


%% Template Image Pyramid Generation!

template_gray_Py=cell(PyLevel,1);  % Use template_gray_level{i} to get every level of template pyramid!
size_tpt=cell(PyLevel,1);


%% Old Method(Just using REsize to do the image Pyramid)
% template_gray_Py{1}=imresize(template_gray,[size_temp_row,NaN],'bicubic');
% size_tpt{1}=size(template_gray_Py{1});
% check=zeros(5,2);
% check(1,:)=size_tpt{1};
% for i=2:1:PyLevel
%     template_gray_Py{i}=imresize(template_gray_Py{i-1},ceil(size_tpt{i-1}/PyScale));
%     size_tpt{i}=size(template_gray_Py{i});
%     check(i,:)=ceil(size_tpt{i-1}/PyScale);% Check if it's the same with size_tpt{i}
% end

%% Use Matlab native method
template_gray_Py{1}=template_gray;
size_tpt{1}=size(template_gray_Py{1});
for i=2:1:PyLevel
    template_gray_Py{i}=impyramid(template_gray_Py{i-1},'reduce');
    size_tpt{i}=size(template_gray_Py{i});
end


%% New Method  (Maybe...MexOpencv)

%% Show Results of Image pyramid!
% %Uncomment below to see the pyramid of templates:
% %subplot(3,2,1:2)
% figure,
% imshow(template_gray_Py{1});
% %subplot(3,2,3)
% figure,
% imshow(template_gray_Py{2});
% %subplot(3,2,4)
% figure,
% imshow(template_gray_Py{3});
% %subplot(3,2,5)
% figure,
% imshow(template_gray_Py{4});
% %subplot(3,2,6)
% figure,
% imshow(template_gray_Py{5});




idx=0;
while 1  %loop for every image in the image set
    %% Looping: finding images
    idx=idx+1;
    idx_toString=num2str(idx,'%03i');
    img_name=[filehead,'_',idx_toString,file_suffix];
    if exist(img_name,'file')==0 % test if the image exists  !!!!!!!! Delete idx>3 when running!
        if idx==1
           error('Image File does not exists, check!\n'); 
        else
        break;
        end
    end
    %% convert to gray scale
    src_img=imread(img_name);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    src_img=imresize(src_img,halfSize);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    src_img_gray=rgb2gray(src_img);
    src_img_gray=double(src_img_gray);
    sizesrc=size(src_img_gray);
    boudbox=[];
    rect{idx}=[];
    %% Finding out all rectangles
    Py_threshold=threshC;
    for Py_idx=1:1:PyLevel
        if Py_idx~=1
      %  Py_threshold=0.01+Py_threshold;
        end
        % result_mat=normxcorr2(template_gray_Py{Py_idx},src_img_gray);
        % imwrite(result_mat,['result_mat_',idx_toString,num2str(Py_idx,'%03i'),file_suffix]);
        [~,result_mat,~]=template_matching(template_gray_Py{Py_idx},src_img_gray);
        box_idx=1;
        boundbox_candi_branch=[];
        while 1
            [max_result,idxMax]=max(abs(result_mat(:)));
            [ypeak,xpeak]=ind2sub(size(result_mat),idxMax(1));
            %             rectx=xpeak-size_tpt{i}(2);
            %             recty=ypeak-size_tpt{i}(1);
            rectx=xpeak;
            recty=ypeak;
            if(max_result>Py_threshold)
                % Based on the sequence x1,y1,x2,y2:
                
                
                                        x1=max(1,rectx-round(size_tpt{Py_idx}(2)*0.5));
                                        y1=max(1,recty-round(size_tpt{Py_idx}(1)*0.5));
                                        x2=max(1,rectx+round(size_tpt{Py_idx}(2)*0.5));
                                        y2=max(1,recty+round(size_tpt{Py_idx}(1)*0.5));
                
                %                 x1=max(1,rectx);
                %                 y1=max(1,recty);
                %                 x2=max(1,rectx+round(size_tpt{Py_idx}(2))+1);
                %                 y2=max(1,recty+round(size_tpt{Py_idx}(1))+1);
%                 x1=max(1,rectx);
%                 y1=max(1,recty);
%                 x2=rectx+round(size_tpt{Py_idx}(2)*0.5)+1;
%                 y2=recty+round(size_tpt{Py_idx}(1)*0.5)+1;
                boundbox_candi_branch(box_idx,:)=[x1/halfSize,y1/halfSize,x2/halfSize,y2/halfSize,max_result];
                box_idx=box_idx+1;
                %set the region to be zero
                %result_mat(ypeak:ypeak+size_tpt{Py_idx}(1),xpeak:xpeak+size_tpt{Py_idx}(2))=0;
                result_mat(ypeak,xpeak)=0;
            else
                break;
            end
        end
        boudbox=[boudbox;boundbox_candi_branch];
        
        
    end
    pick=new_nms_boxes(boudbox,overlap); % Use my "own" bounding box nms
    %[~,pick]=nms_boxes(boudbox,overlap);
    if size(pick,1)
        rect{idx}=boudbox(pick,:);

    end
end




for idx_draw=1:1:idx-1
    %% Draw the results:
    % Step1: Load the annotations:
    Annotation=load([filehead,annotation_suffix]);
    % Step2: Read iamges
    img_toDraw=imread([filehead,'_',num2str(idx_draw,'%03i'),file_suffix]);
    
    img_toDraw=DrawRect(img_toDraw,Annotation(idx_draw,:),1);
    temp_rect=rect{idx_draw};
    for idx_rect_perimg=1:1:size(temp_rect,1)
        
        img_toDraw=DrawRect(img_toDraw,temp_rect(idx_rect_perimg,1:4),temp_rect(idx_rect_perimg,5));
    end
    
    
    %% Calculate the precision recall data!
    % Annotation_per_imge=Annotation(idx_draw,:);
    
    %% Write image to a new image file
    fullfilename=fullfile(savedir,[filehead,'_',num2str(idx_draw,'%03i'),'_NEW_Drift',file_suffix]);
    imwrite(img_toDraw,fullfilename,'png');
    
    
end

%%  Precision-Recall Function!
Area=(Annotation(:,3)-Annotation(:,1)).*(Annotation(:,4)-Annotation(:,2));
all_positives=zeros(idx-1,0);
precision=zeros(idx-1,0);
recall=zeros(idx-1,0);
%i=1; % erase when really doing
for i=1:1:idx-1
    temp_rect=rect{i};
    if size(temp_rect,1)==0
        precision(i,1)=0;
        recall(i,1)=0;
        all_positives(i,1)=0;
        continue;
    end
    %% Calculate the precision
    all_positives(i,1)=size(temp_rect,1);% (rectangles in each image)
    Ano_perimg=Annotation(i,1:4);
    Ano_vecMat=repmat(Ano_perimg,[all_positives(i,1),1]); % every row is the annotaiton data (4 coloums)
    area_anno_mat=(Ano_vecMat(:,3)-Ano_vecMat(:,1)).*(Ano_vecMat(:,4)-Ano_vecMat(:,2));
    x1_vec_inter=max(temp_rect(:,1),Ano_vecMat(:,1));
    y1_vec_inter=max(temp_rect(:,2),Ano_vecMat(:,2));
    x2_vec_inter=min(temp_rect(:,3),Ano_vecMat(:,3));
    y2_vec_inter=min(temp_rect(:,4),Ano_vecMat(:,4));
    
    
    x1_vec_intra=min(temp_rect(:,1),Ano_vecMat(:,1));
    y1_vec_intra=min(temp_rect(:,2),Ano_vecMat(:,2));
    x2_vec_intra=max(temp_rect(:,3),Ano_vecMat(:,3));
    y2_vec_intra=max(temp_rect(:,4),Ano_vecMat(:,4));
    % overlap_rects=[x1_vec,y1_vec,x2_vec,y2_vec];
    % overlap_area=(overlap_rects(:,3)-overlap_rects(:,1)).*(overlap_rects(:,4)-overlap_rects(:,2));
    w_inter=x2_vec_inter-x1_vec_inter;
    h_inter=y2_vec_inter-y1_vec_inter;
    w_inter(w_inter<0)=0;
    h_inter(h_inter<0)=0;
    inter=sum(w_inter.*h_inter,2);
    
    
    w_intra=x2_vec_intra-x1_vec_intra;
    h_intra=y2_vec_intra-y1_vec_intra;
    w_intra(w_intra<0)=0;
    h_intra(h_intra<0)=0;
    intra=sum(w_intra.*h_intra,2);
    o=inter./intra;  % should be overlap and sum!
    
    if(sum(o>0.5)~=0)
        num_tp(i)=1;
    else num_tp(i)=0;
    end
    precision(i,1)=num_tp(i)/all_positives(i,1);
    
    %% do Recall!
    recall(i,1)=max(inter)/Area(i);
    if recall(i,1)>1
        recall(i,1)=1;
    end
end
ser_precision=sum(precision)/(idx-1);
ser_recall=sum(recall)/(idx-1);

% %
% %
% %
% % %% Calculate the results and store images.: show later...
% %
% save([filehead,''],'precision','recall');
writtingformat='%02d %04f %04f %04f \n';
fid=fopen([filehead,'precision_recall.txt'],'a');
%fprintf(fid,[filehead,'  ']);
fprintf(fid,writtingformat,[(idx-1),threshC,ser_precision,ser_recall]);
fclose(fid);

 end