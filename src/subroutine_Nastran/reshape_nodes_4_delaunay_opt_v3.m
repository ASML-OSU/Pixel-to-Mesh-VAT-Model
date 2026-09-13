function cord_2d_reshaped = reshape_nodes_4_delaunay_opt_v3(cord_2d)

% For spar/rib with curved surface, reshape edge nodes to be straight line

% step 1 - reshape the curved line to straight line for a rectangle 

% works only for spar/ribs with 4-edge polygon - reshape the surface.

xy_cord_temp = cord_2d(:,1);
z_cord_temp = cord_2d(:,2);


% find the minimal x and maximum x

min_x = min(xy_cord_temp);

max_x = max(xy_cord_temp);


% find the z coordinates for min_x and max_x

temp_num_z_minX = 1;
temp_num_z_maxX = 1;


for num_temp = 1:size(cord_2d,1)
    
    if cord_2d(num_temp,1) == min_x
        z_at_minX(temp_num_z_minX) = cord_2d(num_temp,2);
        temp_num_z_minX =temp_num_z_minX +1;
        
    elseif cord_2d(num_temp,1) == max_x
        z_at_maxX(temp_num_z_maxX) = cord_2d(num_temp,2);
        temp_num_z_maxX =temp_num_z_maxX +1;
    end
    
end


%%
z_min_minX = min(z_at_minX);
z_max_minX = max(z_at_minX);

z_min_maxX = min(z_at_maxX);
z_max_maxX = max(z_at_maxX);

%  top curve
top_x_edge = [min_x max_x];
top_z_edge = [z_max_minX z_max_maxX];

% bot curve
bot_x_edge = top_x_edge;
bot_z_edge = [z_min_minX z_min_maxX];
%%

cord_2d_reshaped = cord_2d;


unique_x_cord = unique(xy_cord_temp);

for num_temp = 1:length(unique_x_cord)
    
    x_label_temp = find(cord_2d(:,1) == unique_x_cord(num_temp));
    
    z_cords_4_each_uni_x = cord_2d(x_label_temp ,2);
    
    [sorted_z, sorted_z_id] = sort(z_cords_4_each_uni_x);
    
    % top curve
    top_z_interp = interp1(top_x_edge,top_z_edge,unique_x_cord(num_temp),'linear');
    
    if isnan(top_z_interp)
        top_z_interp = interp1(top_x_edge,top_z_edge,unique_x_cord(num_temp),'nearest');
    end
    
    % bot curve
    bot_z_interp = interp1(bot_x_edge,bot_z_edge,unique_x_cord(num_temp),'linear');
    
    if isnan(bot_z_interp)
        bot_z_interp = interp1(bot_x_edge,bot_z_edge,unique_x_cord(num_temp),'nearest');
    end
    
    
    
    
%     z_reshaped= linspace(bot_z_interp,top_z_interp,length( z_cords_4_each_uni_x));
    z_reshaped= linspace(z_min_minX,z_max_minX,length( z_cords_4_each_uni_x));
    
    cord_2d_reshaped(x_label_temp(sorted_z_id) ,2) =   z_reshaped';
    
    
end




