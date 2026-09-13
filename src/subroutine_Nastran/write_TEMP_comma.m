function write_TEMP_comma(nodelabel,tempID,Temp,design_folder,fname,start)

% loadID is for dummy force, used in static loading analysis

if strcmp(start,'1')
    fid102=fopen([design_folder filesep fname],'w+');fclose(fid102);
    fid102=fopen([design_folder filesep fname],'a');

else

    fid102=fopen([design_folder filesep fname],'a');
end

%'FORCE    1       1067            0.     .5773503.5773503.5773503';


% dummy_force_line =['FORCE,'  num2str_integer(loadID) ',' num2str_integer(nodelabel(1)) ',,' '0.,     .5773503,.5773503,.5773503'];
%
% fprintf(fid102,'%s\n',dummy_force_line);

for ii = 1:length(nodelabel)


    % spcd_sample ='SPCD     1       121     1      -1.-4   ';

    %     spcd_sample = ['SPCD     3       21      0       500.   ' num2str8(component(1)) num2str8(component(2)) num2str8(component(3))];





    % for comp = 1:length(component)

    %         spcd_sample(17:24) = num2str_integer(nodelabel(ii));
    %
    %         spcd_sample(25:32) = num2str_integer(component(comp));
    %
    %
    %         spcd_sample(33:40) = num2str8_sci(deltaU(ii));
    %
    %

    if Temp(ii) == 0
        Temp(ii) = 1e-10;
    end

    spcd_sample = ['TEMP' ',' num2str_integer(tempID) ',' ...
        num2str_integer(nodelabel(ii)) ','...
        num2str_float(Temp(ii)) ];




    fprintf(fid102,'%s\n',spcd_sample);
    %
    % end

end

fclose('all');