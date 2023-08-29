function flatFc = reshapeSquareFcIntoFlattenedFc(squareFc)
    % Reshapes a numROI x numROI x numSubjects fc data block into a
    % flattened structure that is numSubjects x numFcEdges
    
    [fcSqSize, ~, numSubj] = size(squareFc);
    
    if size(squareFc,1) ~= size(squareFc,2)
        error('Input square FC must be square, but current size is %i x %i', size(squareFc,1), size(squareFc,2));
    end
    
    numUnqEdges = (fcSqSize.^2 - fcSqSize) / 2; %number of elements in the lower diagonal of the square fc data block
    
    flatFc = zeros(numSubj, numUnqEdges);
    lowerDiagIdxs = logical(getIdxOfLowerDiagInFlattenedSquare(fcSqSize));
    
    for subjIdx = 1:numSubj
        thisSubjFlatFc = reshape(squareFc(:,:,subjIdx),1,[] );
        thisSubjLowerDiagOnly = thisSubjFlatFc(lowerDiagIdxs);
        flatFc(subjIdx, :) = thisSubjLowerDiagOnly;
    end
end

function lowerDiagIdxs = getIdxOfLowerDiagInFlattenedSquare(squareEdgeSize)
    totalElems = squareEdgeSize.^2;
    lowerDiagIdxs = ones(1,totalElems);
    
    for colIdx = 1:squareEdgeSize
        firstIdxOfCol = 1 + (squareEdgeSize * (colIdx - 1));
        idxOfDiagElemInCol = firstIdxOfCol + colIdx - 1;
        lowerDiagIdxs(firstIdxOfCol:idxOfDiagElemInCol) = 0;
    end


end
