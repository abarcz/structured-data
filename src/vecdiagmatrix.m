
function m = vecdiagmatrix(dim)
% Build a matrix M, such that:
% M * a = vec(diag(a))
% for each a of size = (dim, 1
%
% usage: m = vecdiagmatrix(dim)
%

	m = zeros(dim .^ 2, dim);
	for i = 1:dim
		j = 1 + (i - 1) * (dim + 1);
		m(j, i) = 1;
	end
end
