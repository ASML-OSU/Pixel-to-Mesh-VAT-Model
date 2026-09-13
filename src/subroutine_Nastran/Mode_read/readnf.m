function [NaturalFrequency,GM]=readnf(filename,maxmodenum)
% ************************************************
% Read mode frequencies and structural weight from NASTRAN output file *f06
% GK - Generalized stiffness matrix;
% GM - Generalized mass matrix;

fid111=fopen(filename);
status=fseek(fid111,0,'eof');
EOF=ftell(fid111);
currentFPI=fseek(fid111,0,'bof');
jj=1;
flag=1;
while currentFPI<EOF
    
    linef06=fgetl(fid111);currentFPI=ftell(fid111);
    
    str=findstr(linef06,'R E A L   E I G E N V A L U E S');
    
    if length(linef06)>=77 && isempty(str)==0
        linef06=fgetl(fid111);currentFPI=ftell(fid111);
        linef06=fgetl(fid111);currentFPI=ftell(fid111);
        linef06=fgetl(fid111);currentFPI=ftell(fid111);
        while flag
            modedata=str2num(linef06);
            
            NaturalFrequency(jj)=modedata(5);
            GM(jj,jj)=modedata(6);
            GK(jj,jj)=modedata(7);
        
            linef06=fgetl(fid111);currentFPI=ftell(fid111);
            if length(linef06)>100 && isempty(str2num(linef06(17:20))==jj)==0 && jj<maxmodenum
                flag=1;
%                 datafreq=str2num(linef06);
%                 freq(jj)=datafreq(5);
                jj=jj+1;
            else
                flag=0;
            end
        end
    end
end
fclose(fid111);

