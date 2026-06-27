import sys
import numpy as np
import struct
import random

def float_to_hex(f):
    return format(struct.unpack('<I', struct.pack('<f', np.float32(f)))[0], '08x')

def activate(x, mode):
    x = np.float32(x)
    if mode == 0:   
        return np.float32(1.0) / (np.float32(1.0) + np.exp(np.float32(-x)).astype(np.float32))
    elif mode == 1: 
        # Tanh 面積優化公式
        two_x = np.float32(np.float32(2.0) * x)
        exp_2x = np.exp(two_x).astype(np.float32)
        den = np.float32(exp_2x + np.float32(1.0))
        frac = np.float32(np.float32(2.0) / den)
        return np.float32(np.float32(1.0) - frac)
    elif mode == 2: 
        return np.maximum(np.float32(0.0), x).astype(np.float32)
    elif mode == 3:
        out = np.where(x > np.float32(0.0), x, np.float32(0.125) * x)
        threshold = np.float32(-(2.0 ** -123)) 
        return np.where((x <= np.float32(0.0)) & (x > threshold), np.float32(0.0), out).astype(np.float32)

def pad_image(img, pad_mode):
    mode_str = 'constant' if pad_mode == 0 else 'edge'
    return np.pad(img, ((0, 0), (1, 1), (1, 1)), mode=mode_str).astype(np.float32)

def conv2d_with_check(img, weight):
    """
    執行卷積並檢查是否發生災難性抵消(Catastrophic Cancellation)。
    回傳: (運算結果, 是否有歧義的布林值)
    """
    out_c, in_c, _, _ = weight.shape
    h, w = img.shape[1] - 2, img.shape[2] - 2
    out = np.zeros((out_c, h, w), dtype=np.float32)
    is_ambiguous = False

    for oc in range(out_c):
        for i in range(h):
            for j in range(w):
                # 擷取 18 個乘積項 (2 Input Channels * 3x3)
                mult = np.float32(img[:, i:i+3, j:j+3] * weight[oc, :])
                
                # 算法 A：線性平坦相加 (Flattened Accumulation)
                sum_flat = np.sum(mult, dtype=np.float32)
                
                # 算法 B：通道分離相加 (Channel-Separated Accumulation)
                sum_c0 = np.sum(mult[0], dtype=np.float32)
                sum_c1 = np.sum(mult[1], dtype=np.float32)
                sum_tree = np.float32(sum_c0 + sum_c1)
                
                # 🌟 核心修正：只有當數值「不是極小值」時，才去嚴格計算相對誤差！
                if abs(sum_flat) > 1e-4: 
                    err = abs((sum_flat - sum_tree) / sum_flat)
                    if err > 0.001:
                        is_ambiguous = True

                out[oc, i, j] = sum_flat
                
    return out, is_ambiguous

