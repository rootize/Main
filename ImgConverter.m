% Convert image sequence to video
workingDir='C:\Users\zijun\Documents\MATLAB\Main\T0.85';
imageNames=dir(fullfile(workingDir,'*.png'));
imageNames={imageNames.name}';
%outputvideo=VideoWriter(fullfile())
%imageNmae

outputVideo = VideoWriter(fullfile('C:\Users\zijun\Documents\MATLAB\','video.avi'));
outputVideo.FrameRate = 10;
open(outputVideo);

for ii = 1:length(imageNames)
    img = imread(fullfile(workingDir,imageNames{ii}));

    writeVideo(outputVideo,img);
end
close(outputVideo);