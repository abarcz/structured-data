
function printtree(cell)
% prints a tree encoded as cell array in the parentheses-format
	fprintf('(');
	printtreerec(cell);
	fprintf(')\n');
end

function printtreerec(cell)
	for i = 1:size(cell, 2)
		object = cell{i};
		if iscell(object)
			fprintf('(');
			printtreerec(object);
			fprintf(')');
			if i != size(cell, 2)
				fprintf(' ');
			end
		else
			fprintf(object);
			if i != size(cell, 2)
				fprintf(' ');
			end
		end
	end
end
