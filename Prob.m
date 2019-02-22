clc

P = 94/349;

NumCab = 22;
NumExCab = 31;
NumMPs = 349;

% For:

for i = 0:NumCab
    
    display(['Number of Female MPs = ' num2str(i)])
    
    nCr = factorial(NumCab)/(factorial(i)*factorial(NumCab-i));
    
    Pi = nCr*(P^i)*((1-P)^(NumCab-i))
    
end