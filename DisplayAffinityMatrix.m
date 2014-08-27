function [ AffinityMatrix ] = DisplayAffinityMatrix( InputSpace, sigma, TransformMatrix )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

FeatureDimension=size(InputSpace,1);
NumOfFeature=size(InputSpace,2);
if nargin<3
    TransformMatrix=eye(FeatureDimension);
end
AffinityMatrix=double(zeros(NumOfFeature));

%Use simple product as the affinity
% for i=1:NumOfFeature
%     for j=1:NumOfFeature
%         AffinityMatrix(i,j)=InputSpace(:,i)'*TransformMatrix*InputSpace(:,j);
%     end
% end

%Use diffusion map as affinity matrix
for i=1:NumOfFeature
    for j=1:NumOfFeature
        w(i,j)=exp(-(InputSpace(:,i)-InputSpace(:,j))'*TransformMatrix*(InputSpace(:,i)-InputSpace(:,j))/2/sigma);
    end
end
for i=1:NumOfFeature
    for j=1:NumOfFeature
        AffinityMatrix(i,j)=w(i,j)/(sum(w(i,:))-w(i,i));
    end
    AffinityMatrix(i,i)=0;
end
imagesc(AffinityMatrix);
colorbar();
end

