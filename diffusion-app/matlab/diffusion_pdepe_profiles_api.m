function [x_um,O2_mM,CO2_mM,HCO3e_mM,pHe,Lace_mM,HLac_mM,Glu_mM,HCO3i_mM,pHi,Laci_mM,Carbon_total_mM,Uave,ATP_avg_Mps] = diffusion_pdepe_profiles_api(R,RR,GR,ve,startO2,startCO2,startHCO3,startGlucose,NHE)

profiles = diffusion_pdepe_profiles(R,RR,GR,ve,startO2,startCO2,startHCO3,startGlucose,NHE);

x_um = profiles.x_um;
O2_mM = profiles.O2_mM;
CO2_mM = profiles.CO2_mM;
HCO3e_mM = profiles.HCO3e_mM;
pHe = profiles.pHe;
Lace_mM = profiles.Lace_mM;
HLac_mM = profiles.HLac_mM;
Glu_mM = profiles.Glu_mM;
HCO3i_mM = profiles.HCO3i_mM;
pHi = profiles.pHi;
Laci_mM = profiles.Laci_mM;
Carbon_total_mM = profiles.Carbon_total_mM;
Uave = profiles.Uave;
ATP_avg_Mps = profiles.ATP_avg_Mps;
end
