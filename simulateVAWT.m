function desc = simulateVAWT(nacaprofileName, Re, P, V, AR, Nb, sigma)
% simulateVAWT Single step of VAWT parameter optimisation procedure.
%
% desc = simulateVAWT(nacaprofileName, Re, P, V, AR, Nb, sigma)
% single step of VAWT size optimisation according to `Design of a vertical-axis wind turbine: how the aspect ratio
% affects the turbine's performance, S. Brusca and R. Lanzafame and M.
% Messina, Int. J. Energey Environ. Eng.`, 2014
%
% * nacaProfileName is the 4-digit name of a NACA profile. e.g.: '0018'
% * Re is the Reynolds number (initially has to be guessed then use desc.EstimatedRe of previous step)
% * P is the rated power for the vawt (W)
% * V is the wind speed (m/s)
% * AR is the desired aspect ratio (h/R)
% * Nb is the desired number of blades
% * sigma is the desired rotor solidity 
% 
% If desc.done is not 1, you should run another step with desc.EstimatedRe
% as input Reynolds number.
%
% Copyright 2015 Sebastien Soudan 
% Licensed under the Apache License, Version 2.0 (the "License");

%% Add stuffs to path
userdir = userpath
userdir = userdir(1:end-1)
addpath([userdir filesep 'VAWTanalysis'])
addpath([userdir filesep 'naca4gen'])
addpath([userdir filesep 'xfoil'])

%% Constants
vawtDescription.rho = 1.2;      % density of air (kg/m^3)
vawtDescription.nu = 1.46e-5;   % kinematic viscosity of air

%% inputs

vawtDescription.nacaProfileName = nacaprofileName
vawtDescription.Re = Re         % initial Re
vawtDescription.P = P           % target power (W)
vawtDescription.V = V           % wind speed (m/s)
vawtDescription.AR = AR         % aspect ratio h/R -- lower AR gives higher efficiency

vawtDescription.lambdaMin = 0.5 % TSR range spec
vawtDescription.lambdaStep = 0.5
vawtDescription.lambdaMax = 6

vawtDescription.Nb = Nb         % number of blades
vawtDescription.sigma = sigma   % solidity ratio Nb * C / R

%% Computed values

profileDataFilename = [ vawtDescription.nacaProfileName filesep sprintf('naca%s-%f.csv', vawtDescription.nacaProfileName, Re)]
if exist(profileDataFilename) ~= 2
    vawtAirfoilProfile(vawtDescription.nacaProfileName, Re)
end
vawtDescription.lambda = vawtDescription.lambdaMin:vawtDescription.lambdaStep:vawtDescription.lambdaMax;

%% Set stuffs
oldColors = get(0,'DefaultAxesColorOrder');
newColors = jet(length(vawtDescription.lambda));
set(0,'DefaultAxesColorOrder', newColors);

%% Model

% create the model
vawt = VAWT.DMST(vawtDescription.sigma, vawtDescription.lambda, vawtDescription.Nb, profileDataFilename)

% set the pitch
vawt.set('pitch', 0);

% run the solver
vawt.solve

%% Plot
% vawt.getPlots
vawt.getPlots('alpha')
vawt.getPlots('power')
vawt.getPlots('torque')

%% Show a bit of sizing information

CpMax = -1e10;
iMax = 0;
for i = 1:length(vawtDescription.lambda)
    if vawt.solution(i).power.CP > CpMax
        CpMax = vawt.solution(i).power.CP;
        iMax = i;
    end
end

%%% Maximum Cp
vawtDescription.solution.CpMax = CpMax;

%%% Reached for lambda
vawtDescription.solution.lambdaCpMax = vawtDescription.lambda(iMax);

%%% Giving us a radius R of (m)
vawtDescription.solution.R = sqrt(vawtDescription.P/(vawtDescription.rho * vawtDescription.V^3 * vawtDescription.AR * vawtDescription.solution.CpMax));

%%% And a height of (m)
vawtDescription.solution.h = vawtDescription.AR * vawtDescription.solution.R;

%%% And a chord of (m)
vawtDescription.solution.c = vawtDescription.sigma * vawtDescription.solution.R / vawtDescription.Nb;

%%% And a rotational speed of (rpm)
vawtDescription.solution.omegaRpm = 60 * vawtDescription.solution.lambdaCpMax * vawtDescription.V / (2 * pi * vawtDescription.solution.R);

%%% Torque (N.m)
vawtDescription.solution.tho = vawtDescription.P / (vawtDescription.solution.lambdaCpMax * vawtDescription.V / vawtDescription.solution.R);

%%% Torque at 2000 rpm (N.m)
vawtDescription.solution.thoAt2000rpm = vawtDescription.solution.tho * vawtDescription.solution.omegaRpm / 2000

%%% Vawt simulation
vawtDescription.solution.vawt = vawt;

%%% Power function
windRange = (0:(vawtDescription.V/5):(4*vawtDescription.V))';

vawtDescription.solution.powerFunction = [windRange (vawtDescription.solution.CpMax * vawtDescription.solution.R * vawtDescription.solution.h * vawtDescription.rho * windRange.^3)];

%%% Maximum power of a pure-drag vawt of the same size
vawtDescription.solution.pureDragPowerFunction = [windRange (0.36 * vawtDescription.solution.R * vawtDescription.solution.h * windRange.^3)];

vawtDescription.solution.pureDragOmegaRpm = vawtDescription.V * 60 / (2 * pi * vawtDescription.solution.R)

vawtDescription.solution.pureDragTorque = (0.36 * vawtDescription.solution.R * vawtDescription.solution.h * vawtDescription.V^3) / (vawtDescription.V / (vawtDescription.solution.R))

%%% Plot the power as a function of wind speed
figure;
plot(vawtDescription.solution.powerFunction(:,1), vawtDescription.solution.powerFunction(:,2))
hold on 
plot(vawtDescription.solution.pureDragPowerFunction(:,1), vawtDescription.solution.pureDragPowerFunction(:,2))
legend('current vawt', 'size-equivalent pure-drag vawt')
xlabel('wind speed (m/s)')
ylabel('power (W)')

%% Are we done?

vawtDescription.solution.EstimatedRe = vawtDescription.solution.c * vawtDescription.V * vawtDescription.solution.lambdaCpMax / vawtDescription.nu;

vawtDescription.solution.done = true;

if abs(vawtDescription.solution.EstimatedRe - vawtDescription.Re) / max([vawtDescription.solution.EstimatedRe vawtDescription.Re]) > 0.10
    disp(['should consider running another step for a Re of ' num2str(vawtDescription.solution.EstimatedRe)])
    
    disp(['This can be done with: ' sprintf('simulateVAWT(%s, %f, %f, %f, %f, %f, %f)', vawtDescription.nacaProfileName, vawtDescription.solution.EstimatedRe, vawtDescription.P, vawtDescription.V, vawtDescription.AR, vawtDescription.Nb, vawtDescription.sigma)])
    vawtDescription.solution.done = false;
end

desc = vawtDescription;


%% Restore colormap
set(0,'DefaultAxesColorOrder', oldColors);

end