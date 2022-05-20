%% currently working version at time of submission
% current parameters are testing values and may not be the same values as
% in the submitted IEEE paper.

close all; clear; clc;
START_WAYPOINT = [0 0];
END_WAYPOINT = [100 100];
EPOCHS = 20;
THREATS = 10;
POPSIZE = 100;
MRATE_S = 0.1; % mutation rate for mutate_simplify
MRATE_A = 0.25; % mutation rate for mutate_adjust

fprintf("POPSIZE = %d\nTHREATS = %d\nEPOCHS = %d\nMRATE_S = %.2f\nMRATE_A = %.2f\n\n",POPSIZE,THREATS,EPOCHS,MRATE_S,MRATE_A);
T = threatPopulation( THREATS ); % threats
P = myPopulation( POPSIZE ); % main population
A = myPopulation( POPSIZE ); % assistant population

bestControlGA = controlGA( START_WAYPOINT, END_WAYPOINT, EPOCHS, P, T, MRATE_A, MRATE_A );
bestDualGA = dualGA( START_WAYPOINT, END_WAYPOINT, EPOCHS, P, A, T, MRATE_A, MRATE_A );

% plot results
fprintf("plotting results...");
if bestControlGA.pathObj.NumStates > bestDualGA.pathObj.NumStates
    plot_data([bestControlGA,bestDualGA],T);
    fprintf("cyan = ControlGA (fitness: %f)\n",bestControlGA.fitness);
    fprintf("magenta = DualGA (fitness: %f)\n",bestDualGA.fitness);
else
    plot_data([bestDualGA,bestControlGA],T);
    fprintf("cyan = DualGA (fitness: %f)\n",bestDualGA.fitness);
    fprintf("magenta = ControlGA (fitness: %f)\n",bestControlGA.fitness);
end


