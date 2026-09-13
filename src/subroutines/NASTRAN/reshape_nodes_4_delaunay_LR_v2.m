[sorted_x,id] = sort(cord2d_original(:,1));
sorted_x = unique(sorted_x);

% cord2d_original_sortedX = cord2d_original(id,:);


% remove leading and trailing single points


% LE = sorted_x(1);
% TE = sorted_x(end);
% 
% 
% find(cord2d_original(:,1) == LE)
% 
% 
% find(cord2d_original(:,1) == TE)



minZ = min(cord2d_original(:,2));


maxZ = max(cord2d_original(:,2));


for ii = 1:length(sorted_x)
    
    
    
    
end