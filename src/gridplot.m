
function gridplot(data, grid, unifyScale=false, legendStrings={}, prefix='', enumerate=0, minmax={})
% Draws a grid of plots in a single window
%
% usage: gridplot(data, grid, unifyScale=false, legendStrings={}, prefix='', enumerate=0, minmax={})
%
% data : matrix of data - each column represent a property
% grid : grid representing areas of subplot, grid element denotes data column number (0 - no data)
% unifyscale : if true, all subplots will have the same min and max Y
% legendStrings : cell {columnSelector -> name}
% prefix : prefix for all subplot legendStringss
% enumerate : 0 - enumerate subplot legendStringss according to subplot order, 1 - row, 2 - column (works with prefix only)
% minmax : min and max values for scaling {columnSelector -> [min max]}
%

% indices of subplot are as follows:
% +-----+-----+-----+
% |  1  |  2  |  3  |
% +-----+-----+-----+
% |  4  |  5  |  6  |
% +-----+-----+-----+

	nRows = size(grid, 1);
	nCols = size(grid, 2);
	if unifyScale
		minValue = Inf;
		maxValue = -Inf;
		selectors = vec(unique(grid));
		for i = 1:size(selectors, 1)
			columnSelector = selectors(i);
			if columnSelector == 0
				continue;
			end
			currMin = min(data(:, columnSelector));
			currMax = max(data(:, columnSelector));
			if currMin < minValue
				minValue = currMin;
			end
			if currMax > maxValue
				maxValue = currMax;
			end
		end
		globalMaxValue = maxValue;
		globalMinValue = minValue;
	end
	nDataRows = size(data, 1);
	% create fullscreen figure
	screenSize = get(0, 'ScreenSize');
	figure('position', [0 0 screenSize(3) screenSize(4)]);
	for i = 1:nRows
		for j = 1:nCols
			columnSelector = grid(i, j);
			if columnSelector != 0
				plotIndex = (i - 1) * nCols + j;
				subplot(nRows, nCols, plotIndex);
				plot(data(:, columnSelector));

				% create legendStringss
				if strcmp(prefix, '')
					legendPrefix = '';
				else
					if enumerate == 0
						legendStrings_id = (i - 1) * nCols + j;
					elseif enumerate == 1
						legendStrings_id = i;
					else
						legendStrings_id = j;
					end
					legendPrefix = sprintf('%s%d', prefix, legendStrings_id);
				end
				if size(legendStrings, 1) != 0
					if columnSelector > max(size(legendStrings))
						string = legendStrings{1};
					elseif size(legendStrings{columnSelector}, 1) == 0
						string = legendStrings{1};
					else
						string = legendStrings{columnSelector};
					end
					if strcmp(prefix, '')
						legend(string);
					else
						legendString = sprintf('%s : %s', legendPrefix, string);
						legend(legendString);
					end
				else
					legend(legendPrefix);
				end

				if unifyScale
					axis([0, nDataRows, globalMinValue, globalMaxValue]);
				else
					axisSet = false;
					if max(size(minmax)) >= columnSelector
						if size(minmax{columnSelector}, 1) > 0
							minmaxes = minmax{columnSelector};
							axis([0, nDataRows, minmaxes(1), minmaxes(2)]);
							axisSet = true;
						end
					end
					if axisSet == false
						% scale axis for binary data plots
						uniqueValues = unique(data(:, columnSelector));
						if size(uniqueValues, 1) == 2
							minValue = min(uniqueValues);
							maxValue = max(uniqueValues);
							margin = 0.2 * (maxValue - minValue);
							newMinValue = minValue - margin;
							newMaxValue = maxValue + margin;
							axis([0, nDataRows, newMinValue, newMaxValue]);
						else
							axis([0, nDataRows]);
						end
					end
				end
			end
		end
	end
end
