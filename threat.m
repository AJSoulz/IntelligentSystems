classdef threat < handle
    properties
        pathObj;
        radius;
        plotHandle;
    end
    methods
        function t = threat( offset, radius, direction, speed )
            %% constructor
            % create new path object
            t.pathObj = navPath( stateSpaceDubins([-20 120; -20 120; 0 360]) );
            t.pathObj.StateSpace.MinTurningRadius = 0.001;
            t.radius = radius;
            if( direction == 0 )
                endpoints = [-20 offset 180; 120 offset 0; -20 offset 180]; % horizontal setup
            else
                endpoints = [offset -20 270; offset 120 90; offset -20 270]; % vertical setup
            end
            append( t.pathObj, endpoints );
            interpolate( t.pathObj, speed );

            % randomise starting point by 'cutting the deck'.
            r = randi( t.pathObj.NumStates );
            pathSegment1 = t.pathObj.States(1:r,:);
            pathSegment2 = t.pathObj.States(r:end,:);
            newPath = [pathSegment2;pathSegment1];
            delete(t.pathObj); % pathObj is read-only so we are deleting it and creating a new one
            t.pathObj = navPath( stateSpaceDubins([-20 120; -20 120; 0 360]) );
            append( t.pathObj, newPath );
        end
        function draw( t, i )
            %% plot threat - draw circle at index i
            x = t.pathObj.States(i,1);
            y = t.pathObj.States(i,2);
            rad = t.radius;

            theta = 0:0.02:2*pi;
            xCoord = x + rad*cos(theta);
            yCoord = y + rad*sin(theta);
            hold on;
            t.plotHandle = plot(xCoord,yCoord,'red','LineWidth',1);
            
        end
    end
end