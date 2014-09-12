%Refer to Professor Wu's new method pdf, new solution 1.

%Load features
clear;
k_knn=20;
lamda=0.0001;
steplength=1E-6;
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

% two eye feature
S=FindMetricPreservationMatrix(FeatureMatrix,PositionMatrix,64723,0.5383);
figure(1);
AffinityMatrix1=DisplayAffinityMatrix(FeatureMatrix, 0.5383);
figure(2);
AffinityMatrix2=DisplayAffinityMatrix(PositionMatrix,64723);
figure(3);
AffinityMatrix3=DisplayAffinityMatrix(FeatureMatrix,0.5383,S);

TotalError=0;
for QueryNumber=1:36
    QueryFeature=TestingFeatureMatrix(:,QueryNumber);
    TrainingFeatureMatrix=FeatureMatrix;
    TrainingPositionMatrix=PositionMatrix;
    %Calculate the estimate gaze position and display it
    FeatureVector=QueryFeature;
    for ii = 1:36*4
        DistanceMatrix(ii)=(FeatureVector-TrainingFeatureMatrix(:,ii))'*S*(FeatureVector-TrainingFeatureMatrix(:,ii));
    end
    [SortedDistanceMatrix,index]=sort(DistanceMatrix);
    disp('QueryNumber');
    disp(QueryNumber);
    %disp('index:');
    %disp(index);
    %index(find(index==QueryNumber))=[];

    for k=1:k_knn
        AMatrix(:,k)=FeatureMatrix(:,index(k));
        TrainingWeightMatrix(:,k)=TrainingPositionMatrix(:,index(k));
    end
    BMatrix=TrainingWeightMatrix;
    A=AMatrix;
    B=BMatrix;
    CMatrix=(FeatureVector*ones(k_knn,1)'-AMatrix)'*S*(FeatureVector*ones(k_knn,1)'-AMatrix);
    weight=pinv(CMatrix)*ones(k_knn,1);
    weight=weight./sum(weight);
   
    % Gradient descent for new solution 3 target function
    while 1
        Gradient=-2*A'*S*(FeatureVector-A*weight);
        W=double(zeros(36*4,1));
        P=double(zeros(36*4,1));
        for i=1:36*4
            W(i)=exp(-(B*weight-TrainingPositionMatrix(:,i))'*(B*weight-TrainingPositionMatrix(:,i))/2/64723);
        end
        SumW=sum(W);
        for i=1:36*4
            P(i)=W(i)/SumW;
        end
        for i=1:36*4
            Gradient=Gradient+lamda/64723*P(i)*log(P(i))*B'*TrainingPositionMatrix(:,i);
            for j=1:36*4
                Gradient=Gradient-lamda/64723*P(i)*log(P(i))*P(j)*B'*TrainingPositionMatrix(:,j);
            end
        end
        Newweight=weight-steplength*Gradient;
        if norm(Newweight-weight)>0.00001
            TragetfuncitonValue=(FeatureVector-AMatrix*weight)'*S*(FeatureVector-AMatrix*weight);
            for RoundNumber=1:4
                for i=1:36
                    TragetfuncitonValue=TragetfuncitonValue+lamda*((FeatureVector-TrainingFeatureMatrix(:,i+(RoundNumber-1)*36))'*S*(FeatureVector-TrainingFeatureMatrix(:,i+(RoundNumber-1)*36))-norm(BMatrix*weight-TrainingPositionMatrix(:,i+(RoundNumber-1)*36)))^2;
                end
            end
            disp('TargetFunctionValue');
            disp(TragetfuncitonValue);
            weight=Newweight;
        else
            break;
        end
    end
    EstimatePosition=TrainingWeightMatrix*weight;
    TotalError=TotalError+norm(double(EstimatePosition)-double(PositionMatrix(:,QueryNumber)));
    %figure(2);
end
AvgError=TotalError/36;