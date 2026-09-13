function [edges_pnt1,edges_pnt2,tape_centerlines] = generate_reference_lines_4_tows(x_tows_centerline,...
    y_tows_centerline,number_of_tapes,tape_width0,T1,T0,Stru)
%
%
if ~iseven(number_of_tapes)

    number_of_tapes = number_of_tapes + 1;

    warning('number of tows is not an even number')

end

edges_pnt1=  [];
edges_pnt2 = [];
% figure(101);

tape_centerlines =[];
numtemp = 1;


for k = 1:number_of_tapes/2


    center =[Stru.length Stru.width]/2;

    middle_line =  [x_tows_centerline' y_tows_centerline'];

    physical_length = Stru.length; % change along width direction

    tape_width = tape_width0/2 + (k-1)*tape_width0;



    for pnt_num = 1:size(middle_line,1)

        x = middle_line (pnt_num,1);+Stru.length/2;

        yref = middle_line (pnt_num,2);+Stru.width/2;

        %         T0 = 30;
        %         T1 = 60;
        %
        %
        %   center = VAT.center;
        %     physical_length = VAT.physical_length;

        % theta = VAT_fiber_ply_angle_1D(T0,T1,x,center(1),physical_length);

        theta = (T1-T0)*2/Stru.length*abs(x-Stru.length/2) + T0;

        theta = rad2deg(theta);

        % node 1
        theta1 = theta+90;% couter-clockwisely
        normal_vector1 = [cosd(theta1) sind(theta1)];
        normal_vector1 = normal_vector1/norm(normal_vector1);

        %             figure(34);hold on; quiver(x,y,normal_vector1(1),normal_vector1(2),...
        %                 'ShowArrowHead','off','AutoScaleFactor',15,'LineWidth',1);hold on;


        adjacenet_pnt1 = [x yref] + normal_vector1*tape_width;

        edges_pnt1(pnt_num,:,k) = [pnt_num+10000   adjacenet_pnt1];

        % figure(101);hold on;plot(adjacenet_pnt1(:,1),adjacenet_pnt1(:,2),'r-')

        % node 2
        theta2 = theta-90;% clockwisely
        normal_vector2 = [cosd(theta2) sind(theta2)];
        normal_vector2 = normal_vector2/norm(normal_vector2);

        adjacenet_pnt2 = [x yref] + normal_vector2*tape_width;


        edges_pnt2(pnt_num,:,k) = [pnt_num+20000   adjacenet_pnt2];



    end

    tape_centerlines(:,:,numtemp) = edges_pnt1(:,:,k);
    numtemp = numtemp+1;

    tape_centerlines(:,:,numtemp) = edges_pnt2(:,:,k);
    numtemp = numtemp+1;


end



