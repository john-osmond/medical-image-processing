% Script to accept a data, dark and open image and apply correction\

function [CNR] = CNR(Img, TopLeft, TopRight, Height, InnerHeight, Check)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Calculating CNR...']);

if strcmpi(Check,'y')
    
    BoxX = [(BoxCoCen(1)-BoxSize(1)/2) (BoxCoCen(1) - BoxSize(1)/2)...
    (BoxCoCen(1)+BoxSize(1)/2) (BoxCoCen(1) + BoxSize(1)/2)];
BoxY = [(BoxCoCen(2)-BoxSize(2)/2) (BoxCoCen(2)+BoxSize(2)/2)...
    (BoxCoCen(2) + BoxSize(2)/2) (BoxCoCen(2) - BoxSize(2)/2)];
    
    Box = patch(BoxX,BoxY,[0.95 1.0 0.95],...
    'EdgeColor','r','FaceColor','None');
    pause
end

TopLeft = [588 837];
TopRight = [780 829];
Height = 50;
InnerSize = 20;


disp(['...done.']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end