classdef HighestCorr < mlnla.featurefilter.Base
    
    properties
        
        numEdgesToKeep
        
    end
    
    methods
        
        function obj = HighestCorrFilter(numEdgesToKeep)
            obj.numEdgesToKeep = numEdgesToKeep;
        end
        
        function idxsToKeep = filter(obj, fcData, behaviorData)
            [rhoXY, ~] = corr(behaviorData, fcData,'type','Pearson');
            [~, sortedIdxs] = sort(abs(rhoXY),'descend');
            idxsToKeep = sortedIdxs(1:obj.numEdgesToKeep);
        end
    end
    
    
end