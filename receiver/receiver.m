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
    %TODO-----Find a way to have a good theresold
    frame_BW = im2bw(frame, 0.43);
    imwrite(frame_BW, 'test.png');
    
    % TEST----Display the original frame and the BW one.
    subplot(1,2,1), imshow(frame);
    subplot(1,2,2), imshow(frame_BW);
    
    findFinderPattern(frame_BW(600,:),10)

% Finding the finder pattern 
    
% TODO----Waiting for the initial_img----

% TODO----When the initial_img detected find the roi----

    % TODO----Process the frame to extract the roi----

    % TODO----Translate the roi into a bit sequence----

    % TODO----Process the bit sequence to output the message----
    
    % End

message = 'End of the receiver function.';
end

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
                centers = [centers (sum(spacesBW(2, 1:i+2)) + ceil(lB3 / 2))];
            end
            
            i = i + 1;
        end
    end
end