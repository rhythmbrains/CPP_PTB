function structure = degToPix(fieldName, structure, cfg)
    % structure = degToPix(fieldName, structure, cfg)
    %
    % For a given field value in degrees of visual angle in the structure,
    % this computes its value in pixel using the pixel per degree value of the cfg structure
    % and returns a structure with an additional field with Pix suffix holding that new value.
    %
    %
    % USAGE:
    % ------
    % fixation.width = 2;
    % cfg.screen.ppd = 10;
    %
    % fixation = degToPix('width', fixation, cfg);
    %
    % Returns:
    % -------
    % fixation.widthPix = 20;
    %

    deg = getfield(structure, fieldName); %#ok<GFLD>

    structure = setfield(structure, [fieldName 'Pix'], ...
                         floor(deg * cfg.screen.ppd)); %#ok<SFLD>

end
