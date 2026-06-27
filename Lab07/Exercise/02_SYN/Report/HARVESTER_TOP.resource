 
****************************************
Report : resources
Design : HARVESTER_TOP
Version: T-2022.03
Date   : Sun Apr 26 21:09:33 2026
****************************************


Resource Report for this hierarchy in file ../01_RTL/DESIGN_module.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_1        | DW01_inc       | width=3    | u_input_output/add_59 (DESIGN_module.v:59) |
| lt_x_6         | DW_cmp         | width=3    | u_input_output/lt_75 (DESIGN_module.v:75) |
| add_x_7        | DW01_inc       | width=3    | u_input_output/add_82 (DESIGN_module.v:82) |
| add_x_16       | DW01_inc       | width=5    | u_input_output/add_96 (DESIGN_module.v:96) |
| sub_x_17       | DW01_dec       | width=5    | u_input_output/sub_98 (DESIGN_module.v:98) |
| add_x_29       | DW01_add       | width=7    | u_FIFO_syn_output/add_57 (FIFO_syn.v:57) |
| add_x_30       | DW01_add       | width=7    | u_FIFO_syn_output/add_58 (FIFO_syn.v:58) |
| eq_x_31        | DW_cmp         | width=7    | u_FIFO_syn_output/eq_74 (FIFO_syn.v:74) |
| eq_x_32        | DW_cmp         | width=7    | u_FIFO_syn_output/eq_95 (FIFO_syn.v:95) |
| gt_x_33        | DW_cmp         | width=2    | u_DRAM_SYS/gt_715 (DESIGN_module.v:715) |
| add_x_66       | DW01_add       | width=3    | u_DRAM_SYS/add_717 (DESIGN_module.v:717) |
| add_x_67       | DW01_inc       | width=2    | u_DRAM_SYS/add_736 (DESIGN_module.v:736) |
| sub_x_68       | DW01_dec       | width=2    | u_DRAM_SYS/sub_738 (DESIGN_module.v:738) |
| add_x_69       | DW01_inc       | width=2    | u_DRAM_SYS/add_744 (DESIGN_module.v:744) |
| sub_x_70       | DW01_dec       | width=2    | u_DRAM_SYS/sub_746 (DESIGN_module.v:746) |
| add_x_105      | DW01_add       | width=7    | u_FIFO_syn_R/add_57 (FIFO_syn.v:57) |
| add_x_106      | DW01_add       | width=7    | u_FIFO_syn_R/add_58 (FIFO_syn.v:58) |
| eq_x_107       | DW_cmp         | width=7    | u_FIFO_syn_R/eq_74 (FIFO_syn.v:74) |
| eq_x_108       | DW_cmp         | width=7    | u_FIFO_syn_R/eq_95 (FIFO_syn.v:95) |
| add_x_109      | DW01_add       | width=7    | u_FIFO_syn_AR/add_57 (FIFO_syn.v:57) |
| add_x_110      | DW01_add       | width=7    | u_FIFO_syn_AR/add_58 (FIFO_syn.v:58) |
| eq_x_111       | DW_cmp         | width=7    | u_FIFO_syn_AR/eq_74 (FIFO_syn.v:74) |
| eq_x_112       | DW_cmp         | width=7    | u_FIFO_syn_AR/eq_95 (FIFO_syn.v:95) |
| eq_x_113       | DW_cmp         | width=6    | u_DRAM_SYS/eq_790 (DESIGN_module.v:790) |
    |                |            | u_DRAM_SYS/eq_822 (DESIGN_module.v:822) |
| sub_x_80       | DW01_dec       | width=3    | u_DRAM_SYS/sub_805 (DESIGN_module.v:805) |
   |                |            | u_DRAM_SYS/sub_840 (DESIGN_module.v:840) |
| DP_OP_422_127_2777              |            |                            |
|                | DP_OP_422_127_2777 |        |                            |
=============================================================================

Datapath Report for DP_OP_422_127_2777
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_422_127_2777   | add_502 (DESIGN_module.v:502)                       |
|                      | sub_503_2 (DESIGN_module.v:503)                     |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Signed   | 64    |                                          |
| I2    | PI   | Signed   | 64    |                                          |
| I3    | PI   | Unsigned | 1     |                                          |
| O1    | PO   | Signed   | 64    | addsub(I1,I2,I3) ( DESIGN_module.v:502 DESIGN_module.v:503 ) |
==============================================================================


