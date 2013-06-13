function Main_Method2(filehead,captureno,set_thres,overlap,PyLevel,method_no)
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

template_gray_Py=cell(PyLevel+1,1);  % Use template_gray_level{i} to get every level of template pyramid!
size_tpt=cell(PyLevel+1,1);


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
for i=2:1:PyLevel+1
    template_gray_Py{i}=impyramid(template_gray_Py{i-1},'reduce');
    size_tpt{i}=size(template_gray_Py{i});
end


%% New Method  (Maybe...MexOpencv)




%% Start Method 2:
timesRatio_upper=50;
timesRatio_lower=2;
idx=0;


while 1  %loop for every image in the image set  Biggest Loop!
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
    src_img_gray=rgb2gray(src_img);
    src_img_gray=double(src_img_gray);
    size_src=size(src_img_gray);
    
    %% Generate Source Image Pyramids!
    
    src_gray_Py=cell(PyLevel,1);  % Use template_gray_level{i} to get every level of template pyramid!
    size_src=cell(PyLevel,1);
    src_gray_Py{1}=src_img_gray;
    size_src{1}=size(src_gray_Py{1});
    for i=2:1:PyLevel
        src_gray_Py{i}=impyramid(src_gray_Py{i-1},'reduce');
        size_src{i}=size(src_gray_Py{i});
    end
    
    %% Right Up!
    %%
    %% Start Layer based rectangle!
    %% Finding out all rectangles when there is 
     AbsoluteOffset=zeros(1,2); % Records the upperleft corner of the  rectangle!
     relativeRect=[0 0 size(src_gray_Py{PyLevel},2) size(src_gray_Py{PyLevel},1)  0];
    for Py_src_idx=PyLevel:-1:1
        relativeRect(1,5)=0;
        temp_src=src_gray_Py{Py_src_idx};
    if Py_src_idx==1 
        x1_offset=max(AbsoluteOffset(1,1));
        x2_offset=min(AbsoluteOffset(1,1)+(relativeRect(1,3)-relativeRect(1,1)),size(temp_src,2));
        y1_offset=max(AbsoluteOffset(1,2),1);
        y2_offset=min(AbsoluteOffset(1,2)+(relativeRect(1,4)-relativeRect(1,2)),size(temp_src,1));
        relativeRect=LevelMatch(template_gray_Py,temp_src(y1_offset:y2_offset,x1_offset:x2_offset));

        relativeRect=relativeRect+[x1_offset,y1_offset,x1_offset,y1_offset,0];
    else
        x1_offset=max(AbsoluteOffset(1,1),1);
        x2_offset=min(AbsoluteOffset(1,1)+(relativeRect(1,3)-relativeRect(1,1)),size(temp_src,2));
        y1_offset=max(AbsoluteOffset(1,2),1);
        y2_offset=min(AbsoluteOffset(1,2)+(relativeRect(1,4)-relativeRect(1,2)),size(temp_src,1));
        relativeRect=LevelMatch(template_gray_Py,temp_src(y1_offset:y2_offset,x1_offset:x2_offset));
        
        AbsoluteOffset(1,1)=(AbsoluteOffset(1,1)+relativeRect(1,1))*2;
        AbsoluteOffset(1,2)=(AbsoluteOffset(1,2)+relativeRect(1,2))*2;
        relativeRect=relativeRect+[0,0,relativeRect(1,3),relativeRect(1,4),0];
%         relativeRect=relativeRect+[x1_offset,y1_offset,x1_offset,y1_offset,0])*2;
    end
    end
    rect{idx}=relativeRect;
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
    
    if(sum(o>overlap)~=0)
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
fprintf(fid,writtingformat,[(idx-1),threshC,ser_precision,ser_recall]);
fclose(fid);

end