function msg_text = decodeMsg(msg)
%DECODEMSG Summary of this function goes here
%   Detailed explanation goes here
msg_to_traduct = msg(49:end)
msg_text = bits2text(msg(49:end));

end

