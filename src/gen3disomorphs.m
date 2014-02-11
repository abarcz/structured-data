
function graphs = gen3disomorphs(graph, nGraphs)
% Generate graphs isomorphic to source graph

	graphs = {};
	coords = graph.nodeLabels(:, 1:3);
	for i = 1:nGraphs
		translation = createTranslation3d((rand(1, 3) - 0.5) * 10);	% uniform -5..5
		rotationX = createRotationOx(2 * pi * rand());	% in radians
		rotationY = createRotationOy(2 * pi * rand());
		rotationZ = createRotationOz(2 * pi * rand());
		% translation goes first
		transformation = translation * rotationX * rotationY * rotationZ;
		graphs{i} = transform3dgraph(graph, transformation);
	end
end
