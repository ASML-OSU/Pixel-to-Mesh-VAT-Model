% Mesh in natural space
% This subroutine is a generalized geometry parametrization of stiffener
% shape in natural space

%% Geometry Coordinates
clear all;

stiffenernodesnumber=31;

Stru.bdfname='naturalspace12by12.bdf';
Stru.pathfile='Z:\Paper\Stiffened Plate\StiffenedPlateCode\InputBDF';
FEM=geometryinfoplate(Stru);

Xcoord=FEM.nodesCord(:,2);
Ycoord=FEM.nodesCord(:,3);
Zcoord=FEM.nodesCord(:,4);

% For natural space, it's -1 at the first x coordinate
[xlength,ylength]=meshgrid(-1:2/((length(find(Xcoord==-1))-1)/2):1,...
    -1:2/((length(find(Xcoord==-1))-1)/2):1);
zlength=xlength.*0+ylength.*0;
figure(100)
mesh(xlength,ylength,zlength);hold on;view(2)
plot(Xcoord,Ycoord,'k.');hold on;
title('Nodes of Stiffened Plate','FontSize',15);axis image;hold on;
% plate node coordinate in physical space
%%
length2width=0.4;
panel_point_1=[0,0];
panel_point_2=[length2width,0.0];
panel_point_3=[0.6,1.8];
panel_point_4=[0.5,1.8];

%
for platenodeNum=1:length(Xcoord)
    
    platenodeX(platenodeNum)=panel_point_1(1)*1/4*(1-Xcoord(platenodeNum))*(1-Ycoord(platenodeNum))+...
        panel_point_2(1)*1/4*(1+Xcoord(platenodeNum))*(1-Ycoord(platenodeNum))+...
        panel_point_3(1)*1/4*(1+Xcoord(platenodeNum))*(1+Ycoord(platenodeNum))+...
        panel_point_4(1)*1/4*(1-Xcoord(platenodeNum))*(1+Ycoord(platenodeNum));
    
    platenodeY(platenodeNum)=panel_point_1(2)*1/4*(1-Xcoord(platenodeNum))*(1-Ycoord(platenodeNum))+...
        panel_point_2(2)*1/4*(1+Xcoord(platenodeNum))*(1-Ycoord(platenodeNum))+...
        panel_point_3(2)*1/4*(1+Xcoord(platenodeNum))*(1+Ycoord(platenodeNum))+...
        panel_point_4(2)*1/4*(1-Xcoord(platenodeNum))*(1+Ycoord(platenodeNum));
    
end

%% Stiffener parameterization
% Pre-definition
% [0,0.25), left side in natural space
% [0.25,0.5), upper side of natural space
% [0.5,0.75), right side in natural space
% [0.75,1.0], bottom side of natural space
% map
% xinput is from 0.0 to 1.0
XINPUT=[ 0.05 0.95;
%     0.1 0.9;
    0.15 0.85;
%     0.1875 0.8125;
    0.2 0.8;
%     0.25 0.75;
    0.3  0.7;
%     0.35 0.65;
    0.4  0.6;
    % RIBS
    0.05 0.7;
%     0.075 0.675;
    0.1 0.65;
%     0.125 0.625;
    0.15 0.6;
%     0.175 0.575;
    0.2 0.55;
%     0.225 0.525;
    ];

xstep=0.25;
% XINPUT=[0.25-xstep 0.75+xstep;
%     0.25+xstep 0.75-xstep];
deltax=0.0;
% XINPUT=[xstep*0.25+deltax 0.75-xstep*0.25+deltax;
%     (1-xstep)*0.25+deltax 0.75-(1-xstep)*0.25+deltax;
%     0.25+xstep*0.25+deltax 1-xstep*0.25+deltax;
%     0.25+(1-xstep)*0.25+deltax 1-(1-xstep)*0.25+deltax;];

% XINPUT=[xstep 1-xstep;
%     0.25-xstep 0.25+xstep;
%     0.5-xstep 0.5+xstep ;
%     0.75-xstep 0.75+xstep];
xdesign=0.3;
DesignStep=xdesign*[0 1 0.0 1 1 1 1 1 1];

