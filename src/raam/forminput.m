
function res = forminput(keys, values, node)
% Builds RAAM input for given node (having two children)

	assert(size(node, 2) == 2);
	if iscell(node{1})
		value1 = getdictvalue(keys, values, node{1});
	else
		value1 = node{1};	% if node{1} is a leaf, we take its value as encoding
	end
	if iscell(node{2})
		value2 = getdictvalue(keys, values, node{2});
	else
		value2 = node{2};
	end
	res = [value1, value2];
end
