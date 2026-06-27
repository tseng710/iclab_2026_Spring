 
****************************************
Report : resources
Design : OT_DESIGN
Version: T-2022.03
Date   : Sat Apr 18 22:35:46 2026
****************************************


Resource Report for this hierarchy in file ../01_RTL/OT_DESIGN.v
=============================================================================
| Cell           | Module         | Parameters | Contained Operations       |
=============================================================================
| add_x_14       | DW01_add       | width=16   | add_196 (OT_DESIGN.v:196)  |
| add_x_19       | DW01_add       | width=16   | add_218 (OT_DESIGN.v:218)  |
| sub_x_24       | DW01_dec       | width=8    | sub_222 (OT_DESIGN.v:222)  |
| gt_x_25        | DW_cmp         | width=8    | gt_236 (OT_DESIGN.v:236)   |
| gte_x_29       | DW_cmp         | width=8    | gte_244 (OT_DESIGN.v:244)  |
| gt_x_30        | DW_cmp         | width=16   | gt_252 (OT_DESIGN.v:252)   |
| gt_x_38        | DW_cmp         | width=13   | gt_194 (OT_DESIGN.v:194)   |
|                |                |            | gt_216 (OT_DESIGN.v:216)   |
|                |                |            | gt_235 (OT_DESIGN.v:235)   |
| lte_x_39       | DW_cmp         | width=13   | lte_194 (OT_DESIGN.v:194)  |
|                |                |            | lte_216 (OT_DESIGN.v:216)  |
|                |                |            | lte_235 (OT_DESIGN.v:235)  |
| add_x_6        | DW01_inc       | width=13   | add_143 (OT_DESIGN.v:143)  |
|                |                |            | add_151 (OT_DESIGN.v:151)  |
|                |                |            | add_158 (OT_DESIGN.v:158)  |
|                |                |            | add_164 (OT_DESIGN.v:164)  |
|                |                |            | add_170 (OT_DESIGN.v:170)  |
| sub_x_13       | DW01_dec       | width=14   | sub_195 (OT_DESIGN.v:195)  |
|                |                |            | sub_217 (OT_DESIGN.v:217)  |
| DP_OP_105J1_126_3253            |            |                            |
|                | DP_OP_105J1_126_3253 |      |                            |
| DP_OP_107J1_122_3030            |            |                            |
|                | DP_OP_107J1_122_3030 |      |                            |
=============================================================================

Datapath Report for DP_OP_105J1_126_3253
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_105J1_126_3253 | add_294 (OT_DESIGN.v:294) add_307 (OT_DESIGN.v:307) |
|                      | add_298 (OT_DESIGN.v:298) add_302 (OT_DESIGN.v:302) |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 12    |                                          |
| I2    | PI   | Unsigned | 12    |                                          |
| O1    | PO   | Unsigned | 12    | I1 + I2 ( OT_DESIGN.v:294 OT_DESIGN.v:298 OT_DESIGN.v:302 OT_DESIGN.v:307 ) |
==============================================================================

Datapath Report for DP_OP_107J1_122_3030
==============================================================================
| Cell                 | Contained Operations                                |
==============================================================================
| DP_OP_107J1_122_3030 | sub_244 (OT_DESIGN.v:244)                           |
|                      | sub_244_2 (OT_DESIGN.v:244)                         |
|                      | add_243 (OT_DESIGN.v:243)                           |
==============================================================================

==============================================================================
|       |      | Data     |       |                                          |
| Var   | Type | Class    | Width | Expression                               |
==============================================================================
| I1    | PI   | Unsigned | 8     |                                          |
| I2    | PI   | Unsigned | 8     |                                          |
| I3    | PI   | Unsigned | 1     |                                          |
| O1    | PO   | Signed   | 9     | addsub(I1,I2,I3) ( OT_DESIGN.v:243 OT_DESIGN.v:244 ) |
==============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_x_14           | DW01_add         | apparch (area)     |                |
| add_x_19           | DW01_add         | apparch (area)     |                |
| sub_x_24           | DW01_dec         | apparch (area)     |                |
| gt_x_25            | DW_cmp           | apparch (area)     |                |
| gte_x_29           | DW_cmp           | apparch (area)     |                |
| gt_x_30            | DW_cmp           | apparch (area)     |                |
| gt_x_38            | DW_cmp           | apparch (area)     |                |
| lte_x_39           | DW_cmp           | apparch (area)     |                |
| add_x_6            | DW01_inc         | apparch (area)     |                |
| sub_x_13           | DW01_dec         | apparch (area)     |                |
| DP_OP_105J1_126_3253                  |                    |                |
|                    | DP_OP_105J1_126_3253 | str (area)     |                |
| DP_OP_107J1_122_3030                  |                    |                |
|                    | DP_OP_107J1_122_3030 | str (area)     |                |
===============================================================================

1
