import re
import csv

# ====== Đường dẫn file ====== #
input_file  = "/home/noname/Documents/project_tiny/Floating_point/Verision1/03_verif/TopModule/QuestaSim/tb_FPU_unit.log"   # file chứa các dòng log
output_file = "./fpu_data.csv"  # file csv kết quả

# ====== Regex mẫu để bắt dữ liệu ====== #
pattern = re.compile(
    r"i_32_a=.*?\(([-\d\.]+)\).*?([+-]).*?i_32_b=.*?\(([-\d\.]+)\).*?o_32_s=.*?\(([-\d\.]+)\)"
)

# ====== Danh sách kết quả ====== #
data_rows = []

# ====== Đọc file log ====== #
with open(input_file, "r") as f:
    for line in f:
        match = pattern.search(line)
        if match:
            i32a_val = float(match.group(1))  # giá trị i_32_a trong ()
            sign     = 0 if match.group(2) == '+' else 1  # '+' → 0, '-' → 1
            i32b_val = float(match.group(3))  # giá trị i_32_b trong ()
            o32s_val = float(match.group(4))  # giá trị o_32_s trong ()
            data_rows.append([i32a_val, sign, i32b_val, o32s_val])

# ====== Ghi ra file CSV ====== #
with open(output_file, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["i_32_a", "sign", "i_32_b", "o_32_s"])  # header
    writer.writerows(data_rows)

print(f"[PASS] Extracted {len(data_rows)} rows to '{output_file}'")
