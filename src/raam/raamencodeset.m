
function codes = raamencodeset(fnn, cell)

	nSamples = size(cell, 2);
	codes = zeros(nSamples, fnn.nHiddenNeurons);
	for i = 1:nSamples
		codes(i, :) = raamencode(fnn, cell{i});
	end
end
