import random
import sys

# ==========================================
# 參數設定
# ==========================================
NUM_BANKS = 4
NUM_ROWS = 64
COLS_PER_ROW = 256
MAX_DEPTH = 8 # 規格書定義的最大深度

def to_signed_31(val):
    """將數值轉換為 31-bit 有號數格式"""
    val = max(-1073741824, min(1073741823, val))
    return val & 0x7FFFFFFF

def make_leaf(val):
    """生成 Leaf Node: [63]=0, [62:32]=value, [31:0]=0"""
    return (to_signed_31(val) << 32)

def make_op(op, left, right):
    """生成 OP Node: [63]=1, [33:32]=op, [31:16]=left, [15:0]=right"""
    return (1 << 63) | (op << 32) | (left << 16) | right

def build_tree_for_row(bank, row, profile):
    memory = [0] * COLS_PER_ROW
    slots = list(range(1, COLS_PER_ROW))
    base_addr = (bank << 14) | (row << 8)
    
    # --- 極端數值設定 ---
    if profile == 'constant':
        const_val = random.randint(-50, 50)
        
    def get_val():
        if profile == 'constant': return const_val
        if profile == 'negative': return random.randint(-100000, -1)
        if profile == 'large': return random.randint(10000000, 500000000)
        return random.randint(-50, 50) # 預設小數值避免連乘導致 64-bit overflow

    def make_node(depth, is_root=False, force_leaf=False):
        addr = 0 if is_root else slots.pop(0)
        g_addr = base_addr | addr
        
        # 決定是否生成 Leaf
        # 1. 強制生成
        # 2. 達到最大深度
        # 3. 剩餘空間不夠放兩個 Child
        # 4. 隨機提早結束 (除非是 full tree)
        is_leaf = force_leaf or depth >= MAX_DEPTH or len(slots) < 2
        if not is_leaf and profile != 'full' and depth >= 3:
            if random.random() < 0.3:
                is_leaf = True
                
        if is_leaf:
            memory[addr] = make_leaf(get_val())
            return g_addr
        
        # 決定樹的偏斜方向 (Skewed)
        force_left_leaf = False
        force_right_leaf = False
        if profile == 'skewed':
            if random.random() < 0.5:
                force_left_leaf = True
            else:
                force_right_leaf = True

        # 遞迴生成左右子樹
        left_ptr = make_node(depth + 1, force_leaf=force_left_leaf)
        right_ptr = make_node(depth + 1, force_leaf=force_right_leaf)
        
        # 決定運算子 (0:+, 1:-, 2:*, 3:>>>)
        # 稍微降低乘法機率，避免 8 層全乘法超前爆掉 Verilog 64-bit 上限
        op = random.choices([0, 1, 2, 3], weights=[4, 4, 1, 3])[0]
        memory[addr] = make_op(op, left_ptr, right_ptr)
        return g_addr

    # 1. 從 Root (Address 0) 開始建構樹
    make_node(depth=1, is_root=True)
    
    # 2. 填滿剩餘的 Slots (為 GAUSS 模式準備的干擾/過濾測資)
    for s in slots:
        if random.random() < 0.7:
            memory[s] = make_leaf(get_val()) # 塞入合法的數值給 GAUSS 掃描
        else:
            memory[s] = make_op(0, 0, 0)     # 塞入 Dummy OP，GAUSS 應該要忽略它
            
    return memory

def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42
    random.seed(seed)
    print(f"[*] Generating Extreme DRAM Data (Seed: {seed})...")
    
    profiles = ['full', 'skewed', 'constant', 'negative', 'large', 'random']
    full_dram = []
    
    for bank in range(NUM_BANKS):
        for row in range(NUM_ROWS):
            # 每個 Row 隨機分配一種極端情境
            profile = random.choice(profiles)
            row_mem = build_tree_for_row(bank, row, profile)
            full_dram.extend(row_mem)
            
    # 寫出檔案
    out_file = "DRAM_init.dat"
    with open(out_file, 'w') as f:
        for val in full_dram:
            f.write(f"{val:016X}\n")
            
    print(f"[*] Done! Generated {len(full_dram)} entries to {out_file}.")
    print("[*] Profiles mixed: " + ", ".join(profiles))

if __name__ == '__main__':
    main()