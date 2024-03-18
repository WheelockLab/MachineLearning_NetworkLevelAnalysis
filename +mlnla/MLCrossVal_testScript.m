%test script to run ML Cross val

%% FC data (random data generated here to demonstrate data sizes)
numROIs = 333;
numSubj = 965;
numSibGroups = 400;
fcData = rand(numROIs, numROIs, numSubj);

%Remove diagonal elements and flatten fc to lower diagonal
flatFcData = mlnla.utils.reshapeSquareFcIntoFlattenedFc(fcData);

%% Covariates (random data generated here to demonstrate data sizes
subjectID = 1:numSubj;
age = ceil(rand(numSubj,1)*70);
sibIds = ceil(rand(numSubj,1)*numSibGroups);

%% Setup ML Crossval trainer

mlCrossVal = mlnla.MLCrossVal();
mlCrossVal.testDataFraction = 0.2;

%% If you want to filter FC edges, use the following:
FILTER_KEEP_HIGHEST_CORR_EDGES = false;
if FILTER_KEEP_HIGHEST_CORR_EDGES
    numEdgesToKeep = 1000;
    mlCrossVal.featureFilter = mlnla.featurefilter.HighestCorr(numEdgesToKeep);
else
    mlCrossVal.featureFilter = mlnla.featurefilter.Null(); %This is Default
end

%% If you want to change how test/train data is split up, use the following:
IGNORE_GROUPS = false;
if IGNORE_GROUPS
    mlCrossVal.trainTestDataSplitter = mlnla.traintestdatasplitter.IgnoreGroups();
else
    mlCrossVal.trainTestDataSplitter = mlnla.traintestdatasplitter.MaintainGroups(); %This is Default
end

%% If you want to use a K Fold model rather than the default, using the following
USE_K_FOLD = true;
if USE_K_FOLD
    
    kFoldModelFitter = mlnla.tuningmodelfitter.KFoldLinearModel();
    kFoldModelFitter.epsilon = 0.15; % <- default value, but user can change
    kFoldModelFitter.KFolds = 6; % <- default value, but user can change
    kFoldModelFitter.lambdaTestSet = logspace(-5, -1, 10); % <- default value, but user can change
    
    mlCrosVal.tuningModelFitter = kFoldModelFitter;
else
    %This is what happens by default, so don't need to call any of these
    %lines when building new model. Just for traceability to change back
    %and forth between this and KFold modelfitter
    
     %svrModelFitter = mlnla.tuningmodelfitter.SVRLinearModel();
     %svrModelFitter.epsilon = 0.1; % <- default value, but user can change
     
     %mlCrossVal.tuningModelFitter = svrModelFitter;
end

%% Run ML single repetition
output = mlCrossVal.execute(flatFcData, age, sibIds);

%% Run ML n times and get outputs per repetition and avg outputs
numRepetitions = 4;
[outputPerRep, avgOutput] = mlCrossVal.executeNTimes(flatFcData,age,sibIds,numRepetitions);

%% Run ML with different kinds of permutation
%permute behavior only
permuteBehaviorFlag = true;
[outputPerRep, avgOutput] = mlCrossVal.executeNTimesPermuted(flatFcData,age,sibIds,numRepetitions,permuteBehaviorFlag,false);


%permute both behavior and net pairs
%Define the IM_key that will be used for net pair permutation, and apply it
%to the mlCrossVal object
numROIs = 333;
ROI_idx = (1:numROIs)';
numNets = 4; %arbitrary for this example
ROI_net_id = ceil(rand(numROIs,1)*4); 
IM_key = [ROI_idx, ROI_net_id];
mlCrossVal.setIMKeyForNetPairPermutation(IM_key);

%Run with both permutation of behavior and net-pair
permuteBehaviorFlag = true;
permuteNetPairFlag = true;
[outputPerRep, avgOutput] = mlCrossVal.executeNTimesPermuted(flatFcData,age,sibIds,numRepetitions,permuteBehaviorFlag,permuteNetPairFlag);

