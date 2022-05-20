function plot_data( drone, waypoints, T )
    
    %% plot setup
    f = figure('Name', 'Drone Path', 'NumberTitle', 'off');
    xticks([0,100]); xticklabels({'0','100'});
    yticks([0,100]); yticklabels({'0','100'});
    grid on;
    f.Position = [60 60 850 1100]; % [x y w h] you may need to adjust this to suit your own screen
    axis([-20 120 -20 120]);
    title('Best Path');
    
    %% static plotting - planned path of drone
    hold on;
    plot( drone.pathObj.States(:,1), drone.pathObj.States(:,2), '-', 'Color', '#E0E0E0' ); % drone path
    plot( waypoints(1,1), waypoints(1,2), 'o', 'Color', '#000000', 'MarkerSize', 6 ); % start waypoint
    plot( waypoints(end,1), waypoints(end,2), 'o', 'Color', '#000000', 'MarkerSize', 6 ); % end waypoint
    plot( waypoints(:,1), waypoints(:,2), '.', 'Color', '#808080', 'MarkerSize', 10 ); % intermediate waypoints

    %% dynamic plotting - drone and threat movements
    % i is drone index. j is threat. k is threat index.

    threatLevel = 0;
    for i = 1:drone.pathObj.NumStates
        % threats
        for j = 1:size(T.threats,1)
            % if drone path has more states than threat path, then threat loops
            k = i;
            numStates = T.threats(j).pathObj.NumStates;
            if i > numStates
                k = mod(i,numStates)+1;
            end
            % calculate threat level
            dist = myDistance( T.threats(j).pathObj.States(k,:), drone.pathObj.States(i,:) );
            if dist < T.threats(j).radius
                threatLevel = threatLevel + 2;
            end
            % plot threats
            T.threats(j).draw(k);
        end
        % plot drone
        dronePlot = plot( drone.pathObj.States(i,1), drone.pathObj.States(i,2), 'o', 'MarkerSize', 3, 'MarkerFaceColor','cyan','MarkerEdgeColor','black' );
        pause( 0.05 );
        % remove previous location of circles and drone
        if( i < length(drone.pathObj.States) )
            for j = 1:size(T.threats,1)
                delete(T.threats(j).plotHandle);
            end
            delete(dronePlot);
        end
        %subtitle(["Fitness" drone.fitness "Path Deviation" drone.deviation "Penalty(runtime)" threatLevel]);
    end
end