function [TargetPanel_nodecord_rowID3,TargetPanel_nodecord_rowID4,CTRIA3_Area,CQUAD4_Area]=TargetPanel(FEM)
%-------------------------------------------------------------------------
% TargetPanel_nodecord_rowID3 ---------- The nodes row ID in the
% FEM.points_coordinates that connect the 3-noded triangular element, CTRIA3

% TargetPanel_nodecord_rowID4 ---------- The nodes row ID in the
% FEM.points_coordinates that connect the 4-noded quadrilateral
% element,CQUAD4

% CTRIA3_Area, CQUAD4_Area -----Element area of each element.
TargetPanel_nodecord_rowID3=[];
TargetPanel_nodecord_rowID4=[];
CTRIA3_Area=[];
CQUAD4_Area=[];


topElemID4=1;

while topElemID4<=size(FEM.topskinCQUAD4,1)
    
    for ee=1:4
        
        element_node_label=FEM.topskinCQUAD4(topElemID4,1+ee);
        TargetPanel_nodecord_rowID4(topElemID4,ee)=find(FEM.points_coordinates(:,1)==element_node_label);
        
    end
    
    CQUAD4_Area(topElemID4,:)=[FEM.topskinCQUAD4(topElemID4,1) polyarea(FEM.points_coordinates(TargetPanel_nodecord_rowID4(topElemID4,:),2),...
        FEM.points_coordinates(TargetPanel_nodecord_rowID4(topElemID4,:),3))];
    
    topElemID4=topElemID4+1;
    
end
topElemID3=1;

while topElemID3<=size(FEM.topskinCTRIA3,1)
    for ee=1:3
        element_node_label=FEM.topskinCTRIA3(topElemID3,ee+1);
        TargetPanel_nodecord_rowID3(topElemID3,ee)=find(FEM.points_coordinates(:,1)==element_node_label);
    end
    
    CTRIA3_Area(topElemID3,:)=[FEM.topskinCTRIA3(topElemID3,1)  polyarea(FEM.points_coordinates(TargetPanel_nodecord_rowID3(topElemID3,:),2),...
        FEM.points_coordinates(TargetPanel_nodecord_rowID3(topElemID3,:),3))];
    
    topElemID3=topElemID3+1;
end

end

