

function eigenvalue=eigenvalueread(filename)

eigenvalue = 1e-10;

modelimit = 1;

fid100=fopen(filename);

if fid100>0
    disp('Buckling analysis f06 file exists')
else
    disp('Buckling analysis f06 file DOES NOT exist')

end
fclose(fid100);


try
    fid111=fopen(filename);
    status=fseek(fid111,0,'eof');
    EOF=ftell(fid111);
    currentFPI=fseek(fid111,0,'bof');
    jj=1;
    flag=1;

    modenumber = 0;


    while currentFPI<EOF

        linef06=fgetl(fid111);currentFPI=ftell(fid111);

        str=findstr(linef06,'R E A L   E I G E N V A L U E S');

        if length(linef06)>=77 && isempty(str)==0

            linef06=fgetl(fid111);currentFPI=ftell(fid111);
            linef06=fgetl(fid111);currentFPI=ftell(fid111);


            while modenumber < modelimit
                linef06=fgetl(fid111);currentFPI=ftell(fid111);

                %         while flag

                modedata=str2num(linef06);
                modenumber = modedata(1);

                eigenvalue(modenumber,jj)=modedata(3);

            end

        end

    end
    % Mode=jj-1;
    % NaturalFrequency=freq';
    % weight=0;
    fclose(fid111);

catch
    eigenvalue = 0.001*ones(10,1);
end
%end of code





