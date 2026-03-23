import requests
import pandas as pd
import streamlit as st

st.title("Diffusion PDE Solver")

API_BASE = "http://localhost:8000"

with st.sidebar:
    R = st.number_input("Radius", 50.0, 2000.0, 500.0)
    RR = st.number_input("RR", 0.0, 50.0, 2.0)
    GR = st.number_input("GR", 0.0, 50.0, 1.0)
    ve = st.number_input("ve", 0.01, 0.99, 0.25)

    startO2 = st.number_input("O2", 0.0, 100.0, 0.13)
    startCO2 = st.number_input("CO2", 0.0, 100.0, 1.2)
    startHCO3 = st.number_input("HCO3", 0.1, 100.0, 24.0)
    startGlucose = st.number_input("Glucose", 0.0, 100.0, 5.0)

    NHE = st.number_input("NHE", 0.0, 50.0, 1.0)

    run = st.button("Run")

if run:
    payload = {
        "R": R,
        "RR": RR,
        "GR": GR,
        "ve": ve,
        "startO2": startO2,
        "startCO2": startCO2,
        "startHCO3": startHCO3,
        "startGlucose": startGlucose,
        "NHE": NHE,
    }

    res = requests.post(f"{API_BASE}/solve/diffusion", json=payload)
    data = res.json()

    df = pd.DataFrame({
        "x": data["x_um"],
        "O2": data["O2_mM"],
        "CO2": data["CO2_mM"],
        "HCO3e_mM": data["HCO3e_mM"],
        "pHe": data["pHe"],
        "Lace_mM": data["Lace_mM"],
        "HLac_mM": data["HLac_mM"],
        "Glu_mM": data["Glu_mM"],
        "HCO3i_mM": data["HCO3i_mM"],
        "pHi": data["pHi"],
        "Laci_mM": data["Laci_mM"],
    })

    st.subheader("Results")

    col1, col2, col3 = st.columns(3)

    with col1:
        st.write("pH")
        st.line_chart(df.set_index("x")[["pHe", "pHi"]])

    with col2:
        st.write("O2 (mM)")
        st.line_chart(df.set_index("x")[["O2"]])

    with col3:
        st.write("CO2 (mM)")
        st.line_chart(df.set_index("x")[["CO2"]])

    col4, col5, col6 = st.columns(3)

    with col4:
        st.write("HCO3- (mM)")
        st.line_chart(df.set_index("x")[["HCO3e_mM", "HCO3i_mM"]])

    with col5:
        st.write("Lactate (mM)")
        st.line_chart(df.set_index("x")[["Lace_mM", "Laci_mM"]])

    with col6:
        st.write("Glucose (mM)")
        st.line_chart(df.set_index("x")[["Glu_mM"]])

