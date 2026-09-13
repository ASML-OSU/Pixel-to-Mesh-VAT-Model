%% This program was used to read finite element model information and modal
%  information including natural frequencies and mode shapes from NASTRAN
%   normal mode analysis (SOL 103) output files(*.pch and *.f06 file)
%
% -------------------------------------------------------------------------
%               Developed by Wei Zhao @ Virginia Tech
%               Nov 13, 2014 (Contact: weizhao@vt.edu)
% -------------------------------------------------------------------------
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Subroutines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  readnf.m          -----  Read natural frequency, generalized stiffness
%  and mass  matrix
%  readgrid.m        -----  Read node coordinates
%  readtopelement.m  -----  Read element in the top skin of X-56A
%  readMass          -----  Read mass, rigid mass matrix
%  readmodeshape     -----  Read mode shape of X-56A
%  TargetPanel.m     -----  Find out the row ID of the element label in the
%  top skin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ModeShape: structured data
% 1). mode shape of each mode: such as ModeShape.modeshape1 is the first
% mode shape of this finite element model
% 2). natural frequencis of mode of interest
%
% FEM: structured data
% 1). generalized mass
% 2). nodal coordinates
% 3). location of CG of the model
% 4). total weight = structural weight + non-structural weight
% 5). rigid mass body matrix w.r.t user-defined coordinate
% 6). several other information needed in the model interpolation through
% manually input.
%
% The default mode shape are normalized and orthogonalized to the system mass

% Tracking history
% v2. add patch plot for post-processing; all slash in file to filesep for
% both Windows users and Mac users
% works for mode with triangle elements.




clear all;clc;warning off;

global ModeShape
global FEM

disp('--------------- VTModeX56A Reading program Starting.... ------------------');

[filename,filepath]=uigetfile([ '*.f06'],'Select Nastran Output File, .f06');
f06fname=[filepath  filename];

[filename,filepath]=uigetfile([ '*.pch'],'Select Nastran Output File, .pch');
pchfname=[filepath  filename];

% workingFolder=filepath(1:end-17);
% cd(workingFolder);
%% Extracting finite element model and modal information

Modelimit=input('How many modes do you need?(integer and less than 70): '); %% How many modes you need.

%%% ----------------------------------------------------------------------
%%%        Read Modal frequencies, Generalized mass matrix
%%% ----------------------------------------------------------------------
disp('--- Reading natural frequencies and generalized mass and stiffness matrix ---')
[NaturalFrequency,GM]=readnf(f06fname,Modelimit);

% FEM.Generalized_stiffness=GK(7:end,7:end);
FEM.Generalized_mass=GM(7:end,7:end);% diagnolized matrix, each term is generalized mass

%%% ----------------------------------------------------------------------
%%%                         Read node coordinates
%%% ----------------------------------------------------------------------

disp('-------------------- Reading grid coordinates of the X-56A ------------------')
FEM.points_coordinates=readgrid_v2(f06fname);

%%% ----------------------------------------------------------------------
%%%                         Read Element Connectivity
%%% ----------------------------------------------------------------------

disp('-------------------- Reading elements (CQUAD4 & CTRIA3)----------------------')


% filebdf_topskin=[pwd  filesep 'element_topskin_x56a.bdf'];
% [CQUAD4,CTRIA3]=readtopelement(filebdf_topskin);


FEM.topskinCQUAD4=[];%CQUAD4;
FEM.topskinCTRIA3=[];%CTRIA3;


%% ADD manually
FEM.topskinCTRIA3_ID = [100001:100830 500001: 500322 ...
    [100001:100830 500001:500322 ]+10000000 700001:700388 [700001:700388 ]+10000000];

[CQUAD4,CTRIA3]=readelementf06_v1(f06fname);

% % % % for ee=1:size(FEM.topskinCTRIA3_ID ,2)
% % % %     
% % % %     Elem_ID_temp=find(CTRIA3(:,1) == FEM.topskinCTRIA3_ID(ee));
% % % %     
% % % %     
% % % %    FEM.topskinCTRIA3(ee,:) = CTRIA3(Elem_ID_temp,:); 
% % % % end


FEM.topskinCTRIA3 = [];

%%% ----------------------------------------------------------------------
%%%                      Read mass, cg, rigid mass matrix, etc.
%%% ----------------------------------------------------------------------

