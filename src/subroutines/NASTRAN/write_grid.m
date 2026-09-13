function write_grid(grid,design_folder,fname,start)


if strcmp(start,'1')
    fid101=fopen([design_folder filesep fname],'w+');fclose(fid101);
    fid102=fopen([design_folder filesep fname],'a+');
    fprintf(fid102,'%s\n','$1......2.......3.......4.......5.......6.......7.......8.......');
    
else
    fid102=fopen([design_folder filesep fname],'a+');
    
end

% fid102=fopen([design_folder filesep fname],'w+');fclose(fid102);
% fid102=fopen([design_folder filesep fname],'a');


for ii = 1:size(grid,1)
    
    grid_sample = 'GRID     378            .8      .68      0.     ';
    
    label = grid(ii,1);
    
    
    
    grid_sample(9:16) = num2str_integer(label);
    
    
    if abs(grid(ii,2))<1e-10
        
        grid(ii,2) = 0;
    end
    
    grid_sample(25:32) = num2str8(grid(ii,2));
    
    
    if abs(grid(ii,3))<1e-10
        
        grid(ii,3) = 0;
    end
    grid_sample(33:40) = num2str8(grid(ii,3));
    
    if abs(grid(ii,4))<1e-10
        
        grid(ii,4) = 0;
    end
    
    grid_sample(41:48) = num2str8(grid(ii,4));
    
    
    fprintf(fid102,'%s\n',grid_sample);
    
end

fclose('all');