def max_pool2d(img):
    c, h, w = img.shape
    out = np.zeros((c, h//2, w//2), dtype=np.float32)
    switch = np.zeros((c, h//2, w//2), dtype=int)
    is_tie = False # 平手標記
    
    for ch in range(c):
        for i in range(h//2):
            for j in range(w//2):
                window = img[ch, i*2:i*2+2, j*2:j*2+2]
                max_val = np.max(window)
                
                if np.sum(window == max_val) > 1:
                    is_tie = True
                    
                out[ch, i, j] = max_val
                switch[ch, i, j] = np.argmax(window) 
    return out, switch, is_tie

def unpool2d(img, switch):
    c, h, w = img.shape
    out = np.zeros((c, h*2, w*2), dtype=np.float32)
    for ch in range(c):
        for i in range(h):
            for j in range(w):
                val, idx = img[ch, i, j], switch[ch, i, j]
                out[ch, i*2 + (idx // 2), j*2 + (idx % 2)] = val
    return out

def parse_weights(flat, start):
    seg = flat[start:start+36]
    w = np.zeros((2, 2, 3, 3), dtype=np.float32)
    for oc in range(2):
        w[oc, 0] = seg[oc*18 + 0 : oc*18 + 9 ].reshape(3, 3) 
        w[oc, 1] = seg[oc*18 + 9 : oc*18 + 18].reshape(3, 3) 
    return w

def print_tensor(name, tensor, is_int=False):
    print(f"\033[0;32m--- {name} ---\033[m")
    for c in range(tensor.shape[0]):
        print(f"Channel {c}:")
        for r in range(tensor.shape[1]):
            if is_int:
                row_str = " ".join([f"{int(val):2d}" for val in tensor[c, r]])
            else:
                row_str = " ".join([f"{val:10.6f}" for val in tensor[c, r]])
            print(f"[{row_str}]")
    print("")

def generate_patterns(num_patterns, seed=42, debug_target=-1):
    random.seed(seed)
    np.random.seed(seed)

    if debug_target == -1:
        f_in = open("input.txt", "w")
        f_in.write(f"{num_patterns}\n\n")

    p = 0
    discard_count = 0
    
    while p < num_patterns:
        pad_mode = random.randint(0, 1)
        act_mode = random.randint(0, 3)
        inst_val = (pad_mode << 2) | act_mode

        if p < 5:
            # 測試除以極小值 (Min-Max Scaling)
            weights_flat = np.random.uniform(-1.0, 1.0, 144).astype(np.float32)
            images_flat = np.random.uniform(1.0, 1.000001, 128).astype(np.float32)
        elif p >= 5 and p < 10:
            # 確保 weight 範圍合乎 Spec [-1.0, 1.0]
            weights_flat = np.random.uniform(-1.0, 1.0, 144).astype(np.float32)
            images_flat = np.random.uniform(-127.0, 127.0, 128).astype(np.float32)
        elif p >= 10 and p < 15:
            # 稀疏矩陣與平手測資
            weights_flat = np.random.choice([-0.5, 0.0, 0.5], 144).astype(np.float32)
            images_flat = np.random.choice([-10.0, 0.0, 10.0], 128).astype(np.float32)
        else:
            # 常規測資
            weights_flat = np.random.uniform(-1.0, 1.0, 144).astype(np.float32)
            images_int  = np.random.randint(-127, 129, 128)
            images_flat = images_int.astype(np.float32)

        # 只要是生成階段，或是被指定的 Debug 目標，就開始算
        if debug_target == -1 or debug_target == p:
            w0, w1, w2, w3 = parse_weights(weights_flat, 0), parse_weights(weights_flat, 36), parse_weights(weights_flat, 72), parse_weights(weights_flat, 108)
            img_tensor = images_flat.reshape(2, 8, 8).copy()

            for c in range(2):
                c_min = np.float32(np.min(img_tensor[c]))
                c_max = np.float32(np.max(img_tensor[c]))
                if c_max == c_min: c_max = np.float32(c_max + 1e-5)
                diff = np.float32(c_max - c_min)
                img_tensor[c] = np.float32(np.float32(img_tensor[c] - c_min) / diff)

            if debug_target == p:
                print(f"\n\033[0;33m============================================================\033[m")
                print(f"\033[0;33m  [DEBUG] DEBUGGING PATTERN {p}\033[m")
                print(f"\033[0;33m============================================================\033[m")
                print(f"Instruction: Padding={pad_mode}, Activation={act_mode}")

                # 👇👇👇 請在這裡插入這段程式碼 👇👇👇
                print("\033[0;36m--- Raw Input Image (Hex sent to RTL) ---\033[m")
                raw_img_3d = images_flat.reshape(2, 8, 8)
                for ch in range(2):
                    print(f"Channel {ch}:")
                    for r in range(8):
                        row_hex = " ".join([float_to_hex(val) for val in raw_img_3d[ch, r]])
                        print(f"[{row_hex}]")
                print("")
                # 👆👆👆 插入結束 👆👆👆

                print_tensor("00. Normalized Input Image (8x8)", img_tensor)

            # --- Layer 0 ---
            fm_pad = pad_image(img_tensor, pad_mode)
            fm_conv0, is_ambig_0 = conv2d_with_check(fm_pad, w0)
            fm_pool0, sw0, is_tie_0 = max_pool2d(fm_conv0) 
            fm_act0 = activate(fm_pool0, act_mode)

            # --- Layer 1 ---
            fm_pad = pad_image(fm_act0, pad_mode)
            fm_conv1, is_ambig_1 = conv2d_with_check(fm_pad, w1)
            fm_pool1, sw1, is_tie_1 = max_pool2d(fm_conv1) 
            fm_act1 = activate(fm_pool1, act_mode)

            # --- Layer 2 ---
            fm_unpool2 = unpool2d(fm_act1, sw1)
            fm_pad = pad_image(fm_unpool2, pad_mode)
            fm_conv2, is_ambig_2 = conv2d_with_check(fm_pad, w2)
            fm_act2 = activate(fm_conv2, act_mode)

            # --- Layer 3 ---
            fm_unpool3 = unpool2d(fm_act2, sw0)
            fm_pad = pad_image(fm_unpool3, pad_mode)
            fm_conv3, is_ambig_3 = conv2d_with_check(fm_pad, w3)
            fm_final = activate(fm_conv3, act_mode)

            # [捨棄重抽判定] 
            is_tiny_value = False
            flat_final = fm_final.flatten()
            if np.any((np.abs(flat_final) > 0) & (np.abs(flat_final) < 1e-5)):
                is_tiny_value = True

            # 若出現卷積加法歧義，直接捨棄重抽 (注意這裡沒有 p += 1)
            if (is_ambig_0 or is_ambig_1 or is_ambig_2 or is_ambig_3 or is_tiny_value or is_tie_0 or is_tie_1) and debug_target == -1:
                discard_count += 1
                continue

            # 存活下來的測資，判定要不要印出 Debug 資訊
            if debug_target == p:
                print_tensor("01. Layer 0 Conv Output (8x8)", fm_conv0)
                print_tensor("14. Final Output (Activation3) (8x8)", fm_final)
                print(f"\033[0;33m============================================================\033[m\n")
                return # Debug 結束直接離開

            # 🌟 被你刪掉的「寫檔邏輯」補回來了！
            if debug_target == -1:
                f_in.write(f"{inst_val:08x}\n")
                for wv in weights_flat: f_in.write(f"{float_to_hex(wv)}\n")
                for iv in images_flat:  f_in.write(f"{float_to_hex(iv)}\n")
                
                golden_outputs = fm_final.flatten()
                for g in golden_outputs: f_in.write(f"{float_to_hex(g)}\n")
                f_in.write("\n")
                
                if (p + 1) % 100 == 0: 
                    print(f"  Pattern {p + 1:4d} generated.")

        # 🌟 最重要的一行：成功生成並寫入後，p 才會加 1！
        p += 1 

    # 迴圈結束後關閉檔案
    if debug_target == -1:
        f_in.close()
        print(f"\n[SUCCESS] Generated {num_patterns} stable patterns to input.txt!")
        print(f"[INFO] Filtered and discarded {discard_count} ambiguous patterns during generation.")

if __name__ == "__main__":
    import sys
    
    num_patterns = 1000
    seed_val = 42
    target = -1
    
    if len(sys.argv) >= 3:
        num_patterns = int(sys.argv[1])
        seed_val = int(sys.argv[2])
    if len(sys.argv) >= 4:
        target = int(sys.argv[3])

    if target != -1:
        generate_patterns(num_patterns, seed=seed_val, debug_target=target)
    else:
        generate_patterns(num_patterns, seed=seed_val)