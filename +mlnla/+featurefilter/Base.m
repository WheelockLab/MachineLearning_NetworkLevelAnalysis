classdef Base
    
    methods (Abstract)
        
        idxsToKeep = filter(obj, fcData, behaviorData)
    end
    
end