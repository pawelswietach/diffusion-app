function [xmesh,Uend,Uave,ATP_avg_Mps]=diffusion_pdepe(R,RR,GR,ve,startO2,startCO2,startHCO3,startGlucose,NHE)
m = 2;
vi = 1 - ve;

D_free = [2600, 2100, 1300, 10, 1000, 1000, 960, zeros(1,3)];
D = [D_free(1:2), D_free(3:end)*ve];

CA = 100;
kh = 0.14;
kr = kh/(10^-6.1);
kf = 1e6;
kb = kf/(10^-3.9);

JR = @(r) (RR/1000)/60;
JG = @(r) (GR/1000)/60;

startO2_M = startO2 / 1000;
startCO2_M = startCO2 / 1000;
startHCO3_M = startHCO3 / 1000;
startGlucose_M = startGlucose / 1000;

He_blood = startCO2_M * (10^-6.1) / startHCO3_M;

c_blood = [startO2_M, startCO2_M, startHCO3_M, He_blood, 0, 0, startGlucose_M];

params.vi = vi;
params.ve = ve;
params.CA = CA;
params.D  = D;
params.kh = kh;
params.kr = kr;
params.kf = kf;
params.kb = kb;
params.JR = JR;
params.JG = JG;
params.NHE = NHE;
params.c_blood = c_blood;

xmesh = linspace(0,R,500);
tspan = linspace(0,5*3600,60);

b_pHi = 7.2;
u0 = @(x) [c_blood(1:end), startCO2_M * 10^(b_pHi-6.1), 10^-b_pHi, 0]';

opts = odeset('RelTol',1e-7,'AbsTol',1e-12);
sol = pdepe(m, @(x,t,u,dudx) pdefun(x,t,u,dudx,params), @(x) u0(x), @(xl,ul,xr,ur,t) bcfun(xl,ul,xr,ur,t,params), xmesh, tspan, opts);

Uend = squeeze(sol(end,:,:));
r = xmesh(:);

Uave = (3/(R^3)) * trapz(r, Uend .* (r.^2));

O2  = Uend(:,1);
Glu = Uend(:,7);
Hi  = Uend(:,9);

Km = 1e-6;
Kg = 1e-3;

JRv = params.JR(r).*Glu./(Glu+Kg).*O2./(O2+Km);
JGv = params.JG(r).*Glu./(Glu+Kg).*((10^-7.1)^2.25)./(Hi.^2.25+(10^-7.1)^2.25);

ATP_avg_Mps = (3/(R^3)) * trapz(r, (2*JGv + 30*JRv) .* (r.^2));
end

function [c,f,s] = pdefun(x,t,u,dudx,p)
O2=u(1);CO2=u(2);HCO3e=u(3);He=u(4);Lace=u(5);
HLac=u(6);Glu=u(7);HCO3i=u(8);Hi=u(9);Laci=u(10);

c = [1;1;p.ve;p.ve;p.ve;1;1;p.vi;p.vi;p.vi];
f = p.D(:).*dudx;

r_CO2e = p.CA*(p.kr*HCO3e*He - p.kh*CO2);
r_CO2i = p.CA*(p.kr*HCO3i*Hi - p.kh*CO2);
r_HLace= (p.kb*Lace*He - p.kf*HLac);
r_HLaci= (p.kb*Laci*Hi - p.kf*HLac);

Km=1e-6;Kg=1e-3;
JRval = p.JR(x)*Glu/(Glu+Kg)*O2/(O2+Km);
JGval = p.JG(x)*Glu/(Glu+Kg);

Href=10^-7.2;Knhe=10^-6.5;
Jnhe=(p.NHE/1000/60)*(Hi.^2./(Hi.^2+Knhe^2)-Href.^2./(Href.^2+Knhe^2));

s=zeros(10,1);
s(1)=-6*p.vi*JRval;
s(2)=6*p.vi*JRval + p.ve*r_CO2e + p.vi*r_CO2i;
s(3)=p.ve*(-r_CO2e);
s(4)=p.ve*(-r_CO2e -r_HLace +Jnhe);
s(5)=p.ve*(-r_HLace);
s(6)=2*p.vi*JGval + p.ve*r_HLace + p.vi*r_HLaci;
s(7)=-p.vi*(JGval + JRval);
s(8)=p.vi*(-r_CO2i);
s(9)=p.vi*(-r_CO2i -r_HLaci -Jnhe);
s(10)=p.vi*(-r_HLaci);
end

function [pl,ql,pr,qr] = bcfun(xl,ul,xr,ur,t,p)
pr = [ur(1:7)-p.c_blood(1:7)';0;0;0];
qr = [zeros(7,1);1;1;1];
pl = zeros(10,1);
ql = ones(10,1);
end
