function msg = readQRcode4(frame_BW, finderPatterns_pos, marge, error_max, step, unit_min)
%Read a QRcode once it is found in a picture
%   Input: frame_BW = the frame where the QRcode is in Black and white
%          finderPattern_pos = the position of the 4 finder patterns
%          marge = marge to crop the QRcode around the finder patterns
%          error_max = error tolerate
%          step = integer to indicate the distance between each line which
%                 are checked to find the Finder Pattern.
%          unit_min = the smallest minimum unit for a Finder Pattern to be
%                     considered.
%   Output: msg = message bit after bit
    
    % Crop the QRcode according to the general info
    QRcode = getQRcodeImage4(frame_BW, finderPatterns_pos, marge);
    
    % TEST --- Show the QRcode
     imshow(QRcode);
    
    % Relocate the Finder Pattern in the QRcode
    specific_finderPattern_pos = findPositionFinderPattern4(QRcode, step, error_max, unit_min);
    
    % Check if we were able to find the QRcode in the given dimensions
    if ~isempty(specific_finderPattern_pos)
        % Read the horizontal and vertical lines
        msg = readLines(QRcode, specific_finderPattern_pos);

    else % Return an empty line to alert that the position of the QRcode in the frame have to be compute again
        msg = [];
    end
end

function msg_bits_str = readLines(QRcode, FP_pos)
%Read a the horizontal and vertical line of a given QRcode
%   Input: QRcode = the QRcode cropped and with the perspective adjusted
%          finderPattern_pos = the position of the 4 finder patterns
%          unit = size representing the size of a bit of the QRcode
%          rowcol_pos = position of all the limits beetween the lines
%   Output: msg_bits_str = string containing all the bits of the message
    
    % Initialize the variable
    step = 17; 
    unit_v = ceil((FP_pos(3,2) - FP_pos(1,2))/26);
    unit_h = ceil((FP_pos(2,1) - FP_pos(1,1))/26);
    
    % Get the step and the border for each horizontal line
    x_start = floor(FP_pos(1,1) - 3.5 * unit_h);
    x_stop = ceil(FP_pos(2,1) + 3.5 * unit_h);
    
    % Crop and rescale the region of interest for the horizontal lines
    QRcode_hlines = QRcode(floor(FP_pos(1,2) + 4.5 * unit_v):ceil(FP_pos(3,2) - 4.5 * unit_v), x_start:x_stop);
    QRcode_hlines_rescal = imresize(QRcode_hlines, [289 NaN]); % Rescale the QRcode horizontal lines to have a multiple of 17
 
    h_msg_bits = [];
    
    % Read all the horizontal lines
    for i = 1:17
        line = QRcode_hlines_rescal((1 + step*(i-1)):(step*i), :);
        h_msg_bits = [h_msg_bits ; readLine(line)];
    end
    
     % Get the step and the border for each vertical line
    y_start = floor(FP_pos(1,2) - 3.5 * unit_v);
    y_stop = ceil(FP_pos(3,2) + 3.5 * unit_v);
    
    % Crop and rescale the region of interest for the vertical lines
    QRcode_vlines = QRcode(y_start:y_stop, floor(FP_pos(1,1) + 4.5 * unit_h):ceil(FP_pos(2,1) - 4.5 * unit_h));
    QRcode_vlines_rescal = imresize(QRcode_vlines, [NaN 289]); % Rescale the QRcode vertical lines to have a multiple of 17
    
    v_msg_bits = [];
    
    % Read all the horizontal lines
    for i = 1:17
        line = transpose(QRcode_vlines_rescal(:,(1 + step*(i-1)):(step*i)));
        v_msg_bits = [v_msg_bits ; readLine(line)];
    end
    
    % Get each part from the horizontal lines
    msg_0_to_101 = [];
    msg_102_to_203 = [];
    msg_408_to_730 = [];
    
    for i = 1:17
        msg_0_to_101 = [msg_0_to_101, h_msg_bits(i,1:6)];
        msg_102_to_203 = [msg_102_to_203, h_msg_bits(i,28:33)];
        msg_408_to_730  = [msg_408_to_730, h_msg_bits(i,8:26)];
    end
    
    % Get each part from the vertical lines
    msg_204_to_305 = [];
    msg_306_to_407 = [];
    
    for i = 1:6
        msg_306_to_407 = [msg_306_to_407, transpose(v_msg_bits(:,i))];
    end
    
    for i = 28:33
        msg_204_to_305 = [msg_204_to_305, transpose(v_msg_bits(:,i))];
    end
    
    msg_731_to_747 = transpose(v_msg_bits(:,8));
    msg_748_to_759 = transpose(v_msg_bits(1:12,26));
    
    % Merge all the part together
    msg_bits = [msg_0_to_101, msg_102_to_203, msg_204_to_305, msg_306_to_407, msg_408_to_730, msg_731_to_747, msg_748_to_759];
    
    % Convert the matrice in string
    msg_bits_str = sprintf('%d', msg_bits);
end

function msg_line = readLine(line)
%Read a given line to translate it in bits
%   Input: line = matrices containing black and white pixels
%          step = width of a bit
%   Output: msg_line = bits contained in the line
    msg_line = ones(1,33);
    line_rescal = imresize(line, [NaN 363]); % Rescale the line to have a multiple of 33
    step = 11;
        
    for i = 1:33
        msg_line(1,i) = round(mean2(line_rescal(:,(1 + step*(i-1)):(step*i)))); 
    end
end