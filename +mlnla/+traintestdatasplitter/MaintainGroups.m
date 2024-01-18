classdef MaintainGroups < mlnla.traintestdatasplitter.Base
    
    methods

        function [testIdxs, trainIdxs] = split(obj, testDataFraction, groupIds)

            [rows, cols] = size(groupIds);
            if rows ~= 1 && cols ~= 1
                error('groupIds must be 1-D vector, either row or column vector, but no dimension is size 1');
            end

            numSubjects = length(groupIds);
            unqGroups = unique(groupIds);
            numGroups = length(unqGroups);            

            numGroupsInTest = round(testDataFraction * numGroups);
            numGroupsInTrain = numGroups - numGroupsInTest;

            if (numGroupsInTest == 0) | (numGroupsInTest == numGroups)
                warning(['Selection of test data fraction of (%1.3f) results in either test or train set being empty',...
                        '(test set: %i groups, train set: %i groups'], testDataFraction, numGroupsInTest, numGroupsInTrain);
            end

            groupIdsInTest = unqGroups(randperm(numGroups, numGroupsInTest));
            allIdxs = (1:numSubjects)';

            testIdxs = [];
            for grpIdx = 1:length(groupIdsInTest)
                thisGrpId = groupIdsInTest(grpIdx);
                thisSubjIdxs = allIdxs(groupIds == thisGrpId);
                testIdxs = [testIdxs;thisSubjIdxs];
            end

            trainIdxs = setdiff(allIdxs, testIdxs);

        end
        
    end
    
end
