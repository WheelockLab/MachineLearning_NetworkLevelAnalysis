classdef NetPairs
    
    properties
        IM_key %numROI x 2 matrix. Matches each ROI to a network ID. Col 1 is ROI ID, Col 2 is Network ID
    end
    
    methods
        
        function obj = NetPairs(IM_key)
            obj.IM_key = IM_key;
        end
        
        function permFCOutput = permute(obj, inputFC)
            %Permute the order of net-net pairs in FC data
            %
            %inputs:
            %    inputFC - numSubj x numFcEdges. Flattened lower triangle
            %              of FC matrix
            
            
            obj.validateInputDataSizesMatch(inputFC, obj.IM_key);                        
            
            fcIdxInEachNetNetPair= obj.findFCIdxsInEachNetworkPair(obj.IM_key);
            numNets = length(fcIdxInEachNetNetPair);

            netpair_order = randperm(numNets);
            permFCOrder = cell2mat(fcIdxInEachNetNetPair(netpair_order));
            permFCOutput = inputFC(:, permFCOrder);            
            
        end
        
    end
    
    methods (Access = protected)
        
        function validateInputDataSizesMatch(obj, inputFC, IM_key)
            
            [numSubj, numFcEdges] = size(inputFC);
            numROI = size(IM_key,1);
            
            uniqueEdgesForIM = obj.calcLowerTriROIPairsFromNumROI(numROI);
            
            if numFcEdges ~= uniqueEdgesForIM
                error('number of FC Edges in input (%i) does not match expected number of FC pairs from IM_key with (%i) ROI',numFcEdges, numROI);
            end
            
        end
        
        function numEdgePairs = calcLowerTriROIPairsFromNumROI(obj, numROI)
            %Find unique ROI-ROI pairs in lower triangle of square FC
            %matrix
            
            numEdgePairs = (numROI*numROI-numROI)/2;
            
            
        end
        
        function fcIdxInEachNetNetPair= findFCIdxsInEachNetworkPair(obj, IM_key)
            %
            % This function provides indexing into module pairs for fast reference based
            % on the IM structure of a grouped network.

            Nroi=length(IM_key);
            Nnets=max(IM_key(:,2));

            Tidx=find(tril(ones(Nroi),-1)==1);
            TNidx=find(tril(ones(Nnets),0)==1);% Lower triangle w main diag for NN-pairs

            Npairs=size(TNidx,1);
            rs=repmat(IM_key(:,2),[1,Nroi]);
            cs=rs';
            NNTidx=[rs(Tidx),cs(Tidx)];
            clear rs cs
            fcIdxInEachNetNetPair=cell(Npairs,1); % Each cell is a network pair assoc to Tidx 
            n=0;
            for j=1:Nnets
                for k=j:Nnets
                    n=n+1;
                    fcIdxInEachNetNetPair{n,1}=intersect(find(NNTidx(:,1)==k),find(NNTidx(:,2)==j));
                end
            end

        end

        
    end
    
end