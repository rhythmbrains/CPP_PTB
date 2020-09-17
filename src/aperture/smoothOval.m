% (C) Copyright 2010-2020 Sam Schwarzkopf
% (C) Copyright 2020 CPP_PTB developers

function smoothOval(win, color, rect, fringe)
    % SmoothOval(WindowPtr, Color, Rect, Fringe)
    %
    % Draws a filled oval (using the PTB parameters) with a transparent fringe.
    %

    alphas = linspace(0, 255, fringe);

    for f = 0:fringe - 1
        Screen('FillOval', win, ...
            [color alphas(f + 1)], ...
            [rect(1) + f rect(2) + f rect(3) - f rect(4) - f]);
    end
