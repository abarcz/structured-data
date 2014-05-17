
function res = forminput(keys, values, node)
% Builds input for given node (having two children)

	if iscell(node{1})
		value1 = getdictvalue(keys, values, node{1});
	else
		value1 = node{1};
	end
	if iscell(node{2})
		value2 = getdictvalue(keys, values, node{2});
	else
		value2 = node{2};
	end
	res = [value1, value2];
end
