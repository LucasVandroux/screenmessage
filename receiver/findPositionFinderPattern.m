function FP_Position = findPositionFinderPattern(frame, step, error, unit_min)
%Analyse an image to find the position of the center of the 3 Finder Pattern of the QRcode.
%   Input: frame = a black and white image
%          step = integer to indicate the distance between each line which
%                 are checked for Finder Pattern.
%          error = integer representing the variation of length autorized
%          unit_min = the smallest minimum unit for a Finder Pattern to be
%                     considered.
%   Output: FP_Position = a matrix containing in each row the coordinates of
%                         the center of a Finder Pattern and the unit
%                         width. If less than 3 FP are found, FP_Position
%                         is returned empty.

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
    FP_Position_test = FP_Position
    % Test if the function found at least 3 Finder Pattern
    if size(FP_Position, 1) >= 3
         % Sort the matrix to ouput the 3 bests
        FP_Position = sortrows(FP_Position,-4);
        FP_Position = FP_Position(1:3,1:3);

        % Sort the 3 best point such that the first is the left-top, the second
        % right-top and the last left-bottom
        FP_Position = sortrows(FP_Position, 2);
        FP_Position(1:2,1:3) = sortrows(FP_Position(1:2,1:3), 1);
    else
         FP_Position = [];
    end
   
    
end

function centers = findFinderPattern(lineFrame, error)
%Analyse a line to find the specific pattern for Finder Pattern
%   Input: lineFrame = horizontal vector of black or white pixel
%          error = integer representing the variation of length autorized
%   Output: centers = vector of the index of the center of all the patterns
%                     found in the line and the unit dimension.

    centers = [];
    % Convert the line in black and white spaces
    spacesBW = pixelsToSpaces(lineFrame);
   
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
            % if abs(lW2 - lB1) <= error && abs(lB3 - (3*lB1)) <= error && abs(lW4 - lB1) <= error && abs(lB5 - lB1) <= error && ((lW6 + error) - lB1) >= 0
            if abs(lW2 - lB1) <= error && abs(lB3 - (3*lB1)) <= error && abs(lW4 - lB1) <= error && abs(lB5 - lB1) <= error
                centers = [centers [(sum(spacesBW(2, 1:i+2)) + ceil(lB3 / 2)); mean([lB1 lW2 lW4 lB5])]];
            end       
        end
        i = i + 1;
    end
end

function spaces = pixelsToSpaces (line)
%Convert the pixel line in black and white spaces
%   Input: line = line of pixels
%   Output: space = matrice containing the value of the pixels in the first
%                   line and the size of the space on the second.

    spaces = [line(1) ; 1];
   
    for j=2:size(line, 2)
        if line(j) == spaces(1, end)
            spaces(2, end) = spaces(2, end) + 1;
        else
            spaces = [spaces [line(j); 1]];
        end
    end
end


