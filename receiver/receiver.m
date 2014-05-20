% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: May 2014
% Version: 2
%
function message = receiver()
    % Image test
    path_img1 = sprintf('message1-1.jpg');
    path_img2 = sprintf('message1-1-test.png');
    path_img3 = sprintf('Hello_World-test.jpg');
    path_img4 = sprintf('testimg1.jpg');

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
    reading = 0;
    finished = 0;
    
    % Initialize the variable for the QRcode
    list_thereshold_BW = [0.4; 0.45; 0.5; 0.55; 0.6]; % List of all the thereshold to test to find the QRcode
    thereshold_BW = 0;
    finderPatterns_pos= [];
    
    % Variables for image processing
    step = 10;
    error_max = 5;
    unit_min = 10;
    marge = 4;
    
    disp(['Waiting for the first QRcode...']);
    while finished == 0
        % frame = snapshot(cam);
        frame = imread(path_img1);
        % Look for the first QRcode
        if reading == 0
            % Test different thereshold to find the best
            for i = 1:size(list_thereshold_BW,1)
                thereshold_BW = list_thereshold_BW(i);
                frame_BW = im2bw(frame, thereshold_BW);
                finderPatterns_pos = findPositionFinderPattern(frame_BW, step, error_max, unit_min);
                
                if size(finderPatterns_pos,1) == 3
                    reading = 1;
                    disp(sprintf('QRcode detected with thereshold %s.', thereshold_BW));
                    break % Get out of the for function
                end
            end
        end
        
        % If the first QRcode has already been detected
        if reading == 1
            frame_BW = im2bw(frame, thereshold_BW);
            msg = readQRcode(frame_BW, finderPatterns_pos, marge, error_max, step, unit_min);
            disp(['test']);
        end
       
    end

message = 'End of the receiver function.';
end