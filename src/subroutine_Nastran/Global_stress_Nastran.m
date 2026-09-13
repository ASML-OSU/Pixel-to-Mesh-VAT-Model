% Using this subroutine the stress value can be plotted for each layer,
% also in material coordinate system and global coordinate system

% t0 =45;
% t1 = 0;
% T0T1 = [ t0 t1 ;
%     -t0 -t1;
%     t0 t1;
%     t0 t1;
%     -t0 -t1;
%     t0 t1];


% % for layer = 1:Laminate.layer
% %
% %     for elem = 1:FEM.elementNumber
% %
% %
% %         stress_global = [FEM.stress(elem,1,layer)  FEM.stress(elem,2,layer)  FEM.stress(elem,3,layer)]';
% %
% %         T = Tmatrix_global_to_material(PlyAngle(layer));
% %
% %         stress_mat = T*stress_global;
% %         FEM.stress_mat(elem,:,layer) = stress_mat';
% %
% %     end
% %
% % end

% stress recovery for each element since they have different fiber ply
% orientations
% % center =[0.4 0.4];
% % width = 0.8;

% Case_element_connectivity = Mesh.elementNodes = FEM.elementNodes;
% Case_node_cords           = Mesh.nodesCord = FEM.nodeCoordinates_label;

for elem = 1:size(Mesh.elementNodes)
    
    node_labels = Mesh.elementNodes(elem,:);
    
    Element_center_X = sum( Mesh.nodesCord(node_labels,2))/length(node_labels);
    Element_center_Y = sum( Mesh.nodesCord(node_labels,3))/length(node_labels);
    
    
    
    
    cords = [abs(Element_center_X-center(1)) abs(Element_center_Y-center(2))];
      
    
    % for layer = 1:Laminate.layer
    for layer = 1:size(VAT.LXY,1)

        phi   =  VAT.LXY(layer,1);
        T0    =  VAT.LXY(layer,2);
        T1    =  VAT.LXY(layer,3);
        theta(layer) =  VAT_fiber_ply_angle_1D_rotate(T0,T1,Element_center_X,Element_center_Y,center,Plate.width,phi);
        
                % T0 = T0T1(layer,1);
                % T1 = T0T1(layer,2);
                % 
                % theta(layer) = VAT_fiber_ply_angle_1D(T0,T1,centerX,center(1),Stru.length);
        
        % theta(layer) = VAT_fiber_ply_angle_Lagrangian(cords,T0T1(:,:,layer));
        % theta(layer) = VAT_fiber_ply_angle_Lagrangian_2D(cords,VAT,layer);

        stress_global = [FEM.stress(elem,1,layer)  FEM.stress(elem,2,layer)  FEM.stress(elem,3,layer)]';    % Global stress value sigma_x, sigma_y, gamma_xy
        
        T = Tmatrix_global_to_material(theta(layer));       % Transformation matrix
        
        stress_mat = T*stress_global;
        FEM.stress_mat(elem,:,layer) = stress_mat';

    end
    
end

% maxstress_globalcord_each_layer = ...
%     [max((FEM.stress(:,:,1))) 0 min((FEM.stress(:,:,1)))
%     max((FEM.stress(:,:,2))) 0 min((FEM.stress(:,:,2)))
%     max((FEM.stress(:,:,3))) 0 min((FEM.stress(:,:,3)))
%     max((FEM.stress(:,:,4))) 0 min((FEM.stress(:,:,4)))
%     max((FEM.stress(:,:,5))) 0 min((FEM.stress(:,:,5)))
%     max((FEM.stress(:,:,6))) 0 min((FEM.stress(:,:,6)))];

maxstress_globalcord_each_layer = ...
    [max((FEM.stress(:,:,1))) 0 min((FEM.stress(:,:,1)))
    max((FEM.stress(:,:,2))) 0 min((FEM.stress(:,:,2)))
    max((FEM.stress(:,:,3))) 0 min((FEM.stress(:,:,3)))
    max((FEM.stress(:,:,4))) 0 min((FEM.stress(:,:,4)))];



% maxstress_matcord_each_layer = ...
%     [max((FEM.stress_mat(:,:,1))) 0 min((FEM.stress_mat(:,:,1)))
%     max((FEM.stress_mat(:,:,2))) 0 min((FEM.stress_mat(:,:,2)))
%     max((FEM.stress_mat(:,:,3))) 0 min((FEM.stress_mat(:,:,3)))
%     max((FEM.stress_mat(:,:,4))) 0 min((FEM.stress_mat(:,:,4)))
%     max((FEM.stress_mat(:,:,5))) 0 min((FEM.stress_mat(:,:,5)))
%     max((FEM.stress_mat(:,:,6))) 0 min((FEM.stress_mat(:,:,6)))];

