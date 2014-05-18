% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: April 2014
% Version: 1
%
function message = receiver()

% TODO----Webcam Capture----


% Image process the picture to return a black and white picture.
    %Get the frame
    % frame = imread('message1-1-test.png');
    % frame = imread('Hello_World-test.jpg');
    % frame = imread('testimg1.jpg');
    frame = imread('message1-1.jpg');
    
    
    % Turn it black and white 
    %TODO-----Find a way to have a good theresold (try multiple one for the same picture)
    %frame_BW = im2bw(frame, 0.43);
    frame_BW = im2bw(frame, 0.40);
    imwrite(frame_BW, 'test.png');
    
    % TEST----Display the original frame and the BW one.
     subplot(1,2,1), imshow(frame);
     subplot(1,2,2), imshow(frame_BW);
     
    %findFinderPattern(frame_BW(140,:), 10)
     
    
    imshow(getQRcodeImage(frame_BW, 20, 10, 10));

% Finding the finder pattern 
    
% TODO----Waiting for the initial_img----

% TODO----When the initial_img detected find the roi----

    % TODO----Process the frame to extract the roi----

    % TODO----Translate the roi into a bit sequence----

    % TODO----Process the bit sequence to output the message----
    
    % End

message = 'End of the receiver function.';
end