function FunctionValue = RelativePositonToAbsolute( CoordinateAndLengthUnit,RelativePosition )
%Given input Relatvie Position, give the relationship between the absolute coorinates and the
%normorlized length unit and the relative position.
%   CoordinateAndLengthUnit(1)=coordinate on y
%   axis,CoordinateAndLengthUnit(2)=coordinate on x
%   axis,CoordinateAndLengthUnit(3) is the normalized length unit.
%   RelativePosition including the normalized length to
%   upleft,upright,bottomleft,and bottom right corner.
AnchorCoordinate=double(zeros(2,4));
AnchorCoordinate(1,1)=floor(480/7*1);
AnchorCoordinate(2,1)=floor(640/7*1);
AnchorCoordinate(1,2)=floor(480/7*1);
AnchorCoordinate(2,2)=floor(640/7*6);
AnchorCoordinate(1,3)=floor(480/7*6);
AnchorCoordinate(2,3)=floor(640/7*1);
AnchorCoordinate(1,4)=floor(480/7*6);
AnchorCoordinate(2,4)=floor(640/7*6);

FunctionValue(1)=((CoordinateAndLengthUnit(1)'-AnchorCoordinate(1,1)).^2+(CoordinateAndLengthUnit(2)'-AnchorCoordinate(2,1)).^2-(CoordinateAndLengthUnit(3)*RelativePosition(1)).^2).^2;
FunctionValue(2)=((CoordinateAndLengthUnit(1)'-AnchorCoordinate(1,2)).^2+(CoordinateAndLengthUnit(2)'-AnchorCoordinate(2,2)).^2-(CoordinateAndLengthUnit(3)*RelativePosition(2)).^2).^2;
FunctionValue(3)=((CoordinateAndLengthUnit(1)'-AnchorCoordinate(1,3)).^2+(CoordinateAndLengthUnit(2)'-AnchorCoordinate(2,3)).^2-(CoordinateAndLengthUnit(3)*RelativePosition(3)).^2).^2;
%FunctionValue(4)=((CoordinateAndLengthUnit(1)'-AnchorCoordinate(1,4)).^2+(CoordinateAndLengthUnit(2)'-AnchorCoordinate(2,4)).^2-(CoordinateAndLengthUnit(3)*RelativePosition(4)).^2).^2;

end

