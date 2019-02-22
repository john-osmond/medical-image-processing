% Find Img.

function [xOut yOut] = CoLimit(Img, x, y)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Create negative image if necessary:

if (x < 1); x = 1; end
if (x > size()); x = 1; end
if (y < 1); y = 1; end

if ( strcmpi(Neg,'y') == 1 )
    ImgANeg = max(reshape(ImgA,1,[]))-ImgA;
    ImgBNeg = max(reshape(ImgB,1,[]))-ImgB;
else
    ImgANeg = ImgA;
    ImgBNeg = ImgB;
end


end

% imtool and printing matrix are displayed same way round.
% imtool Pixel info goes (X,Y) = (left to right, top to bottom)
% matrix address goes (y top to bottom, x left to right).
% size goes 1: y direction, 2: x direction

