function [CGlocation,Structuremass,Matrix,CGInertia,CGInertiaPrincipal]=readMass(filename)
% ************************************************************************
% loading the MSC.NASTRAN OUTPUT FILE (*.F06)

% CGlocation     ------ location of Center of Gravity of the vehicle
% Structuremass  ------ sum of structural mass + nonstructural mass
% Matrix         ------ 6 by 6 Rigid mass matrix
% CGInertia      ------ Mass moment of inerta w.r.t the C.G.
% CGInertiaPrincipal --- principal mass moment of inerta of the CGInerita


CGInertiaPrincipal=eye(3);
fid111=fopen(filename);

status=fseek(fid111,0,'eof');
EOF=ftell(fid111);
currentFPI=fseek(fid111,0,'bof');
while currentFPI<EOF
    linef06=fgetl(fid111);currentFPI=ftell(fid111);
    
    str1=findstr(linef06,'REFERENCE POINT');
    
    if length(linef06)>55 && isempty(str1)==0
        
        linef06=fgetl(fid111);
        currentFPI=ftell(fid111); %% Read M O
        str2=findstr(linef06,'M O');
        if length(linef06)>60 && isempty(str2)==0
            
            for loop=1:6
                linef06=fgetl(fid111);currentFPI=ftell(fid111);
                Matrix(loop,:)=str2num(linef06(25:108));
            end
            
            linef06=fgetl(fid111);currentFPI=ftell(fid111); %% Read S
            for loop=1:3
                linef06=fgetl(fid111);currentFPI=ftell(fid111);
            end
            
            linef06=fgetl(fid111);currentFPI=ftell(fid111); %% Read DIRECTION
            linef06=fgetl(fid111);currentFPI=ftell(fid111); %% Read MASS X-C.G. etc.
            for loop=1:3
                linef06=fgetl(fid111);currentFPI=ftell(fid111);
                data=str2num(linef06(36:end));
                CG(loop,:)=data(2:end);
                MASS(loop)=data(1);
            end
            
            linef06=fgetl(fid111);currentFPI=ftell(fid111); %% Read I(s)
            for loop=1:3
                linef06=fgetl(fid111);currentFPI=ftell(fid111);
                CGInertia(loop,:)=str2num(linef06(45:87));
            end
            
            linef06=fgetl(fid111);currentFPI=ftell(fid111); %% Read I(Q)
            for loop=1:3
                linef06=fgetl(fid111);currentFPI=ftell(fid111);
                CGInertiaPrincipal(loop,loop)=str2num(linef06(45:87));
            end
        end
    end
end

CGlocation(1)=CG(2,1);
CGlocation(2)=CG(1,2);
CGlocation(3)=CG(1,3);
Structuremass=MASS(1);
fclose(fid111);