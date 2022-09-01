% (C) Copyright 2020 CPP visual motion localizer developpers

function [cfg] = postInitializationSetup(cfg)

    % generic function to finalize some set up after psychtoolbox has been
    % initialized

    cfg = initFixation(cfg);

end
