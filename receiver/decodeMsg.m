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
    if bin2dec(checksum) == bin2dec(msg(1:32))    
        % Decode the message from bits to text
        msg_text = bits2text(msg(49:last_bit));
    else
        % Display a message if the checksum is wrong
        % disp(['/!\ -- Wrong Checksum = ', checksum, ' Expected = ', msg(1:32), ' Message = ', bits2text(msg(49:last_bit))]);
        
        % Return an empty message
        msg_text = [];
    end
    
end

