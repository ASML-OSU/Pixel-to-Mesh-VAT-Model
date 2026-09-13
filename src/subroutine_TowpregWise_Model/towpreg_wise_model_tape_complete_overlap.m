%%
%% ==============================================================
%% Before start using image processing based towpreg wise modeling, you need
%% to make sure the image pixel and the finite element model element are corr-
%% esponding to each other. Otherwise the stiffness and mass matrices are wrong!
%%

% clear all;
% close all
% %
% %% ==== add subroutines ======
% addpath(genpath([pwd filesep 'subroutines']));
% addpath(genpath([pwd filesep 'subroutine_Nastran']));
%
% Plate.length=.5;
%
% Plate.width= .5;


% shiftfactor = 1.00; % d = shiftactor*w

wt0 = 3.175/1000*2;%1/4" for this case

number_of_tapes = 8; 

course_width = number_of_tapes*wt0;

% shiftdistance = tape_width0*shiftfactor;

% T0T1 =[66. 37.7
%     -56.2 -30.2
%     -36.5 -13.4
%     -36.5 -13.4
%     -36.5 -13.4
%     -36.5 -13.4
%     -56.2 -30.2
%     66. 37.7];

laminate_layers = size(T0T1,1);

% layer folder
%  - tow folder
% figure(203) % initialize it.
%% =============== INPUT VALUES =================