maxstress_matcord_each_layer = ...
    [max((FEM.stress_mat(:,:,1))) 0 min((FEM.stress_mat(:,:,1)))
    max((FEM.stress_mat(:,:,2))) 0 min((FEM.stress_mat(:,:,2)))
    max((FEM.stress_mat(:,:,3))) 0 min((FEM.stress_mat(:,:,3)))
    max((FEM.stress_mat(:,:,4))) 0 min((FEM.stress_mat(:,:,4)))];


%% plot stress
% center of each element

for elem=1:size(Mesh.elementNodes, 1)
    
    NodeIndices=Mesh.elementNodes(elem,:);       %% Node NO. for one element
    numberNodes=size(Mesh.nodesCord(:,2:3),1);    %% how many nodes in FEM
    
    centerX(elem) = sum(Mesh.nodesCord( NodeIndices,2))/length( NodeIndices);
    centerY(elem) = sum(Mesh.nodesCord( NodeIndices,3))/length( NodeIndices);
    
    
end

% figure(111);hold on;

%plot(centerX,centerY,'bo');

Xcoord = Mesh.nodesCord(:,2);
Ycoord = Mesh.nodesCord(:,3);

layerno  = 1;

stress_type = 1;

dx=min(Xcoord):(max(Xcoord)-min(Xcoord))/50:max(Xcoord);
dy=min(Ycoord):(max(Ycoord)-min(Ycoord))/50:max(Ycoord);
[x3,y3]=meshgrid(dx,dy);
% 
% figure;
% z3 =  griddata(centerX,centerY,FEM.stress(:,stress_type,layerno),x3,y3,'v4');
% 
% 
% hold on;
% surf(x3,y3,z3,'FaceColor','interp',...
%     'EdgeColor','none',...
%     'FaceLighting','phong');
% 
% title(['Global stress distribution for layer # ' num2str(layerno)]);
% colormap(coolwarm(30))
% colorbar
% figure;
% contour(x3,y3,z3)
% 
% 
% figure;
% 
% z3 =  griddata(centerX,centerY,FEM.stress_mat(:,stress_type,layerno),x3,y3,'v4');
% 
% surf(x3,y3,z3,'FaceColor','interp',...
%     'EdgeColor','none',...
%     'FaceLighting','phong');
% 
% 
% 
% title(['Local(material) stress distribution for layer # ' num2str(layerno)]);
% colormap(coolwarm(30));view(2);
% colorbar
% figure;
% contour(x3,y3,z3)
% 
% axis image;
% 
% 
% 
% figure;
% 
% z3 =  griddata(centerX,centerY,FEM.stress_mat(:,2,layerno),x3,y3,'v4');
% 
% surf(x3,y3,z3,'FaceColor','interp',...
%     'EdgeColor','none',...
%     'FaceLighting','phong');
% 
% 
% 
% title(['Local(material) stress distribution for layer # ' num2str(layerno)]);
% colormap(coolwarm(30));view(2);
% colorbar
% figure;
% contour(x3,y3,z3)
% 
% axis image;
% 
% 
% figure;
% 
% z3 =  griddata(centerX,centerY,FEM.stress_mat(:,3,layerno),x3,y3,'v4');
% 
% surf(x3,y3,z3,'FaceColor','interp',...
%     'EdgeColor','none',...
%     'FaceLighting','phong');
% 
% 
% 
% title(['Local(material) stress distribution for layer # ' num2str(layerno)]);
% colormap(coolwarm(30));view(2);
% colorbar
% figure;
% contour(x3,y3,z3)
% 
% axis image;


%% ================== PLOT Stress Resultant ======================

% integrate stress over thickness

NXX = zeros(1,size(Mesh.elementNodes,1));
NYY = zeros(1,size(Mesh.elementNodes,1));
NXY = zeros(1,size(Mesh.elementNodes,1));

