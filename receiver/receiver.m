% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: May 2014
% Version: 2
%
function message = receiver()

    % -----Webcam Initialization-----
    % Initialization of the object to contain the webcam
    cam = [];
    % Check if the matlab can see the webcam
    if isempty(webcamlist)
        error('No webcam detected on this computer.')
    else
        cam = webcam;
        disp([get(cam, 'Name'), ' is now selected with resolution ',get(cam, 'Resolution'), '.']);
    end
    
    % -----Webcam Capture-----
    reading = 0;
    finished = 1;
    
    disp(['Waiting for the first QRcode...']);
    while finished == 0
        frame = snapshot(cam);
        thereshold_BW = 0.35;
        finderPatterns_pos= [];
        
         if reading == 0
            % Test different thereshold to find the best for the conditions
            for i = 1:6
                thereshold_BW = 0.35 + i*0.5;
                frame_BW = im2bw(frame, thereshold_BW);
                finderPatterns_pos = findPositionFinderPattern(frame, step, error, unit_min);
                
                if size(finderPatterns_pos,1) == 3
                    reading = 1;
                    disp(['QRcode detected with thereshold to ', thereshold_BW, '.']);
                    break % Get out of the for function
                end
            end
            
         end
        
        % If the first QRcode has already been detected
        if reading == 1
            % TODO
        end
       
    end
    
    
    frame = snapshot(cam);
    


% Image process the picture to return a black and white picture.
    %Get the frame
    % frame = imread('message1-1-test.png');
    % frame = imread('Hello_World-test.jpg');
    % frame = imread('testimg1.jpg');
    % frame = imread('message1-1.jpg');
    
    
    % Turn it black and white 
    %TODO-----Find a way to have a good theresold (try multiple one for the same picture)
    %frame_BW = im2bw(frame, 0.43);
    frame_BW = im2bw(frame, 0.50);
    imwrite(frame_BW, 'test.png');
    
    % TEST----Display the original frame and the BW one.
     subplot(1,2,1), imshow(frame);
     subplot(1,2,2), imshow(frame_BW);     
    
    imshow(getBitsPosition(frame_BW, 20, 10, 10));

% Finding the finder pattern 
    
% TODO----Waiting for the initial_img----

% TODO----When the initial_img detected find the roi----

    % TODO----Process the frame to extract the roi----

    % TODO----Translate the roi into a bit sequence----

    % TODO----Process the bit sequence to output the message----
    
    % End

message = 'End of the receiver function.';
end