workingDir='C:\Users\zijun\Documents\MATLAB\Airport_Hard_IMAGE';
mkdir(workingDir);

shuttleVideo=VideoReader('Airport_Positive_Hard.mp4');

for ii = 1:shuttleVideo.NumberOfFrames
    img = read(shuttleVideo,ii);

    % Write out to a JPEG file (img1.jpg, img2.jpg, etc.)
    imwrite(img,fullfile(workingDir,sprintf('NSH_Positive_%03d.png',ii)));
end