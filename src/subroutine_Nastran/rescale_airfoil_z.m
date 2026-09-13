function scaled_airfoil = rescale_airfoil_z(original_airfoil, target_airfoil)


% adjust target_airfoil x to same with original_airfoil



chord_original = max(original_airfoil(:,1)) - min(original_airfoil(:,1));



chord_target = max(target_airfoil(:,1)) - min(target_airfoil(:,1));


target_airfoil = target_airfoil/chord_target*chord_original;



target_airfoil(:,1) = target_airfoil(:,1) - min(target_airfoil(:,1)) ;





scaled_airfoil = original_airfoil;


for ii = 1:size(scaled_airfoil,1)
    
    
    cord_temp = scaled_airfoil(ii,:);
    
    for jj = 1:size(target_airfoil,1)
        
        
        dis(jj) = norm(target_airfoil(jj,:) - cord_temp);
        
        
    end
    

    [min_dis,id ] =min(dis);
    
    
    cord_temp = target_airfoil(id,:);
    
    
    scaled_airfoil(ii,:) = cord_temp;
    
end


