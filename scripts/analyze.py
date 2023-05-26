#!/usr/bin/env python3

import re
import os
import pyverilog.vparser.ast as vast
import pyverilog.vparser.parser as vparser
import pypower

# Specify the paths to the output files
module1_output_path = "./test/alu_output.txt"
module2_output_path = "./test/operand_handler_output.txt"
module3_output_path = "./test/two_port_register_output.txt"

module1_expected_path = "./test/expected_module1_output.txt"
module2_expected_path = "./test/expected_module2_output.txt"



def extract_module_definition(verilog_file, module_name):
    """
    # Extracts a Verilog Module

    # Parameters:
        Verilog File: Path
        Module Name: str

    # Returns:
        reverse(str1):The string which gets reversed.   
    """
    with open(verilog_file, 'r') as file:
        content = file.read()
    
    module_regex = rf"module\s+{module_name}\s*\((.*?)\);"
    module_match = re.search(module_regex, content, re.DOTALL)
    if module_match:
        module_definition = module_match.group(0)
        return module_definition
    else:
        raise ValueError(f"Module '{module_name}' not found in the Verilog file.")



def analyze_timing(verilog_file):
    """
    # Generates a Timing Analysis Report
    """
    # Read the Verilog file
    with open(verilog_file, 'r') as f:
        verilog = f.read()

    # Extract the clock period
    match = re.search(r'timescale\s+(\d+)\s*([munpf])', verilog)
    if match:
        time_unit = match.group(2)
        if time_unit == 'u':
            time_scale = 1e-6
        elif time_unit == 'n':
            time_scale = 1e-9
        elif time_unit == 'p':
            time_scale = 1e-12
        elif time_unit == 'f':
            time_scale = 1e-15
        clock_period = float(match.group(1)) * time_scale
    else:
        raise Exception('Cannot find timescale directive')

    # Extract the delay of each gate
    delays = {}
    matches = re.findall(r'\b(\w+)\s*<=.*#(\d+)\s*(\w+)\s*;', verilog)
    for match in matches:
        gate_name = match[0]
        delay = int(match[1]) * time_scale
        inputs = re.findall(r'\b(\w+)\b', match[2])
        delays[gate_name] = (delay, inputs)
    return clock_period, delays


def generate_timing_report(verilog_file):
    # Analyze the timing of the design
    clock_period, delays = analyze_timing(verilog_file)

    # Compute the critical path
    critical_path = []
    slack = 0
    for gate_name in delays:
        gate_delay, inputs = delays[gate_name]
        input_slack = min([delays[input][0] for input in inputs])
        gate_slack = clock_period - gate_delay - input_slack
        if gate_slack < slack:
            critical_path = [gate_name]
            slack = gate_slack
        elif gate_slack == slack:
            critical_path.append(gate_name)

    # Generate the report
    report = ''
    report += 'Clock period: {:.2f} ns\n\n'.format(clock_period * 1e9)
    report += 'Critical path: {} (slack: {:.2f} ns)\n\n'.format(
        ' -> '.join(critical_path), slack * 1e9)
    report += 'Gate delays:\n'
    for gate_name in delays:
        gate_delay, inputs = delays[gate_name]
        input_slack = min([delays[input][0] for input in inputs])
        gate_slack = clock_period - gate_delay - input_slack
        report += '- {} (delay: {:.2f} ns, slack: {:.2f} ns)\n'.format(
            gate_name, gate_delay * 1e9, gate_slack * 1e9)

    return report


def main():
    pass


if __name__ == "__main__":
    main()





# def generate_timing_analysis_report(verilog_file, module_name):
#     try:
#         module_definition = extract_module_definition(verilog_file, module_name)
#         input_wires, output_wires = extract_input_output_wires(module_definition)
        
#         report = f"Timing Analysis Report for Verilog Module: {module_name}\n"
#         report += "----------------------------------------------\n"
#         report += f"Input Wires:\n{', '.join(input_wires)}\n\n"
#         report += f"Output Wires:\n{', '.join(output_wires)}\n"
        
#         return report
#     except ValueError as e:
#         return str(e)


# # Parse the Verilog code
# code = '''
# module adder(input [7:0] a, b, output [8:0] sum);

# assign sum = a + b;

# endmodule
# '''

# ast, _ = vparser.parse(code)

# # Find the adder module
# adder = None
# for item in ast.description.definitions:
#     if isinstance(item, vast.ModuleDef) and item.name == 'adder':
#         adder = item

# if adder is None:
#     print('Error: Could not find adder module')
# else:
#     # Print the inputs and outputs
#     inputs = []
#     outputs = []
#     for port in adder.portlist.ports:
#         if port.direction == 'input':
#             inputs.append(port.name)
#         elif port.direction == 'output':
#             outputs.append(port.name)
#     print('Inputs:', inputs)
#     print('Outputs:', outputs)







# # Perform power analysis for a given input sequence
# input_sequence = [0, 1, 1, 0, 1, 0, 0, 1]
# power_trace = em.simulate(input_sequence)

# # Calculate the total power consumption
# total_power = sum(power_trace)

# print("Total power consumption:", total_power)


# def extract_input_output_wires(module_definition):
#     input_wires = re.findall(r"input\s+wire\s+(\w+)", module_definition)
#     output_wires = re.findall(r"output\s+wire\s+(\w+)", module_definition)
#     return input_wires, output_wires


# # Example usage
# verilog_file = "example_module.v"
# module_name = "ExampleModule"
# report = generate_timing_analysis_report(verilog_file, module_name)
# print(report)
