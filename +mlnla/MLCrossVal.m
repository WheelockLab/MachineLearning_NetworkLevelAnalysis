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
            
            
        end
        
        function [outputAllReps, avgOutput] = executeNTimes(obj, fcData, behavior, groupIds, numRepetitions)
            
            MSE_SVR_linear = zeros(numRepetitions,1);
            MAE_SVR_linear = zeros(numRepetitions,1);
            r_SVR_linear = zeros(numRepetitions,1);
            CI_SVR_linear = zeros(numRepetitions,2);
            R2_SVR_linear = zeros(numRepetitions,1);
            
            for repIdx = 1:numRepetitions
                outputThisRep = obj.execute(fcData,behavior,groupIds);   
                MSE_SVR_linear(repIdx) = outputThisRep.MSE_SVR_linear;
                MAE_SVR_linear(repIdx) = outputThisRep.MAE_SVR_linear;
                r_SVR_linear(repIdx) = outputThisRep.r_SVR_linear;
                CI_SVR_linear(repIdx,:) = outputThisRep.CI_SVR_linear;
                R2_SVR_linear(repIdx) = outputThisRep.R2_SVR_linear;
            end
            
            outputAllReps.MSE_SVR_linear = MSE_SVR_linear;
            outputAllReps.MAE_SVR_linear = MAE_SVR_linear;
            outputAllReps.r_SVR_linear = r_SVR_linear;
            outputAllReps.CI_SVR_linear = CI_SVR_linear;
            outputAllReps.R2_SVR_linear = R2_SVR_linear;
            
            avgOutput.MSE_SVR_linear = mean(MSE_SVR_linear);
            avgOutput.MAE_SVR_linear = mean(MAE_SVR_linear);
            avgOutput.r_SVR_linear = mean(r_SVR_linear);
            avgOutput.CI_SVR_linear = mean(CI_SVR_linear,1);
            avgOutput.R2_SVR_linear = mean(R2_SVR_linear);
            
            
        end
        
        
    end
    
    
    
end