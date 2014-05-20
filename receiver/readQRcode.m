function msg = readQRcode(frame_BW, finderPatterns_pos, marge, error_max, step, unit_min)
%Read a QRcode once it is found in a picture
%   Input: frame_BW = the frame where the QRcode is in Black and white
%          finderPattern_pos = the position of the 3 finder patterns
%          marge = marge to crop the QRcode around the finder patterns
%          error_max = error tolerate
%   Output: msg = message bit after bit
    
    % Crop the QRcode according to the general info
    QRcode = getQRcodeImage(frame_BW, finderPatterns_pos, marge);
    
    % TEST --- Show the QRcode
    imshow(QRcode);
    
    % Relocate the Finder Pattern in the QRcode
    specific_finderPattern_pos = findPositionFinderPattern(QRcode, step, error_max, unit_min);
    if isempty(specific_finderPattern_pos)
        error('Bad cropping data.');
    end
    unit = floor(mean(specific_finderPattern_pos(:,3)));
    
    % TEST --- Show the QRcode
    imshow(QRcode);
    
    % Get the position of the line
    rowcol_pos = findRowColPosition(QRcode, specific_finderPattern_pos, unit, error_max);
    
    % Read the horizontal and vertical lines
    msg = readLines(QRcode, specific_finderPattern_pos, unit, rowcol_pos);
end

function msg_bits = readLines(QRcode, finderPattern_pos, unit, rowcol_pos)
    x_start = finderPattern_pos(1,1) - 3.5 * unit;
    x_stop = finderPattern_pos(2,1) + 3.5 * unit;
    x_step = floor((x_stop - x_start) / 33);
    h_msg_bits = [];
    
    for i = 2:(size(rowcol_pos, 1)-2)
        line = QRcode(rowcol_pos(i,1):rowcol_pos(i+1,1), x_start:x_stop);
        h_msg_bits = [h_msg_bits ; readLine(line, x_step)];
    end
    
    msg_bits = h_msg_bits;
end

function msg_line = readLine(line, step)
    msg_line = ones(1,33);
    
    for i = 1:33
        msg_line(1,i) = round(mean(line(:,(1 + step*(i-1)):(step*i)))); 
    end
end

function rowcol_pos = findRowColPosition (QRcode, finderPattern_pos, unit, error_max)
    small_cst = 2.5;
    big_cst = 3.5;
    
    x_pos_FP_lt = finderPattern_pos(1,1);
    x_pos_FP_rt = finderPattern_pos(2,1);
    
    y_pos_FP_lt = finderPattern_pos(1,2);
    y_pos_FP_lb = finderPattern_pos(3,2);

    % Get the row position from the left vertical timing
    v_left_timing = pixelColToSpaces(QRcode(:,floor(x_pos_FP_lt + small_cst*unit):ceil(x_pos_FP_lt + big_cst*unit)));
    imshow(QRcode(:,floor(x_pos_FP_lt + small_cst*unit):ceil(x_pos_FP_lt + big_cst*unit)));
    v_left_pos = findLinePos(v_left_timing, unit, error_max);
    
    % Get the row position from the right vertical timing
    v_right_timing = pixelColToSpaces(QRcode(:,floor(x_pos_FP_rt - big_cst*unit):ceil(x_pos_FP_rt - small_cst*unit)));
    imshow(QRcode(:,floor(x_pos_FP_rt - big_cst*unit):ceil(x_pos_FP_rt - small_cst*unit)));
    v_right_pos = findLinePos(v_right_timing, unit, error_max);
    
    % Combine the two lines
    v_pos = [];
    for i = 1:size(v_left_pos, 2)
        v_pos = [v_pos ; floor((v_left_pos(1,i) + v_right_pos(1,i)) / 2)];
    end
    
    % Get the row position from the top horizontal timing
    h_top_timing = pixelColToSpaces(transpose(QRcode(floor(y_pos_FP_lt + small_cst*unit):ceil(y_pos_FP_lt + big_cst*unit),:)));
    imshow(transpose(QRcode(floor(y_pos_FP_lt + small_cst*unit):ceil(y_pos_FP_lt + big_cst*unit),:)));
    h_top_pos = findLinePos(v_left_timing, unit, error_max);
    
    % Get the row position from the bottom horizontal timing
    h_bottom_timing = pixelColToSpaces(transpose(QRcode(floor(y_pos_FP_lb - big_cst*unit):ceil(y_pos_FP_lb - small_cst*unit),:)));
    imshow(transpose(QRcode(floor(y_pos_FP_lb - big_cst*unit):ceil(y_pos_FP_lb - small_cst*unit),:)));
    h_bottom_pos = findLinePos(v_left_timing, unit, error_max);
    
    % Combine the two lines
    h_pos = [];
    for i = 1:size(h_top_pos, 2)
        h_pos = [h_pos ; floor((h_top_pos(1,i) + h_bottom_pos(1,i)) / 2)];
    end
    
    % TODO when we have the coordinate of each frontier between line, we
    % can take the mean between the two of each side of the QRcode.
    
    % After this, we can analyse line by line define by the coordinate
    % found previously to calculate the mean of each square representing a
    % pixel
    
    % Do it vertically and horizontaly and put the bits in the right order
    % to get the message.
    
    % When we have the two matrix representing the byte. We can add them
    % together to have the total msg. We can also compare the byte we have
    % in two form to see if there are some errors.
    
    rowcol_pos = [v_pos h_pos];
end

function line_pos = findLinePos (spaces, unit, error_max)
%Return the top of each line in the spaces given
%   Input: spaces = vector of color and size of the space of it
%          error_max = error tolerate
%          unit = unit of a pixel in the QRcode
    size_timing = 19;
    line_pos = [];
    
    function index_FP = findSideFinderPattern (index_start, spaces, error_max, unit)
    %Return the index of the first finder pattern side in the spaces
    %   Input: index_start = index where to start looking for the finder
    %                        pattern
    %          spaces = vector of color and size of the space of it
    %          error = error tolerate
    %          unit = unit of a pixel in the QRcode
        size(spaces)
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
    
    % Throw an error if there is not finder patter side in the spaces
    if index_first_FP == -1
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
            size_spaces_row1 = size(spaces_row1)
            size_spaces_row2 = size(spaces_row2)
            spaces = [spaces_row1; spaces_row2];
        end
        
        if x == size_timing
            line_pos = [line_pos sum(spaces(2,1:(index-1)))];
        end
    end
end

function spacesBW = pixelColToSpaces(pixel_col)
%Convert the pixel column in black and white spaces using the mean of each
%lines.
%   Input: pixel_col = column of pixels lines
%   Output: spacesBW = matrice containing the best probable color of each line in the first
%                      line and the size of the space on the second.

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