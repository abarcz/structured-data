
function res = getdictvalue(keys, values, key)

	index = cellindexof(keys, key);
	if index == 0
		key
		error('Key not found')
	end
	res = values{index};
end
