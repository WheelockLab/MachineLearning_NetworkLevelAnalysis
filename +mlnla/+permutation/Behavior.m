classdef Behavior
    
    methods
        
        function permOutput = permute(obj, input)
            
            numMeasurements = length(input);
            permOutput = input(randperm(numMeasurements));
            
        end
        
    end
    
end