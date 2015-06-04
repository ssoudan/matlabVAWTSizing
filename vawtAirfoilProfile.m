function data = vawtPowerCoefficient(nacaProfileName, Re)
% vawtPowerCoefficient Computes the drag and lift coefficient of a 4-digit
% naca profile for a range of angle of attack
%
% cp = vawtPowerCoefficient(nacaProfile, Re, sigma)
%
% * nacaProfile is the 4 digit name of a naca profile (as a string)
% * Re is the Reynolds number
%
% Copyright 2015 Sebastien Soudan
% Licensed under the Apache License, Version 2.0 (the "License");

alphaMin=0
alphaStep=1
alphaMax=30

MACH=0

%% generate the profile

iaf.designation=nacaProfileName;
iaf.n=60;
iaf.HalfCosineSpacing=1;
iaf.wantFile=0;
iaf.datFilePath=nacaProfileName; 
iaf.is_finiteTE=0;

af = naca4gen(iaf);

nacaProfile = [[af.xU af.zU] ; [af.xL(2:end-1) af.zL(2:end-1)]];

%% plot the profile
clf
plot(af.xU,af.zU,'bo-')
hold on
plot(af.xL,af.zL,'ro-')

%% now call xfoil to get the CP coefficient
X=nacaProfile(:,1);
Y=nacaProfile(:,2);

data = [];
parfor alpha=alphaMin:alphaStep:alphaMax
    
    [p]=xfoil(X,Y,alpha,Re,MACH);
    
    CL=p.cl;
    CD=p.cd;
    CM=p.cm;
    
    data = [data ; [alpha 0 CD CL]]
end

data = sort(data, 1)

%% plot the Cd and Cl as a function of alpha (the angle of attack)

figure
plot(data(:,1), data(:,3))
xlabel('alpha')
ylabel('Cd')

figure
plot(data(:,1), data(:,4))
xlabel('alpha')
ylabel('Cl')

data

%% write data to a file that can be used by VAWTAnalysis package
mkdir(nacaProfileName)
filename = [nacaProfileName filesep sprintf('naca%s-%f.csv', nacaProfileName, Re)]
fid = fopen(filename, 'w')
fprintf(fid, '%s\n"AoA (deg)","t (s)","Cd","Cl"\n', nacaProfileName)
fprintf(fid,'%6.2f,%6.2f,%12.8f,%12.8f\n', data');
fclose(fid);

disp(['Airfoil profile data have been written to ' filename])

end