Resource Report for Ungrouped Hierarchy u_HARVESTER in file
        ../01_RTL/DESIGN_module.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_1        | DW01_add       | width=3    | add_227 (DESIGN_module.v:227) |
| lt_x_130       | DW_cmp         | width=5    | lt_246 (DESIGN_module.v:246) |
| add_x_160      | DW01_inc       | width=3    | add_406 (DESIGN_module.v:406) |
| add_x_161      | DW01_inc       | width=3    | add_417 (DESIGN_module.v:417) |
| add_x_181      | DW01_inc       | width=4    | add_490 (DESIGN_module.v:490) |
| ashr_183       | DW_rightsh     | A_width=64 | sra_505 (DESIGN_module.v:505) |
              |                | SH_width=6 |                            |
| add_x_199      | DW01_inc       | width=11   | add_537 (DESIGN_module.v:537) |
| add_x_200      | DW01_inc       | width=11   | add_539 (DESIGN_module.v:539) |
| add_x_201      | DW01_add       | width=42   | add_541 (DESIGN_module.v:541) |
| add_x_202      | DW01_inc       | width=11   | add_542 (DESIGN_module.v:542) |
| add_x_203      | DW01_add       | width=73   | add_543 (DESIGN_module.v:543) |
| add_x_243      | DW01_inc       | width=2    | add_590 (DESIGN_module.v:590) |
| sub_x_244      | DW01_dec       | width=2    | sub_592 (DESIGN_module.v:592) |
| add_x_245      | DW01_inc       | width=2    | add_611 (DESIGN_module.v:611) |
| sub_x_246      | DW01_dec       | width=2    | sub_613 (DESIGN_module.v:613) |
| add_x_247      | DW01_inc       | width=5    | add_623 (DESIGN_module.v:623) |
| sub_x_248      | DW01_dec       | width=5    | sub_625 (DESIGN_module.v:625) |
| gt_x_260       | DW_cmp         | width=4    | gt_352 (DESIGN_module.v:352) |
               |                |            | gt_493 (DESIGN_module.v:493) |
| lt_x_261       | DW_cmp         | width=3    | lt_416 (DESIGN_module.v:416) |
               |                |            | lt_431 (DESIGN_module.v:431) |
               |                |            | lt_479 (DESIGN_module.v:479) |
| sub_x_131      | DW01_dec       | width=3    | sub_286 (DESIGN_module.v:286) |
              |                |            | sub_352 (DESIGN_module.v:352) |
              |                |            | sub_354 (DESIGN_module.v:354) |
              |                |            | sub_453 (DESIGN_module.v:453) |
              |                |            | sub_455 (DESIGN_module.v:455) |
              |                |            | sub_494 (DESIGN_module.v:494) |
              |                |            | sub_501 (DESIGN_module.v:501) |
              |                |            | sub_502 (DESIGN_module.v:502) |
              |                |            | sub_503 (DESIGN_module.v:503) |
              |                |            | sub_505 (DESIGN_module.v:505) |
| sub_x_182      | DW01_dec       | width=5    | sub_496 (DESIGN_module.v:496) |
              |                |            | sub_497 (DESIGN_module.v:497) |
              |                |            | sub_507 (DESIGN_module.v:507) |
| DP_OP_418J1_122_7089            |            |                            |
|                | DP_OP_418J1_122_7089 |      |                            |
| DP_OP_419J1_123_6733            |            |                            |
|                | DP_OP_419J1_123_6733 |      |                            |
=============================================================================

Datapath Report for DP_OP_418J1_122_7089
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_418J1_122_7089 | mult_296 (DESIGN_module.v:296)                      |
|                      | lte_298 (DESIGN_module.v:298)                       |
|                      | sub_530 (DESIGN_module.v:530)                       |
|                      | mult_284 (DESIGN_module.v:284)                      |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Signed   | 64    |                                          |
| I2    | PI   | Signed   | 64    |                                          |
| I3    | PI   | Signed   | 86    |                                          |
| I4    | PI   | Unsigned | 11    |                                          |
| I5    | PI   | Unsigned | 73    |                                          |
| T67   | IFO  | Unsigned | 86    | I4 * I5 (DESIGN_module.v:284)            |
| T387  | IFO  | Signed   | 86    | O1[85:0]                                 |
| O1    | PO   | Signed   | 128   | I1 * I2 (DESIGN_module.v:296)            |
| O2    | PO   | Signed   | 1     | O1 <= I3 (DESIGN_module.v:298)           |
| O3    | PO   | Signed   | 86    | T67 - T387 (DESIGN_module.v:530)         |
==============================================================================

