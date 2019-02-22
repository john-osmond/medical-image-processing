% Script to open large number of images and generate statistical data:

function [Img] = RemoveLine(Img, Dim, Lines)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for Line = Lines
    
    if ( strcmpi(Dim,'x') == 1 )
        Img(Line,:) = mean([Img(Lines(1)-1,:); Img(Lines(2)+1,:)],1);
    else
        Img(:,Line) = mean([Img(Lines(1)-1,:) Img(Lines(2)+1,:)],2);
    end
    
end

%MedImg = medfilt2(real(medfilt2(real(Img))));

%if ( strcmpi(Dim,'x') == 1 )
%    Img(Line,:) = MedImg(Line,:);
%else
%    Img(:,Line) = MedImg(:,Line);
%end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end