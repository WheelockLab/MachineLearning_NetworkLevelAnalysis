classdef MLCrossVal
    
    properties
        testDataFraction
        svrBandwidth = 0.1
        
        trainTestDataSplitter mlnla.traintestdatasplitter.Base = mlnla.traintestdatasplitter.MaintainGroups()
        featureFilter mlnla.featurefilter.Base = mlnla.featurefilter.Null()
        
    end
        
    methods
        
        function output = execute(obj, fcData, behavior, groupIds)
            %inputs: 
            %fcData - numObs x numEdges
            %behavior - numObs x 1
            %groupIds - numObs x 1
            
            
            output = struct();            
            
            [testIdxs, trainIdxs] = obj.trainTestDataSplitter.split(obj.testDataFraction, groupIds);

            fcTrain = fcData(trainIdxs,:);
            fcTest = fcData(testIdxs,:);
            behavTrain = behavior(trainIdxs);
            behavTest = behavior(testIdxs);

            edgeIdxsToKeep = obj.featureFilter.filter(fcTrain, behavTrain);
            output.fcEdgesKept = edgeIdxsToKeep;
            fcTrain = fcTrain(:,edgeIdxsToKeep);
            fcTest = fcTest(:,edgeIdxsToKeep);            
            numFeatures = length(edgeIdxsToKeep);

            %This line should be flexible to accomodate lasso,
            %fitrlinear
            fitSVRLinear = fitrlinear(fcTrain', behavTrain, 'ObservationsIn','columns','Epsilon',obj.svrBandwidth);
            output.betaFit = fitSVRLinear.Beta;

            behavPrediction = predict(fitSVRLinear,fcTest','ObservationsIn','columns');

            output.MSE_SVR_linear = sum((behavPrediction - behavTest).^2)/length(behavPrediction);
            output.MAE_SVR_linear = sum(abs(behavPrediction - behavTest))/length(behavPrediction);

            [corr_SVR_linear,p_SVR_linear,CI_left_SVR_linear,CI_right_SVR_linear] = ...
                    corrcoef(behavPrediction,behavTest);

            output.r_SVR_linear = corr_SVR_linear(1,2);
            output.CI_SVR_linear = [CI_left_SVR_linear(1,2),CI_right_SVR_linear(1,2)];
            output.R2_SVR_linear = (corr_SVR_linear(1,2))^2;
            
            % New interpretation
            behav_train_fit = predict(fitSVRLinear,fcTrain','ObservationsIn','columns');
            inv_coef = zeros(numFeatures,1);
            for m = 1:numFeatures
                cov_mat = cov(behav_train_fit,fcTrain(:,m));
                inv_coef(m) = cov_mat(2);
            end
            output.behav_train_fit = behav_train_fit;
            output.inv_coef = inv_coef;
            
            
        end
        
        function [outputAllReps, avgOutput] = executeNTimes(obj, fcData, behavior, groupIds, numRepetitions)
            
            outputAllReps = struct();
            avgOutput = struct();
            
            outputAllReps.MSE_SVR_linear = zeros(numRepetitions,1);
            outputAllReps.MAE_SVR_linear = zeros(numRepetitions,1);
            outputAllReps.r_SVR_linear = zeros(numRepetitions,1);
            outputAllReps.CI_SVR_linear = zeros(numRepetitions,2);
            outputAllReps.R2_SVR_linear = zeros(numRepetitions,1);
            outputAllReps.behav_train_fit = cell(numRepetitions,1);
            outputAllReps.inv_coef = cell(numRepetitions,1);
            
            for repIdx = 1:numRepetitions
                outputThisRep = obj.execute(fcData,behavior,groupIds);   
                outputAllReps.MSE_SVR_linear(repIdx) = outputThisRep.MSE_SVR_linear;
                outputAllReps.MAE_SVR_linear(repIdx) = outputThisRep.MAE_SVR_linear;
                outputAllReps.r_SVR_linear(repIdx) = outputThisRep.r_SVR_linear;
                outputAllReps.CI_SVR_linear(repIdx,:) = outputThisRep.CI_SVR_linear;
                outputAllReps.R2_SVR_linear(repIdx) = outputThisRep.R2_SVR_linear;
                outputAllReps.behav_train_fit{repIdx} = outputThisRep.behav_train_fit;
                outputAllReps.inv_coef{repIdx} = outputThisRep.inv_coef;
            end
            
            avgOutput.MSE_SVR_linear = mean(outputAllReps.MSE_SVR_linear);
            avgOutput.MAE_SVR_linear = mean(outputAllReps.MAE_SVR_linear);
            avgOutput.r_SVR_linear = mean(outputAllReps.r_SVR_linear);
            avgOutput.CI_SVR_linear = mean(outputAllReps.CI_SVR_linear,1);
            avgOutput.R2_SVR_linear = mean(outputAllReps.R2_SVR_linear);
            
            
        end
        
        function obj = set.testDataFraction(obj, val)
            if val < 0 || val > 1
                error('MLCrossVal error.testDataFraction property must be between 0 and 1');
                
            end
            obj.testDataFraction = val;
        end
        
    end
    
end
