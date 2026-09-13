function FEM = mesh_QUAD4_v1(xmesh,ymesh)

% MESH NAUTRUAL SPACE FOR 8-noded QUAD


xmesh_nodes_1 = xmesh+1;   xcords_1 = linspace(-1,1,xmesh_nodes_1);
% xmesh_nodes_2 = xmesh+1;   xcords_2 = linspace(-1,1,xmesh_nodes_2);



ymesh_nodes_1 = ymesh+1; ycords_1 = linspace(-1,1,ymesh_nodes_1);
% ymesh_nodes_2 = ymesh; ycords_2 = linspace(-1+2/(2*ymesh),1-2/(2*ymesh),ymesh_nodes_2);



nodes_number_1  = xmesh_nodes_1 * ymesh_nodes_1;
% nodes_number_2  = xmesh_nodes_2* ymesh;

% node_cords_1 = zeros(nodes_number_1,4); %[nodeid, x, y, z]

nodes_number_total = nodes_number_1;% + nodes_number_2;

node_cords_all = zeros(nodes_number_total,4);

%%
for ii = 1:ymesh_nodes_1
    
    for jj = 1:xmesh_nodes_1
        
        label = (ii - 1)* xmesh_nodes_1 + jj;
        
        node_cords_all(label,:) = [label, xcords_1(jj),ycords_1(ii),0];
        
        
    end
    
end

%
 

figure;plot(node_cords_all(:,2),node_cords_all(:,3),'ro');


All_node_cords =  node_cords_all;

All_node_cords(:,2) = (All_node_cords(:,2) + 1)/2;
All_node_cords(:,3) = (All_node_cords(:,3) + 1)/2;
%% FORM ELEMENT



elements_number = xmesh*ymesh;

elements_con = zeros(elements_number,4);


for ii = 1:ymesh
    
    
    for jj = 1:xmesh
        
        
        elem_label  =(ii-1)*xmesh + jj;
        
        
        label_pnt1 =  jj + (ii-1)*(xmesh+1);
        
        label_pnt2 =  jj + (ii-1) *(xmesh+1) +1;
        
  
        
        label_pnt3 =  jj + ii*(xmesh+1) +1;
        
        label_pnt4 =  jj + ii*(xmesh+1) ;
        
        elements_con(elem_label,:) = [label_pnt1 label_pnt2 label_pnt3 label_pnt4  ];
    end
    
    
    
    
end










FEM.nodesCord = All_node_cords;
FEM.elementNodes = elements_con;

FEM.cbar = '';

FEM.numberElements = elements_number;



