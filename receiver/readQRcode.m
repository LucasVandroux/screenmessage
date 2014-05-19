function msg = readQRcode(frame_BW, finderPatterns_pos, marge, error_max)
%Read a QRcode once it is found in a picture
%   Input: frame_BW = the frame where the QRcode is in Black and white
%          finderPattern_pos = the position of the 3 finder patterns
%          marge = marge to crop the QRcode around the finder patterns
%          error_max = error tolerate
%   Output: msg = message bit after bit
    unit = mean(finderPatterns_pos(:,3));
    QRcode = getQRcodeImage(frame_BW, finderPatterns_pos, marge);
    
    imshow(QRcode);
    
    rowcol_pos = findRowColPosition(QRcode, marge, unit, error_max);
    
    msg = rowcol_pos;
end

function rowcol_pos = findRowColPosition (QRcode, marge, unit, error_max)
    marge_length = marge * unit;
    small_cst = 3;
    big_cst = 4;
    v_left_timing = pixelColToSpaces(QRcode(:,floor(marge_length + small_cst*unit):ceil(marge_length + big_cst*unit)));
    
    imshow(QRcode(:,floor(marge_length + small_cst*unit):ceil(marge_length + big_cst*unit)));
    
    v_left_pos = findLinePos(v_left_timing, unit, error_max);
    
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
    
    rowcol_pos = v_left_pos;
end

function line_pos = findLinePos (spaces, unit, error_max)
%Return the top of each line in the spaces given
%   Input: spaces = vector of color and size of the space of it
%          error_max = error tolerate
%          unit = unit of a pixel in the QRcode
    size_big_timing = 26;
    size_small_timing = 19;
    size_timing = 0;
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
   
    % Find the second side of the other finder pattern (if it exist)
    index_end_FP = findSideFinderPattern((index_first_FP + 1), spaces, error_max, unit);
    
    % Check if this is a small or a big timing and set the size
    if index_end_FP == -1
        size_timing = size_big_timing;
    else
        size_timing = size_small_timing;
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
            spaces = [spaces(:,1:(index - 1)) spaces(1, index) spaces(1,(index + 3):end); spaces(2,1:(index - 1)) sum(spaces(2:index:index+2)) spaces(2,(index + 3):end)];
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