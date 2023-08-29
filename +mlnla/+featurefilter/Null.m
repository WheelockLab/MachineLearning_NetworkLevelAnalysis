classdef Null < mlnla.featurefilter.Base
    
    methods
        
        function idxsToKeep = filter(obj, fcData, behaviorData)
            numEdges = size(fcData,2);
            idxsToKeep = (1:numEdges);
        end
    end
    
end