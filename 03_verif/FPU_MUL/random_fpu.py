import random
import struct

def float_to_hex(f):
    """Chuyển float sang mã IEEE-754 32-bit dạng HEX (8 ký tự, không có '0x')"""
    bits = struct.unpack('>I', struct.pack('>f', f))[0]
    return f"{bits:08X}"

# ====== Cấu hình ====== #
min_val = float(input("Input Min float value: "))
max_val = float(input("Input Max float value: "))
number  = int(input("Input Number of Elements: "))

# ====== Sinh ngẫu nhiên các số float ====== #
floats = [random.uniform(min_val, max_val) for _ in range(number)]

# ====== Chuyển đổi sang HEX IEEE754 ====== #
hex_list = [float_to_hex(f) for f in floats]

# ====== Lưu vào file ====== #
file_path = "./FPU_list.txt"
with open(file_path, "w") as f:
    for h_val in hex_list:
        f.write(f"{h_val}\n")

print(f"[PASS] Generated {number} random IEEE754 32-bit HEX floats in {file_path}")
