
function graphs = gencrystals2(graph, nGraphs)

	graphs = {};
	graphn = noderepr(graph);
	for i = 1:nGraphs
		rotationX = createRotationOx(2 * pi * rand());	% in radians
		rotationY = createRotationOy(2 * pi * rand());
		rotationZ = createRotationOz(2 * pi * rand());
		transformation = rotationX * rotationY * rotationZ;
		graphs{i} = edgerepr(transform3dgraph(graphn, transformation));
	end
end
