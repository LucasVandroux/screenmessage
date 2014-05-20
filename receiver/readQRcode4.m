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
        unit = floor(mean(specific_finderPattern_pos(:,3)));

        % Get the position of the lines
        rowcol_pos = findRowColPosition(QRcode, specific_finderPattern_pos, unit, error_max);

        % Read the horizontal and vertical lines
        msg = readLines(QRcode, specific_finderPattern_pos, unit, rowcol_pos);

    else % Return an empty line to alert that the position of the QRcode in the frame have to be compute again
        msg = [];
    end
end

function msg_bits_str = readLines(QRcode, finderPattern_pos, unit, rowcol_pos)
%Read a the horizontal and vertical line of a given QRcode
%   Input: QRcode = the QRcode cropped and with the perspective adjusted
%          finderPattern_pos = the position of the 4 finder patterns
%          unit = size representing the size of a bit of the QRcode
%          rowcol_pos = position of all the limits beetween the lines
%   Output: msg_bits_str = string containing all the bits of the message
    
    % Get the step and the border for each horizontal line
    x_start = floor(finderPattern_pos(1,1) - 3.5 * unit);
    x_stop = ceil(finderPattern_pos(2,1) + 3.5 * unit);
    h_msg_bits = [];
    
    % Read all the horizontal lines
    for i = 2:(size(rowcol_pos, 1)-2)
        line = QRcode(rowcol_pos(i,1):rowcol_pos(i+1,1), x_start:x_stop);
        h_msg_bits = [h_msg_bits ; readLine(line)];
    end
    
     % Get the step and the border for each vertical line
    y_start = floor(finderPattern_pos(1,2) - 3.5 * unit);
    y_stop = ceil(finderPattern_pos(3,2) + 3.5 * unit);
    v_msg_bits = [];
    
    % Read all the vertical lines
    for i = 2:(size(rowcol_pos, 1)-2)
        line = transpose(QRcode(y_start:y_stop, rowcol_pos(i,2):rowcol_pos(i+1,2)));
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

function rowcol_pos = findRowColPosition (QRcode, finderPattern_pos, unit, error_max)
%Read a QRcode once it is found in a picture
%   Input: QRcode = the QRcode cropped and with the perspective adjusted
%          finderPattern_pos = the position of the 4 finder patterns
%          unit = size representing the size of a bit of the QRcode
%          error_max = maximum error tolerated
%   Output: rowcol_pos = matrice containing the limits between each
%                        horizontal and vertical lines in two column vector
    
    % Unit indicating the limits of the timing line from the FP's center
    small_cst = 2.5;
    big_cst = 3.5;
    
    % Getting the position of the FP needed to find the timing lines
    x_pos_FP_lt = finderPattern_pos(1,1);
    x_pos_FP_rt = finderPattern_pos(2,1);
    
    y_pos_FP_lt = finderPattern_pos(1,2);
    y_pos_FP_lb = finderPattern_pos(3,2);

    % Get the row position from the left vertical timing
    v_left_timing = pixelColToSpaces(QRcode(:,floor(x_pos_FP_lt + small_cst*unit):ceil(x_pos_FP_lt + big_cst*unit)));
    v_left_pos = findLinePos(v_left_timing, unit, error_max);
    
    % Get the row position from the right vertical timing
    v_right_timing = pixelColToSpaces(QRcode(:,floor(x_pos_FP_rt - big_cst*unit):ceil(x_pos_FP_rt - small_cst*unit)));
    v_right_pos = findLinePos(v_right_timing, unit, error_max);
    
    % Combine the two lines by computing the mean between the two
    v_pos = [];
    for i = 1:size(v_left_pos, 2)
        v_pos = [v_pos ; floor((v_left_pos(1,i) + v_right_pos(1,i)) / 2)];
    end
    
    % Get the row position from the top horizontal timing
    h_top_timing = pixelColToSpaces(transpose(QRcode(floor(y_pos_FP_lt + small_cst*unit):ceil(y_pos_FP_lt + big_cst*unit),:)));
    h_top_pos = findLinePos(h_top_timing, unit, error_max);
    
    % Get the row position from the bottom horizontal timing
    h_bottom_timing = pixelColToSpaces(transpose(QRcode(floor(y_pos_FP_lb - big_cst*unit):ceil(y_pos_FP_lb - small_cst*unit),:)));
    h_bottom_pos = findLinePos(h_bottom_timing, unit, error_max);
    
    % Combine the two lines  by computing the mean between the two
    h_pos = [];
    for i = 1:size(h_top_pos, 2)
        h_pos = [h_pos ; floor((h_top_pos(1,i) + h_bottom_pos(1,i)) / 2)];
    end
    
    % Combine the two column vector
    rowcol_pos = [v_pos h_pos];
