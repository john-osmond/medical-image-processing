clear A
TempFlood = Data;
for i = 1:size(TempFlood,3)
    i
    clear ColLeft ColRight Left Right
    
    [~, FiltImg, ~, ~] = CorData(TempFlood(:,:,i), 'n', DarkImg, 'n', FloodImg, 'n');
    Prof = diff(mean(FiltImg,1));
    ProfAll(:,i)=Prof;
    
    Right = sort(find(Prof>200));
    Left = sort(find(Prof<-200));
    
    k=0;
    Old=-2;
    for j=1:size(Right,2)
        if ((Right(j)-Old)>2)
            k = k+1;
            ColRight(k)=Right(j);
            Old=Right(j);
        else
            ColRight(k)=mean([ColRight(k) Right(j)]);
        end
    end
    
    k=0;
    Old=-2;
    for j=1:size(Left,2)
        if ((Left(j)-Old)>1)
            k = k+1;
            ColLeft(k)=Left(j);
            Old=Left(j);
        else
            ColLeft(k)=mean([ColLeft(k) Left(j)]);
        end
    end
    
    if ((ColLeft(1) < ColRight(1)) && (size(ColLeft,2)==5) && (size(ColRight,2)==5))
        A(:,i) = [ColLeft ColRight];
        A(:,i);
    end
        
end

j=1;
clear Width Spacing Diff B;
for i = 1:size(A,2)
    
    if (A(1,i) ~= 0)
        B=A(:,i)
        Width(j)=mean([B(6)-B(1) B(7)-B(2) B(8)-B(3) B(9)-B(4) B(10)-B(5)]);
        
        Diff=diff(B);
        Spacing(j)=mean([permute(Diff(1:4),[2 1]) permute(Diff(6:9),[2 1])]);
        
        C(:,j) = B;
        
        j = j + 1;
    end

end

Speed = diff(C(1,:));

mean(Width)
mean(Spacing)
mean(Speed(Speed>0))