function draw_circle( threat )
    x = threat(1);
    y = threat(2);
    rad = threat(3);
    
    hold on;
    theta = 0:0.1:2*pi;
    xCoord = x + rad*cos(theta);
    yCoord = y + rad*sin(theta);
    c = plot(xCoord,yCoord);
    patch(xCoord,yCoord,[1 0.5 0.5], 'EdgeColor', [1 0.3 0.3]);
end