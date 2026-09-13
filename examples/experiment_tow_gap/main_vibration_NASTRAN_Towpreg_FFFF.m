% MAIN CODE FOR

clear all;warning off;format long;

close all


current_folder_path = pwd;

folder_example = fileparts(current_folder_path);

folder_main = fileparts(folder_example);

%% ==== add subroutines ======
addpath(genpath([folder_main  filesep 'src']));

%%

Plate.length =0.4;

Plate.width = 0.3;

mesh_number_x = 1*40;
mesh_number_y = 1*30;

design_folder = ['NASTRAN_Z0_MIN_analysis_SOL103_VAT_TowpregWiseModel_FFFF' '_x_' num2str(mesh_number_x) '_y_' num2str(mesh_number_y)];
%% Generate plate mesh

% FEM = mesh_QUAD8_v2(mesh_number_x,mesh_number_y);

FEM = mesh_QUAD4_v1(mesh_number_x,mesh_number_y);

patch_plot(FEM.elementNodes,FEM.nodesCord,101,'skin')

%
%
%% Only for check the sequence of the element order to ensure
%% it is consistent with the image binary matrix

if 0
    for ijk = 1:size(FEM.elementNodes,1)


        hold on;
        nodeid = FEM.elementNodes(ijk,:);
        elem_center_x = sum(FEM.nodesCord(nodeid,2))/length(nodeid);
        elem_center_y = sum(FEM.nodesCord(nodeid,3))/length(nodeid);
        elem_center_z = sum(FEM.nodesCord(nodeid,4))/length(nodeid);
        text(elem_center_x,elem_center_y,elem_center_z,num2str(ijk))

    end
end

%% =============== PANEL GEOMETRY================================

FEM.nodesCord(:,2)=FEM.nodesCord(:,2)/max(FEM.nodesCord(:,2))*Plate.length;
FEM.nodesCord(:,3)=FEM.nodesCord(:,3)/max(FEM.nodesCord(:,3))*Plate.width;

%---------Coordinates of node------------
Xcoord=FEM.nodesCord(:,2);
Ycoord=FEM.nodesCord(:,3);
Zcoord=FEM.nodesCord(:,4);

%%
%-----------------------------------------
Stru.length=max(abs(Xcoord));
Stru.width=max(abs(Ycoord));

FEM.nodeCoordinates=FEM.nodesCord(:,2:3);

%---------------------------------------
FEM.NodeNumber=size(FEM.nodesCord,1);
FEM.elementNumber=size(FEM.elementNodes,1);


FEM.nodeCoordinates_label = zeros(size(FEM.nodeCoordinates,1),4);

FEM.nodeCoordinates_label(:,2:3) = FEM.nodeCoordinates;
figure(200);hold on;
plot(FEM.nodeCoordinates(:,1),FEM.nodeCoordinates(:,2),'ko')
FEM.nodeCoordinates_label(:,1)  = 1:size(FEM.nodeCoordinates,1);


patch_plot(FEM.elementNodes,FEM.nodeCoordinates_label,200,'skin');axis image;


FEM.PlateNodeDof=5;%% for plate
FEM.GDof = FEM.PlateNodeDof*size(FEM.nodeCoordinates,1);



T0T1 =[30 10
    -30 -10
    30 10
    -30 -10
    90 90
    90 90
    -30 -10
    30 10
    -30 -10
    30 10];

%% Prepreg tape thickness
Laminate.layer_thickness = 1.75e-4;% 0.0018/size(T0T1,1); %1.545e-4;%%1.27e-4;

Laminate.number_of_plies = size(T0T1,1);

% Laminate.theta = zeros(Laminate.number_of_plies,FEM.numberElements);
%
% Laminate.ply_thickness = zeros(Laminate.number_of_plies,FEM.numberElements);

%%

%% towpreg wise model

if 0

    edge_plot_option = 0;
    % towpreg_wise_model_tape_complete_overlap
    towpreg_wise_model_tape_cut_restart_complete_gap
end

read_tape_binary_lamina_info_tape_cut_restart_complete_gap_v3


