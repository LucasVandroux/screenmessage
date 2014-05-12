% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: April 2014
% Version: 1
%
function message = receiver()

% TODO----Webcam Capture----


% Image process the picture to return a black and white picture.
    %Get the frame
    frame = imread('testimg1.jpg');
    % Turn it black and white 
    %TODO-----Find a way to have a good theresold (try multiple one for the same picture)
    %frame_BW = im2bw(frame, 0.43);
    frame_BW = im2bw(frame, 0.40);
    imwrite(frame_BW, 'test.png');
    
    % TEST----Display the original frame and the BW one.
     subplot(1,2,1), imshow(frame);
     subplot(1,2,2), imshow(frame_BW);
    
    %
    %findFinderPattern(frame_BW(600,:),10)
    findPositionFinderPattern(frame_BW, 20, 7)

% Finding the finder pattern 
    
% TODO----Waiting for the initial_img----

% TODO----When the initial_img detected find the roi----

    % TODO----Process the frame to extract the roi----

    % TODO----Translate the roi into a bit sequence----

    % TODO----Process the bit sequence to output the message----
    
    % End

message = 'End of the receiver function.';
end

% Analyse an image to find the position of the center of the 3 Finder
% Pattern of the QRcode.
% Input: frame = a black and white image
%        step = integer to indicate the distance between each line which
%               are checked for Finder Pattern.
%        error = integer representing the variation of length autorized
% Output: FP_Position = a matrix containing in each row the coordinates of
%                       the center of a Finder Pattern
% TODO---Also give the distance from the webcam
function FP_Position = findPositionFinderPattern(frame, step, error)
    FP_Position = [];
    cut_range = 10;
    j = 1;
    while j < floor(size(frame, 1)/step)
        row = j * step;
        centers = findFinderPattern(frame(row,:), error);
        if ~isempty(centers) % If not empty
            for i = 1:size(centers, 2)
                % We restrict a vertical line to check if it's a Finder Pattern 
                start_FP = ceil(row - cut_range * centers(2, i));
                end_FP = floor(row + cut_range * centers(2, i));
                verticalFrame = transpose (frame(start_FP:end_FP, centers(1, i)));
                center = findFinderPattern(verticalFrame, error);
                %TODO----Test 3 other possibility to avoid problem and
                %noise
                if ~isempty(center) %If not empty
                    row_position = center(1, 1) + start_FP;
                    FP_Position = [FP_Position [row_position; centers(1, i); centers(2, i)]];
                    j = j + cut_range;
                    continue
                end
            end
        end
        j = j + 1;
    end
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
    while(i < size(spacesBW, 2) - 6)
        if spacesBW(1,i) == 0
            i = i + 1;
        else
            lB1 = spacesBW(2, (i+1));
            lW2 = spacesBW(2, (i+2));
            lB3 = spacesBW(2, (i+3));
            lW4 = spacesBW(2, (i+4));
            lB5 = spacesBW(2, (i+5));
            lW6 = spacesBW(2, (i+6));
            
            if i == 3
               
            end
            
            if abs(lW2 - lB1) <= error && abs(lB3 - (3*lB1)) <= error && abs(lW4 - lB1) <= error && abs(lB5 - lB1) <= error && ((lW6 + error) - lB1) >= 0
                centers = [centers [(sum(spacesBW(2, 1:i+2)) + ceil(lB3 / 2)); mean([lB1 lW2 lW4 lB5])]];
            end
            
            i = i + 1;
        end
    end
end