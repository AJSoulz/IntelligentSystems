function plot_data( drones, T )
    
    %% plot setup
    f = figure('Name', 'Drone Path', 'NumberTitle', 'off');
    xticks([0,100]); xticklabels({'0','100'});
    yticks([0,100]); yticklabels({'0','100'});
    grid on;
    f.Position = [60 60 850 1100]; % [x y w h] you may need to adjust this to suit your own screen
    axis([-20 120 -20 120]);
    title('Best Path');

    drone1 = drones(1);
    drone2 = drones(2);
    waypoints1 = [0 0; drone1.gene; 100 100];
    waypoints2 = [0 0; drone2.gene; 100 100];
    %% static plotting - planned path of drone
    hold on;
    plot( drone1.pathObj.States(:,1), drone1.pathObj.States(:,2), '-', 'Color', 'cyan' ); % drone path
    plot( drone2.pathObj.States(:,1), drone2.pathObj.States(:,2), '-', 'Color', 'magenta' ); % drone path
    plot( 0, 0, 'o', 'Color', '#000000', 'MarkerSize', 6 ); % start waypoint
    plot( 100, 100, 'o', 'Color', '#000000', 'MarkerSize', 6 ); % end waypoint
    plot( waypoints1(:,1), waypoints1(:,2), '.', 'Color', '#808080', 'MarkerSize', 10 ); % intermediate waypoints
    plot( waypoints2(:,1), waypoints2(:,2), '.', 'Color', '#808080', 'MarkerSize', 10 ); % intermediate waypoints

    %% dynamic plotting - drone and threat movements
    % i is drone index. j is threat. k is threat index.
    

    %threatLevel = 0;
    for i = 1:drone1.pathObj.NumStates
        % threats
        for j = 1:size(T.threats,1)
            % if drone path has more states than threat path, then threat loops
            k = i;
            numStates = T.threats(j).pathObj.NumStates;
            if i > numStates
                k = mod(i,numStates)+1;
            end
            %{
            % calculate threat level
            dist = myDistance( T.threats(j).pathObj.States(k,:), drone.pathObj.States(i,:) );
            if dist < T.threats(j).radius
                threatLevel = threatLevel + 2;
            end
            %}
            % plot threats
            T.threats(j).draw(k);
        end

        k = i;
        numStates = drone2.pathObj.NumStates;
        if i > numStates
            k = numStates;
        end
        drone2Plot = plot( drone2.pathObj.States(k,1), drone2.pathObj.States(k,2), 'o', 'MarkerSize', 3, 'MarkerFaceColor','magenta','MarkerEdgeColor','black' );
      
        % plot drone
        drone1Plot = plot( drone1.pathObj.States(i,1), drone1.pathObj.States(i,2), 'o', 'MarkerSize', 3, 'MarkerFaceColor','cyan','MarkerEdgeColor','black' );
        pause( 0.05 );
        % remove previous location of circles and drone
        if( i < length(drone1.pathObj.States) )
            for j = 1:size(T.threats,1)
                delete(T.threats(j).plotHandle);
            end
            delete(drone1Plot);
            delete(drone2Plot);
        end
        %subtitle(["Fitness" drone.fitness "Path Deviation" drone.deviation "Penalty(runtime)" threatLevel]);
    end
end