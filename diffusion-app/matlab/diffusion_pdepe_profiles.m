function profiles = diffusion_pdepe_profiles(R,RR,GR,ve,startO2,startCO2,startHCO3,startGlucose,NHE)
[xmesh,Uend,Uave,ATP_avg_Mps] = diffusion_pdepe(R,RR,GR,ve,startO2,startCO2,startHCO3,startGlucose,NHE);

vi = 1 - ve;

profiles.x_um = xmesh(:)';
profiles.O2_mM = (1000 * Uend(:,1))';
profiles.CO2_mM = (1000 * Uend(:,2))';
profiles.HCO3e_mM = (1000 * Uend(:,3))';
profiles.pHe = (-log10(Uend(:,4)))';
profiles.Lace_mM = (1000 * Uend(:,5))';
profiles.HLac_mM = (1000 * Uend(:,6))';
profiles.Glu_mM = (1000 * Uend(:,7))';
profiles.HCO3i_mM = (1000 * Uend(:,8))';
profiles.pHi = (-log10(Uend(:,9)))';
profiles.Laci_mM = (1000 * Uend(:,10))';

profiles.Carbon_total_mM = (1000 * (ve*Uend(:,3) + vi*Uend(:,8) + Uend(:,2)))';
profiles.Uave = Uave(:)';
profiles.ATP_avg_Mps = ATP_avg_Mps;
end
