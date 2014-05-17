% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: April 2014
% Version: 1
%
function message = receiver()

% TODO----Webcam Capture----


% Image process the picture to return a black and white picture.
    %Get the frame
    frame = imread('message1-1-test.png');
    % frame = imread('Hello_World-test.jpg');
    % frame = imread('testimg1.jpg');
    % Turn it black and white 
    %TODO-----Find a way to have a good theresold (try multiple one for the same picture)
    %frame_BW = im2bw(frame, 0.43);
    frame_BW = im2bw(frame, 0.40);
    imwrite(frame_BW, 'test.png');
    
    % TEST----Display the original frame and the BW one.
     subplot(1,2,1), imshow(frame);
     subplot(1,2,2), imshow(frame_BW);
     
     findFinderPattern(frame_BW(720,:), 10)
     
    
    imshow(getQRcodeImage(frame_BW, 1, 5, 5));

% Finding the finder pattern 
    
% TODO----Waiting for the initial_img----

% TODO----When the initial_img detected find the roi----

    % TODO----Process the frame to extract the roi----

    % TODO----Translate the roi into a bit sequence----

    % TODO----Process the bit sequence to output the message----
    
    % End

message = 'End of the receiver function.';
end

% Get the Qrcode image
function QRcode_img = getQRcodeImage(frame, step, error, unit_min)
    cst_marge = 4.5;
    
    % Find the coordinate and the unit of the Qrcode in the frame
    FinderPattern_pos = findPositionFinderPattern(frame, step, error, unit_min);
    
    unit_max = max (FinderPattern_pos(:, 3));
    marge = ceil(unit_max * cst_marge);
    x_min = min(FinderPattern_pos(:, 1)) - marge;
    x_max = max(FinderPattern_pos(:, 1)) + marge;
    y_min = min(FinderPattern_pos(:, 2)) - marge;
    y_max = max(FinderPattern_pos(:, 2)) + marge;
    
    QRcode_img_notranslate = frame(y_min:y_max, x_min:x_max);
    
    % find the angle to retablish the QRcode
    upper_FP = sortrows(FinderPattern_pos, 2);
    upper_FP = upper_FP(1:2, 1:2);
    height = abs(upper_FP(1,2) - upper_FP(2,2));
    width = abs(upper_FP(1,1) - upper_FP(2,1));
    angle = - atand(height/width);
    
    tform = affine2d([1 0 0; 0.5 1 0; 0 0 1]);

    % Fill with gray and use bicubic interpolation. 
    % Make the output size the same as the input size.
    
    % http://www.particleincell.com/blog/2012/quad-interpolation/
    % http://www.mathworks.fr/fr/help/images/ref/imtransform.html

    % QRcode_img = imwarp(QRcode_img_notranslate,tform,'FillValues',[1]);
    
    %QRcode_img = imrotate(QRcode_img_notranslate, angle,'bilinear','crop');
    
    QRcode_img = QRcode_img_notranslate;
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
                                if abs(x_pos - FP_Position(m,1)) < error && abs(x_pos - FP_Position(m,1)) < error
                                    x_pos = floor(mean([FP_Position(m, 1) x_pos]));
                                    y_pos = floor(mean([FP_Position(m, 2) y_pos]));
                                    unit = mean([FP_Position(m, 3) unit]);
                                    points = FP_Position(m, 4) + 1;

                                    FP_Position(m,:) = [ x_pos y_pos unit points];

                                    placed = 1;
                                end
                                
                                m = m + 1;
                                
                                %If not in the matrix add it 
                                if m >= size(FP_Position, 1) && placed == 0
                                    FP_Position = [FP_Position ; [x_pos y_pos centers(2, i) 1]];
                                    placed == 1;
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