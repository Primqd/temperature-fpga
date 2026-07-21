"""
Thermistor Temperature Calculator
----------------------------------
Converts an RC time-constant measurement (in FPGA clock ticks) from the
Nandland Go Board into a temperature reading, using the standard NTC
thermistor Beta-parameter equation.

Circuit: thermistor (R, unknown/varies with temp) + fixed capacitor (C)
Measured: number of clock ticks corresponding to one RC time constant (tau)

Calibration point (from problem statement):
    Clock freq   = 25 MHz   (Go Board on-board oscillator)
    Capacitor    = 10^4 pF  = 10 nF
    Ticks        = 15000    -> tau = 600 microseconds -> R = 60 kOhm
    Room temp    = 79 F     = 26.11 C = 299.26 K

If you have the actual thermistor's datasheet, replace R0/T0_K/BETA below
with the datasheet's values for a more accurate result.
"""

import math

# ---- Hardware / circuit constants ----
CLOCK_FREQ_HZ = 25e6           # Go Board on-board oscillator
CAPACITANCE_F = 1e4 * 1e-12    # 10^4 pF = 10 nF

# ---- Thermistor calibration (Beta-parameter model) ----
# 1/T = 1/T0 + (1/BETA) * ln(R / R0)
R0_OHMS = 60_000.0             # resistance at calibration temp T0
T0_K = 26.11 + 273.15          # calibration temp: 79 F = 26.11 C
BETA = 3950.0                  # typical NTC beta; replace with datasheet value


def ticks_to_resistance(ticks: float) -> float:
    """Convert measured clock ticks (one RC time constant) to resistance (ohms)."""
    clock_period_s = 1.0 / CLOCK_FREQ_HZ
    tau_s = ticks * clock_period_s
    r_ohms = tau_s / CAPACITANCE_F
    return r_ohms


def resistance_to_temperature_c(r_ohms: float) -> float:
    """Convert thermistor resistance (ohms) to temperature (Celsius) via Beta equation."""
    inv_t = (1.0 / T0_K) + (1.0 / BETA) * math.log(r_ohms / R0_OHMS)
    t_kelvin = 1.0 / inv_t
    return t_kelvin - 273.15


def ticks_to_temperature(ticks: float) -> dict:
    """Full pipeline: clock ticks -> resistance -> temperature (C and F)."""
    r_ohms = ticks_to_resistance(ticks)
    temp_c = resistance_to_temperature_c(r_ohms)
    temp_f = temp_c * 9.0 / 5.0 + 32.0
    return {
        "ticks": ticks,
        "resistance_ohms": r_ohms,
        "temp_c": temp_c,
        "temp_f": temp_f,
    }


def write_mem_file(min_ticks, max_ticks, step):
    """Write Fahrenheit values (rounded, clamped to 0-255, one 2-digit hex
    byte per line) for ticks in {min_ticks, min_ticks+step, ..., max_ticks}
    to "farenheit_lut_ones" for the less significant digit and
    "farenheit_lut_tens" for the more significant digit.
    note ticks=0 needs to be manually fixed to 9 in both files
    although surely it wouldn't matter...
    """
    ones = []
    tens = []
    for ticks in range(min_ticks, max_ticks + 1, step):
        r_ohms = ticks_to_resistance(ticks)
        r_ohms = max(r_ohms, 1e-9)  # avoid log(0) domain error at ticks == 0 or something
        temp_c = resistance_to_temperature_c(r_ohms)

        temp_c_int = round(temp_c)
        temp_c_int = max(0, min(99, round(temp_c_int)))  # clamp to two-digit display

        print(ticks, temp_c_int)
        ones.append(str(temp_c_int % 10))
        tens.append(str((temp_c_int // 10) % 10))

    with open("./lut_ones.mem", "w") as f:
        f.write("\n".join(ones) + "\n")
    with open("./lut_tens.mem", "w") as f:
        f.write("\n".join(tens) + "\n")

    print("finished")


if __name__ == "__main__":
    # Sanity check against the given calibration point
    result = ticks_to_temperature(15000)
    print(f"Ticks:        {result['ticks']}")
    print(f"Resistance:   {result['resistance_ohms']:.1f} ohms")
    print(f"Temperature:  {result['temp_c']:.2f} C  ({result['temp_f']:.2f} F)")

    # Fahrenheit temperature LUT for ticks = 0, 256, 512, ..., 65280
    write_mem_file(min_ticks=0, max_ticks=65280, step=256)