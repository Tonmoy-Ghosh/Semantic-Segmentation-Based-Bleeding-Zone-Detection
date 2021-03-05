% Developer: Tonmoy Ghosh (tghosh@crimson.ua.edu)
function labelIDs = PixelLabelIDs()
labelIDs = { ...
    
    % "Bleeding"
    [
    255 000 000; ... % "Bleeding"
    ]
    
    % "Non-Bleeding"
    [
    000 255 255; ... % "Non-Bleeding"
    ]
    
    % "Background" 
    [
    000 000 000; ... % "Background"
    ]
    

    };
end