for lamina_layer = 1:laminate_layers

    lamina_layer_folder = ['lamina_layer_' num2str(lamina_layer)];

    if exist(lamina_layer_folder, 'dir')

        rmdir(lamina_layer_folder, 's');  % 's' = recursive delete

    end
    mkdir(lamina_layer_folder)

    close all;
    % T0 = 30./180*pi;
    % T1 = 10.00/180*pi; % for straight fibers, put very small pertubation to the T0

    T0 = T0T1(lamina_layer,1)/180*pi;
    T1 = T0T1(lamina_layer,2)/180*pi; % for straight fibers, put very small pertubation to the T0

    % if T0 == T1


    if abs(T0-T1)<=deg2rad(0.2)
        % T1 = T1 - 0.001;
        % return

        lamina_info(:,lamina_layer) = 1;

    else

        %% shift distance

        theta_ref = linspace(T0,T1,1000);
        cstheta = cos(theta_ref);

        shiftfactor = min(1./cstheta);
        % shiftfactor = max(1./cstheta);

        % shiftdistance = tape_width0*FACTOR(lamina_layer);

        shiftdistance = course_width*shiftfactor;

        %%

        XX_centerline = [];
        YY_centerline = [];

        extra_factor = 0.4;

        %% ================= generate a large plate region ===============
        xleft = (Plate.length/2 - Plate.length) - extra_factor*Plate.length/2;

        xright = -xleft;

        ymax = Plate.width/2*(1+extra_factor);


        x_VALUE = linspace(xleft,xright,101);

        %% =============== Reference line curve ===================
        yref = zeros(length(x_VALUE),1);

        a = Plate.length;

        zcheck = 0.; % for all laminas check.

        for ii = 1:length(x_VALUE)

            x = x_VALUE(ii);

            if x>=0

                c0 = cos(T0);
                c2 = cos(  T0 + 2*(T1-T0)*x/a  );

                yref(ii) = a/(2*(T1-T0))*(log(c0) - log(c2));

            else % x<0

                c1 = cos(T0);

                c2 = cos(  T0 + 2*(T0-T1)*x/a  );

                yref(ii) = a/(2*(T0-T1))*(log(c1) - log(c2) );
            end

        end

        stiffenerelements_num = 100;

        figure(1);hold on;plot(x_VALUE,yref,'r-')

        axis([min(x_VALUE),max(x_VALUE),min(yref),max(yref)])


        %% ================== Shift reference line =================

        tows_num = 1;
        XX_centerline(tows_num,:) = x_VALUE;
        YY_centerline(tows_num,:) = yref;
        tows_number = round(Plate.width/(course_width))-1+4;

        % move upwards
        yy = yref;

        for ijk = 1:tows_number

            yy = yy + shiftdistance;

            hold on;
            plot(x_VALUE,yy,'r-')

            tows_num = tows_num+1;
            XX_centerline(tows_num,:) = x_VALUE;
            YY_centerline(tows_num,:) = yy;

        end

        % move downwards
        yy = yref;

        for ijk = 1:tows_number


            yy = yy - shiftdistance;

            hold on;
            plot(x_VALUE,yy,'r-')
            tows_num = tows_num+1;
            XX_centerline(tows_num,:) = x_VALUE;
            YY_centerline(tows_num,:) = yy;
        end

        hold on;
        axis equal;
        grid on;

        % Draw rectangle
        rectangle('Position', [ -Plate.length/2, -Plate.width/2, Plate.length, Plate.width], ...
            'EdgeColor', 'k', ...   % black border
            'FaceColor', 'none');      % black filled

        %%


        %% Tows for reference line
        tows_no = 1;  %% middle reference line


        % create folder for tows
        lamina_layer_tows_no_folder = ['lamina_layer_' num2str(lamina_layer) filesep 'tows_' num2str(tows_no)];

        if exist(lamina_layer_tows_no_folder, 'dir')

            rmdir(lamina_layer_tows_no_folder, 's');  % 's' = recursive delete

        end
        mkdir(lamina_layer_tows_no_folder)




        tow_edges_1 =[];

        tow_edges_2 =[];

        % x_tows_centerline = x_VALUE + Plate.length/2;
        % y_tows_centerline = yref'   + Plate.length/2;

        x_tows_centerline = XX_centerline(tows_no,:)' + Plate.length/2;
        y_tows_centerline = YY_centerline(tows_no,:)' + Plate.width/2;

        % number_of_tapes = 32;
        %
        % wt0 = 3.175e-3;

        [edges_1,edges_2,tapecenterlines] = generate_reference_lines_4_tows(x_tows_centerline',...
            y_tows_centerline',number_of_tapes,wt0,T1,T0,Plate);

        Tows_center_lines = zeros(size(tapecenterlines,1),size(tapecenterlines,2),size(tapecenterlines,3));

        Tows_center_lines(:,:,1:size(edges_2,3)) = edges_2(:,:,size(edges_2,3):-1:1);
        Tows_center_lines(:,:,1+size(edges_2,3):size(tapecenterlines,3)) = edges_1;

        tapecenterlines = Tows_center_lines;
        if 1
            figure;
            plot(x_tows_centerline,y_tows_centerline,'k--');


            for ii = 1:size(tapecenterlines,3)

                hold on;
                plot(tapecenterlines(:,2,ii),tapecenterlines(:,3,ii),'r-')

            end
        end


        for kk = 1:size(tapecenterlines,3)

            clf % close the image with single slit tape due to a new one will be created

            real_tape_num = kk;
            xx = tapecenterlines(:,2,kk);
            yy = tapecenterlines(:,3,kk);

            middle_line =  [xx yy];

            physical_length = Plate.length; % change along width direction

            tape_width = wt0/2;

            edges_pnt1=  [];
            edges_pnt2 = [];

            for pnt_num = 1:size(middle_line,1)

                x = middle_line (pnt_num,1);
                yref = middle_line (pnt_num,2);

                %         T0 = 30;
                %         T1 = 60;
                %
                %
                %   center = VAT.center;
                %     physical_length = VAT.physical_length;

                % theta = VAT_fiber_ply_angle_1D(T0,T1,x,center(1),physical_length);

                theta = (T1-T0)*2/a*abs(x-Plate.length/2) + T0;

                theta = rad2deg(theta);

                % node 1
                theta1 = theta+90;% couter-clockwisely
                normal_vector1 = [cosd(theta1) sind(theta1)];
                normal_vector1 = normal_vector1/norm(normal_vector1);

                %             figure(34);hold on; quiver(x,y,normal_vector1(1),normal_vector1(2),...
                %                 'ShowArrowHead','off','AutoScaleFactor',15,'LineWidth',1);hold on;


                adjacenet_pnt1 = [x yref] + normal_vector1*tape_width;


                edges_pnt1(pnt_num,:) = [pnt_num+10000   adjacenet_pnt1 zcheck];

                % node 2
                theta2 = theta-90;% clockwisely

                normal_vector2 = [cosd(theta2) sind(theta2)];

                normal_vector2 = normal_vector2/norm(normal_vector2);

                adjacenet_pnt2 = [x yref] + normal_vector2*tape_width;

                edges_pnt2(pnt_num,:) = [pnt_num+20000   adjacenet_pnt2 zcheck];

            end


            tape_elements = zeros(size(middle_line,1)-1,4);

            edges_points_all = [ edges_pnt1
                edges_pnt2];

            % edges_points_line1 =

            for elem_num = 1:size(tape_elements,1)

                tape_elements(elem_num,:) = [10000+elem_num 10000+elem_num+1 ...
                    20000+elem_num+1 20000+elem_num  ];

            end

            % if iseven(tows_no)
            patch_plot( tape_elements,edges_points_all ,203,'tape');axis image;
            % else

            % patch_plot( tape_elements,edges_points_all ,5,'tape3');axis image;
            % end
            %
            % hold on;
            % plot(edges_pnt1(:,2),edges_pnt1(:,3),'k-')
            % hold on;
            % plot(edges_pnt2(:,2),edges_pnt2(:,3),'k-')

            if kk == 1 % store the tows start and end edges

                start_edgesREF = edges_pnt2;


            elseif kk==size(tapecenterlines,3)

                end_edgesREF = edges_pnt1;

            end

            tape_edge_check   = edges_pnt2;
            tape_edge_another = edges_pnt1;


            %% create image and save the centerline of each prepreg slit tape

            create_image_save_center

        end

        %
        if 0
            hold on;plot(start_edgesREF(:,2),start_edgesREF(:,3),'b-','LineWidth',2)
            %
            hold on;plot(end_edgesREF(:,2),end_edgesREF(:,3),'r-','LineWidth',2)
            %
        end

        tow_edges_1 = start_edgesREF; %

        tow_edges_2 = end_edgesREF;

        previous_edge = end_edgesREF;

        %%
        %%
        %% Tow for tapes moving downwards
        %%
        %%

        for tows_no = 2:tows_number+1


            %%
            lamina_layer_tows_no_folder = ['lamina_layer_' num2str(lamina_layer) filesep 'tows_' num2str(tows_no)];

            if exist(lamina_layer_tows_no_folder, 'dir')

                rmdir(lamina_layer_tows_no_folder, 's');  % 's' = recursive delete

            end
            mkdir(lamina_layer_tows_no_folder)

            %%
            %% generate tows middle lines
            % x_tows_centerline = x_VALUE + Plate.length/2;
            % y_tows_centerline = yref'   + Plate.length/2;

            x_tows_centerline = XX_centerline(tows_no,:)' + Plate.length/2;
            y_tows_centerline = YY_centerline(tows_no,:)' + Plate.width/2;


            % number_of_tapes = 32;
            %
            % wt0 = 3.175e-3;

            [edges_1,edges_2,tapecenterlines] = generate_reference_lines_4_tows(x_tows_centerline',...
                y_tows_centerline',number_of_tapes,wt0,T1,T0,Plate);

            Tows_center_lines = zeros(size(tapecenterlines,1),size(tapecenterlines,2),size(tapecenterlines,3));

            Tows_center_lines(:,:,1:size(edges_2,3)) = edges_2(:,:,size(edges_2,3):-1:1);
            Tows_center_lines(:,:,1+size(edges_2,3):size(tapecenterlines,3)) = edges_1;

            tapecenterlines = Tows_center_lines;

            if 0
                figure;
                plot(x_tows_centerline,y_tows_centerline,'k-');


                for ii = 1:size(tapecenterlines,3)

                    hold on;
                    plot(tapecenterlines(:,2,ii),tapecenterlines(:,3,ii),'r-')

                end
            end

            %% reconPlatect tapes

            for kk = 1:size(tapecenterlines,3)

                clf

                real_tape_num = kk;

                xx = tapecenterlines(:,2,kk);
                yy = tapecenterlines(:,3,kk);

                middle_line =  [xx yy];

                physical_length = Plate.length; % change along width direction

                tape_width = wt0/2;

                edges_pnt1=  [];
                edges_pnt2 = [];

                for pnt_num = 1:size(middle_line,1)

                    x = middle_line (pnt_num,1);
                    yref = middle_line (pnt_num,2);

                    %         T0 = 30;
                    %         T1 = 60;
                    %
                    %
                    %   center = VAT.center;
                    %     physical_length = VAT.physical_length;

                    % theta = VAT_fiber_ply_angle_1D(T0,T1,x,center(1),physical_length);

                    theta = (T1-T0)*2/a*abs(x-Plate.length/2) + T0;

                    theta = rad2deg(theta);

                    % node 1
                    theta1 = theta+90;% couter-clockwisely
                    normal_vector1 = [cosd(theta1) sind(theta1)];
                    normal_vector1 = normal_vector1/norm(normal_vector1);

                    %             figure(34);hold on; quiver(x,y,normal_vector1(1),normal_vector1(2),...
                    %                 'ShowArrowHead','off','AutoScaleFactor',15,'LineWidth',1);hold on;


                    adjacenet_pnt1 = [x yref] + normal_vector1*tape_width;


                    edges_pnt1(pnt_num,:) = [pnt_num+10000   adjacenet_pnt1 zcheck];

                    % node 2
                    theta2 = theta-90;% clockwisely

                    normal_vector2 = [cosd(theta2) sind(theta2)];

                    normal_vector2 = normal_vector2/norm(normal_vector2);

                    adjacenet_pnt2 = [x yref] + normal_vector2*tape_width;

                    edges_pnt2(pnt_num,:) = [pnt_num+20000   adjacenet_pnt2 zcheck];

                end


                tape_elements = zeros(size(middle_line,1)-1,4);

                edges_points_all = [ edges_pnt1
                    edges_pnt2];

                % edges_points_line1 =

                for elem_num = 1:size(tape_elements,1)

                    tape_elements(elem_num,:) = [10000+elem_num 10000+elem_num+1 ...
                        20000+elem_num+1 20000+elem_num  ];

                end

                % if iseven(tows_no)
                    patch_plot( tape_elements,edges_points_all ,203,'tape');axis image;
                % else
                % 
                %     patch_plot( tape_elements,edges_points_all ,5,'tape3');axis image;
                % end
                % %
                % hold on;plot(edges_pnt1(:,2),edges_pnt1(:,3),'k-')
                % hold on;plot(edges_pnt2(:,2),edges_pnt2(:,3),'k-')

                % if kk == 1 % store the tows start and end edges
                % 
                %     start_edges = edges_pnt2;
                % 
                % elseif kk==size(tapecenterlines,3)
                % 
                %     end_edges = edges_pnt1;
                % 
                % end
                % 
                % tape_edge_check   = edges_pnt2;
                % tape_edge_another = edges_pnt1;
                % 
                % %
                % cut_tapes %%


                %% create image and save the centerline of each prepreg slit tape

                create_image_save_center

            end

            % hold on;plot(start_edges(:,2),start_edges(:,3),'b-','LineWidth',2)
            % hold on;plot(end_edges(:,2),end_edges(:,3),'b-','LineWidth',2)



            %% update the edge nodes for next overlap check

            % tow_edges_1 = start_edges; %
            % 
            % tow_edges_2 = end_edges;
            % 
            % previous_edge = end_edges;
            % 
            % if 0
            %     figure(5);hold on;
            % 
            %     plot(tow_edges_2(:,2),tow_edges_2(:,3),'r-')
            % end
            % previous_edge = tow_edges_2;

            % figure(5);hold on;plot(tow_edges_2(:,2),tow_edges_2(:,3),'r-')
        end




        %%
        %%
        %% Move downwards


        previous_edge = start_edgesREF;

        for tows_no = 2+tows_number:tows_number*2+1



            %%
            lamina_layer_tows_no_folder = ['lamina_layer_' num2str(lamina_layer) filesep 'tows_' num2str(tows_no)];

            if exist(lamina_layer_tows_no_folder, 'dir')

                rmdir(lamina_layer_tows_no_folder, 's');  % 's' = recursive delete

            end
            mkdir(lamina_layer_tows_no_folder)


            %%
            %%
            %% generate tows middle lines
            % x_tows_centerline = x_VALUE + Plate.length/2;
            % y_tows_centerline = yref'   + Plate.length/2;

            x_tows_centerline = XX_centerline(tows_no,:)' + Plate.length/2;
            y_tows_centerline = YY_centerline(tows_no,:)' + Plate.width/2;


            % number_of_tapes = 32;
            %
            % wt0 = 3.175e-3;

            [edges_1,edges_2,tapecenterlines] = generate_reference_lines_4_tows(x_tows_centerline',...
                y_tows_centerline',number_of_tapes,wt0,T1,T0,Plate);

            Tows_center_lines = zeros(size(tapecenterlines,1),size(tapecenterlines,2),size(tapecenterlines,3));

            Tows_center_lines(:,:,1:size(edges_2,3)) = edges_2(:,:,size(edges_2,3):-1:1);
            Tows_center_lines(:,:,1+size(edges_2,3):size(tapecenterlines,3)) = edges_1;

            tapecenterlines = Tows_center_lines;

            if 0
                figure(5); hold on;
                plot(x_tows_centerline,y_tows_centerline,'k-');


                for ii = 1:size(tapecenterlines,3)

                    hold on;
                    plot(tapecenterlines(:,2,ii),tapecenterlines(:,3,ii),'r-')

                end
            end


            %%

            tapecenterlines0 = tapecenterlines;
            tapecenterlines = tapecenterlines0(:,:,size(tapecenterlines0,3):-1:1);
            %% reconPlatect tapes

            for kk = 1:size(tapecenterlines,3)

                clf

                real_tape_num = kk;

                xx = tapecenterlines(:,2,kk);
                yy = tapecenterlines(:,3,kk);


                middle_line =  [xx yy]; % 8 tows, each tow has 32 slit tapes.


                physical_length = Plate.length; % change along width direction

                tape_width = wt0/2;

                edges_pnt1=  [];
                edges_pnt2 = [];

                for pnt_num = 1:size(middle_line,1)

                    x = middle_line (pnt_num,1);
                    yref = middle_line (pnt_num,2);

                    %         T0 = 30;
                    %         T1 = 60;
                    %
                    %
                    %   center = VAT.center;
                    %     physical_length = VAT.physical_length;

                    % theta = VAT_fiber_ply_angle_1D(T0,T1,x,center(1),physical_length);

                    theta = (T1-T0)*2/a*abs(x-Plate.length/2) + T0;

                    theta = rad2deg(theta);

                    % node 1
                    theta1 = theta+90;% couter-clockwisely
                    normal_vector1 = [cosd(theta1) sind(theta1)];
                    normal_vector1 = normal_vector1/norm(normal_vector1);

                    %             figure(34);hold on; quiver(x,y,normal_vector1(1),normal_vector1(2),...
                    %                 'ShowArrowHead','off','AutoScaleFactor',15,'LineWidth',1);hold on;


                    adjacenet_pnt1 = [x yref] + normal_vector1*tape_width;


                    edges_pnt1(pnt_num,:) = [pnt_num+10000   adjacenet_pnt1 zcheck];

                    % node 2
                    theta2 = theta-90;% clockwisely

                    normal_vector2 = [cosd(theta2) sind(theta2)];

                    normal_vector2 = normal_vector2/norm(normal_vector2);

                    adjacenet_pnt2 = [x yref] + normal_vector2*tape_width;

                    edges_pnt2(pnt_num,:) = [pnt_num+20000   adjacenet_pnt2 zcheck];

                end


                tape_elements = zeros(size(middle_line,1)-1,4);

                edges_points_all = [ edges_pnt1
                    edges_pnt2];

                % edges_points_line1 =

                for elem_num = 1:size(tape_elements,1)

                    tape_elements(elem_num,:) = [10000+elem_num 10000+elem_num+1 ...
                        20000+elem_num+1 20000+elem_num  ];

                end

                % if iseven(tows_no)
                    patch_plot( tape_elements,edges_points_all ,203,'tape');axis image;
                % else
                % 
                %     patch_plot( tape_elements,edges_points_all ,5,'tape3');axis image;
                % end
                % %
                % hold on;plot(edges_pnt1(:,2),edges_pnt1(:,3),'r-')
                % hold on;plot(edges_pnt2(:,2),edges_pnt2(:,3),'k-')

                % if kk == 1 % store the tows start and end edges
                % 
                %     start_edges = edges_pnt1;
                % 
                % elseif kk==size(tapecenterlines,3)
                % 
                %     end_edges = edges_pnt2;
                % 
                % end
                % 
                % tape_edge_check   = edges_pnt1;
                % tape_edge_another = edges_pnt2;
                % 
                % %
                % cut_tapes_downwards

                %% create image and save the centerline of each prepreg slit tape

                create_image_save_center



            end

            % hold on;plot(start_edges(:,2),start_edges(:,3),'b-','LineWidth',2)
            % hold on;plot(end_edges(:,2),end_edges(:,3),'b-','LineWidth',2)



            %% update the edge nodes for next overlap check

            % tow_edges_1 = start_edges; %
            % 
            % tow_edges_2 = end_edges;
            % 
            % previous_edge = end_edges;
            % 
            % if 0
            %     figure(5);hold on;
            % 
            %     plot(tow_edges_2(:,2),tow_edges_2(:,3),'r-')
            % end
            % previous_edge = tow_edges_2;

            % figure(5);hold on;plot(tow_edges_2(:,2),tow_edges_2(:,3),'r-')
        end



        %%


    end %% check straight or curved

end % end of lamina layer

%%