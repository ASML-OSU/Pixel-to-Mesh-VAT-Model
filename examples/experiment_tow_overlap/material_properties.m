% material properties

Mat.E1(1) = 1.263E+11;
Mat.E2(1)  = 8.7649997e+9;
Mat.E3(1)  = 8.7649997e+9;

Mat.G12(1) =  4.92e9;
Mat.G13(1)  = 4.92e9;
Mat.G23(1)  = 3.35e9;

Mat.v12(1)  = 0.334;



Mat.E3(1)   = Mat.E2(1);
Mat.v21(1)  =Mat.E2(1)/Mat.E1(1)*Mat.v12(1);
Mat.v13(1)  = Mat.v12(1);
Mat.v31(1)  = Mat.v13(1)/Mat.E1(1)*Mat.E3(1);
Mat.v23(1)  = Mat.v12(1);
Mat.v32(1)  = Mat.v23(1)*Mat.E3(1)/Mat.E2(1);

%% 
Mat.E1(2)  = 4.67e9;
Mat.E2(2)  = 4.67e9;
Mat.E3(2)  = 4.67e9;

Mat.G12(2) =  1.70e9;
Mat.G13(2)  = 1.70e9;
Mat.G23(2)  = 1.70e9;

Mat.v12(2)  = 0.3;

Mat.E3(2)  = Mat.E2(2);
Mat.v21(2) = Mat.E2(2)/Mat.E1(2)*Mat.v12(2);
Mat.v13(2) = Mat.v12(2);
Mat.v31(2) = Mat.v13(2)/Mat.E1(2)*Mat.E3(2);
Mat.v23(2) = Mat.v12(2);
Mat.v32(2) = Mat.v23(2)*Mat.E3(2)/Mat.E2(2);