classdef Base
    
    methods (Abstract)

        [testIdxs, trainIdxs] = split(obj, testDataFraction, groupIds)
        
    end
    
end