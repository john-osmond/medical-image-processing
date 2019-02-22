% Find Img.

function [xOff yOff] = MatchImg(ImgA, ImgB, Neg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create negative image if necessary:

if ( strcmpi(Neg,'y') == 1 )
    ImgANeg = max(reshape(ImgA,1,[]))-ImgA;
    ImgBNeg = max(reshape(ImgB,1,[]))-ImgB;
else
    ImgANeg = ImgA;
    ImgBNeg = ImgB;
end

ImgANeg(isnan(ImgANeg)) = 0;
ImgBNeg(isnan(ImgBNeg)) = 0;

ImgConv = conv2(ImgANeg,ImgBNeg);
[y,x] = find(ImgConv == max(reshape(ImgConv,1,[])));

xOff = round(x(1) - (size(ImgConv,2)+1)/2);
yOff = round(y(1) - (size(ImgConv,1)+1)/2);

%imagesc(ImgANeg)
%colormap('gray')
%pause

%imagesc(ImgBNeg)
%colormap('gray')
%pause

%imagesc(ImgConv)
%colormap('gray')
%pause

end

% imtool and printing matrix are displayed same way round.
% imtool Pixel info goes (X,Y) = (left to right, top to bottom)
% matrix address goes (y top to bottom, x left to right).
% size goes 1: y direction, 2: x direction

