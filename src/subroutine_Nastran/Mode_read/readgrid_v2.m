function GridCord=readgrid_v2(filename)
% ************************************************
% Read grid ID and coordinate from *f06 file with ECHO=SORT
% Grid = [nodelabel, xcord, ycord, zcord]

fid111=fopen(filename);
status=fseek(fid111,0,'eof');
EOF=ftell(fid111);
currentFPI=fseek(fid111,0,'bof');
jj=1;
while currentFPI<EOF
    linef06=fgetl(fid111);currentFPI=ftell(fid111);
    str=findstr(linef06,'GRID');
    if length(linef06)>70 && isempty(str)==0 && str==31
%         disp('---- find the correct line ----');
        if length(linef06)>77
            gridata=linef06(39:77);
        else
            gridata=linef06(39:end);
        end
        
        nodenum=gridata(1:8);
        gridata1=gridata(17:24);
        gridata2=gridata(25:32);
        gridata3=gridata(33:end);
        gridcord(jj,:)=[str2num(nodenum),str2num(gridata1),str2num(gridata2),str2num(gridata3)];
%         gridcordLabel(jj,:)=str2num(nodenum)
        jj=jj+1;
    end
end
GridCord=gridcord;
fclose(fid111);