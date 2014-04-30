% Authors: Mickael Misbach, Lucas Vandroux 
% License: Please refer to the LICENCE file
% Date: April 2014
% Version: 1
%
function message = receiver()




%Test should return 0.2222
whitePercentage([0.2 0.3 0.1, 0.5 0.6 0.1, 0.0 0.0 0.2])

message = 'End of the receiver function.';
end

% In a grayscale image 0.0 = black and 1.0 = white
function percentage = whitePercentage (grayImg);

percentage = mean(grayImg); 
end