%% =========== generate nastran file


program_folder = pwd;

% design_folder = 'NASTRAN_analysis_validation_LS_C_originalAngle';
% design_folder = ['NASTRAN_analysis_sol105_thermal_VAT_TowpregWiseModel' '_x_' num2str(mesh_number_x) '_y_' num2str(mesh_number_y)];

nastran_base_folder = 'sol103';


if ~exist(design_folder, 'dir')

    % rmdir(design_folder, 's');  % 's' = recursive delete

    mkdir(design_folder)
end

copyfile([nastran_base_folder filesep 'sol103_free.bdf'],design_folder)
%% ====================== Write GRID ==================

case_node_cords =FEM.nodesCord;

% write_grid ==> node coordinates
fname = 'GRID.dat';
write_grid(case_node_cords,design_folder,fname,'1');

%% ============= write quad4 ==================

QUAD4 = zeros(FEM.elementNumber,6); % id, pid, node1, node2, node3, node4
QUAD4(:,1) = 1:FEM.elementNumber;
QUAD4(:,2) = 1:FEM.elementNumber;

QUAD4(:,3:6) = FEM.elementNodes;

write_CQUAD4(QUAD4,design_folder,'CQUAD4.dat')

%%  =========== write PCOMP =================
% 1- lamina_info --> overlap, gap or resin
Case_element_connectivity = FEM.elementNodes;

ElementThicknessContour = zeros(FEM.numberElements,3);


material_properties

for elem = 1:FEM.elementNumber


    temp_angle = fiber_angle2{elem};
    temp_lamina = lamina_info2{elem};

    theta = zeros(1,size(temp_angle ,2));
    Layerthickness = zeros(1,size(temp_angle ,2));
    MatID =zeros(1,size(temp_angle ,2));

    if ~isempty(fiber_angle2{elem}) %% not complete gap

        for layer = 1:size(temp_angle,2)
            %
            theta(layer)  = str2double(temp_angle{layer});


            present_layer =  str2double(temp_lamina{layer});

            %% mode this element as normal laying-up
            MatID(layer) = 1;
            Layerthickness(layer) = Laminate.layer_thickness;
            % end




        end

    else %% complete gap case

        theta = 0;% one layer
        Layerthickness = Laminate.layer_thickness; %*ones(size(T0T1,1),1);

        MatID = 2;%2*ones(size(T0T1,1),1);

        disp(['================= Present Element is Void == # == ' num2str(elem) ' ============'])


    end


    %% Calculate elemental ABD matrices

    zk = zeros(length(theta),1);
    zk0 = zeros(length(theta),1);


    for layer = 1:length(theta)
        if layer == 1

            zk0(layer) = 0;

        else

            zk0(layer) = sum(Layerthickness(1:layer-1));

        end


        zk(layer) =   zk0(layer) +Layerthickness(layer);

    end

    % ElementThicknessContour(elem,:) = [Element_center_X Element_center_Y sum(Laminate.ply_thickness(:,elem))];


    [Amatrix,Dmatrix,Ashear,Bmatrix,Qbar_theta]=LaminatedComposite_ABD_Matrix(Mat,theta,zk,zk0,MatID);


    ABD.A(:,:,elem) = Amatrix;
    ABD.B(:,:,elem) = Bmatrix;
    ABD.D(:,:,elem) = Dmatrix;





    % ElementThicknessContour(elem,:) = [Element_center_X Element_center_Y sum(Laminate.ply_thickness(:,elem))];

    %% write PCOMP

    section  = ['VAT=== Elem#' num2str(elem)];
    Sym_flag = 'FULL';
    FT = ' ';
    PCOMP_label = elem;

    Z0 =[];
    Z0 = 0.0;

    FullPlyAngles = theta;

    if elem == 1
        start ='1';
    else
        start ='0';
    end
    %     design_folder ='C:\Users\weizhao\Documents\Paper\AIAAJ_curve_fiber\AIAAJ_Vibration_Code_modified\NASTRAN_examples\design_folder';
    pcomp_bdf_file_name = 'PCOMP.dat';
    write_PCOMP_v1(design_folder,pcomp_bdf_file_name,...
        PCOMP_label,section,...
        MatID,Layerthickness,FullPlyAngles,...
        Sym_flag,Z0,start,FT);

