# Universal gas constant
R̄() = 8.314472 # ± 0.000015 # kJ/kmol·K

# Standard Tref
Tref() = 298.15 # K

# IG (Ideal Gas) structure: values for each gas instance
struct IG
    MW                  # Molecular "Weight", kg/kmol
    CP::Ntuple{4}       # Exactly 4 c̄p(T) coefficients
    Tmin                # T_min, K
    Tmax                # T_max, K
    sref                # s̄°ref, kJ/kmol·K
end