for elem = 1:size(Mesh.elementNodes,1)
    
    
    for layer = 1:length(Laminate.layer_thickness)
        
        
        NXX(elem) = NXX(elem) + Laminate.layer_thickness(layer)*FEM.stress_mat(elem,1,layer);
        NYY(elem) = NYY(elem) + Laminate.layer_thickness(layer)*FEM.stress_mat(elem,2,layer);
        NXY(elem) = NXY(elem) + Laminate.layer_thickness(layer)*FEM.stress_mat(elem,3,layer);
        
    end
    
    
end



figure;
subplot(1,3,1)
z3 =  griddata(centerX,centerY, NXX,x3,y3,'v4');

surf(x3,y3,z3,'FaceColor','interp',...
    'EdgeColor','none',...
    'FaceLighting','phong');view(2);
colormap(coolwarm(30));view(2);
colorbar;axis image;


subplot(1,3,2)
z3 =  griddata(centerX,centerY, NYY,x3,y3,'v4');

surf(x3,y3,z3,'FaceColor','interp',...
    'EdgeColor','none',...
    'FaceLighting','phong');view(2);
colormap(coolwarm(30));view(2);
colorbar;axis image;
title('In-plane stress resultants - Material Co-ordinate, N_{XX}, N_{YY}, N_{XY} (N/m)');


subplot(1,3,3)
z3 =  griddata(centerX,centerY, NXY,x3,y3,'v4');

surf(x3,y3,z3,'FaceColor','interp',...
    'EdgeColor','none',...
    'FaceLighting','phong');view(2);
colormap(coolwarm(30));view(2);
colorbar;axis image;
axis image;



%%

% integrate stress over thickness

NXX = zeros(1,size(Mesh.elementNodes,1));
NYY = zeros(1,size(Mesh.elementNodes,1));
NXY = zeros(1,size(Mesh.elementNodes,1));

for elem = 1:size(Mesh.elementNodes,1)
    
    
    for layer = 1:length(Laminate.layer_thickness)
        
        
        NXX(elem) = NXX(elem) + Laminate.layer_thickness(layer)*FEM.stress(elem,1,layer);
        NYY(elem) = NYY(elem) + Laminate.layer_thickness(layer)*FEM.stress(elem,2,layer);
        NXY(elem) = NXY(elem) + Laminate.layer_thickness(layer)*FEM.stress(elem,3,layer);
    end
    
    
end

% save Nxx_resultant_straight_beta0.txt NXX -ascii
% save Nyy_resultant_straight_beta0.txt NYY -ascii
% save Nxy_resultant_straight_beta0.txt NXY -ascii

figure;
subplot(1,3,1)
z3 =  griddata(centerX,centerY, -NXX ,x3,y3,'v4'); 
griddata(centerX,centerY, NXX,Plate.length/2,Plate.width/2,'v4')
surf(x3,y3,z3,'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
view(2);
colormap(coolwarm(30));
view(2);
% caxis([min(-NXX(:)/max(abs(NXX(:)))) max(-NXX(:)/max(abs(NXX(:))))])
colorbar('fontsize',25)
set(gca, 'FontSize',25); % Adjust the font size as needed
axis image;

subplot(1,3,2)% /max(abs(NXX(:)))
z3 =  griddata(centerX,centerY, -NYY,x3,y3,'v4'); 
griddata(centerX,centerY, NYY,Plate.length/2,Plate.width/2,'v4')
surf(x3,y3,z3,'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
view(2);
colormap(coolwarm(30));
view(2);
colorbar('fontsize',25)
set(gca, 'FontSize',25); % Adjust the font size as needed
axis image;

% caxis([min(-NYY(:)/max(abs(NXX(:)))) max(-NYY(:)/max(abs(NXX(:))))])
% title('In-plane stress resultants - GLOBAL CORD, NXX, NYY, NXY (N/m)');
% title('In-plane stress resultants - Global Co-ordinate, N_{XX}, N_{YY}, N_{XY} (N/m)');


subplot(1,3,3)
z3 =  griddata(centerX,centerY, -NXY ,x3,y3,'v4'); 
griddata(centerX,centerY, NXY,Plate.length/2,Plate.width/2,'v4')

surf(x3,y3,z3,'FaceColor','interp','EdgeColor','none','FaceLighting','phong');
view(2);
colormap(coolwarm(30));
view(2);
axis image;
colorbar('fontsize',25)
set(gca, 'FontSize', 25); % Adjust the font size as needed
% caxis([min(-NXY(:)/max(abs(NXX(:)))) max(-NXY(:)/max(abs(NXX(:))))])

axis image;






