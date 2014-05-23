function checksum = computeCheckSum(msgToCheck)
%Compute the check sum of the input using the SDBM algorithm
%   Input: msgToCheck = string containing all the bits of the message we
%                       want to compute the checksum on.
%   Output: checksum = checksum of the message

    % Initialize the checksum
    checksum = 0;
    
    % Compute the checksum
    for i = 1:(length(msgToCheck)/8)
        checksum = mod(checksum * 65599 + bin2dec(msgToCheck((1+(i-1)*8) : (i*8))), 2^32-1);
    end
    
    % Convert the checksum in binary
    checksum = dec2bin(checksum);
end