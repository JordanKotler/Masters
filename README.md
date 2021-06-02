# Masters
Code repository for Masters project

## MATLAB CODE:
  - **Matlab** programs and algorithms for the simulations
    - Demand_Profile.m is the script which generates a demand profile. This script is integrated into the MC simulation to reduce runtime of importing CSV data. The main purpose is therefore just to produce the plot.
    - MonteCarlo7kW.m is the Monte Carlo simulation which produces a surface plot of profit when 7kW chargers are installed
    - MonteCarlo22kW.m is the Monte Carlo simulation which produces a surface plot of profit when 22kW chargers are installed
    - Parameter_Modification.m contains scripts that show how profit changes when varying budget as well as ratio of x_1 to x_2
    - Boxplot.m produces a boxplot for profit and also calculates coefficient of variance
    - Commuter_histogram.m produces a histogram for the commuter distances travelled to work because it looked better in Matlab than excel
    - NB Demand_Profile.m must be run before Parameter_Modification.m and Car Packing Problem.ipynb in order to work.


- **Datasets** used to inform the probabilities in the matlab scripts include: the raw census data for commuter travel times (CT0641.xls) and start of commute journeys (StartTimes.ods)
    
 
## Bin Packing Algorithm:

- **Car Packing Problem.ipynb** is a Jupyter notebook file containing cells which process the data and use a bin packing algorithm to minimise bin sizes.
- This script will not run unless you install Gurobi Optimiser 9.1


