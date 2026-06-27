 
****************************************
Report : resources
Design : DCCPU
Version: T-2022.03
Date   : Wed May  6 12:37:12 2026
****************************************


Resource Report for this hierarchy in file ../01_RTL/DCCPU.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| eq_x_1         | DW_cmp         | width=10   | eq_521 (DCCPU.v:521)       |
| eq_x_2         | DW_cmp         | width=10   | eq_522 (DCCPU.v:522)       |
| eq_x_3         | DW_cmp         | width=10   | eq_523 (DCCPU.v:523)       |
| eq_x_4         | DW_cmp         | width=10   | eq_524 (DCCPU.v:524)       |
| eq_x_5         | DW_cmp         | width=10   | eq_532 (DCCPU.v:532)       |
| eq_x_6         | DW_cmp         | width=10   | eq_533 (DCCPU.v:533)       |
| eq_x_7         | DW_cmp         | width=10   | eq_534 (DCCPU.v:534)       |
| eq_x_8         | DW_cmp         | width=10   | eq_535 (DCCPU.v:535)       |
| add_x_213      | DW01_add       | width=17   | u_mult/add_1041 (DCCPU.v:1041) |
| sub_x_214      | DW01_sub       | width=17   | u_mult/sub_1042 (DCCPU.v:1042) |
| add_x_216      | DW01_inc       | width=5    | u_mult/add_1070 (DCCPU.v:1070) |
| eq_x_230       | DW_cmp         | width=16   | u_alu/eq_1175 (DCCPU.v:1175) |
| add_x_63       | DW01_inc       | width=3    | add_760_S2 (DCCPU.v:760)   |
|                |                |            | add_761_S2 (DCCPU.v:761)   |
| DP_OP_326J1_122_1582            |            |                            |
|                | DP_OP_326J1_122_1582 |      |                            |
=============================================================================

Datapath Report for DP_OP_326J1_122_1582
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_326J1_122_1582 | add_992 (DCCPU.v:992) u_alu/add_1144 (DCCPU.v:1144) |
|                      | u_alu/C345 (DCCPU.v:1148)                           |
|                      | u_alu/add_1152 (DCCPU.v:1152)                       |
|                      | u_alu/add_1152_2 (DCCPU.v:1152)                     |
|                      | u_alu/add_1177 (DCCPU.v:1177)                       |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 16    |                                          |
| I2    | PI   | Unsigned | 1     |                                          |
| I3    | PI   | Unsigned | 16    |                                          |
| I4    | PI   | Unsigned | 1     |                                          |
| I5    | PI   | Unsigned | 16    |                                          |
| I6    | PI   | Unsigned | 1     |                                          |
| T225  | IFO  | Unsigned | 16    | { I2, I4 } ? O1 : I3 (DCCPU.v:1148)      |
| T321  | IFO  | Signed   | 16    | O2 << 1                                  |
| O1    | PO   | Unsigned | 16    | I1 + $unsigned(2'b10) ( DCCPU.v:992 DCCPU.v:1144 ) |
| O2    | PO   | Unsigned | 16    | T225 + I5 + I6 (DCCPU.v:1152)            |
| O3    | PO   | Unsigned | 16    | $unsigned(13'b1000000000000) + T321 (DCCPU.v:1177) |
==============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| eq_x_1             | DW_cmp           | apparch (area)     |                |
| eq_x_2             | DW_cmp           | apparch (area)     |                |
| eq_x_3             | DW_cmp           | apparch (area)     |                |
| eq_x_4             | DW_cmp           | apparch (area)     |                |
| eq_x_5             | DW_cmp           | apparch (area)     |                |
| eq_x_6             | DW_cmp           | apparch (area)     |                |
| eq_x_7             | DW_cmp           | apparch (area)     |                |
| eq_x_8             | DW_cmp           | apparch (area)     |                |
| add_x_213          | DW01_add         | pparch (area,speed)                 |
| sub_x_214          | DW01_sub         | pparch (area,speed)                 |
| add_x_216          | DW01_inc         | apparch (area)     |                |
| eq_x_230           | DW_cmp           | apparch (area)     |                |
| add_x_63           | DW01_inc         | apparch (area)     |                |
| DP_OP_326J1_122_1582                  |                    |                |
|                    | DP_OP_326J1_122_1582 | str (area,speed)                |
===============================================================================

1
