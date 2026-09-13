function write_CHEXA(elements,design_folder,fname)



fid102=fopen([design_folder filesep fname],'w+');fclose(fid102);
fid102=fopen([design_folder filesep fname],'a');



for ii = 1:size(elements,1)
    
    chexa ='CHEXA    20734   1       23794   23832   23828   23792   24181   24219  ';
    
    chexa(9:16) = num2str_integer(elements(ii,1));
    chexa(17:24) = num2str_integer(elements(ii,2));
    
    chexa(25:32) = num2str_integer(elements(ii,3));
    chexa(33:40) = num2str_integer(elements(ii,4));
    chexa(41:48) = num2str_integer(elements(ii,5));
    chexa(49:56) = num2str_integer(elements(ii,6));
    
    chexa(57:64) = num2str_integer(elements(ii,7));
    
    chexa(65:72) = num2str_integer(elements(ii,8));
    
    fprintf(fid102,'%s\n',chexa);
    
    chexa = blanks(24);
    chexa(9:16) =  num2str_integer(elements(ii,9));
    chexa(17:24) = num2str_integer(elements(ii,10));
    
      fprintf(fid102,'%s\n',chexa);
    
end
fclose('all');
