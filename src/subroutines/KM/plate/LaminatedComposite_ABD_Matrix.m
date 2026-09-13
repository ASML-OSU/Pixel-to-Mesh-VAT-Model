%% Material Constant
function [Amatrix,Dmatrix,Ashear,Bmatrix,Qbar_theta]=LaminatedComposite_ABD_Matrix(Mat,theta,zk,zk0,MatID)



Amatrix = zeros(3,3);
Bmatrix = zeros(3,3);
Dmatrix = zeros(3,3);

Mat.kappa = 5/6;

for layer_no = 1:length(theta)

    matid = MatID(layer_no);

    c=cosd(theta(layer_no));
    s=sind(theta(layer_no));
    %--------Transform Matrix for Coordinate Transformation--------


    Q11=Mat.E1(matid)/(1-Mat.v12(matid)*Mat.v21(matid));
    Q12=Mat.v12(matid)*Mat.E2(matid)/(1-Mat.v12(matid)*Mat.v21(matid));
    Q22=Mat.E2(matid)/(1-Mat.v12(matid)*Mat.v21(matid));
    Q66=Mat.G12(matid);
    Q44=Mat.G23(matid);
    Q55=Mat.G13(matid);


    %------Orthotropic Material--------------
    Q11b=Q11*c^4+2*(Q12+2*Q66)*s^2*c^2+Q22*s^4;
    Q12b=(Q11+Q22-4*Q66)*s^2*c^2+Q12*(s^4+c^4);
    Q22b=Q11*s^4+2*(Q12+2*Q66)*s^2*c^2+Q22*c^4;
    Q16b=(Q11-Q12-2*Q66)*s*c^3+(Q12-Q22+2*Q66)*s^3*c;
    Q26b=(Q11-Q12-2*Q66)*c*s^3+(Q12-Q22+2*Q66)*c^3*s;
    Q66b=(Q11+Q22-2*Q12-2*Q66)*s^2*c^2+Q66*(s^4+c^4);
    Q44b=Q44*c^2+Q55*s^2;
    Q45b=(Q55-Q44)*c*s;
    Q55b=Q55*c^2+Q44*s^2;


    Qbar=[Q11b,  Q12b,  0,   0,  Q16b;
        Q12b,  Q22b,  0,   0,  Q26b;
        0,     0,  Q44b, Q45b,  0;
        0,     0,  Q45b, Q55b,  0;
        Q16b,   Q26b, 0,    0,   Q66b];

    bendingNO = [1,2,5];
    shearNO=[3,4];

    number = [1,2,3,4,5];

    Qbar_theta = Qbar(number,number);

    Qbar_bend = Qbar(bendingNO,bendingNO);

    Qbar_shear = Qbar(shearNO,shearNO);

    % zk1=-Stru.thickness/2+layerNo*thickness;
    % zk0=-Stru.thickness/2+(layerNo-1)*thickness;

    % zk-zk0

    Amatrix =Amatrix + (zk(layer_no)  -zk0(layer_no))*Qbar_bend;
    Bmatrix= Bmatrix +  1/2*(zk(layer_no)^2-zk0(layer_no)^2)*Qbar_bend;
    Dmatrix= Dmatrix + 1/3*(zk(layer_no)^3-zk0(layer_no)^3)*Qbar_bend;

    Ashear=Mat.kappa*(zk(layer_no)-zk0(layer_no))*Qbar_shear;



end