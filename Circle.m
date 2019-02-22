function [Img] = Circle(Img, Co, RIn, ROut)

% Function to find mlc leaves in an imrt image.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if numel(Co) == 0;
    Co = fliplr(round(size(Img)/2));
end

if numel(RIn) == 0
    RIn = 0;
end

if numel(ROut) == 0
    ROut = sqrt((size(Img,1)^2)+(size(Img,2)^2));
end

for i = 1:size(Img,1)
    for j = 1:size(Img,2)
        DistCen = sqrt(((i-Co(2))^2)+((j-Co(1))^2));
        if (DistCen < RIn || DistCen > ROut)
            Img(i,j) = NaN;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end