function [CQUAD4,CTRIA3]=readelementf06_v1(filename)

% ************************************************
% read elements from f06 file
% CQUAD4 ----- 4-noded quadrlateral element
% CTRIA3 ----- 3-noded triangular element

fid111=fopen(filename);
status=fseek(fid111,0,'eof');
EOF=ftell(fid111);
currentFPI=fseek(fid111,0,'bof');
jj=1;ii=1;
CQUAD4=[];
CTRIA3=[];
while currentFPI<EOF
    
    linef06=fgetl(fid111);currentFPI=ftell(fid111);
    str1=findstr(linef06,'CQUAD4');
    str2=findstr(linef06,'CTRIA3');
    
    if isempty(str1)==0  || isempty(str2)==0 
        
        flag=1;
    else
        flag=0;
    end
    
    if flag
        
%         flag
        %disp('---- find the correct line ----');

        element_type=linef06(31:36);
        element_con_str=linef06(39:end);
        
%         element_con_num=str2num(element_con_str);
%         
        switch element_type
            
            case 'CQUAD4'
                
                elementID = str2num( element_con_str(1:8));
                
                element_node_1 = str2num( element_con_str(17:24));
                element_node_2 = str2num( element_con_str(25:32));
                element_node_3 = str2num( element_con_str(33:40));
                
                if length(element_con_str)<48
                    element_node_4 = str2num( element_con_str(41:end));
                else
                    element_node_4 = str2num( element_con_str(41:48));
                end
                
                CQUAD4(jj,:)=[elementID element_node_1 element_node_2 element_node_3 element_node_4];
                
                jj=jj+1;
            case 'CTRIA3'
                
                elementID = str2num( element_con_str(1:8));
                
                element_node_1 = str2num( element_con_str(17:24));
                element_node_2 = str2num( element_con_str(25:32));
                
                if length(element_con_str)<40
                    element_node_3 = str2num( element_con_str(33:end));
                else
                    element_node_3 = str2num( element_con_str(33:40));
                end
                
                CTRIA3(ii,:)=[elementID element_node_1 element_node_2 element_node_3];
                ii=ii+1;
        end
    end
end

fclose(fid111);