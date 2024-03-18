classdef SVRLinearModel < mlnla.tuningmodelfitter.Base
    
    properties
        
        epsilon = 0.1;
        
    end
    
    
    methods
        
        function outModel = fitModel(obj, xTrainData, yTrainData)
            %xTrainData -[numSubj x numFeatures] matrix
            %yTrainData - [numSubj x 1] matrix            
            
            %Note: switched from using 'ObservationsIn', 'columns' settings
            %for fitrlinear. MATLAB claims using columns is quicker, but no
            %difference observed on test data
            
            %if want to switch back to columns, use line below
            %outModel = fitrlinear(xTrainData', yTrainData, 'ObservationsIn','columns','Epsilon','obj.epsilon')
            
            
            outModel = fitrlinear(xTrainData, yTrainData, 'Epsilon',obj.epsilon);
            
        end
        
        
    end
    
    
end