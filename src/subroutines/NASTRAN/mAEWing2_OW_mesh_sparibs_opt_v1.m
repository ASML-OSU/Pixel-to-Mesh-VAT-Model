curves_number = size(OW_global_SpaRibs_pnts,3);

% curves_number = global_num_stiffener+OW_num_temp; 

line_start_label_new = 10000;

start='0';
section='OW';
mesh_xAEWing3_v2(curves_number,line_start_label_new,...
    design_folder,OW_ses_file_name,start,plate_meshsize,design_file_name,section,patran_version);

% add quit patran when meshing is over


% run PATRAN for OW mesh
cd(design_folder);

% design_folder
% % ! patran ' ' [design_folder filesep design_pcl_ses]]
design_pcl_ses = OW_ses_file_name;
call_PATRAN_OW_2D_Mesh=[ patran ' ' [design_folder filesep design_pcl_ses] ' -ans yes '];
system(call_PATRAN_OW_2D_Mesh);



% theprogram = patran;
% thearguments = [design_folder filesep design_pcl_ses];
% system(sprintf('%s %s', [theprogram thearguments]))
if isunix
    design_db=[section '_' design_file_name];
    fname = [design_folder filesep design_db];
    
    program_patran_determine(fname)
    
end
disp(['----- finish mAEWing2 ' design_file_name '_' section ' panels mesh! ------'])

%delete *.db
% !del *.jou
% cd(test_program_folder );

%
%% --- LIFT SURFACE
% % 
% for constructing lifting surface
LS_OW_liftsurf(2:4,:) = OW_FEM(1:3,:);
LS_OW_liftsurf (1,:) = OW_FEM(4,:);

% --- offset
offset_topskin=10100000;
offset_botskin=10200000;
offset_sparib_mid=10300000;
plateID_offset=11000000;

OWoffset=[offset_topskin offset_botskin offset_sparib_mid plateID_offset];

% [FEM_OW_topskin_node,FEM_OW_botskin_node,FEM_OW_equiv_skins_nodes,...
%     FEM_OW_topskin_elem,FEM_OW_botskin_elem,FEM_OW_2D_nodecords]=mAEWing2_mesh_skin_opt_v1(design_folder,section,...
%     design_file_name,LS_OW_liftsurf, OWoffset,Tol,sparibs_plot,alpha_0);

[FEM_OW_topskin_node,FEM_OW_botskin_node,FEM_OW_equiv_skins_nodes,...
    FEM_OW_topskin_elem,FEM_OW_botskin_elem,FEM_OW_2D_nodecords]=mAEWing2_mesh_skin_opt_v3(design_folder,section,...
    design_file_name,LS_OW_liftsurf, OWoffset,Tol,sparibs_plot,alpha_0,tip_def_weight_0);
                             
curves_number = curves_number-OW_refine_mesh_line_number -1 ;%(-1 because the last line is used to refine mesh)  


[FEM_OW_sparibs_3d_nodes,FEM_OW_sparibs_3d_elements]=mAEWing2_mesh_sparibs_opt_v1(curves_number,design_folder,...
    section,design_file_name,...   
    OWoffset,Tol,sparibs_plot,...
    sparibs_meshsize,FEM_OW_topskin_node,FEM_OW_botskin_node);                                


%% ADD TIP and ROOT ribs nodes and element to FEM_CB_sparibs_3d...

OW_span_tip = max(OW_FEM(:,2));
OW_span_root = min(OW_FEM(:,2));

% tip rib
OW_TR_nodes_label_in_2d = find(abs(OW_span_tip-abs(FEM_OW_2D_nodecords(:,3)))<Tol(2));
[OW_tip_rib_nodes,OW_tip_rib_elements]= delaunay_sparibs_mesh_opt_v1(OW_TR_nodes_label_in_2d,FEM_OW_topskin_node,...
    FEM_OW_botskin_node,'rib',sparibs_plot,Tol,OWoffset,sparibs_meshsize);


FEM_OW_sparibs_3d_nodes(1:size(OW_tip_rib_nodes,1),:,size(FEM_OW_sparibs_3d_nodes,3)+1) = OW_tip_rib_nodes;
FEM_OW_sparibs_3d_elements(1:size(OW_tip_rib_elements,1),:,size(FEM_OW_sparibs_3d_elements,3)+1) = OW_tip_rib_elements;


% root rib
OW_TR_nodes_label_in_2d = find(abs(OW_span_root-abs(FEM_OW_2D_nodecords(:,3)))<Tol(2));
[OW_tip_rib_nodes,OW_tip_rib_elements]= delaunay_sparibs_mesh_opt_v1(OW_TR_nodes_label_in_2d,FEM_OW_topskin_node,...
    FEM_OW_botskin_node,'rib',sparibs_plot,Tol,OWoffset,sparibs_meshsize);


FEM_OW_sparibs_3d_nodes(1:size(OW_tip_rib_nodes,1),:,size(FEM_OW_sparibs_3d_nodes,3)+1) = OW_tip_rib_nodes;
FEM_OW_sparibs_3d_elements(1:size(OW_tip_rib_elements,1),:,size(FEM_OW_sparibs_3d_elements,3)+1) = OW_tip_rib_elements;


%% form equivalent nodes for FEM_OW_equiv_full_nodes

FEM_OW_equiv_full_nodes_temp = FEM_OW_equiv_skins_nodes;

skins_nodes_number = size(FEM_OW_equiv_skins_nodes,1);

sparib_nodes_number_temp = 0;

for sparib_num=1:size(FEM_OW_sparibs_3d_nodes,3)

    sparib_nodes_temp = FEM_OW_sparibs_3d_nodes(:,:,sparib_num);
    
    sparib_nodes_temp_nonzeros = remove_zero_row(sparib_nodes_temp);
    
    sparib_nodes_number = size(sparib_nodes_temp_nonzeros,1);
    
    FEM_OW_equiv_full_nodes_temp(skins_nodes_number+sparib_nodes_number_temp+1:...
        skins_nodes_number+sparib_nodes_number_temp+sparib_nodes_number,:) = sparib_nodes_temp_nonzeros ;
    
    sparib_nodes_number_temp = sparib_nodes_number_temp+sparib_nodes_number;
end



%% equivalent code for ow
[uniA,locC]=unique(FEM_OW_equiv_full_nodes_temp(:,1));

FEM_OW_equiv_full_nodes=FEM_OW_equiv_full_nodes_temp(locC,:);

figure(231);plot3(FEM_OW_equiv_full_nodes(:,2),FEM_OW_equiv_full_nodes(:,3),FEM_OW_equiv_full_nodes(:,4),'ro')