end


%% 2 - Generate SPC: boundary conditions

% free free boundary condition

%% 3 - run NASTRAN analysis


nastran = 'C:\MSC.Software\MSC_Nastran\2023.3\bin\nast20233.exe ';

cd(design_folder); % Change the current working directory to the folder containing BDF files.

delete *.1 % remove previous files

call_NASTRAN_BDF = [nastran 'sol103_free.bdf']; % Create a command to call Nastran with the main_sol101.bdf file as input.

system(call_NASTRAN_BDF); % Execute the Nastran analysis by running the system command with the created command.

program_nastran_determine('sol103_free');

cd(program_folder)


%% 4 - read NASTRAN results

pchfname=[design_folder filesep 'sol103_free.pch'];
minodeid = min(FEM.nodeCoordinates_label(:,1));
maxnodeid = max(FEM.nodeCoordinates_label(:,1));
Modelimit = 13;
ModeShape=readmodeshape_v2(pchfname,minodeid,maxnodeid,Modelimit);

[naturafrequency,GM ] = readnf([design_folder filesep 'sol103_free.f06'],Modelimit);

disp('==natural frequencies (Hz):');

naturafrequency'

%% 5 - plot nastran mode shape results

for modenumber = 7:13  % the first 6 modes are rigid modes for free free vibration analysis


    deformUZ = ModeShape.modeshape(:,4,modenumber);

    positive_or_negative = find(abs(deformUZ(:)) ==max(abs(deformUZ(:))));

    scalefactor =  -1/deformUZ(positive_or_negative(1));

    deformedW = FEM.nodeCoordinates_label;

    deformedW(:,4) =   deformedW(:,4) +  deformUZ*scalefactor;

    figure1 = figure(1000+modenumber);
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    patch_plot_v2(FEM.elementNodes,FEM.nodeCoordinates_label,1000+modenumber,'modeshape',deformedW);axis image;
    axis(axes1,'tight');
    hold(axes1,'off');
    % Set the remaining axes properties
    set(gca,'FontSize',20)
    % set(axes1,'DataAspectRatio',[1 1 1],'FontSize',14);
    xlabel('a/m')
    ylabel('b/m')


    colorbar('FontSize',20)
    %     colormap(jet(10));
    % colormap(coolwarm(10));

    export_fig( ['modeshape_' num2str(modenumber) '.png'], '-png', '-r300');

    copyfile(['modeshape_' num2str(modenumber) '.png'],design_folder)
    saveas(gcf, [design_folder filesep 'modeshape_' num2str(modenumber) ],'fig')


end
%% End of code

%%
xy = FEM.nodeCoordinates;
conn = FEM.elementNodes;

D11 = ABD.D(1,1,:);
D22 = ABD.D(2,2,:);

figure
subplot(1,2,1)
patch('Faces',conn, ...
    'Vertices',xy, ...
    'FaceVertexCData',D11(:), ...
    'FaceColor','flat', ...
    'EdgeColor','none');

axis equal
axis tight
box on

set(gca,'FontSize',20)
xlabel('x')
ylabel('y')

cb = colorbar;
cb.Label.String = 'D_{11}';

title('Elemental D_{11} distribution')

colormap(coolwarm(20));
%

subplot(1,2,2)
patch('Faces',conn, ...
    'Vertices',xy, ...
    'FaceVertexCData',D22(:), ...
    'FaceColor','flat', ...
    'EdgeColor','none');

axis equal
axis tight
box on
xlabel('x')
ylabel('y')
set(gca,'FontSize',20)
cb = colorbar;
cb.Label.String = 'D_{22}';

title('Elemental D_{22} distribution')

colormap(coolwarm(20));

set(gcf,'color','w');



save FEM.mat FEM -mat
save ABD.mat ABD -mat


%%


