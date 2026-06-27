#!/bin/bash

# 測試 IP_WIDTH 從 3 到 8
for w in {2..8}
do
    echo "=================================================="
    echo "🚀 RUNNING SIMULATION FOR IP_WIDTH = $w"
    echo "=================================================="
    
    # 執行 VCS，並加上 +define+WIDTH_MACRO=$w 將參數傳入
    vcs -R -sverilog +v2k ../00_TESTBED/TESTBED_IP.v -full64 -debug_access+all +define+RTL +define+WIDTH_MACRO=$w
    
    echo ""
done

echo "🎉 All simulations finished!"
