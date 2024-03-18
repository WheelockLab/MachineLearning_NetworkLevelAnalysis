classdef Base < handle
        
    
    methods (Abstract)
        
        %xTrainData -[numSubj x numFeatures] matrix
        %yTrainData - [numSubj x 1] matrix            
        %outModel will be RegressionLinear object
        outModel = fitModel(obj, xTrainData, yTrainData)
            
            
               
        
    end
    
    
end