%% currently working version at time of submission
% dualGA does not currently work

close all; clear; clc;
START_WAYPOINT = [0 0];
END_WAYPOINT = [100 100];
EPOCHS = 50;
THREATS = 10;
POPSIZE = 100;
MRATE_S = 0.2; % mutation rate for mutate_simplify
MRATE_A = 0.5; % mutation rate for mutate_adjust

fprintf("POPSIZE = %d\nTHREATS = %d\nEPOCHS = %d\nMRATE_S = %.2f\nMRATE_A = %.2f\n\n",POPSIZE,THREATS,EPOCHS,MRATE_S,MRATE_A);
T = threatPopulation( THREATS ); % threats
P = myPopulation( POPSIZE ); % main population
A = myPopulation( POPSIZE ); % assistant population

best_controlGA = controlGA( START_WAYPOINT, END_WAYPOINT, EPOCHS, P, T, MRATE_A, MRATE_A );
%best_dualGA = dualGA( START_WAYPOINT, END_WAYPOINT, EPOCHS, P, A, T, MRATE_A, MRATE_A );

% plot results
fprintf("plotting results...");
waypoints = [START_WAYPOINT; best_controlGA.gene; END_WAYPOINT];
plot_data( best_controlGA, waypoints, T );

% end message
fprintf(" Done.\n\n   Type the following to replay plot results.\n   plot_data(best,waypoints,T)\n\n");

