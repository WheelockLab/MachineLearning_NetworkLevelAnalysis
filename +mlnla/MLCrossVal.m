classdef MLCrossVal < handle
    
    properties
        testDataFraction
        svrBandwidth = 0.1
        
        trainTestDataSplitter mlnla.traintestdatasplitter.Base = mlnla.traintestdatasplitter.MaintainGroups()
        featureFilter mlnla.featurefilter.Base = mlnla.featurefilter.Null()
        tuningModelFitter mlnla.tuningmodelfitter.Base = mlnla.tuningmodelfitter.SVRLinearModel()
        
    end
    
    properties (Access = protected)
        behavPermMethod = mlnla.permutation.Behavior()
        netPairPermMethod = mlnla.permutation.Null()
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
            
            fitSVRLinear = obj.tuningModelFitter.fitModel(fcTrain, behavTrain);
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
            
            resultObj = mlnla.MLRepeatedResult(numRepetitions);
                        
            for repIdx = 1:numRepetitions
                outputThisRep = obj.execute(fcData,behavior,groupIds); 
                resultObj.setOutputAtRepetitionIndex(outputThisRep, repIdx);
            end
            
            outputAllReps = resultObj.asStruct();
            avgOutput = resultObj.avgAsStruct();            
            
        end
        
        function [outputAllReps, avgOutput] = executeNTimesPermuted(obj, fcData, behavior, groupIds, numRepetitions,...
                                                                    permuteBehavFlag, permuteNetPairsFlag)
                                                    
            resultObj = mlnla.MLRepeatedResult(numRepetitions);
            
            if permuteNetPairsFlag
                isInit = obj.isNetPairPermObjectInitialized();
                if ~isInit
                    errorStr = sprintf([['Called MLCrossVal to run with permuted net pairs, '],...
                                        ['but did not provide an IM_key for net-pair assignments of ROIs.\n'],...
                                        ['To run with net-pair permutation, get an IM_key corresponding to your FC data, '],...
                                        ['and call method "setIMKeyForNetPairPermutation(IM_key)" on your MLCrossVal object']]);
                    error(errorStr);
                end
            end
                        
            for repIdx = 1:numRepetitions
                if permuteBehavFlag
                    thisBehavior = obj.behavPermMethod.permute(behavior);
                else
                    thisBehavior = behavior;
                end
                if permuteNetPairsFlag
                    thisFcData = obj.netPairPermMethod.permute(fcData);
                else
                    thisFcData = fcData;
                end
                
                outputThisRep = obj.execute(thisFcData,thisBehavior,groupIds); 
                resultObj.setOutputAtRepetitionIndex(outputThisRep, repIdx);
            end
            
            outputAllReps = resultObj.asStruct();
            avgOutput = resultObj.avgAsStruct(); 
                                                    
        end
        
        function obj = set.testDataFraction(obj, val)
            if val < 0 || val > 1
                error('MLCrossVal error.testDataFraction property must be between 0 and 1');
                
            end
            obj.testDataFraction = val;
        end
        
        function setIMKeyForNetPairPermutation(obj, IM_key)
            obj.netPairPermMethod = mlnla.permutation.NetPairs(IM_key);            
        end
        
    end
    
    methods (Access = protected)

        function isInit = isNetPairPermObjectInitialized(obj)
            
            if isa(obj.netPairPermMethod,'mlnla.permutation.Null')
                isInit = false;
            else
                isInit = true;
            end
            
        end

    end
    
    
end
