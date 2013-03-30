function xb = addbias(x)
% Add bias column to data

	xb = [x repmat(1, size(x, 1), 1)];
end
