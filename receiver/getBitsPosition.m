% Get the position of the bytes in the frame using the QRcode
% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: April 2014
% Version: 1
%
function bits_pos = getBitsPosition(frame, step, error, unit_min)

     % Find the coordinate and the unit of the Qrcode in the frame
    finderPattern_pos = findPositionFinderPattern(frame, step, error, unit_min);
        

    bits_pos = getQRcodeImage(frame, finderPattern_pos, 4.5);
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

% Analyse an image to find the position of the center of the 3 Finder
% Pattern of the QRcode.
% Input: frame = a black and white image
%        step = integer to indicate the distance between each line which
%               are checked for Finder Pattern.
%        error = integer representing the variation of length autorized
%        unit_min = the smallest minimum unit for a Finder Pattern to be
%                   considered.
% Output: FP_Position = a matrix containing in each row the coordinates of
%                       the center of a Finder Pattern and the unit width
function FP_Position = findPositionFinderPattern(frame, step, error, unit_min)
    % Initialize
    FP_Position = [];
    j = 1;
    
    % Go throught the image
    while j < floor(size(frame, 1)/step)
        % Look for Finder Pattern in the line
        row = j * step;
        centers = findFinderPattern(frame(row,:), error);
        
        % If Finder Pattern found then...
        if ~isempty(centers)  % If not empty
            % For each center found check the verticality
            for i = 1:size(centers, 2)
                % We test 3 vertical line which have to be in the Finder Pattern
                unit = floor(centers(2, i));
                middle = centers(1, i);
                
                if unit > unit_min % Discard the small one
                    % Determine a frame according to the cut_range where the
                    % Finder Pattern is. 
                    start_FP = ceil(row - 6 * unit);
                    end_FP = floor(row + 6 * unit);
                    
                    % Check if the selected index are not outside the frame
                    if start_FP < 1
                        start_FP = 1;
                    end
                    if end_FP > size(frame, 1)
                        end_FP = size(frame, 1);
                    end;

                    % Check the three different lines
                    verticalFrame_left = transpose (frame(start_FP:end_FP, middle-unit));
                    verticalFrame_center = transpose (frame(start_FP:end_FP, middle));
                    verticalFrame_right = transpose (frame(start_FP:end_FP, middle+unit));

                    center = [findFinderPattern(verticalFrame_left, error) findFinderPattern(verticalFrame_center, error) findFinderPattern(verticalFrame_right, error)];
                    
                    % If two line are finding a pattern it's ok
                    if size(center, 2) >= 2 && size(center, 2) <= 3
                        x_pos = centers(1,i);
                        y_pos = floor(mean(center(1, :)) + start_FP);
                        
                        % Populate the matrix
                        if isempty(FP_Position)
                            
                            FP_Position = [x_pos y_pos centers(2, i) 1];
                        
                        else
                            
                            m = 1;
                            placed = 0;
                            
                            while placed == 0
                                % If already in the matrix add 1 point
                                if abs(x_pos - FP_Position(m,1)) < error && abs(y_pos - FP_Position(m,2)) < error
                                    x_pos = floor(mean([FP_Position(m, 1) x_pos]));
                                    y_pos = floor(mean([FP_Position(m, 2) y_pos]));
                                    unit = mean([FP_Position(m, 3) unit]);
                                    points = FP_Position(m, 4) + 1;

                                    FP_Position(m,:) = [ x_pos y_pos unit points];

                                    placed = 1;
                                end
                                
                                m = m + 1;
                                
                                %If not in the matrix add it 
                                if m > size(FP_Position, 1) && placed == 0
                                    FP_Position = [FP_Position ; [x_pos y_pos centers(2, i) 1]];
                                    placed = 1;
                                end
                            end
                        end
                    end
                end
            end
        end
        j = j + 1;
    end
    % Sort the matrix to ouput the 3 bests
    FP_Position = sortrows(FP_Position,-4);
    FP_Position = FP_Position(1:3,1:3);
    
end

% Analyse a line to find the specific pattern for Finder Pattern
% Input: lineFrame = horizontal vector of black or white pixel
%        error = integer representing the variation of length autorized
% Output: centers = vector of the index of the center of all the patterns
%                   found in the line and the unit dimension.
function centers = findFinderPattern(lineFrame, error)
    centers = [];
    spacesBW = [lineFrame(1) ; 1];
    % Convert the line in black and white spaces
    for j=2:size(lineFrame, 2)
        if lineFrame(j) == spacesBW(1, end)
            spacesBW(2, end) = spacesBW(2, end) + 1;
        else
            spacesBW = [spacesBW [lineFrame(j); 1]];
        end
    end
    % Search for the pattern
    i = 1;
    while(i <= size(spacesBW, 2) - 6)
        if spacesBW(1,i) == 1
            lB1 = spacesBW(2, (i+1));
            lW2 = spacesBW(2, (i+2));
            lB3 = spacesBW(2, (i+3));
            lW4 = spacesBW(2, (i+4));
            lB5 = spacesBW(2, (i+5));
            lW6 = spacesBW(2, (i+6));
            
            % Check if the actual pattern is matching the Finder Pattern
            if abs(lW2 - lB1) <= error && abs(lB3 - (3*lB1)) <= error && abs(lW4 - lB1) <= error && abs(lB5 - lB1) <= error && ((lW6 + error) - lB1) >= 0
                centers = [centers [(sum(spacesBW(2, 1:i+2)) + ceil(lB3 / 2)); mean([lB1 lW2 lW4 lB5])]];
            end       
        end
        i = i + 1;
    end
end

