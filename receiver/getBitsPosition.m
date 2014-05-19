% Get the position of the bytes in the frame using the QRcode
% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: May 2014
% Version: 1
%
function bits_pos = getBitsPosition(frame, step, error, unit_min)

     % Find the coordinate and the unit of the Qrcode in the frame
    finderPattern_pos = findPositionFinderPattern(frame, step, error, unit_min);
    
    % Get the vertical timing line
    
    timing_pos = getTimingPosition([0 0 1 1 1 0 0 0 1 1 1 0 0 0 1 1 1 0])

    bits_pos = getQRcodeImage(frame, finderPattern_pos, 4.5);
end

% Return the position of the middle of each space
% Input: timing_line = line of pixel in which there is the timing sequence
% Output: timing_pos = position of the center of each space according to
%                      the timing_line size.
function timing_pos = getTimingPosition(timing_line)
    % Initialize
    timing_pos = [];
    start_thereshold = 0;
    
    % Get the timing_line in space of black and white pixel
    timing_spaces = pixelsToSpaces(timing_line);
    
    % Be sure the first space is white
    if timing_spaces(1,1) == 0
        start_thereshold = timing_spaces(2,1);
        timing_spaces = timing_spaces(:,2:end);
    end
    
    % Be sure the last space is white
    if timing_spaces(1,end) == 0
        timing_spaces = timing_spaces(:,1:(end -1));
    end
    
    % Find the center of each timing
    for i = 1:size(timing_spaces, 2)
        timing_pos = [timing_pos (start_thereshold + ceil(timing_spaces(2,i)/2) + sum(timing_spaces(2,1:(i-1))))];
    end
    
end

% Return the QRcode image cropped
% Input: frame = a black and white image
%        finderPattern_pos = the position of the 3 finder pattern in the
%                            frame
%        cst_marge = the marge from the center of the finder pattern to
%                    crop the QRcode.
% Output: QRcode_img = QRcode cropped
function QRcode_img = getQRcodeImage(frame, finderPattern_pos, cst_marge)

    unit_max = max (finderPattern_pos(:, 3));
    marge = ceil(unit_max * cst_marge);
    x_min = min(finderPattern_pos(:, 1)) - marge;
    x_max = max(finderPattern_pos(:, 1)) + marge;
    y_min = min(finderPattern_pos(:, 2)) - marge;
    y_max = max(finderPattern_pos(:, 2)) + marge;
    
    QRcode_img = frame(y_min:y_max, x_min:x_max);
end


