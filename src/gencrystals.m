
function graphs = gencrystals(graph, nGraphs)
% Generate graphs isomorphic by scaling
% Given a cubic crystal generates tetragonal crystals

	graphs = {};
	for i = 1:nGraphs
		a = (rand() - 0.5) * 10;
		b = a;
		c = (rand() - 0.5) * 10;
		graphs{i} = scalecrystal(graph, a, b, c);
	end
end
