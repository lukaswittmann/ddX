#!/usr/bin/python3
import sys
import os
import subprocess

threshold = 1e-4

def list_diff(list1, list2):
    diff = []
    for i in range(len(list1)):
        tmp = []
        for j in range(len(list1[0])):
            tmp.append(list1[i][j] - list2[i][j])
        diff.append(tmp)
    return diff

def inf_norm(input_list):
    max_val = 0.0
    for i in range(len(input_list)):
        for j in range(len(input_list[0])):
            val = abs(input_list[i][j])
            if val > max_val:
                max_val = val
    return max_val

def read_log(path):
    """Read a log file from disk and return (energy, forces)."""
    energy = 0.0
    forces = []
    with open(path, "r", encoding="utf-8") as log:
        section = ""
        for line in log:
            if "Solvation energy (Hartree):" in line:
                tokens = line.split()
                energy = float(tokens[3]) 
            if section == 'forces':
                tokens = line.split()
                forces.append([float(tokens[1]), float(tokens[2]), \
                               float(tokens[3])])
            if 'Full forces (kcal/mol/A)' in line:
                section = 'forces'
    return energy, forces

def parse_log_from_string(s):
    """Parse log content from a string and return (energy, forces)."""
    energy = 0.0
    forces = []
    section = ""
    for line in s.splitlines():
        if "Solvation energy (Hartree):" in line:
            tokens = line.split()
            energy = float(tokens[3])
        if section == 'forces':
            tokens = line.split()
            # defensive: only append if there are enough tokens
            if len(tokens) >= 4:
                forces.append([float(tokens[1]), float(tokens[2]), float(tokens[3])])
        if 'Full forces (kcal/mol/A)' in line:
            section = 'forces'
    return energy, forces

basename = sys.argv[1]
input_file = basename + ".txt"
ref_file = basename + ".ref"

# Run the driver and capture stdout instead of writing a logfile
proc = subprocess.run(["./ddx_driver_testing", input_file], capture_output=True, text=True)
if proc.returncode != 0:
    print(proc.stdout)
    print(proc.stderr, file=sys.stderr)
    raise SystemExit(proc.returncode)

energy, forces = parse_log_from_string(proc.stdout)
ref_energy, ref_forces = read_log(ref_file)

print(f"Energy:         {energy:20.10f}")
print(f"Ref. energy:    {ref_energy:20.10f}")
assert (energy - ref_energy)/ref_energy < threshold

force_diff = list_diff(forces, ref_forces)
force_max_diff = inf_norm(force_diff)
force_max_ref = inf_norm(ref_forces)
print(f"Force max diff: {force_max_diff:20.10f}")
assert force_max_diff/force_max_ref < threshold
