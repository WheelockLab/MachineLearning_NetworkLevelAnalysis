classdef Default < mlnla.traintestdatasplitter.Base
    
    methods

        function [testIdxs, trainIdxs] = split(obj, testDataFraction, groupIds)
            
            [rows, cols] = size(groupIds);
            if rows ~= 1 && cols ~= 1
                error('groupIds must be 1-D vector, either row or column vector, but no dimension is size 1');
            end
            

            numSubjects = length(groupIds);
            unqGroups = unique(groupIds);
            numGroups = length(unqGroups);            

            numSubjsInTest = round(testDataFraction * numSubjects);
            numSubjsInTrain = numSubjects - numSubjsInTest;

            testIdxs = randperm(numSubjects, numSubjsInTest);
            trainIdxs = setdiff((1:numSubjects), testIdxs);

        end
        
    end
    
end