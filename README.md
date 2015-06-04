
= vawtSimulation =

Disclaimer: There is no guarantee the results of the simulation are by any mean close to something. 

== Description ==
This is inspired from Design of a vertical-axis wind turbine: how the aspect ratio affects the turbine's performance, S. Brusca and R. Lanzafame and M. Messina, Int. J. Energy Environ. Eng., 2014 - DOI 10.1007/s40095-014-0129-x

You'll need few other matlab packages to use this code:
* http://www.mathworks.com/matlabcentral/fileexchange/46909-vawt-analysis
* http://www.mathworks.com/matlabcentral/fileexchange/50070-xfoil-for-matlab
* http://www.mathworks.com/matlabcentral/fileexchange/19915-naca-4-digit-airfoil-generator

Many thanks to their authors as it would have been much more difficult without pre-existing code.

These packages are expected to be in your PATH (or ~/Documents/MATLAB/... on OS X). 

Note: you might have to increase p.itermax in xfoil.m to reach a convergence for some angle of attack under (pretty) low Reynolds number.

```matlab
>>> help simulateVAWT
  simulateVAWT is a single step of VAWT parameter optimisation procedure.
 
  desc = simulateVAWT(Re, P, V, AR, Nb, sigma)
  single step of VAWT size optimisation according to `Design of a vertical-axis wind turbine: how the aspect ratio
  affects the turbine's performance, S. Brusca and R. Lanzafame and M.
  Messina, Int. J. Energey Environ. Eng.`, 2014
 
  If desc.done is not 1, you should run another step with desc.EstimatedRe
  as input Reynolds number.

>> vawt = simulateVAWT('0018', 1.8e5, 100, 5, 0.5, 4, 0.4)
    ...
    vawt = 
                rho: 1.2000
                 nu: 1.4600e-05
    nacaProfileName: '0018'
                 Re: 180000
                  P: 100
                  V: 5
                 AR: 0.5000
          lambdaMin: 0.5000
         lambdaStep: 0.5000
          lambdaMax: 6
                 Nb: 4
              sigma: 0.4000
             lambda: [0.5000 1 1.5000 2 2.5000 3 3.5000 4 4.5000 5 5.5000 6]
           solution: [1x1 struct]
>> vawt.solution
    ans = 
            CpMax: 0.4193
      lambdaCpMax: 3
                R: 1.7833
                h: 0.8916
                c: 0.1783
         omegaRpm: 481.9399
              tho: 11.8886
             vawt: [1x1 VAWT.DMST]
    powerFunction: [21x2 double]
      EstimatedRe: 1.8321e+05
             done: 1
>> 
```

If Cd/Cl as a function of the angle of attack for a given Reynolds and profile is not available to `simulateVAWT`, it will computed with `vawtAirfoilProfile` and stored in a file for later use.

Only 4-digit NACA profiles are currently supported.

From there it's easy to add a while-loop until 'done' flag becomes true but there is no guarantee your computer will not blow up. Stated differently: there is no proof of convergence of the iterative procedure in the aforementioned paper and no guarantee all the pieces of code (referenced and mine) are bug free.

That said, have fun.

== License ==

Copyright 2015 Sebastien Soudan 
 
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and 
limitations under the License.