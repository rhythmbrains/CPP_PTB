% (C) Copyright 2020 CPP_PTB developers

function newPositions = generateNewDotPositions(cfg, dotNumber)

    newPositions = rand(dotNumber, 2) * cfg.dot.matrixWidth;

end
