% Developer: Tonmoy Ghosh (tghosh@crimson.ua.edu)
function pxds = resizeCEPixelLabels(pxds, labelFolder)
% Resize pixel label data to [360 480].

classes = pxds.ClassNames;
labelIDs = 1:numel(classes);
if ~exist(labelFolder,'dir')
    mkdir(labelFolder)
%else
    %pxds = pixelLabelDatastore(labelFolder,classes,labelIDs);
    %return; % Skip if images already resized
end

reset(pxds)
while hasdata(pxds)
    % Read the pixel data.
    [C,info] = read(pxds);

    % Convert from categorical to uint8.
    L = uint8(C{1});

    % Resize the data. Use 'nearest' interpolation to
    % preserve label IDs.
    L = imresize(L,[256 256],'nearest');

    % Write the data to disk.
    [~, filename, ext] = fileparts(info.Filename);
    imwrite(L,[labelFolder filename ext])
end

pxds = pixelLabelDatastore(labelFolder,classes,labelIDs);
end