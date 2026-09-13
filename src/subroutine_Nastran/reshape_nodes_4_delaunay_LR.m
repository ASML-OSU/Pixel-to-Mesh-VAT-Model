function cord_2d_reshaped = reshape_nodes_4_delaunay_LR(cord_2d)

% LR: leading/rear points.
% For spar/rib with curved surface, reshape edge nodes to be straight line

% step 1 - reshape the curved line to straight line for a rectangle 

% works only for spar/ribs with 4-edge polygon - reshape the surface.

% 




x_cord_temp = cord_2d(:,1);


x_cord_temp_unique = unique(x_cord_temp);

z_share_unique_x_num_temp = 1;

for num_temp = 1:length(x_cord_temp_unique)
   
    share_x_zcord_num = find(x_cord_temp == x_cord_temp_unique(num_temp));
    
    if length(share_x_zcord_num )==1
    
    unique_x_index(z_share_unique_x_num_temp ) = share_x_zcord_num ;
    z_share_unique_x_num_temp = z_share_unique_x_num_temp+1;
    
    end
    
end


z_cord_temp = cord_2d(:,2);

max_z = max(z_cord_temp);
min_z = min(z_cord_temp);
mid_z = (max_z+min_z)/2;

%%
% apply mid_z to lead/rear point
cord_2d_reshaped = cord_2d;

for num_temp = 1:length(unique_x_index)
   
    index_temp = unique_x_index(num_temp);
    
    cord_2d_reshaped( index_temp ,2) = mid_z;
    
end


%% reduced cord_2d


cord_2d_reduced = cord_2d(setdiff(1:length(x_cord_temp),unique_x_index),:);

cord_2d_reduced_reshaped = cord_2d_reduced;

unique_x_cord = unique(cord_2d_reduced(:,1));


for num_temp = 1:length(unique_x_cord)
    
    x_label_temp = find(cord_2d_reduced(:,1) == unique_x_cord(num_temp));
    
    z_cords_4_each_uni_x = cord_2d_reduced(x_label_temp ,2);
    
    [sorted_z, sorted_z_id] = sort(z_cords_4_each_uni_x);
    
%     % top curve
%     top_z_interp = interp1(top_x_edge,top_z_edge,unique_x_cord(num_temp),'linear');
%     
%     if isnan(top_z_interp)
%         top_z_interp = interp1(top_x_edge,top_z_edge,unique_x_cord(num_temp),'nearest');
%     end
%     
%     % bot curve
%     bot_z_interp = interp1(bot_x_edge,bot_z_edge,unique_x_cord(num_temp),'linear');
%     
%     if isnan(bot_z_interp)
%         bot_z_interp = interp1(bot_x_edge,bot_z_edge,unique_x_cord(num_temp),'nearest');
%     end
    
    
%     z_reshaped= linspace(bot_z_interp,top_z_interp,length( z_cords_4_each_uni_x));
    z_reshaped= linspace(min_z,max_z,length( z_cords_4_each_uni_x));
    
    cord_2d_reduced_reshaped(x_label_temp(sorted_z_id) ,2) =   z_reshaped';
    
    
end


cord_2d_reshaped(setdiff(1:length(x_cord_temp),unique_x_index),:) =  cord_2d_reduced_reshaped;

