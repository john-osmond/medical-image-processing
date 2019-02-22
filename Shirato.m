clear
for j = 1:40
    
    clear S
    File = ['/Users/josmond/Data/Shirato/hokudai/j' num2str(j) '.mat'];
    S = load(File,'yConcat');
    
    clear All
    for i = 1:size(S.yConcat,2)
        if (i==1)
            All = S.yConcat{i};
        else
            All = [All; S.yConcat{i}];
        end
    end
    
    Disp(j) = mean(abs(diff(All)))*30;
    
    display(['j' num2str(j) ' Median displacement = ' num2str(Disp(j))]);

end

clear
for j = 1:40
    
    clear S
    File = ['/Users/josmond/Data/Shirato/hokudai/j' num2str(j) '.mat'];
    S = load(File,'yConcat');
    
    for i = 1:size(S.yConcat,2)
        if (j==1 && i==1)
            TravAll = diff(S.yConcat{i});
        else
            TravAll = [TravAll; diff(S.yConcat{i})];
        end
    end
    
end

TravAll = abs(TravAll)*30;

hist(TravAll);
xlim([0 1000])
ylim([0 1000]);

prctile(TravAll,50)
prctile(TravAll,75)
prctile(TravAll,90)

mean(TravAll)

std(TravAll)

% patient 2

clear
S = load('/Users/josmond/Data/Shirato/hokudai/j2.mat');

for i = 1:size(S.yConcat,2)
    if (i==1)
        PeriodAll = S.periodTime{i};
        PeriodNum = size(S.periodTime{i},1);
    else
        PeriodAll = [PeriodAll; S.periodTime{i}];
        PeriodNum = [PeriodNum; size(S.periodTime{i},1)];
    end
end

RandNo = ceil(rand*size(PeriodAll,1))
PeriodSum = cumsum(PeriodNum);

for i = 1:size(S.yConcat,2)
    if (RandNo<PeriodSum(i))
        RandFrac = i
        RandPeriod = RandNo-PeriodSum(i-1)
    end
end

plot(S.yConcat{6})
hold on
plot(S.maxExhTime{6},'r');
hold off
xlim([0 100])


