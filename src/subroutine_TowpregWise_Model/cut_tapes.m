
%%
%%
vec0 = previous_edge;   line0 = vec0(:,2:3);
vec1 = tape_edge_check; line1 = vec1(:,2:3);
vec2 = tape_edge_another; line2 = vec2(:,2:3);


if 0
    figure(5);hold on;
    plot(vec0(:,2),vec0(:,3),'b-')
    hold on;
    plot(vec1(:,2),vec1(:,3),'b-')
    hold on;
    plot(vec2(:,2),vec2(:,3),'r-')
end
%% Find intersection points

intersectionPoints = findPolylineIntersections(line1, line0);

if isempty(intersectionPoints) ==0

    if 0
        figure(5);hold on;plot(intersectionPoints(:,1),intersectionPoints(:,2),'o');
    end
    line1New = line1;
    % After computing intersectionPoints using findPolylineIntersections:
    closedid_line1 = zeros(length(intersectionPoints),1);

    closedid_line0 = zeros(length(intersectionPoints),1);

    cut_points_in_another_edge =[];

    for k = 1:size(intersectionPoints, 1)

        intPt = intersectionPoints(k, :);

        % Compute distances from all points in line1
        distances = sqrt(sum((line1 - intPt).^2, 2));

        [minDist, minIdx] = min(distances);

        closedid_line1(k) = minIdx;

        line1New(minIdx,:) = intersectionPoints(k,:);

        %%
        % Compute distances from all points in line1
        distances = sqrt(sum((line0 - intPt).^2, 2));

        % Find the closest point and its index
        [minDist, minIdx] = min(distances);

        closedid_line0(k) = minIdx;


        %% update the other edge nodes due to the perpendicular cut

        angle_deg = tangentAngleAtPoint(line1, intersectionPoints(k));

        x_intersection = intersectionPoints(k,1);
        y_intersection = intersectionPoints(k,2);


        % node 1
        angle_deg = angle_deg+90;% couter-clockwisely
        normal_vector = [cosd(angle_deg) sind(angle_deg)];
        normal_vector = normal_vector/norm(normal_vector);

        cut_points_in_another_edge(k,:) = [x_intersection y_intersection] + normal_vector*wt0;

    end

    %hold on; plot( line1New(:,1), line1New(:,2),'ro','LineWidth',3)





    %% 1 intersection point?

    if size(intersectionPoints,1) == 1



    end
    %% two intersection points?

    if size(intersectionPoints,1) == 2

        middlepointID = round(sum(closedid_line1)/2);
        x1 = line1(middlepointID,1);y1 = line1(middlepointID,2);
        y0 = interp1(line0(:,1),line0(:,2),x1);
        

        if y0>=y1 % inner overlap

            Remained_nodesID = [1:closedid_line1(1) closedid_line1(2):size(line1,1)];

            Removed_nodes_indices = closedid_line1(1):closedid_line1(2);

        else % outerovelap

            Remained_nodesID = closedid_line1(1):closedid_line1(2);

            Removed_nodes_indices = [1:closedid_line1(1) closedid_line1(2):size(line1,1)];

        end

        removed_nodes = vec1(Removed_nodes_indices,1);
        % if each element has two grid on this edge, this element is in overlapped
        newElements = [];

        for ii = 1:size(tape_elements,1)

            nodeid = tape_elements(ii,:);

            commonnodes = intersect(nodeid,removed_nodes');

            if length(commonnodes)<=1

                newElements =[newElements;
                    tape_elements(ii,:)];
            end
        end
        %
        %



        %%

        edges_pnt1_new = edges_pnt1;

        edges_pnt1_new(closedid_line1,2:3) =  cut_points_in_another_edge;

        %
        edges_pnt2_new = edges_pnt2;

        edges_pnt2_new(closedid_line1,2:3) = intersectionPoints;

        edges_points_all = [
            edges_pnt1_new
            edges_pnt2_new];

        % check
        
        if iseven(tows_no)
            patch_plot(newElements,edges_points_all ,203,'tape');axis image;
        else
            patch_plot(newElements,edges_points_all ,203,'tape3');axis image;
        end


        if edge_plot_option %% plot edges

            if y0>=y1 % inner overlap

                Remained_nodesID = [1:closedid_line1(1) closedid_line1(2):size(line1,1)];

                Removed_nodes_indices = closedid_line1(1):closedid_line1(2);

                hold on;
                plot(edges_pnt1_new(1:closedid_line1(1),2),edges_pnt1_new(1:closedid_line1(1),3),'k-')
                hold on;
                plot(edges_pnt1_new(closedid_line1(2):size(line1,1),2),edges_pnt1_new(closedid_line1(2):size(line1,1),3),'k-')
                hold on;
                plot(edges_pnt2_new(1:closedid_line1(1),2),edges_pnt2_new(1:closedid_line1(1),3),'k-')
                hold on;
                plot(edges_pnt2_new(closedid_line1(2):size(line1,1),2),edges_pnt2_new(closedid_line1(2):size(line1,1),3),'k-')



            else % outerovelap

                Remained_nodesID = closedid_line1(1):closedid_line1(2);

                Removed_nodes_indices = [1:closedid_line1(1) closedid_line1(2):size(line1,1)];


                hold on;
                plot(edges_pnt1_new(Remained_nodesID,2),edges_pnt1_new(Remained_nodesID,3),'k-')
                hold on;
                plot(edges_pnt2_new(Remained_nodesID,2),edges_pnt2_new(Remained_nodesID,3),'k-')



            end
        end


    end




else

    % complete overlap of the start edge and previous edge
    intersectionPoints2 = findPolylineIntersections(line2, line0);


    if isempty(intersectionPoints2) ==0

        tape_elements =[]; % the start edge is completely emerged to the adjacenet deposited tows

    else


        if iseven(tows_no)
            patch_plot( tape_elements,edges_points_all ,203,'tape');axis image;
        else
            patch_plot( tape_elements,edges_points_all ,203,'tape3');axis image;
        end

      

        if edge_plot_option
            hold on;
            plot(edges_pnt1(:,2),edges_pnt1(:,3),'k-')
            hold on;
            plot(edges_pnt2(:,2),edges_pnt2(:,3),'k-')
        end

    end
end




%% check middle points removed or others
% % % for this case we use y coordinate to determine this
% %
% %
% % angle_deg = tangentAngleAtPoint(line1, intersectionPoints(1,:))
% %
% % angle_deg = tangentAngleAtPoint(line0, intersectionPoints(1,:))

%% use trajectory path location, and finite element middle point to determine which


%% elements are the current deposition material.

