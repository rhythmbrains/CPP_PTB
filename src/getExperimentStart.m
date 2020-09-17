% (C) Copyright 2020 CPP_PTB developers

function cfg = getExperimentStart(cfg)
    % cfg = getExperimentStart(cfg)
    %
    % Stores the onset time in cfg.experimentStart

    drawFixation(cfg);
    vbl = Screen('Flip', cfg.screen.win);
    cfg.experimentStart = vbl;

end
