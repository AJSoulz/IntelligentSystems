function best = dualGA( START_WAYPOINT, END_WAYPOINT, EPOCHS, M, A, T, MRATE_S, MRATE_A )
    %% Runs the dual-population GA

    fprintf("\nrunning Dual-population GA\n");
    best = M.individuals(1);
    for n = 1:EPOCHS
        fprintf("Epoch %d  ", n);
        % selection process + fitness process
        [M_candidates,A_candidates] = selection_dualGA(M,A);
        M_candidates = M_candidates.fitness(T,START_WAYPOINT,END_WAYPOINT);
        A_candidates = A_candidates.fitness(T,START_WAYPOINT,END_WAYPOINT);
        m = fix(size(M_candidates.individuals,1)/2);
        M.individuals = M_candidates.individuals(1:m);
        A.individuals = A_candidates.individuals(1:m);
        A = A.alternate_fitness( M, 10 );

        % mutation process
        M = M.mutate( MRATE_S, MRATE_A );
        A = A.mutate( MRATE_S, MRATE_A );
        
        if M.individuals(1).fitness < best.fitness
            best = M.individuals(1);
        end

        fprintf(" Fitness = %f\n", M.individuals(1).fitness );
        if M.individuals(1).fitness <= 0
            fprintf("Straight path found. Terminating GA early.\n");
            break;
        end
    end
    fprintf("best fitness: %f", best.fitness);
end