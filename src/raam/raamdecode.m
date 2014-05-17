
function cell = raamdecode(fnn, code, originalCell)
% decode single tree, using original structure for termination problem

	if !iscell(originalCell)
		cell = code;	% terminate decoding, we got leaf
	else
		decode = applydecoder(fnn, code);
		codeSize = size(decode, 2) / 2;	% binary tree
		code1 = decode(:, 1:codeSize);
		code2 = decode(:, (codeSize + 1):size(decode, 2));
		cell = {raamdecode(fnn, code1, originalCell{1}), raamdecode(fnn, code2, originalCell{2})};
	end
end
