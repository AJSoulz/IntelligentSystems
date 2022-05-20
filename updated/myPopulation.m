classdef myPopulation < handle
    properties
        individuals;
    end
    methods
        function p = myPopulation( popSize )
            if nargin > 0
                for n = 1:popSize
                    randGene = randi( [-20 120], 20, 2 );
                    ind = myIndividual( randGene );
                    p.individuals = [p.individuals; ind];
                end
            end
        end
        %% utility functions
        function p = add( p, ind )
            p.individuals = [p.individuals; ind];
        end
        function p = remove( p, ind )
            if ind == 1
                p.individuals = p.individuals(2:end); % remove first
            elseif ind == size(p.individuals,1)
                p.individuals = p.individuals(1:end-1); % remove last
            else
                p.individuals = [p.individuals(1:ind-1); p.individuals(ind+1:end)]; % remove intermediate
            end
        end
        %% fitness function
        function p = fitness( p, threat, START_WAYPOINT, END_WAYPOINT )

            % get fitness values for all individuals
            clearCommandLine = '';
            for i = 1:size(p.individuals,1)
                p.individuals(i).calcFitness( threat, START_WAYPOINT, END_WAYPOINT );
                % display progress
                percentDone = 100 * i / size(p.individuals,1);
                msg = sprintf(' Progress: %3.1f', percentDone);
                fprintf([clearCommandLine, msg]);
                clearCommandLine = repmat(sprintf('\b'), 1, length(msg));
            end
            fprintf(clearCommandLine);
            % sort population by fitness in ascending order
            [~,i] = sort( [p.individuals.fitness] );
            p.individuals = p.individuals(i);
        end
        %% additional fitness function for assistant population
        function A = alternate_fitness( A, M, threshhold )
            
            % get average fitness of main population
            sum = 0;
            n = size(M.individuals,1);
            for i = 1:n
                sum = sum + M.individuals(i).fitness;
            end
            avg = sum/n;
            threshhold = threshhold + avg;

            % give penalty to individuals below threshhold
            m = size(A.individuals,1);
            for i = 1:m
                if A.individuals(i).fitness < threshhold
                    penalty = threshhold - A.individuals(i).fitness;
                    A.individuals(i).fitness = A.individuals(i).fitness + penalty;
                end
            end

        end
        
        %% selection function (includes crossover)
        function new_p = selection( p )
            new_p = myPopulation; % Next Epoch

            % crossover top two individuals
            
            new_p.add( p.individuals(1) ); % save parent
            new_p.add( p.individuals(2) ); % save parent
            [child1, child2] = crossover( p.individuals(1), p.individuals(2) );
            new_p.add( child1 ); % save child
            new_p.add( child2 ); % save child

            % crossover top K individuals for rest of new population
            K = fix(size(p.individuals,1));
            for i = 3:size(p.individuals,1)/2
                [child1, child2] = crossover( p.individuals(randi(K)), p.individuals(randi(K)) );
                new_p.add( child1 );
                new_p.add( child2 );
            end
        end
        %% selection function for dualGA
        
        function [M_candidates,A_candidates] = selection_dualGA( M, A )

            n = size(M.individuals,1);

            % split main population into two halves
            MI = myPopulation; % main inbreed
            MC = M; % main crossbreed
            m = n;
            for i = 1:n/2
                r = randi(m);
                MI.individuals = [MI.individuals; MC.individuals(r)];
                MC = MC.remove( r );
                m = m - 1;
            end
            
            % split assistant population into two halves
            AI = myPopulation; % assistant inbreed
            AC = A; % assistant crossbreed
            m = n;
            for i = 1:n/2
                r = randi(m);
                AI.individuals = [AI.individuals; AC.individuals(r)];
                AC.remove( r );
                m = m - 1;
            end
            
            % crossbreed of both populations
            MCAC = myPopulation;
            MCAC.individuals = [MC.individuals; AC.individuals];
            C = myPopulation;
            MCAC_size = size(MCAC.individuals,1);
            for i = 1:fix(MCAC_size/2)
                [offspring1, offspring2] = crossover( MCAC.individuals(MCAC_size), MCAC.individuals(MCAC_size) );
                C = C.add( offspring1 );
                C = C.add( offspring2 );
            end
            if mod(MCAC_size,2) ~= 0
                [offspring1, ~] = crossover( MCAC.individuals(MCAC_size), MCAC.individuals(MCAC_size) );
                C = C.add( offspring1 );
            end
            
            % inbred main
            IM = myPopulation;
            MI_size = size(MI.individuals,1);
            for i = 1:fix(MI_size/2)
                [offspring1, offspring2] = crossover( MI.individuals(randi(MI_size)), MI.individuals(randi(MI_size)) );
                IM.add( offspring1 );
                IM.add( offspring2 );
            end
            if mod(MI_size,2) ~= 0
                [offspring1, ~] = crossover( MI.individuals(randi(MI_size)), MI.individuals(randi(MI_size)) );
                IM.add( offspring1 );
            end

            % elite main
            EM = myPopulation;
            EM.individuals = M.individuals(1:fix(n/2));

            % random main
            %RM = myPopulation( n/4 );
            
            % candidates main
            M_candidates = myPopulation;
            M_candidates.individuals = [IM.individuals; EM.individuals; C.individuals];

            % inbred assistant
            IA = myPopulation;
            AI_size = size(AI.individuals,1);
            for i = 1:fix(AI_size/2)
                [offspring1, offspring2] = crossover( AI.individuals(AI_size), AI.individuals(AI_size) );
                IA.add( offspring1 );
                IA.add( offspring2 );
            end
            if mod(AI_size,2) ~= 0
                [offspring1, ~] = crossover( AI.individuals(AI_size), AI.individuals(AI_size) );
                IA.add( offspring1 );
            end

            % elite assistant
            EA = myPopulation;
            EA.individuals = A.individuals(1:fix(n/2));

            % random assistant
            %RA = myPopulation( n/4 );

            % candidates assistant
            A_candidates = myPopulation;
            A_candidates.individuals = [IA.individuals; EA.individuals; C.individuals];
        end
        
        %% mutate function
        function p = mutate( p, mrate1, mrate2 )
            for i = 3:length(p.individuals)
                if( rand < mrate1 )
                    p.individuals(i) = p.individuals(i).mutate_simplify();
                end
                if( rand < mrate2 )
                    p.individuals(i) = p.individuals(i).mutate_adjust();
                end
            end
        end
    end
end