%Refer to Professor Wu's new method pdf, new solution 1. Use relatvie gaze

%Load features
clear;
k_knn=20;
featureName='enlarged_RegisteredFeature_Aug27_left_';
rightfeatureName='enlarged_RegisteredFeature_Aug27_right_';

%Load training feature matrix.
for RoundNumber=1:4
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        rightfeature=load([rightfeatureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        rightfeaturevector=rightfeature.x;
        FeatureMatrix(:,i+(RoundNumber-1)*36)=[featurevector;rightfeaturevector]; 
    end
end

%Load testing feature matrix
for RoundNumber=5
    for i = 1:36
        feature=load([featureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        featurevector=feature.x;
        rightfeature=load([rightfeatureName,int2str(i-1),'__',int2str(RoundNumber),'.mat']);
        rightfeaturevector=rightfeature.x;
        TestingFeatureMatrix(:,i)=[featurevector;rightfeaturevector]; 
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

%Generate training relative gaze position matrix
for RoundNumber=1:4
    for y=1:6
        for x=1:6
            for i=1:36
                RelativePositionMatrix(i,(y-1)*6+x+(RoundNumber-1)*36)=PositionMatrix(:,i)'*PositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36);
            end
            RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)=RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36)./norm(RelativePositionMatrix(:,(y-1)*6+x+(RoundNumber-1)*36));
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

% one eye feature, sigma is default in Find... function
%S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix);
% two eye feature
% S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix,64723,0.5383);
% figure(1);
% AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix, 0.5383);
% figure(2);
% AffinityMatrix2=DisplayAffinityMatrix(PositionMatrix,64723);
% figure(3);
% AffinityMatrix3=DisplayAffinityMatrix(FeatureMatrix,0.5383,S);

%Normalized relative gaze position
%Absolute gaze sigma
%S=FindMetricPreservationMatrix(FeatureMatrix,RelativePositionMatrix,0.0686,0.5383);
%36 point relative gaze sigma
% S=FindMetricPreservationMatrix(FeatureMatrix,RelativePositionMatrix,0.0452,0.5383);
% figure(1);
% AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix, 0.5383);
% figure(2);
% AffinityMatrix2=DisplayAffinityMatrix(RelativePositionMatrix,0.0686);
% figure(3);
% AffinityMatrix3=DisplayAffinityMatrix(FeatureMatrix,0.5383,S);

S=eye(size(FeatureMatrix,1));
TotalError=0;
for QueryNumber=1:36
    QueryFeature=TestingFeatureMatrix(:,QueryNumber);
    TrainingFeatureMatrix=FeatureMatrix;
    %TrainingFeatureMatrix(:,QueryNumber)=[];
    TrainingPositionMatrix=RelativePositionMatrix;
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
    for ii = 1:36*4
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
%     %Estimation for absolute gaze position
%     EstimatePosition=TrainingWeightMatrix*weight;
%     TotalError=TotalError+norm(double(EstimatePosition)-double(TestingPositionMatrix(:,QueryNumber)));
    EstimateRelativePosition=TrainingWeightMatrix*weight;
    EstimatePosition=pinv(TestingPositionMatrix')*EstimateRelativePosition./norm(EstimateRelativePosition);
    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    %figure(2);
end

disp('AvgError');
AvgError=TotalError/36;
disp(AvgError);