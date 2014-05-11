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
    
    % TEST----Display the original frame and the BW one.
    subplot(1,2,1), imshow(frame);
    subplot(1,2,2), imshow(frame_BW);
   

% TODO----Waiting for the initial_img----

% TODO----When the initial_img detected find the roi----

    % TODO----Process the frame to extract the roi----

    % TODO----Translate the roi into a bit sequence----

    % TODO----Process the bit sequence to output the message----
    
    % End
%Test should return 0.2222
whitePercentage([0.2 0.3 0.1, 0.5 0.6 0.1, 0.0 0.0 0.2])

message = 'End of the receiver function.';
end

% In a grayscale image 0.0 = black and 1.0 = white
function percentage = whitePercentage (grayImg);

percentage = mean(grayImg); 
end