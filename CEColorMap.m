% Developer: Tonmoy Ghosh (tghosh@crimson.ua.edu)
function cmap = CEColorMap()
% Define the colormap used by CamVid dataset.

cmap = [
    255 000 000   % "Bleeding"
    000 255 255   % "Non-Bleeding"
    000 000 000   % "Background"
    ];

% Normalize between [0 1].
cmap = cmap ./ 255;
end