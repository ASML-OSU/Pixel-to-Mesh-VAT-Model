function [NodeLabel,min_dis_location]=closest_node(TargetPointCoordinate,SetsPointsCoordinates)

% calculate distance between them

% No label in TargetPointCoordinates
% SetsPointsCoordinates - includes label, x, y, z.

distance_2_nodes=zeros(1,size(SetsPointsCoordinates,1));

x0=TargetPointCoordinate(1);
y0=TargetPointCoordinate(2);
z0=TargetPointCoordinate(3);




for sets_nodes_num=1:size(SetsPointsCoordinates)
    
    x1=SetsPointsCoordinates(sets_nodes_num,2);
    y1=SetsPointsCoordinates(sets_nodes_num,3);
    z1=SetsPointsCoordinates(sets_nodes_num,4);
    
    distance_2_nodes(sets_nodes_num)=sqrt((x0-x1)^2+(y0-y1)^2+(z0-z1)^2);
    
    
end

[min_dis,min_dis_location]=min(distance_2_nodes);



NodeLabel=SetsPointsCoordinates(min_dis_location,1);