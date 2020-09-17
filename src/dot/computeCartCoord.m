% (C) Copyright 2020 CPP_PTB developers

function cartesianCoordinates = computeCartCoord(positions, cfg)
    cartesianCoordinates = ...
        [positions(:, 1) + cfg.dot.matrixWidth, ... % x coordinate
        positions(:, 2) + cfg.dot.matrixWidth]; % y coordinate

    %         cartesianCoordinates = positions;
end
