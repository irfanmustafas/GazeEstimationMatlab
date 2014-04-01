function [ OutCor ] = NewCor2ImgCor( InputCor, Xe, Theta )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

InputCoordinate=double(InputCor);
InputXe=double(Xe);
InputTheta=double(Theta);

CorShiftXe=[cos(-InputTheta),-sin(-InputTheta);sin(-InputTheta),cos(-InputTheta)]*InputCoordinate;

OutCor=[round(InputXe(1)-CorShiftXe(1));round(CorShiftXe(2)+InputXe(2))];
end

