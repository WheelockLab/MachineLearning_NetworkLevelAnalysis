%test script to run ML Cross val

%% Load HCP rest 1 data
fcData = load('/data/wheelock/data1/datasets/HCP/HCP_965_10min_Gordon333_20220330/mat/HCP_965_10min_Gordon333_20220331_Rest1.mat');
fcData = fcData.HCPRest1;


%% Load IM Data and reorder fc data to match it
load('/data/wheelock/data1/people/ecka/NLA/NetworkLevelAnalysis/support_files/Gordon_13nets_333parcels_on_MNI.mat');
fcData = fcData(ROI_order, ROI_order, :);
flatFcData = mlnla.utils.reshapeSquareFcIntoFlattenedFc(fcData);


%% Load HCP metadata
hcpMetadata = readtable('/data/wheelock/data1/people/ecka/NLA/testdata/HCP_10min_trim.txt');
subjectID = hcpMetadata.Subject;
age = hcpMetadata.Age;
famIdStrings = hcpMetadata.Family_ID;
sibIds = hcpMetadata.sib_group;


%% Setup ML Crossval trainer

mlCrossVal = mlnla.MLCrossVal();
mlCrossVal.testDataFraction = 0.2;

%% Run ML single permutation
output = mlCrossVal.execute(flatFcData, age, sibIds);

%% Run ML n times and get outputs per repetition and avg outputs
numRepetitions = 10;
[outputPerRep, avgOutput] = mlCrossVal.executeNTimes(flatFcData,age,sibIds,numRepetitions);
