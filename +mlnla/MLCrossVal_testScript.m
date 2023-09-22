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

%% Run ML single permutation
output = mlCrossVal.execute(flatFcData, age, sibIds);

%% Run ML n times and get outputs per repetition and avg outputs
numRepetitions = 10;
[outputPerRep, avgOutput] = mlCrossVal.executeNTimes(flatFcData,age,sibIds,numRepetitions);
