function best = dualGA( START_WAYPOINT, END_WAYPOINT, EPOCHS, M, A, T, MRATE_S, MRATE_A )
    %% Runs the dual-population GA

    % run initial fitness
    fprintf("Epoch 1  ");
    M.fitness( T, START_WAYPOINT, END_WAYPOINT );
    A.fitness( T, START_WAYPOINT, END_WAYPOINT );
    A.alternate_fitness( M, A, 20 );
    fprintf(" Fitness = %f\n", M.individuals(1).fitness );
    % run genetic operators for each generation
    for n = 2:EPOCHS
        fprintf("Epoch %d  ", n);
        [M,A] = selection(M,A);
        M = M.mutate( MRATE_S, MRATE_A );
        A = A.mutate( MRATE_S, MRATE_A );

        M.fitness( T, START_WAYPOINT, END_WAYPOINT );
        A.fitness( T, START_WAYPOINT, END_WAYPOINT );
        A.alternate_fitness( M, A, 20 );

        fprintf(" Fitness = %f\n", M.individuals(1).fitness );
        if M.individuals(1).fitness <= 0
            fprintf("Straight path found. Terminating GA early.\n");
            break;
        end
    end
    % best individual to be returned
    best = M.individuals(1);

end