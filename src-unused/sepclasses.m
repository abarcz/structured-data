
function classes = sepclasses(samples)
% Given samples, separates them into cellarray of classes, preserving ids
% samples : each row = [ classId feat1 feat2 ... ]

	% get all classes ids, in ascending order
	classIds = unique(samples(:, 1));

	previousId = classIds(1, 1);
	for i = 2:size(classIds, 1)
		if classIds(i) != (previousId + 1)
			disp(classIds');
			error('Class ids in sepclasses() miss a value');
		end
		previousId = classIds(i);
	end

	nClasses = size(classIds, 1);
	classes = cell(nClasses, 1);

	for i = 1:nClasses
		classId = classIds(i, 1);
		classes(i, 1) = samples(samples(:, 1) == classId, :);
	end
end
