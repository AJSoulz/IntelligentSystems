function best = controlGA( START_WAYPOINT, END_WAYPOINT, EPOCHS, P, T, MRATE_S, MRATE_A )
    %% Runs the control GA

    fprintf("\nrunning Control GA\n");
    % run initial fitness
    fprintf("Epoch 1  ");
    P = P.fitness( T, START_WAYPOINT, END_WAYPOINT );
    fprintf(" Fitness = %f\n", P.individuals(1).fitness );
    % run genetic operators for each generation
    best = P.individuals(1);
    for n = 2:EPOCHS
        fprintf("Epoch %d  ", n);
        P = P.selection();
        P = P.mutate( MRATE_S, MRATE_A );
        P = P.fitness( T, START_WAYPOINT, END_WAYPOINT );
        fprintf(" Fitness = %f\n", P.individuals(1).fitness );

        if P.individuals(1).fitness < best.fitness
            best = P.individuals(1);
        end

        if P.individuals(1).fitness <= 0
            fprintf("Straight path found. Terminating GA early.\n");
            break;
        end
    end
    fprintf("best fitness: %f", best.fitness);
end