% Script to accept a data, dark and open image and apply correction.

function [] = WriteAVI(ImgArray, File, Range, FPS)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Writing AVI...']);

Fig=figure;
AviObj = avifile(File, 'fps', FPS);

for i = 1:size(ImgArray,3)
    
    imagesc(ImgArray(:,:,i), Range);
    colormap('gray');
    axis off;
    Frame = getframe(Fig);
    AviObj = addframe(AviObj,Frame);

end

close(Fig);
AviObj = close(AviObj);

disp(['...done.']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end