%Refer to Professor Wu's new method pdf, new solution 1.

%Load features
clear;
k_knn=20;
featureName='enlarged_RegisteredFeature_Aug27_left_';

%Load training feature matrix.
for RoundNumber=1:4
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*36)=featurevector; 
    end
end

%Load testing feature matrix
for RoundNumber=5
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        TestingFeatureMatrix(:,i)=featurevector; 
    end
end

%Split traning feature matrix into training matrix and testing matrix;
% for i = 1:18
%         TrainingFeatureMatrix(:,i)=FeatureMatrix(:,2*(i-1)+1);
%         TestingFeatureMatrix(:,i)=FeatureMatrix(:,2*(i-1)+2);
% end

%Generate all training position information, stored in a PositionMatrix.
for RoundNumber=1:4
    for y=1:6
        for x=1:6
            PositionMatrix(1,(y-1)*6+x+(RoundNumber-1)*36)=floor(480/7*y);
            PositionMatrix(2,(y-1)*6+x+(RoundNumber-1)*36)=floor(640/7*x);
        end
    end
end

%Generate testing positon information
for RoundNumber=5
    for y=1:6
        for x=1:6
            TestingPositionMatrix(1,(y-1)*6+x)=floor(480/7*y);
            TestingPositionMatrix(2,(y-1)*6+x)=floor(640/7*x);
        end
    end
end

%Split traning position matrix into training matrix and testing matrix;
% for i = 1:18
%         TrainingPositionMatrix(:,i)=PositionMatrix(:,2*(i-1)+1);
%         TestingPositionMatrix(:,i)=PositionMatrix(:,2*(i-1)+2);
% end

% S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix);
% figure(1);
% AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix, 0.1199);
% figure(2);
% AffinityMatrix2=DisplayAffinityMatrix(PositionMatrix,64723);
% figure(3);
% AffinityMatrix3=DisplayAffinityMatrix(FeatureMatrix,0.1199,S);

S=eye(size(FeatureMatrix,1));
TotalError=0;
for QueryNumber=1:36
    QueryFeature=TestingFeatureMatrix(:,QueryNumber);
    TrainingFeatureMatrix=FeatureMatrix;
    %TrainingFeatureMatrix(:,QueryNumber)=[];
    TrainingPositionMatrix=PositionMatrix;
    %TrainingPositionMatrix(:,QueryNumber)=[];
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
%    S=FindMetricPreservationMatrix(TrainingFeatureMatrix,TrainingPositionMatrix);
%     figure(1);
%     AffinityMatrix1=DisplayAffinityMatrix(TrainingFeatureMatrix, 0.1199);
%     figure(2);
%     AffinityMatrix2=DisplayAffinityMatrix(TrainingPositionMatrix,64723);
%     figure(3);
%     AffinityMatrix3=DisplayAffinityMatrix(TrainingFeatureMatrix,0.1199,S);
    for ii = 1:36*3
        DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    disp('QueryNumber');
    disp(QueryNumber);
    disp('index:');
    disp(index);
    %index(find(index==QueryNumber))=[];

    for k=1:k_knn
        AMatrix(:,k)=TrainingFeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=TrainingPositionMatrix(:,index(k));
    end
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);
    EstimatePosition=TrainingWeightMatrix*weight;
    TotalError=TotalError+norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
    %figure(2);
end
AvgError=TotalError/36;