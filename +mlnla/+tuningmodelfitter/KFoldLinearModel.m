classdef KFoldLinearModel < mlnla.tuningmodelfitter.Base
    
    properties
        
        epsilon = 0.1
        KFolds = 5;
        lambdaTestSet = logspace(-5, -1, 15)
        
    end
    
    
    methods
        
        function outModel = fitModel(obj, xTrainData, yTrainData)
            %xTrainData -[numSubj x numFeatures] matrix
            %yTrainData - [numSubj x 1] matrix            
            
            tuning_para_Mdl = fitrlinear(xTrainData,yTrainData,...
                'KFold',obj.KFolds,...
                'Lambda',obj.lambdaTestSet,...
                'Learner','svm','Solver','sgd','Regularization','ridge');
            
            tuning_para_MSE = kfoldLoss(tuning_para_Mdl);
            [~,optimal_lambda_idx] = min(tuning_para_MSE);
            optimal_lambda = obj.lambdaTestSet(optimal_lambda_idx);

            outModel = fitrlinear(xTrainData,yTrainData,'Epsilon',obj.epsilon,'Lambda',optimal_lambda);
            
            
        end
        
        
    end
    
    
end