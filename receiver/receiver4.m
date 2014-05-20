% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: May 2014
% Version: 2
%
function message = receiver4()
    % Image test
    path_img1 = sprintf('qrc4-test-2.png');

    % -----Webcam Initialization-----
    % Initialization of the object to contain the webcam
    cam = [];
    % Check if MATLAB can see the webcam
    if isempty(webcamlist)
        error('No webcam detected on this computer.')
    else
        cam = webcam;
        disp([get(cam, 'Name'), ' is now selected with resolution ',get(cam, 'Resolution'), '.']);
    end
    
    % -----Webcam Capture-----
    % Initialize the variable to monitor the reading
    reading = 0;
    finished = 0;
    last_seq = -1;
    
    % Initialize the variable containing the message
    message = '';
    
    % Initialize the variable for the QRcode
    list_thereshold_BW = [0.4; 0.45; 0.5; 0.55; 0.6]; % List of all the thereshold to test to find the QRcode
    thereshold_BW = 0;
    finderPatterns_pos= [];
    
    % Variables for image processing
    step = 10;
    error_max = 5;
    unit_min = 10;
    marge = 4;
    
    % -----Begining to analyse the frames-----
    disp(['Waiting for the first QRcode...']);
    while finished == 0
        frame = snapshot(cam); % Get the frame from the webcam
%         frame = imread(path_img8); % Get the frame from a specific image

        % -----Looking for the first QRcode-----
        if reading == 0 % If no QRcode has been detected yet
            imshow(frame); % Show the current frame to help visualize what the webcam is seeing
            % Test different thereshold to find the best
            for i = 1:size(list_thereshold_BW,1)
                thereshold_BW = list_thereshold_BW(i);
                frame_BW = im2bw(frame, thereshold_BW); % Converting the frame into black and White image
                finderPatterns_pos = findPositionFinderPattern4(frame_BW, step, error_max, unit_min); % Searching for the 4 FPs
                
                if ~isempty(finderPatterns_pos) % If 4 FPs are found
                    reading = 1; % Notify the program that the first QRcode has ben found
                    disp(sprintf('QRcode detected with thereshold %s.', thereshold_BW));
                    break % Get out of the for function
                end
            end
        end
        
        % -----Reading the QRcode-----
        if reading == 1 % If the first QRcode has been found
            frame_BW = im2bw(frame, thereshold_BW); % Converting the frame into black and White image
            
            imshow(getQRcodeImage4(frame_BW, finderPatterns_pos, marge)); % Show the QRcode found
            
            % Get the sequence of bytes from the QRcode (It's a String)
            msg = readQRcode(frame_BW, finderPatterns_pos, marge, error_max, step, unit_min);
            
            % -----Decode the QRcode-----
            seq_num = bits2text(msg(33:39));
            
            if seq_num == (last_seq + 1) % Check if it's the next sequence
                decoded_msg = decodeMsg(msg); % Decode the message and check it

                if ~isempty(decoded_msg) % Check is the message has been correctly decoded
                    message = strcat(message, decoded_msg); % Concatenate the message with the previous one
                    finished = msg(40); % Refresh the finished variable with the new information
                    last_seq = last_seq + 1; % Prepare to read the next sequence
                    disp(sprintf('seq_num = %s | finished = %s | decoded_msg = %s', seq_num, finished, decoded_msg));
                end
            end
        end
    end
end