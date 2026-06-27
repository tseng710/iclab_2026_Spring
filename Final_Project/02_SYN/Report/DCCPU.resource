 
****************************************
Report : resources
Design : DCCPU
Version: T-2022.03
Date   : Thu Jun 25 15:33:27 2026
****************************************


Resource Report for this hierarchy in file ../01_RTL/DCCPU.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| eq_x_3         | DW_cmp         | width=12   | eq_298 (DCCPU.v:298)       |
| eq_x_4         | DW_cmp         | width=12   | eq_302 (DCCPU.v:302)       |
| eq_x_5         | DW_cmp         | width=10   | eq_349 (DCCPU.v:349)       |
| eq_x_6         | DW_cmp         | width=10   | eq_350 (DCCPU.v:350)       |
| eq_x_7         | DW_cmp         | width=10   | eq_351 (DCCPU.v:351)       |
| eq_x_8         | DW_cmp         | width=10   | eq_352 (DCCPU.v:352)       |
| eq_x_9         | DW_cmp         | width=10   | eq_359 (DCCPU.v:359)       |
| eq_x_10        | DW_cmp         | width=10   | eq_360 (DCCPU.v:360)       |
| eq_x_11        | DW_cmp         | width=10   | eq_361 (DCCPU.v:361)       |
| eq_x_12        | DW_cmp         | width=10   | eq_362 (DCCPU.v:362)       |
| add_x_114      | DW01_inc       | width=3    | add_773_S2 (DCCPU.v:773)   |
| add_x_74       | DW01_inc       | width=3    | add_670_S2 (DCCPU.v:670)   |
|                |                |            | add_671_S2 (DCCPU.v:671)   |
| DP_OP_241J1_122_2416            |            |                            |
|                | DP_OP_241J1_122_2416 |      |                            |
| DP_OP_242J1_123_1830            |            |                            |
|                | DP_OP_242J1_123_1830 |      |                            |
=============================================================================

Datapath Report for DP_OP_241J1_122_2416
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_241J1_122_2416 | add_586 (DCCPU.v:586) add_587 (DCCPU.v:587)         |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 16    |                                          |
| I2    | PI   | Unsigned | 16    |                                          |
| O1    | PO   | Unsigned | 16    | I1 + $unsigned(2'b10) (DCCPU.v:586)      |
| O2    | PO   | Unsigned | 16    | O1 + I2 (DCCPU.v:587)                    |
==============================================================================

Datapath Report for DP_OP_242J1_123_1830
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_242J1_123_1830 | add_589 (DCCPU.v:589) add_590 (DCCPU.v:590)         |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 16    |                                          |
| I2    | PI   | Unsigned | 16    |                                          |
| O1    | PO   | Unsigned | 16    | I1 + $unsigned(13'b1000000000000) + I2 ( DCCPU.v:589 DCCPU.v:590 ) |
==============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| eq_x_3             | DW_cmp           | apparch (area)     |                |
| eq_x_4             | DW_cmp           | apparch (area)     |                |
| eq_x_5             | DW_cmp           | apparch (area)     |                |
| eq_x_6             | DW_cmp           | apparch (area)     |                |
| eq_x_7             | DW_cmp           | apparch (area)     |                |
| eq_x_8             | DW_cmp           | apparch (area)     |                |
| eq_x_9             | DW_cmp           | apparch (area)     |                |
| eq_x_10            | DW_cmp           | apparch (area)     |                |
| eq_x_11            | DW_cmp           | apparch (area)     |                |
| eq_x_12            | DW_cmp           | apparch (area)     |                |
| add_x_114          | DW01_inc         | apparch (area)     |                |
| add_x_74           | DW01_inc         | apparch (area)     |                |
| DP_OP_241J1_122_2416                  |                    |                |
|                    | DP_OP_241J1_122_2416 | str (area,speed)                |
| DP_OP_242J1_123_1830                  |                    |                |
|                    | DP_OP_242J1_123_1830 | str (area,speed)                |
===============================================================================

1
