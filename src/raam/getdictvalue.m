
function res = getdictvalue(keys, values, key)
% return value from keys + values map

	index = cellindexof(keys, key);
	if index == 0
		key
		error('Key not found')
	end
	res = values{index};
end
