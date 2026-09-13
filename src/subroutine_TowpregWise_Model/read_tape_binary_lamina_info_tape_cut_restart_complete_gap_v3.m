%% loop layer number
% layer_no = 1;
laminate_layers = size(T0T1,1);

lamina_info = sparse(FEM.numberElements,laminate_layers); % lamina information about the gap/overlap
fiber_angle = sparse(FEM.numberElements,laminate_layers); % lamina information about the gap/overlap


% lamina_info2 = cell(FEM.elementNumber,1);
% fiber_angle2 =  cell(FEM.elementNumber,1);


lamina_info2 = cell(1,FEM.elementNumber);
fiber_angle2 = cell(1,FEM.elementNumber);

%Element_Laminate_Info: angle, thickness.

for layer_no = 1:laminate_layers

    % how many generated tows

    T0 = T0T1(layer_no,1)/180*pi;

    T1 = T0T1(layer_no,2)/180*pi; % for straight fibers, put very small pertubation to the T0

    if abs(T0-T1)<=deg2rad(0.2)

     
        for ijk = 1:FEM.elementNumber

            angle_data = fiber_angle2{ijk};

            angle_data = [angle_data,{num2str(rad2deg((T0+T1)/2))}];

            fiber_angle2{ijk} = angle_data;

            lamina_data = lamina_info2{ijk};

            lamina_data = [lamina_data,{'1'}];

            lamina_info2{ijk} = lamina_data;

        end

        %%

    else

        lamina_layer_folder = ['lamina_layer_' num2str(layer_no)];

        items = dir( lamina_layer_folder );

        % Filter only subfolders (exclude '.' and '..')
        subfolders = items([items.isdir]);  % Only directories
        subfolders = subfolders(~ismember({subfolders.name}, {'.', '..'}));

        % Count number of subfolders
        number_of_courses = numel(subfolders);

        for course_no = 1:number_of_courses

            % create folder for tows
            lamina_layer_tows_no_folder = ['lamina_layer_' num2str(layer_no) filesep 'tows_' num2str(course_no)];

            imgFiles = dir([lamina_layer_tows_no_folder filesep '*.png']);

            real_tow_number = length(imgFiles); % how many tow for each course.

            % layer_no = lamina_layer;

            %% image processing

            for real_tow_num = 1:real_tow_number % for test


                % 5. Read the image
                img = imread( [lamina_layer_tows_no_folder filesep 'single_tape_' num2str(real_tow_num) '.png']);

                % 6. Convert to grayscale
                gray = im2gray(img);

                % 7. Binarize: 1 = black/tape, 0 = white/background
                BW = imbinarize(gray, 0.99);   % You may tune threshold as needed
                % BW = ~BW;  % Flip so that black = 1, white = 0

                tapelocation = ~BW;

                % 5. Show the result
                % imshow(BW);

                % === Step 4: Resize to fixed resolution ===
                % 300 rows and 400 columns, corresponding to the size of elements.

                BW_fixed = imresize(BW, [mesh_number_y,mesh_number_x], 'nearest');  % Preserves binary edges

                tapelocation2 = ~BW_fixed;

                % 5. Show the result
                % figure(102);imshow(BW_fixed);

                %% sparse
                % 6. Save in sparse matrix
                material_location_on_image  = sparse(tapelocation2);

                % material_location_on_FEM = material_location_on_image;


                % convert to element information.

                % figure;
                % spy(material_location_on_image)

                [rowIdx, colIdx, val] = find(material_location_on_image);

                for num = 1:length(val)


                    rowIdx_on_FEM = size(material_location_on_image,1) - rowIdx(num) + 1;

                    element_id = (rowIdx_on_FEM-1)*mesh_number_x + colIdx(num);


                    % lamina_info(element_id,layer_no) = lamina_info(element_id,layer_no) + val(num);


                    % lamina_info2{element_id,size( lamina_info2{element_id},1)+1} =  val(num);


                    lamina_data = lamina_info2{element_id};

                    lamina_data = [lamina_data,{num2str(val(num))}];

                    lamina_info2{element_id} = lamina_data;

                    %%

                    nodeID = FEM.elementNodes(element_id,:);
                    centerofelement_X = sum(FEM.nodesCord(nodeID,2))/4;
                    centerofelement_Y = sum(FEM.nodesCord(nodeID,3))/4;

                    elementcenterpt = [centerofelement_X ,centerofelement_Y];

                    % load the centerline of this tape

                    centerline_txt = [lamina_layer_tows_no_folder filesep 'centerline_' num2str(real_tow_num) '.txt'];

                    centerline= load(centerline_txt);


                    % because this curve is obained by shifting line along
                    % x-axis

                    [closest_point, min_distance] = findClosestPoint(centerline,elementcenterpt);

                    diff_Y = abs(centerofelement_Y - centerline(:,2));

                    [mindistance,idy] = min(diff_Y);

                    closest_point = centerline(idy,:);

                    % figure(2);hold on;plot(closest_point(1),closest_point(2),'bo');


                    if (elementcenterpt(1)-Plate.length/2) >=0

                        x_deriv = [closest_point(1) closest_point(1)+1e-3];

                        y_deriv = interp1(centerline(:,1),centerline(:,2),x_deriv);

                        if max(isnan(y_deriv))


                            x_deriv = [closest_point(1)-1e-3 closest_point(1)];
                            y_deriv = interp1(centerline(:,1),centerline(:,2),x_deriv);

                        end

                        tanvalue = (y_deriv(2)-y_deriv(1))/(1e-3) ;

                    else %% right hand side


                        x_deriv = [closest_point(1)-1e-3 closest_point(1)];

                        y_deriv = interp1(centerline(:,1),centerline(:,2),x_deriv);


                        if max(isnan(y_deriv))


                            x_deriv = [closest_point(1) closest_point(1)+1e-3];
                            y_deriv = interp1(centerline(:,1),centerline(:,2),x_deriv);

                        end


                        tanvalue = (y_deriv(2)-y_deriv(1))/(1e-3) ;
                    end


                    if isnan(tanvalue)

                        tanvalue

                        [element_id layer_no]

                        % break
                    end

                    fiber_angle(element_id,layer_no) = atand(tanvalue);

                    angle_temp = atand(tanvalue);


                    angle_data = fiber_angle2{element_id};

                    angle_data = [angle_data,{num2str(angle_temp)}];

                    fiber_angle2{element_id} = angle_data;


                    % fiber_angle2{element_id,size(   fiber_angle2{element_id},1)+1} =  atand(tanvalue);

                end

            end % end of real tape

        end % end of tows

    end % end of straight or curved layers

end % end of layer