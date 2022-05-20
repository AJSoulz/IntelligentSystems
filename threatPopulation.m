classdef threatPopulation < handle
    properties
        threats
    end
    methods
        function T = threatPopulation( popSize )
            if( nargin > 0 )
                for i = 1:popSize
                    o = randi([15 85]);   % location offset
                    r = randi([5 25]);    % radius
                    d = mod(i,2);         % direction (horizontal/vertical)
                    s = r*randi([20 150]); % speed (lower=faster)
                    newThreat = threat(o,r,d,s);
                    T.threats = [T.threats; newThreat];
                end
            end
        end
    end
end