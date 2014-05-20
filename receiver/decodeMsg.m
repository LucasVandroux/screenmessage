function msg_text = decodeMsg(msg)
%Verify the checksum and decode the message in bytes
%   Input: msg = string containing all the bits of the message
%   Output: msg_text = [] if the checksum is not right and the message if
%                      it is

    % Compute the index of the last bit
    data_length = bin2dec(msg(41:48));
    last_bit = 48 + (data_length*8);
    
    % Compute the checksum of the message
    checksum = computeCheckSum(msg(33:last_bit));

    % Compare it with the one in the message
    if strcmp(checksum,msg(1:32))    
        % Decode the message from bits to text
        msg_text = bits2text(msg(49:last_bit));
    else
        msg_text = [];
    end

function checksum = computeCheckSum(msgToCheck)
%Compute the check sum of the input using the SDBM algorithm
%   Input: msgToCheck = string containing all the bits of the message we
%                       want to compute the checksum on.
%   Output: checksum = checksum of the message
    
    % Initialize the checksum
    checksum = 0;
    
    % Compute the checksum
    for i = 1:(length(msgToCheck)/3)
        checksum = checksum * 65599 + bin2dec(msgToCheck((1+(i-1)*8) : (i*8)));
    end
    
    % Convert the checksum in binary
    checksum = dec2bin(checksum);
    
    % Casted the checksum to 32 bits
    checksum = checksum((end-31):end);

end

