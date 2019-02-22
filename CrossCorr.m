function [ CorrImg ] = CrossCorr( Img, Kern )

ImgSize = size(Img);
KernSize = size(Kern);

CorrImg = Img*0;

for x = 1:ImgSize(1)-KernSize(1)+1
    for y = 1:ImgSize(2)-KernSize(2)+1
        ImgCo = [x x+KernSize(1)-1 y y+KernSize(1)-1];
        Corr = Img(ImgCo(3):ImgCo(4),ImgCo(1):ImgCo(2)).*Kern;
        
        CorrCo = [x-1+round(KernSize(1)/2) y-1+round(KernSize(2)/2)];
        CorrImg(CorrCo(2),CorrCo(1)) = sum(sum(Corr));
        clear(Corr);
    end
end