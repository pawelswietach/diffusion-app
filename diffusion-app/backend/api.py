from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import matlab.engine
import numpy as np
import os

app = FastAPI()

MATLAB_CODE_DIR = os.getenv("MATLAB_CODE_DIR", "../matlab")

eng = matlab.engine.start_matlab("-nodisplay")
eng.addpath(eng.genpath(MATLAB_CODE_DIR), nargout=0)


class DiffusionInput(BaseModel):
    R: float
    RR: float
    GR: float
    ve: float
    startO2: float
    startCO2: float
    startHCO3: float
    startGlucose: float
    NHE: float


def to_list(x):
    return np.array(x, dtype=float).ravel().tolist()


@app.post("/solve/diffusion")
def solve(inp: DiffusionInput):
    try:
        result = eng.diffusion_pdepe_profiles_api(
            inp.R, inp.RR, inp.GR, inp.ve,
            inp.startO2, inp.startCO2,
            inp.startHCO3, inp.startGlucose,
            inp.NHE,
            nargout=14
        )

        return {
            "x_um": to_list(result[0]),
            "O2_mM": to_list(result[1]),
            "CO2_mM": to_list(result[2]),
            "HCO3e_mM": to_list(result[3]),
            "pHe": to_list(result[4]),
            "Lace_mM": to_list(result[5]),
            "HLac_mM": to_list(result[6]),
            "Glu_mM": to_list(result[7]),
            "HCO3i_mM": to_list(result[8]),
            "pHi": to_list(result[9]),
            "Laci_mM": to_list(result[10]),
            "Carbon_total_mM": to_list(result[11]),
            "Uave": to_list(result[12]),
            "ATP_avg_Mps": float(result[13]),
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))