function pws = t2pws_ashrae2021_si(T)
%% Notes
% Source: ASHRAE 2021 Handbook Chapter 1 Equation (5)
% Inputs
% T:   Temperature [C]
% Outputs
% pws:   Water saturation pressure [kPa]
%% Main
% conversion
TK = T + 273.15;
% coefficients
n1 = 0.11670521452767e4;
n2 = -0.72421316703206e6;
n3 = -0.17073846940092e2;
n4 = 0.12020824702470e5;
n5 = -0.32325550322333e7;
n6 = 0.14915108613530e2;
n7 = -0.48232657361591e4;
n8 = 0.40511340542057e6;
n9 = -0.23855557567849;
n10 = 0.65017534844798e3;
theta = TK + n9./(TK-n10);
A = theta.^2 + n1.*theta + n2;
B = n3.*theta.^2 + n4.*theta + n5;
C = n6.*theta.^2 + n7.*theta + n8;
% result
pws = 1000*(2*C./(-B+sqrt(B.^2-4*A.*C))).^4;
end