end

function line_pos = findLinePos (spaces, unit, error_max)
%Return the top of each line in the spaces given
%   Input: spaces = vector of color and size of the space of it
%          error_max = error tolerate
%          unit = unit of a pixel in the QRcode
%   Output: line_pos = vector containing the position of the limit between
%           each line

    % Initialize variables
    size_timing = 19;
    line_pos = [];
    
    function index_FP = findSideFinderPattern (index_start, spaces, error_max, unit)
    %Return the index of the first finder pattern side in the spaces
    %   Input: index_start = index where to start looking for the finder
    %                        pattern
    %          spaces = vector of color and size of the space of it
    %          error = error tolerate
    %          unit = unit of a pixel in the QRcode
    %   Output: index_FP = index of the first FP's side founded
        
        % Initialize variables
        index = index_start;
        index_FP = 0;
        
        while index_FP == 0
            % Check if the current space correspond to the finder pattern side
            if spaces(1, index) == 0 && abs(spaces(2, index) - (7 * unit)) <= 4 * error_max
                index_FP = index;
            end
            
            index = index + 1; 
            
            % Put the index_FP to -1 if there is not side finder patter in
            % the spaces
            if index > size(spaces, 2)
                index_FP = -1;
            end
        end
    end
    
    % Find the first side of the finder pattern
    index_first_FP = findSideFinderPattern(1, spaces, error_max, unit);
    
    % Throw an error if there is no finder pattern side in the spaces
    if index_first_FP == -1
        imshow(spaces(1,:));
        error('No Finder Pattern side found in the line.');
    end
    
    x = 0;
    index = index_first_FP + 1;

    while x < size_timing
        if abs(spaces(2, index) - unit) < error_max
            % Record the position of the line up
            line_pos = [line_pos sum(spaces(2,1:(index-1)))];
            x = x + 1;
            index = index + 1;
        else    
            % Merge the small part with the next part
            sum_spaces = sum(spaces(2:index:index+2));
            spaces_row1 = [spaces(1,1:index), spaces(1,(index + 3):end)];
            spaces_row2 = [spaces(2,1:(index - 1)), sum_spaces, spaces(2,(index + 3):end)];
            spaces = [spaces_row1; spaces_row2];
            disp('Merge the small part');
        end
        
        if x == size_timing
            % Take the last limit
            line_pos = [line_pos sum(spaces(2,1:(index-1)))];
        end
    end
end

function spacesBW = pixelColToSpaces(pixel_col)
%Convert the pixel column in black and white spaces using the mean of each
%lines.
%   Input: pixel_col = column of pixels lines
%   Output: spacesBW = matrice containing the best probable color of each line in the first
%                      line and the size(number of lines) of the space on the second.

    spacesBW = [color(pixel_col(1,:)) ; 1];
   
    for y=2:size(pixel_col, 1)
        if color(pixel_col(y,:)) == spacesBW(1, end)
            spacesBW(2, end) = spacesBW(2, end) + 1;
        else
            spacesBW = [spacesBW [color(pixel_col(y,:)); 1]];
        end
    end
end

function color = color(line)
%Compute the color according to the mean of the color of the line
%   Input: line = line of pixel
%   Output: color = color of the line
    color = round(mean(line(:)));
end