disp('---------------- Reading C.G., mass and rigid mass matrix of X-56A ----------')
[CG,Weight,MassMatrixOutput,CGInertia,CGInertiaPrincipal]=readMass(f06fname);

FEM.model_CenterofGravity=CG;
FEM.model_total_weight=Weight;
FEM.rigid_mass_matrix_inertial=MassMatrixOutput;

%%% ----------------------------------------------------------------------
%%%                            Read Mode shape
%%% ----------------------------------------------------------------------

minodecord=FEM.points_coordinates(1,:);
minodeid=minodecord(1);
maxnodecord=FEM.points_coordinates(end,:);
maxnodeid=maxnodecord(1);
disp('-------------------- Reading mode shapes, it takes time ---------------------')
ModeShape=readmodeshape_v2(pchfname,minodeid,maxnodeid,Modelimit);

ModeShape.natural_frequency=NaturalFrequency;
%end of reading information and mode shapes
%% Plot undeformed body in 4 perspectives
% figure(1000);
% subplot(2,2,1)
% plot3(FEM.points_coordinates(:,2),FEM.points_coordinates(:,3),FEM.points_coordinates(:,4),'b.'); view(2); axis image; grid minor; box on;view(0,0);
% subplot(2,2,2)
% plot3(FEM.points_coordinates(:,2),FEM.points_coordinates(:,3),FEM.points_coordinates(:,4),'b.'); view(2); axis image; grid minor; box on;view(90,0);
% subplot(2,2,3)
% plot3(FEM.points_coordinates(:,2),FEM.points_coordinates(:,3),FEM.points_coordinates(:,4),'b.'); view(2); axis image; grid minor; box on;view(0,90);
% subplot(2,2,4)
% plot3(FEM.points_coordinates(:,2),FEM.points_coordinates(:,3),FEM.points_coordinates(:,4),'b.'); view(2); axis image; grid minor; box on;view(90,90);
% hold off;

%% Plot undeformed body
figure(2000);
subplot(2,2,1)
patch_plot_opt_v2(CTRIA3(:,2:end),FEM.points_coordinates,2000,'skin'); view(2); axis image; grid minor; box on;view(0,0);
patch_plot_opt_v2(CQUAD4(:,2:end),FEM.points_coordinates,2000,'spar'); view(2); axis image; grid minor; box on;view(0,0);
subplot(2,2,2)
patch_plot_opt_v2(CTRIA3(:,2:end),FEM.points_coordinates,2000,'skin'); view(2); axis image; grid minor; box on;view(90,0);
patch_plot_opt_v2(CQUAD4(:,2:end),FEM.points_coordinates,2000,'spar'); view(2); axis image; grid minor; box on;view(90,0);
subplot(2,2,3)
patch_plot_opt_v2(CTRIA3(:,2:end),FEM.points_coordinates,2000,'skin'); view(2); axis image; grid minor; box on;view(0,90);
patch_plot_opt_v2(CQUAD4(:,2:end),FEM.points_coordinates,2000,'spar'); view(2); axis image; grid minor; box on;view(0,90);
subplot(2,2,4)
patch_plot_opt_v2(CTRIA3(:,2:end),FEM.points_coordinates,2000,'skin'); view(2); axis image; grid minor; box on;view(90,90);
patch_plot_opt_v2(CQUAD4(:,2:end),FEM.points_coordinates,2000,'spar'); view(2); axis image; grid minor; box on;view(90,90);
hold off;

%
figure(2001);
patch_plot_opt_v2(CTRIA3(:,2:end),FEM.points_coordinates,2001,'skin'); view(2); axis image; grid minor; box on;view(0,0);hold on;
patch_plot_opt_v2(CQUAD4(:,2:end),FEM.points_coordinates,2001,'spar'); view(2); axis image; grid minor; box on;view(0,0);

%% Plot undeformed body and mode shapes
% ----------------------------------------------------------------------
% Undeformed body
disp('----------------------------------------------------------------');
flag_mode_num=input(['Select mode number to plot (1-' num2str(Modelimit) ')[Integer Number]: ']);

