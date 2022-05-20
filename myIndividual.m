classdef myIndividual < handle
    properties
        gene;
        fitness = 0;
        deviation = 0;
        pathObj;
    end
    methods

        function ind = myIndividual( gene )
            if nargin > 0
                ind.gene = gene;
            end
            ind.pathObj = navPath( stateSpaceDubins([-20,120;-20,120;-pi,pi]) );
            ind.pathObj.StateSpace.MinTurningRadius = 0.001;
        end

        function fitnessScore = calcFitness( ind, T, START_WAYPOINT, END_WAYPOINT )
            %% calculate fitness value
            % create path object by interpolating poses along line segments
            % defined by gene. Calculates threat level by checking
            % distance of each pathObj pose with each threat. Fitness value is
            % line length + threat level.

            % create path object of individual

            waypoints = [START_WAYPOINT; ind.gene; END_WAYPOINT];
            % create third column - this isn't relevant but is required for pathObj to work.
            v = zeros( size(waypoints,1), 1 );
            v(:) = pi/4; % 45degrees
            waypoints = [waypoints,v];
            % convert waypoints to pathObj
            append( ind.pathObj, waypoints );
            numOfPoses = fix(pathLength(ind.pathObj)*2); % ensures that speed of drone flies at fixed rate.
            interpolate( ind.pathObj, numOfPoses ); 

            threatLevel = 0;
            for i = 1:ind.pathObj.NumStates
                for j = 1:size(T.threats,1)
                    % if drone path has more states than threat path, then threat loops
                    k = i;
                    numStates = T.threats(j).pathObj.NumStates;
                    if i > numStates
                        k = mod(i,numStates)+1;
                    end
                    % calculate threat level
                    dist = myDistance( T.threats(j).pathObj.States(k,:), ind.pathObj.States(i,:) );
                    if dist < T.threats(j).radius
                        threatLevel = threatLevel + 2;
                    end
                end
            end

            % get line length
            len = pathLength( ind.pathObj );

            ind.deviation = len - myDistance(START_WAYPOINT,END_WAYPOINT);
            % fitness is sum of len and threat level
            fitnessScore = ind.deviation + threatLevel;

            ind.fitness = fitnessScore;
        end

        function [child1, child2] = crossover( parent1, parent2 )
            %% crossover - uses one-point crossover to create two children

            % error prevention - abort crossover if either parent is empty
            if( isempty(parent1.gene) || isempty(parent2.gene) )
                child1 = [0 0];
                child2 = [0 0];
                return
            end

            % choose random crossover point from smallest parent
            if( size(parent1.gene,1) <= size(parent2.gene,1) )
                crossPoint = randi( size(parent1.gene,1) );
            else
                crossPoint = randi( size(parent2.gene,1) );
            end
           
            % create first child
            child1L = parent1.gene( 1:crossPoint, 1:2 );
            child1R = parent2.gene( crossPoint+1:end, 1:2 );
            child1 = [child1L; child1R];
            % create second child
            child2L = parent2.gene( 1:crossPoint, 1:2 );
            child2R = parent1.gene( crossPoint+1:end, 1:2 );
            child2 = [child2L; child2R];
        end

        function ind = mutate_adjust( ind )            
            %% move a gene element gently in a random direction

            % error prevention - abort mutation if gene is empty
            if( isempty(ind.gene) )
                return
            end
            
            % select gene element at random
            r = randi( size(ind.gene,1) );

            % generate new x and y coordinates for chosen gene element
            x = ind.gene(r,1) + randi([-10 10]);
            y = ind.gene(r,2) + randi([-10 10]); 

            % only commit changes if new values are within grid boundaries
            if( x >= -20 && x <= 120 )
                ind.gene(r,1) = x;
            end
            if( y >= -20 && y <= 120 )
                ind.gene(r,2) = y;
            end
        end

        function ind = mutate_simplify( ind )
            %% remove elements from gene

            % error prevention - abort mutation if gene is empty
            if( isempty(ind.gene) )
                return
            end

            % chance to remove first or last gene element...
            if( rand > 0.5 )
                if( rand > 0.5 )
                    ind.gene = ind.gene(1:end-1,:); % remove last element
                else
                    ind.gene = ind.gene(2:end,:); % remove first element
                end
                return
            end
            % ...or remove portion of middle elements
            r1 = randi( size(ind.gene,1) ); % r1 & r2 define range to be removed
            r2 = randi( [r1 size(ind.gene,1)] );
            geneL = ind.gene(1:r1,:);
            geneR = ind.gene(r2:end,:);
            ind.gene = [geneL;geneR];
        end
    end
end