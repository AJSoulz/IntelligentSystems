function lineLength = myDistance( pos1, pos2 )
    x1 = pos1(1,1);
    y1 = pos1(1,2);
    x2 = pos2(1,1);
    y2 = pos2(1,2);
    lineLength = sqrt( (x1-x2)^2 + (y1-y2)^2 );
end