if flag_mode_num~=0
    
    figure(31);
    %     xcoord=FEM.points_coordinates(:,2);
    %     ycoord=FEM.points_coordinates(:,3);
    %     zcoord=FEM.points_coordinates(:,4);
    %     plot3(xcoord,ycoord,zcoord,'b.');
    
    patch_plot_opt_v2(CTRIA3(:,2:end),FEM.points_coordinates,31,'spar');view(3);hold on;axis image;
    patch_plot_opt_v2(CQUAD4(:,2:end),FEM.points_coordinates,31,'spar');view(3);hold on;axis image;
    
    modeshape_4_plot=ModeShape.modeshape(:,:,flag_mode_num);
    
    scalefactor=input('Input scale factor for mode shape: '); %% Scale mode shape in plot
    
    
    plot_full_modeshape(CTRIA3,FEM.points_coordinates,scalefactor,modeshape_4_plot)
    plot_full_modeshape(CQUAD4,FEM.points_coordinates,scalefactor,modeshape_4_plot)
%     FEM.points_coordinates_updates =  FEM.points_coordinates;
%     FEM.points_coordinates_updates(:,2)=FEM.points_coordinates(:,2)+scalefactor*modeshapeplot(:,2);
%     FEM.points_coordinates_updates(:,3)=FEM.points_coordinates(:,3)+scalefactor*modeshapeplot(:,3);
%     FEM.points_coordinates_updates(:,4)=FEM.points_coordinates(:,4)+scalefactor*modeshapeplot(:,4);
%     
%     patch_plot_opt_v2(CTRIA3(:,2:end),FEM.points_coordinates_updates,31,'skin');
    
    
    %     plot3(FEM.points_coordinates(:,2)+...
    %         scalefactor*modeshapeplot(:,2),FEM.points_coordinates(:,3) ...
    %         +scalefactor*modeshapeplot(:,3) ...
    %         ,FEM.points_coordinates(:,4)+scalefactor*modeshapeplot(:,4),'r.');
    %
    title({['Mode shape of mode ' num2str(flag_mode_num) ', mode shape scale factor=' num2str(scalefactor)],...
        ['Natural Frequency:' sprintf('%03e',ModeShape.natural_frequency(flag_mode_num)) ' Hz'],...
        '(bule - undeformed body; red - mode shape)'},'FontSize',12);
    %
    ylabel('span(inches)','FontSize',12);
    xlabel('length(inches)','FontSize',12)
    zlabel('height(inches)','FontSize',12);
    %
    grid on;
    % legend('undeformed body','mode shape transverse displacements');
    axis image;
    hold off;
    
%     flag_mode_num=input(['Select other mode number to plot (1-' num2str(Modelimit) ') [Integer Number]; Stop (0):']);
    disp('----------------------------------------------------------------');
end

% nodes along the centerline of the fuselage to interpolate the mode shape of the nodes along
% this line
% FEM.Fuselage_TopNodeLabel=[21501:21504 10004 10009 10014 10019 10024 10029 10034 10039 10044 10049 10054 10059 ...
%     21130 10101 10102 10103 10104 21131 10064 10069 10074 10079 10084 10089 10094 21327 21328 21329];


FEM.Fuselage_TopElemLabel =700001:700388;

jj=1;
for num_temp = 1:length(FEM.Fuselage_TopElemLabel)
   
    element_rowID = find(CTRIA3(:,1)==FEM.Fuselage_TopElemLabel(num_temp));

    for ii_temp=1:3
       
       cords = label2cord(CTRIA3(element_rowID,1+ii_temp),FEM.points_coordinates);
       
      
       if abs(cords(3))<eps
           
         FEM.Fuselage_TopNodeLabel(jj) = CTRIA3(element_rowID,ii_temp+1);
         jj=jj+1;
       end
    end
end


unique_nodes = unique( FEM.Fuselage_TopNodeLabel);

FEM.Fuselage_TopNodeLabel = unique_nodes;


for ee=1:size(FEM.Fuselage_TopNodeLabel ,2)
    
    Elem_ID_temp=find(CTRIA3(:,1) == FEM.Fuselage_TopElemLabel(ee));
    
    
   FEM.topskinFuselageCTRIA3(ee,:) = CTRIA3(Elem_ID_temp,:); 
end




[TargetPanel_nodecord_rowID3,TargetPanel_nodecord_rowID4,CTRIA3_Area,CQUAD4_Area]=TargetPanel(FEM);

%%% Save mode shape database
save('mAEWing2_modeinfo.mat');
c = clock;
disp(datestr(datenum(c(1),c(2),c(3),c(4),c(5),c(6))));




%% end of diary