Datapath Report for DP_OP_419J1_123_6733
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_419J1_123_6733 | mult_283 (DESIGN_module.v:283)                      |
|                      | sub_554 (DESIGN_module.v:554)                       |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 11    |                                          |
| I2    | PI   | Unsigned | 31    |                                          |
| I3    | PI   | Unsigned | 42    |                                          |
| T66   | IFO  | Unsigned | 42    | I1 * I2 (DESIGN_module.v:283)            |
| O1    | PO   | Signed   | 43    | T66 - I3 (DESIGN_module.v:554)           |
==============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_x_1            | DW01_inc         | apparch (area)     |                |
| lt_x_6             | DW_cmp           | apparch (area)     |                |
| add_x_7            | DW01_inc         | apparch (area)     |                |
| add_x_16           | DW01_inc         | apparch (area)     |                |
| sub_x_17           | DW01_dec         | apparch (area)     |                |
| add_x_29           | DW01_add         | apparch (area)     |                |
| add_x_30           | DW01_add         | apparch (area)     |                |
| eq_x_31            | DW_cmp           | apparch (area)     |                |
| eq_x_32            | DW_cmp           | apparch (area)     |                |
| gt_x_33            | DW_cmp           | apparch (area)     |                |
| add_x_66           | DW01_add         | apparch (area)     |                |
| add_x_67           | DW01_inc         | apparch (area)     |                |
| sub_x_68           | DW01_dec         | apparch (area)     |                |
| add_x_69           | DW01_inc         | apparch (area)     |                |
| sub_x_70           | DW01_dec         | apparch (area)     |                |
| add_x_105          | DW01_add         | apparch (area)     |                |
| add_x_106          | DW01_add         | apparch (area)     |                |
| eq_x_107           | DW_cmp           | apparch (area)     |                |
| eq_x_108           | DW_cmp           | apparch (area)     |                |
| add_x_109          | DW01_add         | apparch (area)     |                |
| add_x_110          | DW01_add         | apparch (area)     |                |
| eq_x_111           | DW_cmp           | apparch (area)     |                |
| eq_x_112           | DW_cmp           | apparch (area)     |                |
| eq_x_113           | DW_cmp           | apparch (area)     |                |
| sub_x_80           | DW01_dec         | apparch (area)     |                |
| add_x_1            | DW01_add         | apparch (area)     |                |
| lt_x_130           | DW_cmp           | apparch (area)     |                |
| add_x_160          | DW01_inc         | apparch (area)     |                |
| add_x_161          | DW01_inc         | apparch (area)     |                |
| add_x_181          | DW01_inc         | apparch (area)     |                |
| ashr_183           | DW_rightsh       | astr (area)        |                |
| add_x_199          | DW01_inc         | apparch (area)     |                |
| add_x_200          | DW01_inc         | apparch (area)     |                |
| add_x_201          | DW01_add         | pparch (area,speed)                 |
| add_x_202          | DW01_inc         | apparch (area)     |                |
| add_x_203          | DW01_add         | pparch (area,speed)                 |
| add_x_243          | DW01_inc         | apparch (area)     |                |
| sub_x_244          | DW01_dec         | apparch (area)     |                |
| add_x_245          | DW01_inc         | apparch (area)     |                |
| sub_x_246          | DW01_dec         | apparch (area)     |                |
| add_x_247          | DW01_inc         | apparch (area)     |                |
| sub_x_248          | DW01_dec         | apparch (area)     |                |
| gt_x_260           | DW_cmp           | apparch (area)     |                |
| lt_x_261           | DW_cmp           | apparch (area)     |                |
| sub_x_131          | DW01_dec         | apparch (area)     |                |
| sub_x_182          | DW01_dec         | apparch (area)     |                |
| DP_OP_422_127_2777 | DP_OP_422_127_2777 | str (area,speed) |                |
| DP_OP_418J1_122_7089                  |                    |                |
|                    | DP_OP_418J1_122_7089 | str (speed)    |                |
|                    |                  | mult_arch: benc_radix4              |
|                    |                  | mult_arch: benc_radix4              |
| DP_OP_419J1_123_6733                  |                    |                |
|                    | DP_OP_419J1_123_6733 | str (area,speed)                |
|                    |                  | mult_arch: benc_radix4              |
===============================================================================

1
