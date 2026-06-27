# gen_rom.py
# 假設你的 lsc_gain_map.txt 依序存放 R, Gr, Gb, B 各 36 個數值 (總共 144 個)
with open("lsc_gain_map.txt", "r") as f:
    words = f.read().split()

channels = ['R', 'Gr', 'Gb', 'B']

for c, ch in enumerate(channels):
    print(f"// ====== Gain {ch} ======")
    for i in range(36):
        # 取得對應的數值並轉為 Verilog 格式
        val = words[c*36 + i]
        print(f"assign gain_{ch}[{i}] = 12'd{val};")
    print("")