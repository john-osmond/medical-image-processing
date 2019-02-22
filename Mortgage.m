% INTRODUCTION

% Script to process image data of Atlantis Phantom.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% PREPARATION

% Prepare workspace:

clear
close all hidden
clc
tic

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
% Set qualitative variables:

OutDir = '/Users/John/Desktop';
Name = 'Mortgage';
FBI = 'n';

% Set quantitative variables:

FullPrice = 220000;
Share = 100;
MortVal = FullPrice*(Share/100);

TotPay = 1000;
Rent = 0;
ServCharge = 0;

IntRate = 4;
Duration = 25;
Deposit = 60000;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% Calculate constants:

MortPay = TotPay - Rent - ServCharge;

YearAll = 1:Duration;
MonthAll = 1:12;

Cap = Deposit;
Int = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Print variables:

%if (Pay < ((MortVal - Cap) * (IntRate/(12*100))))
%    Pay = (MortVal - Cap) * (IntRate/(12*100));
%    fprintf('\n%s\n%s%.0f\n','Payment less than interest!','Resetting payment to: £',Pay);
%end

% Print initial variables:

disp('Mortgage Repayment Projection');
disp(' ');
disp('==============================');
disp(' ');
disp(['Full Price: £' num2str(FullPrice)]);
disp(['Share: ' num2str(Share) '%']);
disp(['Mortgage Value: £' num2str(MortVal)]);
disp(' ');
disp(['Deposit: £' num2str(Deposit)]);
disp(['Interest Rate: ' num2str(IntRate) '%']);
disp(['Duration: ' num2str(Duration) ' years']);
disp(' ');
disp(['Total Payment: £' num2str(TotPay)]);
disp(['Mortgage Payment: £' num2str(MortPay)]);
disp(['Rent: £' num2str(Rent)]);
disp(['Service Charge: £' num2str(ServCharge)]);
disp(' ');
disp('==============================');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop round all years:

for Year=YearAll
    
    % Store values from previous year:
    
    CapOld = Cap;
    IntOld = Int;
    
    % Calculate rent for this year:
    
    if ( strcmp(lower(FBI),'y') == 1 )
        Rent = Year - 2;
        if (Rent < 0 )
            Rent = 0;
        elseif (Rent > 3)
            Rent = 3;
        end
        MortPay = TotPay - Rent - ServCharge;
    end
    
    Rent
    
    % Loop round all months:
    
    for Month=MonthAll
        
        if ( Cap < MortVal )
            
            % Calculate interest for this month:
            
            IntMonth = (MortVal-Cap)*(IntRate/(12*100));
            
            % Calculate capital paid off this month:
            
            if ((MortPay - IntMonth) < (MortVal - Cap))
                
                CapMonth = MortPay - IntMonth;
                
            else
                
                CapMonth = MortVal - Cap;
                
            end
            
            % Add values for this month to total:
            
            Cap = Cap + CapMonth;
            Int = Int + IntMonth;
            
        end
          
    end
    
    CapAll(Year) = (Cap-CapOld)/12;
    IntAll(Year) = (Int-IntOld)/12;
    
    FeeAll(Year) = IntAll(Year) + Rent + ServCharge;
    FeeAll(find(CapAll==0)) = 0;

    PaidAll(Year) = Cap;
    OutAll(Year) = MortVal-Cap;
    
    if (OutAll(end) < 0 )
        OutAll(end) = 0;
    end
    
    Share = (Cap/MortVal) * 100;
    ShareAll(Year) = Share;
    
    fprintf('\n%s %i%s\n\n%s%.0f\n%s%.0f\n%s%.0f\n%s%.0f\n%s%.0f\n','End of Year',Year,':',...
        'Mean Repayment Per Month: £',CapAll(Year)+IntAll(Year),...
        'Mean Capital Paid Per Month: £',CapAll(Year),...
        'Mean Interest Paid Per Month: £',IntAll(Year),...
        'Total Mortgage Paid: £',Cap,...
        'Total Interest Paid: £',Int);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate stacked bar chart of monthly repayments:

BarAll = cat(2,permute(CapAll,[2 1]),permute(FeeAll,[2 1]));
bar(YearAll,BarAll,0.6,'stack')

set(gca,'xlim',[0 Duration+1])
set(gca,'ylim',[0 TotPay+50])

xlabel('Time (Years)');
ylabel('Average Monthly Repayment (£)');
title('Repayment Breakdown vs Time');

writeplot(OutDir, 'Breakdown', 'n', 'y');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Grouped = cat(2,permute(PaidAll,[2 1]),permute(OutAll,[2 1]));
bar(YearAll,Grouped,1,'group')

set(gca,'xlim',[0 Duration+1])
set(gca,'ylim',[0 Cap+10000])
line([0 Duration+1],[MortVal MortVal],'Color','k');

xlabel('Time (Years)');
ylabel('Repaid & Outstanding Amount (£)');
title('Repaid & Outstanding Amount vs Time');

writeplot(OutDir, 'Paid', 'n', 'y');