% Script to accept a data, dark and open image and apply correction

% Thickness in mm

function [EnergyInt, Spec] = IntSpec(InDir, File, AW, EnergyInt, Density, Thickness, Mode, OutDir)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Calculating spectrum...');

if (isa(File,'char')==1)
    File = {File};
end

for i = 1:length(File)
    
    % Read data:
    
    Data = importdata([InDir '/' char(File(i)) '.txt']);
    Energy = Data(:,1);
    AttCo = Data(:,2);
    
    if (i==1 && numel(EnergyInt)==0)
        EnergyInt = Energy;
    end
    
    % Interpolate if necessary:
    
    AttCoInt(:,i) = interp1(Energy,AttCo,EnergyInt)*(AW(i)/sum(AW));
    
    clear Data Energy AttCo;
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate spectrum:

if ( strcmpi(Mode,'A') == 1 )
    Spec = 1-exp(-1*sum(AttCoInt,2)*Density*(Thickness/10));
    ModeName = 'Attenuation';
    ShortName = 'Att';
elseif ( strcmpi(Mode,'T') == 1 )
    Spec = exp(-1*sum(AttCoInt,2)*Density*(Thickness/10));
    ModeName = 'Transmission';
    ShortName = 'Trans';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot spectrum if required:

if OutDir
    
    plot(EnergyInt, Spec*100)
    %ylim([0 100])
    xlabel('Energy (MeV)');
    ylabel([ModeName ' at ' num2str(Thickness) ' mm (%)']);
    WritePlot(OutDir, [char(File(1)) ShortName], 'n', 'y');

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('...done.')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end