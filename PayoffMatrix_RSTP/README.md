## Introduction

This custom code performs the simulations for the paper: **Aspiration dynamics generate robust predictions in heterogeneous populations**, by *Lei Zhou*, *Bin Wu*, *Jinming Du*, and *Long Wang*. 

In this version of the code, the game payoff matrix is parameterized by $R, S, T, P$ where $R=1$ and $P=0$. 

## Included files

#### Monte Carlo simulations
- *Control.f90*: The main program of the Monte Carlo simulation used in the paper. It defines all the global variables and reads all the input parameters except the static network structure. 

- *frequencyCalculationStationaryDist.f90*: Calculate the distribution of the number of strategy A when the system reaches its stationary states.

- *Inintial_strategies_not_equal.f90*: Initialize individuals' strategies according to a specified initial frequency of strategy A.

- *readNetwork.f90*: Read the network structure.

- *PairwiseGame_AnyWeightedGraph.f90*: Calculate the payoff of the individual who is randomly selected to update its strategy on any weighted network.

- *HeteroAspirationUpdateRule.f90*: The randomly selected individual compares its aspiration value with its payoff and updates its strategy based on the aspiration-based update function. Here, each individual can have its own update function (including the case where everyone shares the same update function). 

- *MT_PNRG.f90*: A module contains the random number generators from the IMSL library. 

- *AspirationDynamicsParameters.txt*: This input file contains parameters including the payoff matrix, the selection intensity, personalized aspiration values, and parameters for individualized update functions.

- *simulationParameters.inp*: This input file contains the parameters for the simulation setting, including
  - networkType: the type of the network (random, regular, or scale-free),
  - weightsDistType: the type of the edge weight distribution (homogeneous, uniform, or power-law),
  - TTBeg, TTGap, and TTEnd: the starting point, increment, and ending point of the payoff value $T$,
  - SSBeg, SSGap, and SSEnd: the starting point, increment, and ending point of the payoff value $S$,
  - timesRepeated: number of repetitions (or runs) in the whole simulation, 
  - initialFrequencyA: the initial frequency of strategy A, 
  - isPayoffAveraged: the way of payoff calculation, averaged (isPayoffAveraged=1) or accumulated (isPayoffAveraged=0), 
  - totalNumLoopSimulation: the number of simulation loops in one run, 
  - generationNumPerLoop: the number of simulation time steps in one loop,  
  - sampleStartLoopIndex: the index of the simulation loop where the sampling of distribution begins.

- *NetworkStructure_AspDyn_X_Weighted_Y*: Network structure of type X (X=RG, RRG, or SF) with an edge weight distribution Y (Y=Homogeneous, Uniform, or PowerLaw) under network size ($N=100$). Each node corresponds to 3 rows. For example, the $i$-th node corresponds to Row $3i-2$, $3i-1$, and $3i$: Row $3i-2$ defines its degree (i.e., the number of neighbors it has); Row $3i-1$ defines the index of all its neighbors; and Row $3i$ defines the corresponding weights.

#### Others
- *LICENSE*: MIT License

- *README.MD*: This file 


## Dependencies

Fortran 90 files for **Monte Carlo simulations** was tested using *Intel(R) Visual Fortran* version 13.0.3600.2010 and IMSL Fortran Numerical Library version 6.0 under Microsoft Visual Studio 2010 Version 10.0.30319.1. To use the random number generator, the IMSL static library is needed, in particular the dynamical library *libiomp5md.lib*. 

## Running the software

All files of **Monte Carlo simulations** and the dynamical library file  *libiomp5md.lib* should be put in the same folder. 

The default parameter setting is for population size $N=100$ on the scale-free network with a power-law edge weight distribution. To change the network type to other types of network structure or edge weight distribution, change the first line from *networkType = SF* to *networkType = RG* or *networkType = RRG* and the second line from *weightsDistType = PowerLaw* to *weightsDistType = Homogeneous* or *weightsDistType = Uniform* in the **simulationParameters.inp** file.

This program generates an output file named *numA_Dist_TT_Z_SS_U* where *Z* represents the current payoff value $T$ and *U* the current payoff value $S$. In this output file, each row corresponds to one repetition (i.e., run) that records one distribution of the number of strategy A sampled in the simulation. 

## License

See LICENSE for details.
