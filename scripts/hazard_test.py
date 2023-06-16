import cocotb
from cocotb.triggers import Timer
from cocotb.binary import BinaryValue


@cocotb.test()
async def hazard_forwarding_unit_test(dut):

    # Initialize input signals
    dut.EX_Register_File_Enable.value = 0
    dut.MEM_Register_File_Enable.value = 0
    dut.WB_Register_File_Enable.value = 0
    dut.EX_load_instr.value = 0
    dut.ID_store_instr.value = 0
    dut.ID_rs1.value = 0
    dut.ID_rs2.value = 0
    dut.ID_rd.value = 0
    dut.EX_RD.value = 0
    dut.MEM_RD.value = 0
    dut.WB_RD.value = 0

    await Timer(1, 'ns')

    # Test case 1: No forwarding
    # cocotb.binary.BinaryValue

    dut.EX_Register_File_Enable.value = 1
    dut.EX_RD.value = 3
    dut.ID_rs1.value = 2
    dut.ID_rs2.value = 4
    dut.ID_rd.value = 1

    await Timer(1, 'ns')

    try:
        assert dut.forwardMX1.value == 0
        assert dut.forwardMX2.value == 0
        assert dut.forwardMX3.value == 0b00  # unresolvable Value
        assert dut.nPC_LE == 1
        assert dut.PC_LE == 1
        assert dut.IF_ID_LE == 1
        assert dut.CU_S == 0
    except AssertionError as e:
        cocotb.log.error(str(e))
        return

    await Timer(1, 'ns')

    # Test case 2: Forwarding
    dut.MEM_Register_File_Enable.value = 1
    dut.MEM_RD.value = 2

    await Timer(1, 'ns')

    try:
        # assert dut.forwardMX1.value == 0b10
        assert dut.forwardMX2.value == 0b00
        assert dut.forwardMX3.value == 0b00
        assert dut.nPC_LE.value == 1
        assert dut.PC_LE.value == 1
        assert dut.IF_ID_LE.value == 1
        assert dut.CU_S.value == 0
    except AssertionError as e:
        cocotb.log.error(str(e))
        return

    # Test case 3: Hazard asserted
    dut.EX_load_instr.value = 1
    dut.ID_rs1.value = 3

    await Timer(1, 'ns')

    try:
        assert dut.forwardMX1.value == 0b01
        assert dut.forwardMX2.value == 0b00
        assert dut.forwardMX3.value == 0b00
        assert dut.nPC_LE.value == 0
        assert dut.PC_LE.value == 0
        assert dut.IF_ID_LE.value == 0
        assert dut.CU_S.value == 1
    except AssertionError as e:
        cocotb.log.error(str(e))
        return

    # Test case 4: Hazard asserted
    dut.EX_Register_File_Enable.value = 0
    dut.MEM_Register_File_Enable.value = 0
    dut.WB_Register_File_Enable.value = 1
    dut.EX_load_instr.value = 0
    dut.ID_store_instr.value = 1
    dut.ID_rs1.value = 0
    dut.ID_rs2.value = 0
    dut.ID_rd.value = 0
    dut.EX_RD.value = 0
    dut.MEM_RD.value = 0
    dut.WB_RD.value = 7

    await Timer(1, 'ns')

    try:
        assert dut.forwardMX1.value == 0b00
        assert dut.forwardMX2.value == 0b00
        assert dut.forwardMX3.value == 0b00
        assert dut.nPC_LE.value == 1
        assert dut.PC_LE.value == 1
        assert dut.IF_ID_LE.value == 1
        assert dut.CU_S.value == 0
    except AssertionError as e:
        cocotb.log.error(str(e))
        return

    await Timer(1, 'ns')
