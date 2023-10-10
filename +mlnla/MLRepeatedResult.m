classdef MLRepeatedResult < handle
    
    properties
        MSE_SVR_linear
        MAE_SVR_linear
        r_SVR_linear
        CI_SVR_linear
        R2_SVR_linear
        behav_train_fit
        inv_coef
    end
    
    methods
        function obj = MLRepeatedResult(numRepetitions)
            if nargin == 0
                numRepetitions = 0;
            end
            
            obj.MSE_SVR_linear = zeros(numRepetitions,1);
            obj.MAE_SVR_linear = zeros(numRepetitions,1);
            obj.r_SVR_linear = zeros(numRepetitions,1);
            obj.CI_SVR_linear = zeros(numRepetitions,2);
            obj.R2_SVR_linear = zeros(numRepetitions,1);
            obj.behav_train_fit = cell(numRepetitions,1);
            obj.inv_coef = cell(numRepetitions,1);
            
        end
        
        function setOutputAtRepetitionIndex(obj, oneRepOutput, repIdx)
                         
            obj.MSE_SVR_linear(repIdx) = oneRepOutput.MSE_SVR_linear;
            obj.MAE_SVR_linear(repIdx) = oneRepOutput.MAE_SVR_linear;
            obj.r_SVR_linear(repIdx) = oneRepOutput.r_SVR_linear;
            obj.CI_SVR_linear(repIdx,:) = oneRepOutput.CI_SVR_linear;
            obj.R2_SVR_linear(repIdx) = oneRepOutput.R2_SVR_linear;
            obj.behav_train_fit{repIdx} = oneRepOutput.behav_train_fit;
            obj.inv_coef{repIdx} = oneRepOutput.inv_coef;
            
        end
        
        function outStruct = asStruct(obj)
            
            outStruct = struct();
            
            outStruct.MSE_SVR_linear = obj.MSE_SVR_linear;            
            outStruct.MAE_SVR_linear = obj.MAE_SVR_linear;
            outStruct.r_SVR_linear = obj.r_SVR_linear;
            outStruct.CI_SVR_linear = obj.CI_SVR_linear;
            outStruct.R2_SVR_linear = obj.R2_SVR_linear;
            outStruct.behav_train_fit = obj.behav_train_fit;
            outStruct.inv_coef = obj.inv_coef;
            
        end
        
        function outAvg = avgAsStruct(obj)
            
            outAvg = struct();
            
            outAvg.MSE_SVR_linear = mean(obj.MSE_SVR_linear);
            outAvg.MAE_SVR_linear = mean(obj.MAE_SVR_linear);
            outAvg.r_SVR_linear = mean(obj.r_SVR_linear);
            outAvg.CI_SVR_linear = mean(obj.CI_SVR_linear,1);
            outAvg.R2_SVR_linear = mean(obj.R2_SVR_linear);
            
        end
    end
    
    
end