figure(100)
for stiffenerNumber=1:size(XINPUT,1)
    xinput(1)=XINPUT(stiffenerNumber,1);
    xinput(2)=XINPUT(stiffenerNumber,2);
    
    for pointID=1:length(xinput)
        %
        leftFlag=xinput(pointID)>=0 && xinput(pointID)<0.25;
        rightFlag=xinput(pointID)>=0.5 && xinput(pointID)<0.75;
        %
        upperFlag=xinput(pointID)>=0.25 && xinput(pointID)<0.5;
        bottomFlag=xinput(pointID)>=0.75 && xinput(pointID)<=1;
        %
        if leftFlag
            xi(pointID)=-1;
            eta(pointID)=-1+8*xinput(pointID);
        elseif rightFlag
            xi(pointID)=1;
            eta(pointID)=-8*(xinput(pointID)-0.5)+1;
        elseif upperFlag
            xi(pointID)=8*(xinput(pointID)-0.25)-1;
            eta(pointID)=1;
        elseif bottomFlag
            xi(pointID)=-8*(xinput(pointID)-1)-1;
            eta(pointID)=-1;
        end
    end
    % middle point natural coordinates
    xi_middle=0.5*sum(xi);
    eta_middle=0.5*sum(eta);
    %\
    xi_eta_vector=[xi(2)-xi(1) eta(2)-eta(1)];
    xi_eta_per=[eta(2)-eta(1) -xi(2)+xi(1)]/norm(xi_eta_vector);
    %
    xi11=xi(1);xi12=xi_middle+xi_eta_per(1)*DesignStep(stiffenerNumber);xi13=xi(2);
    eta11=eta(1);eta12=eta_middle+xi_eta_per(2)*DesignStep(stiffenerNumber);eta13=eta(2);
    %    
    xieta3=[ xi11 eta11;
        xi12 eta12;
        xi13 eta13];
    p_spl=Bspline_web(3,3,xieta3,stiffenernodesnumber);
    p_spl(end+1,:)=xieta3(3,:);
    
    xi1=p_spl(:,1);eta1=p_spl(:,2);
    figure(100);hold on;plot(xi1,eta1,'ro-');
    hold on;plot(xieta3(:,1),xieta3(:,2),'ko');axis([-1,1,-1,1]);box on;
    %     pause
    % stiffener node coordinate in physical space
    for node_num=1:length(xi1)
        
        XXstiffener(stiffenerNumber,node_num)=...
            panel_point_1(1)*1/4*(1-xi1(node_num))*(1-eta1(node_num))+...
            panel_point_2(1)*1/4*(1+xi1(node_num))*(1-eta1(node_num))+...
            panel_point_3(1)*1/4*(1+xi1(node_num))*(1+eta1(node_num))+...
            panel_point_4(1)*1/4*(1-xi1(node_num))*(1+eta1(node_num));
        
        YYstiffener(stiffenerNumber,node_num)=...
            panel_point_1(2)*1/4*(1-xi1(node_num))*(1-eta1(node_num))+...
            panel_point_2(2)*1/4*(1+xi1(node_num))*(1-eta1(node_num))+...
            panel_point_3(2)*1/4*(1+xi1(node_num))*(1+eta1(node_num))+...
            panel_point_4(2)*1/4*(1-xi1(node_num))*(1+eta1(node_num));
        
    end
end
figure(200); plot(platenodeX,platenodeY,'k.');axis image; hold on;
Xcord=[panel_point_1(1) panel_point_2(1) panel_point_3(1) panel_point_4(1)];
Ycord=[panel_point_1(2) panel_point_2(2) panel_point_3(2) panel_point_4(2)];
fill(Xcord,Ycord,'r','LineWidth',3,'FaceColor','none','EdgeColor',[1,0,0]);

% [xlength,ylength]=meshgrid(0:panel_point_2(1)/12:panel_point_2(1),...
%     0:panel_point_3(2)/12:panel_point_3(2));
% zlength=xlength.*0+ylength.*0;
% mesh(xlength,ylength,zlength);hold on;view(2);
figure(100);axis image;axis([-1 1 -1 1]);
figure(1);axis image;axis([-1 1 -1 1]);
for stiffenerNumber=1:size(XINPUT,1)
    figure(200);hold on;
    plot(XXstiffener(stiffenerNumber,:),YYstiffener(stiffenerNumber,:),'k-','LineWidth',2);hold on;
end;
hold off;