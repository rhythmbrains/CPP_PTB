function checkAbortGetResponse(responseEvents, cfg)

    if isfield(responseEvents, 'keyName') > 0 && ...
            any( ...
            strcmpi({responseEvents(:).keyName}, cfg.keyboard.escapeKey) ...
            )
        errorAbortGetReponse;
    end
end
