-- |-----------------------------------------------------------------------|
-- 
--              Synchronous Dual Port SRAM Compiler 
-- 
--                    UMC 0.18um Generic Logic Process 
--    __________________________________________________________________________
-- 
-- 
--        (C) Copyright 2002-2009 Faraday Technology Corp. All Rights Reserved.
-- 
--      This source code is an unpublished work belongs to Faraday Technology
--      Corp.  It is considered a trade secret and is not to be divulged or
--      used by parties who have not received written authorization from
--      Faraday Technology Corp.
-- 
--      Faraday's home page can be found at:
--      http://www.faraday-tech.com/
--     
-- ________________________________________________________________________________
-- 
--       Module Name       :  DUAL_512x128  
--       Word              :  512           
--       Bit               :  128           
--       Byte              :  1             
--       Mux               :  1             
--       Power Ring Type   :  port          
--       Power Ring Width  :  2 (um)        
--       Output Loading    :  0.05 (pf)     
--       Input Data Slew   :  0.02 (ns)     
--       Input Clock Slew  :  0.02 (ns)     
-- 
-- ________________________________________________________________________________
-- 
--       Library          : FSA0M_A
--       Memaker          : 200901.2.1
--       Date             : 2026/04/05 14:47:45
-- 
-- ________________________________________________________________________________
-- 
--
-- Warning : 
--   If customer's design viloate the set-up time or hold time criteria of 
--   synchronous SRAM, it's possible to hit the meta-stable point of 
--   latch circuit in the decoder and cause the data loss in the memory 
--   bitcell. So please follow the memory IP's spec to design your 
--   product.
--
-- |-----------------------------------------------------------------------|
--
--       Library          : FSA0M_A
--       Memaker          : 200901.2.1
--       Date             : 2026/04/05 14:47:45
--
-- |-----------------------------------------------------------------------|

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;
use std.textio.all;
use IEEE.std_logic_textio.all;

-- entity declaration --
entity DUAL_512x128 is
   generic(
      SYN_CS:      integer  := 1;
      NO_SER_TOH:  integer  := 1;
      AddressSize: integer  := 9;
      Bits:        integer  := 128;
      Words:       integer  := 512;
      Bytes:       integer  := 1;
      AspectRatio: integer  := 1;
      Tr2w:        time     := 2.605 ns;
      Tw2r:        time     := 2.152 ns;
      TOH:         time     := 0.868 ns;

      TimingChecksOn: Boolean := True;
      InstancePath: STRING := "*";
      Xon: Boolean := True;
      MsgOn: Boolean := True;


      tpd_CKA_DOA0_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA1_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA2_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA3_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA4_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA5_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA6_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA7_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA8_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA9_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA10_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA11_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA12_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA13_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA14_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA15_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA16_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA17_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA18_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA19_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA20_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA21_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA22_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA23_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA24_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA25_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA26_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA27_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA28_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA29_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA30_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA31_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA32_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA33_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA34_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA35_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA36_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA37_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA38_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA39_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA40_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA41_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA42_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA43_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA44_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA45_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA46_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA47_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA48_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA49_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA50_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA51_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA52_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA53_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA54_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA55_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA56_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA57_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA58_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA59_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA60_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA61_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA62_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA63_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA64_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA65_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA66_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA67_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA68_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA69_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA70_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA71_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA72_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA73_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA74_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA75_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA76_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA77_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA78_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA79_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA80_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA81_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA82_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA83_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA84_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA85_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA86_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA87_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA88_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA89_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA90_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA91_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA92_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA93_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA94_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA95_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA96_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA97_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA98_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA99_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA100_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA101_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA102_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA103_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA104_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA105_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA106_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA107_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA108_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA109_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA110_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA111_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA112_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA113_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA114_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA115_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA116_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA117_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA118_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA119_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA120_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA121_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA122_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA123_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA124_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA125_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA126_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKA_DOA127_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);

      tpd_CKB_DOB0_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB1_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB2_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB3_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB4_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB5_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB6_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB7_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB8_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB9_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB10_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB11_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB12_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB13_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB14_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB15_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB16_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB17_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB18_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB19_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB20_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB21_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB22_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB23_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB24_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB25_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB26_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB27_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB28_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB29_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB30_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB31_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB32_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB33_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB34_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB35_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB36_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB37_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB38_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB39_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB40_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB41_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB42_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB43_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB44_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB45_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB46_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB47_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB48_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB49_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB50_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB51_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB52_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB53_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB54_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB55_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB56_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB57_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB58_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB59_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB60_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB61_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB62_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB63_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB64_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB65_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB66_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB67_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB68_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB69_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB70_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB71_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB72_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB73_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB74_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB75_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB76_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB77_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB78_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB79_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB80_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB81_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB82_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB83_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB84_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB85_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB86_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB87_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB88_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB89_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB90_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB91_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB92_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB93_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB94_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB95_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB96_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB97_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB98_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB99_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB100_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB101_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB102_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB103_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB104_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB105_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB106_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB107_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB108_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB109_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB110_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB111_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB112_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB113_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB114_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB115_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB116_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB117_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB118_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB119_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB120_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB121_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB122_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB123_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB124_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB125_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB126_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);
      tpd_CKB_DOB127_posedge : VitalDelayType01 :=  (1.947 ns, 1.947 ns);

      tpd_OEA_DOA0    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA1    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA2    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA3    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA4    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA5    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA6    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA7    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA8    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA9    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA10    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA11    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA12    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA13    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA14    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA15    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA16    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA17    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA18    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA19    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA20    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA21    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA22    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA23    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA24    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA25    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA26    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA27    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA28    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA29    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA30    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA31    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA32    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA33    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA34    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA35    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA36    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA37    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA38    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA39    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA40    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA41    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA42    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA43    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA44    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA45    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA46    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA47    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA48    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA49    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA50    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA51    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA52    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA53    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA54    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA55    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA56    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA57    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA58    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA59    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA60    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA61    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA62    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA63    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA64    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA65    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA66    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA67    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA68    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA69    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA70    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA71    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA72    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA73    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA74    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA75    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA76    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA77    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA78    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA79    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA80    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA81    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA82    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA83    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA84    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA85    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA86    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA87    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA88    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA89    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA90    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA91    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA92    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA93    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA94    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA95    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA96    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA97    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA98    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA99    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA100    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA101    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA102    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA103    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA104    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA105    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA106    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA107    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA108    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA109    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA110    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA111    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA112    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA113    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA114    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA115    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA116    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA117    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA118    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA119    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA120    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA121    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA122    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA123    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA124    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA125    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA126    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEA_DOA127    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB0    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB1    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB2    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB3    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB4    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB5    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB6    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB7    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB8    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB9    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB10    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB11    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB12    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB13    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB14    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB15    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB16    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB17    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB18    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB19    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB20    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB21    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB22    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB23    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB24    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB25    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB26    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB27    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB28    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB29    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB30    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB31    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB32    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB33    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB34    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB35    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB36    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB37    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB38    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB39    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB40    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB41    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB42    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB43    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB44    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB45    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB46    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB47    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB48    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB49    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB50    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB51    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB52    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB53    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB54    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB55    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB56    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB57    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB58    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB59    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB60    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB61    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB62    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB63    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB64    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB65    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB66    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB67    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB68    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB69    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB70    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB71    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB72    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB73    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB74    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB75    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB76    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB77    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB78    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB79    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB80    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB81    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB82    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB83    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB84    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB85    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB86    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB87    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB88    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB89    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB90    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB91    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB92    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB93    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB94    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB95    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB96    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB97    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB98    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB99    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB100    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB101    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB102    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB103    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB104    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB105    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB106    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB107    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB108    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB109    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB110    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB111    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB112    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB113    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB114    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB115    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB116    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB117    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB118    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB119    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB120    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB121    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB122    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB123    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB124    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB125    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB126    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);
      tpd_OEB_DOB127    : VitalDelayType01Z := (1.499 ns, 1.499 ns, 0.958 ns, 1.499 ns, 0.958 ns, 1.499 ns);

      tsetup_A0_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A0_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A1_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A1_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A2_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A2_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A3_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A3_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A4_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A4_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A5_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A5_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A6_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A6_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A7_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A7_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A8_CKA_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_A8_CKA_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B0_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B0_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B1_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B1_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B2_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B2_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B3_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B3_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B4_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B4_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B5_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B5_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B6_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B6_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B7_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B7_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B8_CKB_posedge_posedge    :  VitalDelayType := 0.800 ns;
      tsetup_B8_CKB_negedge_posedge    :  VitalDelayType := 0.800 ns;
      thold_A0_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A0_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A1_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A1_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A2_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A2_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A3_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A3_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A4_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A4_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A5_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A5_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A6_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A6_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A7_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A7_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A8_CKA_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_A8_CKA_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B0_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B0_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B1_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B1_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B2_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B2_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B3_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B3_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B4_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B4_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B5_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B5_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B6_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B6_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B7_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B7_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B8_CKB_posedge_posedge     :  VitalDelayType := 0.122 ns;
      thold_B8_CKB_negedge_posedge     :  VitalDelayType := 0.122 ns;
      tsetup_DIA0_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA0_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA1_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA1_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA2_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA2_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA3_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA3_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA4_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA4_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA5_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA5_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA6_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA6_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA7_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA7_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA8_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA8_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA9_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA9_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA10_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA10_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA11_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA11_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA12_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA12_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA13_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA13_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA14_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA14_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA15_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA15_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA16_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA16_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA17_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA17_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA18_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA18_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA19_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA19_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA20_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA20_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA21_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA21_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA22_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA22_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA23_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA23_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA24_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA24_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA25_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA25_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA26_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA26_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA27_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA27_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA28_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA28_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA29_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA29_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA30_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA30_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA31_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA31_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA32_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA32_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA33_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA33_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA34_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA34_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA35_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA35_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA36_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA36_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA37_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA37_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA38_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA38_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA39_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA39_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA40_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA40_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA41_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA41_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA42_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA42_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA43_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA43_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA44_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA44_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA45_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA45_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA46_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA46_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA47_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA47_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA48_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA48_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA49_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA49_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA50_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA50_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA51_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA51_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA52_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA52_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA53_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA53_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA54_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA54_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA55_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA55_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA56_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA56_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA57_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA57_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA58_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA58_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA59_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA59_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA60_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA60_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA61_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA61_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA62_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA62_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA63_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA63_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA64_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA64_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA65_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA65_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA66_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA66_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA67_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA67_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA68_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA68_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA69_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA69_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA70_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA70_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA71_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA71_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA72_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA72_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA73_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA73_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA74_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA74_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA75_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA75_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA76_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA76_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA77_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA77_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA78_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA78_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA79_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA79_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA80_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA80_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA81_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA81_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA82_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA82_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA83_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA83_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA84_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA84_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA85_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA85_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA86_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA86_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA87_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA87_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA88_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA88_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA89_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA89_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA90_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA90_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA91_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA91_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA92_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA92_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA93_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA93_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA94_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA94_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA95_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA95_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA96_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA96_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA97_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA97_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA98_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA98_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA99_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA99_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA100_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA100_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA101_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA101_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA102_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA102_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA103_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA103_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA104_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA104_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA105_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA105_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA106_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA106_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA107_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA107_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA108_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA108_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA109_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA109_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA110_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA110_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA111_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA111_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA112_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA112_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA113_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA113_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA114_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA114_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA115_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA115_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA116_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA116_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA117_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA117_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA118_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA118_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA119_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA119_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA120_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA120_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA121_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA121_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA122_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA122_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA123_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA123_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA124_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA124_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA125_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA125_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA126_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA126_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA127_CKA_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIA127_CKA_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB0_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB0_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB1_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB1_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB2_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB2_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB3_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB3_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB4_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB4_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB5_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB5_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB6_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB6_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB7_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB7_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB8_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB8_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB9_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB9_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB10_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB10_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB11_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB11_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB12_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB12_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB13_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB13_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB14_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB14_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB15_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB15_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB16_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB16_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB17_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB17_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB18_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB18_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB19_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB19_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB20_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB20_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB21_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB21_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB22_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB22_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB23_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB23_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB24_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB24_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB25_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB25_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB26_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB26_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB27_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB27_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB28_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB28_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB29_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB29_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB30_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB30_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB31_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB31_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB32_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB32_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB33_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB33_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB34_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB34_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB35_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB35_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB36_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB36_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB37_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB37_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB38_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB38_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB39_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB39_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB40_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB40_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB41_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB41_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB42_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB42_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB43_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB43_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB44_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB44_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB45_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB45_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB46_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB46_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB47_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB47_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB48_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB48_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB49_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB49_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB50_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB50_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB51_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB51_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB52_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB52_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB53_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB53_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB54_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB54_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB55_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB55_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB56_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB56_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB57_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB57_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB58_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB58_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB59_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB59_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB60_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB60_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB61_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB61_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB62_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB62_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB63_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB63_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB64_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB64_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB65_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB65_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB66_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB66_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB67_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB67_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB68_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB68_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB69_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB69_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB70_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB70_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB71_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB71_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB72_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB72_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB73_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB73_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB74_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB74_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB75_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB75_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB76_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB76_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB77_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB77_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB78_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB78_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB79_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB79_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB80_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB80_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB81_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB81_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB82_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB82_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB83_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB83_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB84_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB84_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB85_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB85_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB86_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB86_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB87_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB87_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB88_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB88_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB89_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB89_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB90_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB90_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB91_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB91_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB92_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB92_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB93_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB93_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB94_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB94_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB95_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB95_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB96_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB96_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB97_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB97_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB98_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB98_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB99_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB99_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB100_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB100_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB101_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB101_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB102_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB102_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB103_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB103_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB104_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB104_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB105_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB105_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB106_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB106_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB107_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB107_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB108_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB108_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB109_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB109_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB110_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB110_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB111_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB111_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB112_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB112_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB113_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB113_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB114_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB114_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB115_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB115_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB116_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB116_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB117_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB117_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB118_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB118_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB119_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB119_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB120_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB120_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB121_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB121_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB122_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB122_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB123_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB123_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB124_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB124_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB125_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB125_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB126_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB126_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB127_CKB_posedge_posedge    :  VitalDelayType := 0.106 ns;
      tsetup_DIB127_CKB_negedge_posedge    :  VitalDelayType := 0.106 ns;
      thold_DIA0_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA0_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA1_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA1_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA2_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA2_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA3_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA3_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA4_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA4_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA5_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA5_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA6_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA6_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA7_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA7_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA8_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA8_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA9_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA9_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA10_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA10_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA11_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA11_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA12_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA12_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA13_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA13_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA14_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA14_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA15_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA15_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA16_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA16_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA17_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA17_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA18_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA18_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA19_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA19_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA20_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA20_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA21_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA21_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA22_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA22_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA23_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA23_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA24_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA24_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA25_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA25_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA26_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA26_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA27_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA27_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA28_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA28_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA29_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA29_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA30_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA30_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA31_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA31_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA32_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA32_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA33_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA33_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA34_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA34_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA35_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA35_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA36_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA36_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA37_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA37_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA38_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA38_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA39_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA39_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA40_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA40_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA41_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA41_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA42_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA42_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA43_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA43_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA44_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA44_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA45_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA45_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA46_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA46_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA47_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA47_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA48_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA48_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA49_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA49_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA50_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA50_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA51_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA51_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA52_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA52_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA53_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA53_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA54_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA54_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA55_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA55_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA56_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA56_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA57_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA57_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA58_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA58_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA59_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA59_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA60_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA60_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA61_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA61_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA62_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA62_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA63_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA63_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA64_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA64_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA65_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA65_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA66_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA66_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA67_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA67_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA68_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA68_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA69_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA69_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA70_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA70_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA71_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA71_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA72_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA72_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA73_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA73_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA74_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA74_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA75_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA75_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA76_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA76_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA77_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA77_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA78_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA78_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA79_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA79_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA80_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA80_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA81_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA81_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA82_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA82_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA83_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA83_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA84_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA84_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA85_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA85_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA86_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA86_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA87_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA87_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA88_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA88_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA89_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA89_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA90_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA90_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA91_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA91_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA92_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA92_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA93_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA93_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA94_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA94_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA95_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA95_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA96_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA96_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA97_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA97_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA98_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA98_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA99_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA99_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA100_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA100_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA101_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA101_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA102_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA102_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA103_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA103_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA104_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA104_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA105_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA105_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA106_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA106_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA107_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA107_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA108_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA108_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA109_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA109_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA110_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA110_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA111_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA111_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA112_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA112_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA113_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA113_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA114_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA114_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA115_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA115_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA116_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA116_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA117_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA117_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA118_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA118_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA119_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA119_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA120_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA120_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA121_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA121_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA122_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA122_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA123_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA123_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA124_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA124_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA125_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA125_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA126_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA126_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA127_CKA_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIA127_CKA_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB0_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB0_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB1_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB1_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB2_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB2_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB3_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB3_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB4_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB4_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB5_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB5_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB6_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB6_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB7_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB7_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB8_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB8_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB9_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB9_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB10_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB10_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB11_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB11_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB12_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB12_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB13_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB13_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB14_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB14_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB15_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB15_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB16_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB16_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB17_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB17_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB18_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB18_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB19_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB19_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB20_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB20_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB21_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB21_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB22_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB22_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB23_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB23_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB24_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB24_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB25_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB25_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB26_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB26_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB27_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB27_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB28_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB28_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB29_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB29_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB30_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB30_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB31_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB31_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB32_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB32_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB33_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB33_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB34_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB34_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB35_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB35_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB36_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB36_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB37_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB37_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB38_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB38_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB39_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB39_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB40_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB40_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB41_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB41_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB42_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB42_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB43_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB43_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB44_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB44_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB45_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB45_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB46_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB46_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB47_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB47_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB48_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB48_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB49_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB49_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB50_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB50_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB51_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB51_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB52_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB52_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB53_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB53_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB54_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB54_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB55_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB55_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB56_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB56_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB57_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB57_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB58_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB58_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB59_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB59_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB60_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB60_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB61_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB61_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB62_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB62_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB63_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB63_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB64_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB64_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB65_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB65_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB66_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB66_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB67_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB67_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB68_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB68_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB69_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB69_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB70_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB70_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB71_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB71_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB72_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB72_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB73_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB73_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB74_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB74_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB75_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB75_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB76_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB76_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB77_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB77_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB78_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB78_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB79_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB79_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB80_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB80_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB81_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB81_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB82_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB82_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB83_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB83_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB84_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB84_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB85_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB85_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB86_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB86_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB87_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB87_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB88_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB88_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB89_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB89_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB90_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB90_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB91_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB91_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB92_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB92_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB93_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB93_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB94_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB94_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB95_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB95_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB96_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB96_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB97_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB97_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB98_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB98_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB99_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB99_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB100_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB100_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB101_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB101_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB102_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB102_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB103_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB103_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB104_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB104_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB105_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB105_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB106_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB106_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB107_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB107_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB108_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB108_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB109_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB109_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB110_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB110_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB111_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB111_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB112_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB112_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB113_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB113_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB114_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB114_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB115_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB115_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB116_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB116_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB117_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB117_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB118_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB118_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB119_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB119_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB120_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB120_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB121_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB121_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB122_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB122_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB123_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB123_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB124_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB124_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB125_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB125_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB126_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB126_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB127_CKB_posedge_posedge     :  VitalDelayType := 0.275 ns;
      thold_DIB127_CKB_negedge_posedge     :  VitalDelayType := 0.275 ns;
      tsetup_WEAN_CKA_posedge_posedge   :  VitalDelayType := 0.418 ns;
      tsetup_WEAN_CKA_negedge_posedge   :  VitalDelayType := 0.418 ns;
      thold_WEAN_CKA_posedge_posedge    :  VitalDelayType := 0.069 ns;
      thold_WEAN_CKA_negedge_posedge    :  VitalDelayType := 0.069 ns;
      tsetup_WEBN_CKB_posedge_posedge   :  VitalDelayType := 0.418 ns;
      tsetup_WEBN_CKB_negedge_posedge   :  VitalDelayType := 0.418 ns;
      thold_WEBN_CKB_posedge_posedge    :  VitalDelayType := 0.069 ns;
      thold_WEBN_CKB_negedge_posedge    :  VitalDelayType := 0.069 ns;
      tsetup_CSA_CKA_posedge_posedge    :  VitalDelayType := 0.816 ns;
      tsetup_CSA_CKA_negedge_posedge    :  VitalDelayType := 0.816 ns;
      tsetup_CSB_CKB_posedge_posedge    :  VitalDelayType := 0.816 ns;
      tsetup_CSB_CKB_negedge_posedge    :  VitalDelayType := 0.816 ns;
      thold_CSA_CKA_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_CSA_CKA_negedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_CSB_CKB_posedge_posedge     :  VitalDelayType := 0.000 ns;
      thold_CSB_CKB_negedge_posedge     :  VitalDelayType := 0.000 ns;
      tperiod_CKA                       :  VitalDelayType := 2.605 ns;
      tperiod_CKB                       :  VitalDelayType := 2.605 ns;
      tpw_CKA_posedge                   :  VitalDelayType := 0.868 ns;
      tpw_CKB_posedge                   :  VitalDelayType := 0.868 ns;
      tpw_CKA_negedge                   :  VitalDelayType := 0.868 ns;
      tpw_CKB_negedge                   :  VitalDelayType := 0.868 ns;
      tipd_A0                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A1                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A2                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A3                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A4                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A5                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A6                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A7                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_A8                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B0                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B1                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B2                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B3                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B4                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B5                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B6                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B7                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_B8                     :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA0                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA1                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA2                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA3                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA4                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA5                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA6                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA7                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA8                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA9                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA10                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA11                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA12                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA13                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA14                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA15                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA16                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA17                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA18                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA19                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA20                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA21                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA22                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA23                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA24                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA25                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA26                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA27                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA28                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA29                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA30                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA31                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA32                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA33                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA34                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA35                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA36                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA37                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA38                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA39                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA40                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA41                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA42                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA43                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA44                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA45                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA46                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA47                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA48                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA49                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA50                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA51                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA52                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA53                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA54                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA55                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA56                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA57                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA58                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA59                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA60                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA61                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA62                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA63                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA64                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA65                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA66                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA67                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA68                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA69                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA70                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA71                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA72                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA73                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA74                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA75                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA76                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA77                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA78                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA79                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA80                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA81                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA82                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA83                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA84                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA85                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA86                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA87                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA88                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA89                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA90                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA91                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA92                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA93                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA94                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA95                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA96                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA97                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA98                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA99                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA100                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA101                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA102                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA103                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA104                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA105                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA106                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA107                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA108                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA109                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA110                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA111                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA112                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA113                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA114                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA115                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA116                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA117                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA118                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA119                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA120                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA121                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA122                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA123                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA124                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA125                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA126                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIA127                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB0                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB1                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB2                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB3                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB4                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB5                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB6                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB7                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB8                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB9                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB10                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB11                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB12                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB13                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB14                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB15                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB16                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB17                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB18                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB19                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB20                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB21                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB22                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB23                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB24                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB25                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB26                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB27                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB28                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB29                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB30                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB31                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB32                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB33                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB34                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB35                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB36                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB37                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB38                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB39                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB40                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB41                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB42                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB43                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB44                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB45                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB46                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB47                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB48                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB49                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB50                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB51                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB52                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB53                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB54                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB55                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB56                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB57                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB58                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB59                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB60                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB61                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB62                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB63                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB64                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB65                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB66                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB67                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB68                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB69                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB70                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB71                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB72                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB73                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB74                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB75                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB76                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB77                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB78                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB79                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB80                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB81                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB82                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB83                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB84                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB85                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB86                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB87                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB88                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB89                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB90                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB91                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB92                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB93                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB94                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB95                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB96                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB97                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB98                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB99                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB100                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB101                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB102                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB103                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB104                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB105                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB106                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB107                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB108                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB109                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB110                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB111                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB112                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB113                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB114                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB115                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB116                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB117                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB118                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB119                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB120                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB121                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB122                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB123                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB124                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB125                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB126                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_DIB127                    :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_WEAN                       :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_WEBN                       :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CSA                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CSB                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CKA                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_CKB                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OEA                        :  VitalDelayType01 := (0.000 ns, 0.000 ns);
      tipd_OEB                        :  VitalDelayType01 := (0.000 ns, 0.000 ns)
      );

   port(
      A0                            :   IN   std_logic;
      A1                            :   IN   std_logic;
      A2                            :   IN   std_logic;
      A3                            :   IN   std_logic;
      A4                            :   IN   std_logic;
      A5                            :   IN   std_logic;
      A6                            :   IN   std_logic;
      A7                            :   IN   std_logic;
      A8                            :   IN   std_logic;
      B0                            :   IN   std_logic;
      B1                            :   IN   std_logic;
      B2                            :   IN   std_logic;
      B3                            :   IN   std_logic;
      B4                            :   IN   std_logic;
      B5                            :   IN   std_logic;
      B6                            :   IN   std_logic;
      B7                            :   IN   std_logic;
      B8                            :   IN   std_logic;
      DOA0                        :   OUT   std_logic;
      DOA1                        :   OUT   std_logic;
      DOA2                        :   OUT   std_logic;
      DOA3                        :   OUT   std_logic;
      DOA4                        :   OUT   std_logic;
      DOA5                        :   OUT   std_logic;
      DOA6                        :   OUT   std_logic;
      DOA7                        :   OUT   std_logic;
      DOA8                        :   OUT   std_logic;
      DOA9                        :   OUT   std_logic;
      DOA10                        :   OUT   std_logic;
      DOA11                        :   OUT   std_logic;
      DOA12                        :   OUT   std_logic;
      DOA13                        :   OUT   std_logic;
      DOA14                        :   OUT   std_logic;
      DOA15                        :   OUT   std_logic;
      DOA16                        :   OUT   std_logic;
      DOA17                        :   OUT   std_logic;
      DOA18                        :   OUT   std_logic;
      DOA19                        :   OUT   std_logic;
      DOA20                        :   OUT   std_logic;
      DOA21                        :   OUT   std_logic;
      DOA22                        :   OUT   std_logic;
      DOA23                        :   OUT   std_logic;
      DOA24                        :   OUT   std_logic;
      DOA25                        :   OUT   std_logic;
      DOA26                        :   OUT   std_logic;
      DOA27                        :   OUT   std_logic;
      DOA28                        :   OUT   std_logic;
      DOA29                        :   OUT   std_logic;
      DOA30                        :   OUT   std_logic;
      DOA31                        :   OUT   std_logic;
      DOA32                        :   OUT   std_logic;
      DOA33                        :   OUT   std_logic;
      DOA34                        :   OUT   std_logic;
      DOA35                        :   OUT   std_logic;
      DOA36                        :   OUT   std_logic;
      DOA37                        :   OUT   std_logic;
      DOA38                        :   OUT   std_logic;
      DOA39                        :   OUT   std_logic;
      DOA40                        :   OUT   std_logic;
      DOA41                        :   OUT   std_logic;
      DOA42                        :   OUT   std_logic;
      DOA43                        :   OUT   std_logic;
      DOA44                        :   OUT   std_logic;
      DOA45                        :   OUT   std_logic;
      DOA46                        :   OUT   std_logic;
      DOA47                        :   OUT   std_logic;
      DOA48                        :   OUT   std_logic;
      DOA49                        :   OUT   std_logic;
      DOA50                        :   OUT   std_logic;
      DOA51                        :   OUT   std_logic;
      DOA52                        :   OUT   std_logic;
      DOA53                        :   OUT   std_logic;
      DOA54                        :   OUT   std_logic;
      DOA55                        :   OUT   std_logic;
      DOA56                        :   OUT   std_logic;
      DOA57                        :   OUT   std_logic;
      DOA58                        :   OUT   std_logic;
      DOA59                        :   OUT   std_logic;
      DOA60                        :   OUT   std_logic;
      DOA61                        :   OUT   std_logic;
      DOA62                        :   OUT   std_logic;
      DOA63                        :   OUT   std_logic;
      DOA64                        :   OUT   std_logic;
      DOA65                        :   OUT   std_logic;
      DOA66                        :   OUT   std_logic;
      DOA67                        :   OUT   std_logic;
      DOA68                        :   OUT   std_logic;
      DOA69                        :   OUT   std_logic;
      DOA70                        :   OUT   std_logic;
      DOA71                        :   OUT   std_logic;
      DOA72                        :   OUT   std_logic;
      DOA73                        :   OUT   std_logic;
      DOA74                        :   OUT   std_logic;
      DOA75                        :   OUT   std_logic;
      DOA76                        :   OUT   std_logic;
      DOA77                        :   OUT   std_logic;
      DOA78                        :   OUT   std_logic;
      DOA79                        :   OUT   std_logic;
      DOA80                        :   OUT   std_logic;
      DOA81                        :   OUT   std_logic;
      DOA82                        :   OUT   std_logic;
      DOA83                        :   OUT   std_logic;
      DOA84                        :   OUT   std_logic;
      DOA85                        :   OUT   std_logic;
      DOA86                        :   OUT   std_logic;
      DOA87                        :   OUT   std_logic;
      DOA88                        :   OUT   std_logic;
      DOA89                        :   OUT   std_logic;
      DOA90                        :   OUT   std_logic;
      DOA91                        :   OUT   std_logic;
      DOA92                        :   OUT   std_logic;
      DOA93                        :   OUT   std_logic;
      DOA94                        :   OUT   std_logic;
      DOA95                        :   OUT   std_logic;
      DOA96                        :   OUT   std_logic;
      DOA97                        :   OUT   std_logic;
      DOA98                        :   OUT   std_logic;
      DOA99                        :   OUT   std_logic;
      DOA100                        :   OUT   std_logic;
      DOA101                        :   OUT   std_logic;
      DOA102                        :   OUT   std_logic;
      DOA103                        :   OUT   std_logic;
      DOA104                        :   OUT   std_logic;
      DOA105                        :   OUT   std_logic;
      DOA106                        :   OUT   std_logic;
      DOA107                        :   OUT   std_logic;
      DOA108                        :   OUT   std_logic;
      DOA109                        :   OUT   std_logic;
      DOA110                        :   OUT   std_logic;
      DOA111                        :   OUT   std_logic;
      DOA112                        :   OUT   std_logic;
      DOA113                        :   OUT   std_logic;
      DOA114                        :   OUT   std_logic;
      DOA115                        :   OUT   std_logic;
      DOA116                        :   OUT   std_logic;
      DOA117                        :   OUT   std_logic;
      DOA118                        :   OUT   std_logic;
      DOA119                        :   OUT   std_logic;
      DOA120                        :   OUT   std_logic;
      DOA121                        :   OUT   std_logic;
      DOA122                        :   OUT   std_logic;
      DOA123                        :   OUT   std_logic;
      DOA124                        :   OUT   std_logic;
      DOA125                        :   OUT   std_logic;
      DOA126                        :   OUT   std_logic;
      DOA127                        :   OUT   std_logic;
      DOB0                        :   OUT   std_logic;
      DOB1                        :   OUT   std_logic;
      DOB2                        :   OUT   std_logic;
      DOB3                        :   OUT   std_logic;
      DOB4                        :   OUT   std_logic;
      DOB5                        :   OUT   std_logic;
      DOB6                        :   OUT   std_logic;
      DOB7                        :   OUT   std_logic;
      DOB8                        :   OUT   std_logic;
      DOB9                        :   OUT   std_logic;
      DOB10                        :   OUT   std_logic;
      DOB11                        :   OUT   std_logic;
      DOB12                        :   OUT   std_logic;
      DOB13                        :   OUT   std_logic;
      DOB14                        :   OUT   std_logic;
      DOB15                        :   OUT   std_logic;
      DOB16                        :   OUT   std_logic;
      DOB17                        :   OUT   std_logic;
      DOB18                        :   OUT   std_logic;
      DOB19                        :   OUT   std_logic;
      DOB20                        :   OUT   std_logic;
      DOB21                        :   OUT   std_logic;
      DOB22                        :   OUT   std_logic;
      DOB23                        :   OUT   std_logic;
      DOB24                        :   OUT   std_logic;
      DOB25                        :   OUT   std_logic;
      DOB26                        :   OUT   std_logic;
      DOB27                        :   OUT   std_logic;
      DOB28                        :   OUT   std_logic;
      DOB29                        :   OUT   std_logic;
      DOB30                        :   OUT   std_logic;
      DOB31                        :   OUT   std_logic;
      DOB32                        :   OUT   std_logic;
      DOB33                        :   OUT   std_logic;
      DOB34                        :   OUT   std_logic;
      DOB35                        :   OUT   std_logic;
      DOB36                        :   OUT   std_logic;
      DOB37                        :   OUT   std_logic;
      DOB38                        :   OUT   std_logic;
      DOB39                        :   OUT   std_logic;
      DOB40                        :   OUT   std_logic;
      DOB41                        :   OUT   std_logic;
      DOB42                        :   OUT   std_logic;
      DOB43                        :   OUT   std_logic;
      DOB44                        :   OUT   std_logic;
      DOB45                        :   OUT   std_logic;
      DOB46                        :   OUT   std_logic;
      DOB47                        :   OUT   std_logic;
      DOB48                        :   OUT   std_logic;
      DOB49                        :   OUT   std_logic;
      DOB50                        :   OUT   std_logic;
      DOB51                        :   OUT   std_logic;
      DOB52                        :   OUT   std_logic;
      DOB53                        :   OUT   std_logic;
      DOB54                        :   OUT   std_logic;
      DOB55                        :   OUT   std_logic;
      DOB56                        :   OUT   std_logic;
      DOB57                        :   OUT   std_logic;
      DOB58                        :   OUT   std_logic;
      DOB59                        :   OUT   std_logic;
      DOB60                        :   OUT   std_logic;
      DOB61                        :   OUT   std_logic;
      DOB62                        :   OUT   std_logic;
      DOB63                        :   OUT   std_logic;
      DOB64                        :   OUT   std_logic;
      DOB65                        :   OUT   std_logic;
      DOB66                        :   OUT   std_logic;
      DOB67                        :   OUT   std_logic;
      DOB68                        :   OUT   std_logic;
      DOB69                        :   OUT   std_logic;
      DOB70                        :   OUT   std_logic;
      DOB71                        :   OUT   std_logic;
      DOB72                        :   OUT   std_logic;
      DOB73                        :   OUT   std_logic;
      DOB74                        :   OUT   std_logic;
      DOB75                        :   OUT   std_logic;
      DOB76                        :   OUT   std_logic;
      DOB77                        :   OUT   std_logic;
      DOB78                        :   OUT   std_logic;
      DOB79                        :   OUT   std_logic;
      DOB80                        :   OUT   std_logic;
      DOB81                        :   OUT   std_logic;
      DOB82                        :   OUT   std_logic;
      DOB83                        :   OUT   std_logic;
      DOB84                        :   OUT   std_logic;
      DOB85                        :   OUT   std_logic;
      DOB86                        :   OUT   std_logic;
      DOB87                        :   OUT   std_logic;
      DOB88                        :   OUT   std_logic;
      DOB89                        :   OUT   std_logic;
      DOB90                        :   OUT   std_logic;
      DOB91                        :   OUT   std_logic;
      DOB92                        :   OUT   std_logic;
      DOB93                        :   OUT   std_logic;
      DOB94                        :   OUT   std_logic;
      DOB95                        :   OUT   std_logic;
      DOB96                        :   OUT   std_logic;
      DOB97                        :   OUT   std_logic;
      DOB98                        :   OUT   std_logic;
      DOB99                        :   OUT   std_logic;
      DOB100                        :   OUT   std_logic;
      DOB101                        :   OUT   std_logic;
      DOB102                        :   OUT   std_logic;
      DOB103                        :   OUT   std_logic;
      DOB104                        :   OUT   std_logic;
      DOB105                        :   OUT   std_logic;
      DOB106                        :   OUT   std_logic;
      DOB107                        :   OUT   std_logic;
      DOB108                        :   OUT   std_logic;
      DOB109                        :   OUT   std_logic;
      DOB110                        :   OUT   std_logic;
      DOB111                        :   OUT   std_logic;
      DOB112                        :   OUT   std_logic;
      DOB113                        :   OUT   std_logic;
      DOB114                        :   OUT   std_logic;
      DOB115                        :   OUT   std_logic;
      DOB116                        :   OUT   std_logic;
      DOB117                        :   OUT   std_logic;
      DOB118                        :   OUT   std_logic;
      DOB119                        :   OUT   std_logic;
      DOB120                        :   OUT   std_logic;
      DOB121                        :   OUT   std_logic;
      DOB122                        :   OUT   std_logic;
      DOB123                        :   OUT   std_logic;
      DOB124                        :   OUT   std_logic;
      DOB125                        :   OUT   std_logic;
      DOB126                        :   OUT   std_logic;
      DOB127                        :   OUT   std_logic;
      DIA0                        :   IN   std_logic;
      DIA1                        :   IN   std_logic;
      DIA2                        :   IN   std_logic;
      DIA3                        :   IN   std_logic;
      DIA4                        :   IN   std_logic;
      DIA5                        :   IN   std_logic;
      DIA6                        :   IN   std_logic;
      DIA7                        :   IN   std_logic;
      DIA8                        :   IN   std_logic;
      DIA9                        :   IN   std_logic;
      DIA10                        :   IN   std_logic;
      DIA11                        :   IN   std_logic;
      DIA12                        :   IN   std_logic;
      DIA13                        :   IN   std_logic;
      DIA14                        :   IN   std_logic;
      DIA15                        :   IN   std_logic;
      DIA16                        :   IN   std_logic;
      DIA17                        :   IN   std_logic;
      DIA18                        :   IN   std_logic;
      DIA19                        :   IN   std_logic;
      DIA20                        :   IN   std_logic;
      DIA21                        :   IN   std_logic;
      DIA22                        :   IN   std_logic;
      DIA23                        :   IN   std_logic;
      DIA24                        :   IN   std_logic;
      DIA25                        :   IN   std_logic;
      DIA26                        :   IN   std_logic;
      DIA27                        :   IN   std_logic;
      DIA28                        :   IN   std_logic;
      DIA29                        :   IN   std_logic;
      DIA30                        :   IN   std_logic;
      DIA31                        :   IN   std_logic;
      DIA32                        :   IN   std_logic;
      DIA33                        :   IN   std_logic;
      DIA34                        :   IN   std_logic;
      DIA35                        :   IN   std_logic;
      DIA36                        :   IN   std_logic;
      DIA37                        :   IN   std_logic;
      DIA38                        :   IN   std_logic;
      DIA39                        :   IN   std_logic;
      DIA40                        :   IN   std_logic;
      DIA41                        :   IN   std_logic;
      DIA42                        :   IN   std_logic;
      DIA43                        :   IN   std_logic;
      DIA44                        :   IN   std_logic;
      DIA45                        :   IN   std_logic;
      DIA46                        :   IN   std_logic;
      DIA47                        :   IN   std_logic;
      DIA48                        :   IN   std_logic;
      DIA49                        :   IN   std_logic;
      DIA50                        :   IN   std_logic;
      DIA51                        :   IN   std_logic;
      DIA52                        :   IN   std_logic;
      DIA53                        :   IN   std_logic;
      DIA54                        :   IN   std_logic;
      DIA55                        :   IN   std_logic;
      DIA56                        :   IN   std_logic;
      DIA57                        :   IN   std_logic;
      DIA58                        :   IN   std_logic;
      DIA59                        :   IN   std_logic;
      DIA60                        :   IN   std_logic;
      DIA61                        :   IN   std_logic;
      DIA62                        :   IN   std_logic;
      DIA63                        :   IN   std_logic;
      DIA64                        :   IN   std_logic;
      DIA65                        :   IN   std_logic;
      DIA66                        :   IN   std_logic;
      DIA67                        :   IN   std_logic;
      DIA68                        :   IN   std_logic;
      DIA69                        :   IN   std_logic;
      DIA70                        :   IN   std_logic;
      DIA71                        :   IN   std_logic;
      DIA72                        :   IN   std_logic;
      DIA73                        :   IN   std_logic;
      DIA74                        :   IN   std_logic;
      DIA75                        :   IN   std_logic;
      DIA76                        :   IN   std_logic;
      DIA77                        :   IN   std_logic;
      DIA78                        :   IN   std_logic;
      DIA79                        :   IN   std_logic;
      DIA80                        :   IN   std_logic;
      DIA81                        :   IN   std_logic;
      DIA82                        :   IN   std_logic;
      DIA83                        :   IN   std_logic;
      DIA84                        :   IN   std_logic;
      DIA85                        :   IN   std_logic;
      DIA86                        :   IN   std_logic;
      DIA87                        :   IN   std_logic;
      DIA88                        :   IN   std_logic;
      DIA89                        :   IN   std_logic;
      DIA90                        :   IN   std_logic;
      DIA91                        :   IN   std_logic;
      DIA92                        :   IN   std_logic;
      DIA93                        :   IN   std_logic;
      DIA94                        :   IN   std_logic;
      DIA95                        :   IN   std_logic;
      DIA96                        :   IN   std_logic;
      DIA97                        :   IN   std_logic;
      DIA98                        :   IN   std_logic;
      DIA99                        :   IN   std_logic;
      DIA100                        :   IN   std_logic;
      DIA101                        :   IN   std_logic;
      DIA102                        :   IN   std_logic;
      DIA103                        :   IN   std_logic;
      DIA104                        :   IN   std_logic;
      DIA105                        :   IN   std_logic;
      DIA106                        :   IN   std_logic;
      DIA107                        :   IN   std_logic;
      DIA108                        :   IN   std_logic;
      DIA109                        :   IN   std_logic;
      DIA110                        :   IN   std_logic;
      DIA111                        :   IN   std_logic;
      DIA112                        :   IN   std_logic;
      DIA113                        :   IN   std_logic;
      DIA114                        :   IN   std_logic;
      DIA115                        :   IN   std_logic;
      DIA116                        :   IN   std_logic;
      DIA117                        :   IN   std_logic;
      DIA118                        :   IN   std_logic;
      DIA119                        :   IN   std_logic;
      DIA120                        :   IN   std_logic;
      DIA121                        :   IN   std_logic;
      DIA122                        :   IN   std_logic;
      DIA123                        :   IN   std_logic;
      DIA124                        :   IN   std_logic;
      DIA125                        :   IN   std_logic;
      DIA126                        :   IN   std_logic;
      DIA127                        :   IN   std_logic;
      DIB0                        :   IN   std_logic;
      DIB1                        :   IN   std_logic;
      DIB2                        :   IN   std_logic;
      DIB3                        :   IN   std_logic;
      DIB4                        :   IN   std_logic;
      DIB5                        :   IN   std_logic;
      DIB6                        :   IN   std_logic;
      DIB7                        :   IN   std_logic;
      DIB8                        :   IN   std_logic;
      DIB9                        :   IN   std_logic;
      DIB10                        :   IN   std_logic;
      DIB11                        :   IN   std_logic;
      DIB12                        :   IN   std_logic;
      DIB13                        :   IN   std_logic;
      DIB14                        :   IN   std_logic;
      DIB15                        :   IN   std_logic;
      DIB16                        :   IN   std_logic;
      DIB17                        :   IN   std_logic;
      DIB18                        :   IN   std_logic;
      DIB19                        :   IN   std_logic;
      DIB20                        :   IN   std_logic;
      DIB21                        :   IN   std_logic;
      DIB22                        :   IN   std_logic;
      DIB23                        :   IN   std_logic;
      DIB24                        :   IN   std_logic;
      DIB25                        :   IN   std_logic;
      DIB26                        :   IN   std_logic;
      DIB27                        :   IN   std_logic;
      DIB28                        :   IN   std_logic;
      DIB29                        :   IN   std_logic;
      DIB30                        :   IN   std_logic;
      DIB31                        :   IN   std_logic;
      DIB32                        :   IN   std_logic;
      DIB33                        :   IN   std_logic;
      DIB34                        :   IN   std_logic;
      DIB35                        :   IN   std_logic;
      DIB36                        :   IN   std_logic;
      DIB37                        :   IN   std_logic;
      DIB38                        :   IN   std_logic;
      DIB39                        :   IN   std_logic;
      DIB40                        :   IN   std_logic;
      DIB41                        :   IN   std_logic;
      DIB42                        :   IN   std_logic;
      DIB43                        :   IN   std_logic;
      DIB44                        :   IN   std_logic;
      DIB45                        :   IN   std_logic;
      DIB46                        :   IN   std_logic;
      DIB47                        :   IN   std_logic;
      DIB48                        :   IN   std_logic;
      DIB49                        :   IN   std_logic;
      DIB50                        :   IN   std_logic;
      DIB51                        :   IN   std_logic;
      DIB52                        :   IN   std_logic;
      DIB53                        :   IN   std_logic;
      DIB54                        :   IN   std_logic;
      DIB55                        :   IN   std_logic;
      DIB56                        :   IN   std_logic;
      DIB57                        :   IN   std_logic;
      DIB58                        :   IN   std_logic;
      DIB59                        :   IN   std_logic;
      DIB60                        :   IN   std_logic;
      DIB61                        :   IN   std_logic;
      DIB62                        :   IN   std_logic;
      DIB63                        :   IN   std_logic;
      DIB64                        :   IN   std_logic;
      DIB65                        :   IN   std_logic;
      DIB66                        :   IN   std_logic;
      DIB67                        :   IN   std_logic;
      DIB68                        :   IN   std_logic;
      DIB69                        :   IN   std_logic;
      DIB70                        :   IN   std_logic;
      DIB71                        :   IN   std_logic;
      DIB72                        :   IN   std_logic;
      DIB73                        :   IN   std_logic;
      DIB74                        :   IN   std_logic;
      DIB75                        :   IN   std_logic;
      DIB76                        :   IN   std_logic;
      DIB77                        :   IN   std_logic;
      DIB78                        :   IN   std_logic;
      DIB79                        :   IN   std_logic;
      DIB80                        :   IN   std_logic;
      DIB81                        :   IN   std_logic;
      DIB82                        :   IN   std_logic;
      DIB83                        :   IN   std_logic;
      DIB84                        :   IN   std_logic;
      DIB85                        :   IN   std_logic;
      DIB86                        :   IN   std_logic;
      DIB87                        :   IN   std_logic;
      DIB88                        :   IN   std_logic;
      DIB89                        :   IN   std_logic;
      DIB90                        :   IN   std_logic;
      DIB91                        :   IN   std_logic;
      DIB92                        :   IN   std_logic;
      DIB93                        :   IN   std_logic;
      DIB94                        :   IN   std_logic;
      DIB95                        :   IN   std_logic;
      DIB96                        :   IN   std_logic;
      DIB97                        :   IN   std_logic;
      DIB98                        :   IN   std_logic;
      DIB99                        :   IN   std_logic;
      DIB100                        :   IN   std_logic;
      DIB101                        :   IN   std_logic;
      DIB102                        :   IN   std_logic;
      DIB103                        :   IN   std_logic;
      DIB104                        :   IN   std_logic;
      DIB105                        :   IN   std_logic;
      DIB106                        :   IN   std_logic;
      DIB107                        :   IN   std_logic;
      DIB108                        :   IN   std_logic;
      DIB109                        :   IN   std_logic;
      DIB110                        :   IN   std_logic;
      DIB111                        :   IN   std_logic;
      DIB112                        :   IN   std_logic;
      DIB113                        :   IN   std_logic;
      DIB114                        :   IN   std_logic;
      DIB115                        :   IN   std_logic;
      DIB116                        :   IN   std_logic;
      DIB117                        :   IN   std_logic;
      DIB118                        :   IN   std_logic;
      DIB119                        :   IN   std_logic;
      DIB120                        :   IN   std_logic;
      DIB121                        :   IN   std_logic;
      DIB122                        :   IN   std_logic;
      DIB123                        :   IN   std_logic;
      DIB124                        :   IN   std_logic;
      DIB125                        :   IN   std_logic;
      DIB126                        :   IN   std_logic;
      DIB127                        :   IN   std_logic;
      WEAN                           :   IN   std_logic;
      WEBN                           :   IN   std_logic;
      CKA                            :   IN   std_logic;
      CKB                            :   IN   std_logic;
      CSA                            :   IN   std_logic;
      CSB                            :   IN   std_logic;
      OEA                            :   IN   std_logic;
      OEB                            :   IN   std_logic
      );

attribute VITAL_LEVEL0 of DUAL_512x128 : entity is TRUE;

end DUAL_512x128;

-- architecture body --
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Primitives.all;
use IEEE.VITAL_Timing.all;

architecture behavior of DUAL_512x128 is
   -- attribute VITALMEMORY_LEVEL1 of behavior : architecture is TRUE;

   CONSTANT True_flg:       integer := 0;
   CONSTANT False_flg:      integer := 1;
   CONSTANT Range_flg:      integer := 2;

   FUNCTION Minimum ( CONSTANT t1, t2 : IN TIME ) RETURN TIME IS
   BEGIN
      IF (t1 < t2) THEN RETURN (t1); ELSE RETURN (t2); END IF;
   END Minimum;

   FUNCTION Maximum ( CONSTANT t1, t2 : IN TIME ) RETURN TIME IS
   BEGIN
      IF (t1 < t2) THEN RETURN (t2); ELSE RETURN (t1); END IF;
   END Maximum;

   FUNCTION BVtoI(bin: std_logic_vector) RETURN integer IS
      variable result: integer;
   BEGIN
      result := 0;
      for i in bin'range loop
         if bin(i) = '1' then
            result := result + 2**i;
         end if;
      end loop;
      return result;
   END; -- BVtoI

   PROCEDURE ScheduleOutputDelay (
       SIGNAL   OutSignal        : OUT std_logic;
       VARIABLE Data             : IN  std_logic;
       CONSTANT Delay            : IN  VitalDelayType01 := VitalDefDelay01;
       VARIABLE Previous_A       : IN  std_logic_vector(AddressSize-1 downto 0);
       VARIABLE Current_A        : IN  std_logic_vector(AddressSize-1 downto 0);
       CONSTANT NO_SER_TOH       : IN  integer
   ) IS
   BEGIN

      if (NO_SER_TOH /= 1) then
         OutSignal <= TRANSPORT 'X' AFTER TOH;
         OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
      else
         if (Current_A /= Previous_A) then
            OutSignal <= TRANSPORT 'X' AFTER TOH;
            OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
         else
            OutSignal <= TRANSPORT Data AFTER Maximum(Delay(tr10), Delay(tr01));
         end if;
      end if;
   END ScheduleOutputDelay;

   FUNCTION TO_INTEGER (
     a: std_logic_vector
   ) RETURN INTEGER IS
     VARIABLE y: INTEGER := 0;
   BEGIN
        y := 0;
        FOR i IN a'RANGE LOOP
            y := y * 2;
            IF a(i) /= '1' AND a(i) /= '0' THEN
                y := 0;
                EXIT;
            ELSIF a(i) = '1' THEN
                y := y + 1;
            END IF;
        END LOOP;
        RETURN y;
   END TO_INTEGER;

   function AddressRangeCheck(AddressItem: std_logic_vector; flag_Address: integer) return integer is
     variable Uresult : std_logic;
     variable status  : integer := 0;

   begin
      if (Bits /= 1) then
         Uresult := AddressItem(0) xor AddressItem(1);
         for i in 2 to AddressItem'length-1 loop
            Uresult := Uresult xor AddressItem(i);
         end loop;
      else
         Uresult := AddressItem(0);
      end if;

      if (Uresult = 'U') then
         status := False_flg;
      elsif (Uresult = 'X') then
         status := False_flg;
      elsif (Uresult = 'Z') then
         status := False_flg;
      else
         status := True_flg;
      end if;

      if (status=False_flg) then
        if (flag_Address = True_flg) then
           -- Generate Error Messae --
           assert FALSE report "** MEM_Error: Unknown value occurred in Address." severity WARNING;
        end if;
      end if;

      if (status=True_flg) then
         if ((BVtoI(AddressItem)) >= Words) then
             assert FALSE report "** MEM_Error: Out of range occurred in Address." severity WARNING;
             status := Range_flg;
         else
             status := True_flg;
         end if;
      end if;

      return status;
   end AddressRangeCheck;

   function CS_monitor(CSItem: std_logic; flag_CS: integer) return integer is
     variable status  : integer := 0;

   begin
      if (CSItem = 'U') then
         status := False_flg;
      elsif (CSItem = 'X') then
         status := False_flg;
      elsif (CSItem = 'Z') then
         status := False_flg;
      else
         status := True_flg;
      end if;

      if (status=False_flg) then
        if (flag_CS = True_flg) then
           -- Generate Error Messae --
           assert FALSE report "** MEM_Error: Unknown value occurred in ChipSelect." severity WARNING;
        end if;
      end if;

      return status;
   end CS_monitor;

   Type memoryArray Is array (Words-1 downto 0) Of std_logic_vector (Bits-1 downto 0);

   SIGNAL CSA_ipd        : std_logic := 'X';
   SIGNAL CSB_ipd        : std_logic := 'X';
   SIGNAL OEA_ipd        : std_logic := 'X';
   SIGNAL OEB_ipd        : std_logic := 'X';
   SIGNAL CKA_ipd        : std_logic := 'X';
   SIGNAL CKB_ipd        : std_logic := 'X';
   SIGNAL A_ipd          : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   SIGNAL B_ipd          : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   SIGNAL WEAN_ipd       : std_logic := 'X';
   SIGNAL WEBN_ipd       : std_logic := 'X';
   SIGNAL DIA_ipd        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DIB_ipd        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DOA_int        : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   SIGNAL DOB_int        : std_logic_vector(Bits-1 downto 0) := (others => 'X');

begin

   ---------------------
   --  INPUT PATH DELAYs
   ---------------------
   WireDelay : block
   begin
   VitalWireDelay (CSA_ipd, CSA, tipd_CSA);
   VitalWireDelay (CSB_ipd, CSB, tipd_CSB);
   VitalWireDelay (WEAN_ipd, WEAN, tipd_WEAN);
   VitalWireDelay (WEBN_ipd, WEBN, tipd_WEBN);
   VitalWireDelay (OEA_ipd, OEA, tipd_OEA);
   VitalWireDelay (OEB_ipd, OEB, tipd_OEB);
   VitalWireDelay (CKA_ipd, CKA, tipd_CKA);
   VitalWireDelay (CKB_ipd, CKB, tipd_CKB);
   VitalWireDelay (A_ipd(0), A0, tipd_A0);
   VitalWireDelay (A_ipd(1), A1, tipd_A1);
   VitalWireDelay (A_ipd(2), A2, tipd_A2);
   VitalWireDelay (A_ipd(3), A3, tipd_A3);
   VitalWireDelay (A_ipd(4), A4, tipd_A4);
   VitalWireDelay (A_ipd(5), A5, tipd_A5);
   VitalWireDelay (A_ipd(6), A6, tipd_A6);
   VitalWireDelay (A_ipd(7), A7, tipd_A7);
   VitalWireDelay (A_ipd(8), A8, tipd_A8);
   VitalWireDelay (B_ipd(0), B0, tipd_B0);
   VitalWireDelay (B_ipd(1), B1, tipd_B1);
   VitalWireDelay (B_ipd(2), B2, tipd_B2);
   VitalWireDelay (B_ipd(3), B3, tipd_B3);
   VitalWireDelay (B_ipd(4), B4, tipd_B4);
   VitalWireDelay (B_ipd(5), B5, tipd_B5);
   VitalWireDelay (B_ipd(6), B6, tipd_B6);
   VitalWireDelay (B_ipd(7), B7, tipd_B7);
   VitalWireDelay (B_ipd(8), B8, tipd_B8);
   VitalWireDelay (DIA_ipd(0), DIA0, tipd_DIA0);
   VitalWireDelay (DIB_ipd(0), DIB0, tipd_DIB0);
   VitalWireDelay (DIA_ipd(1), DIA1, tipd_DIA1);
   VitalWireDelay (DIB_ipd(1), DIB1, tipd_DIB1);
   VitalWireDelay (DIA_ipd(2), DIA2, tipd_DIA2);
   VitalWireDelay (DIB_ipd(2), DIB2, tipd_DIB2);
   VitalWireDelay (DIA_ipd(3), DIA3, tipd_DIA3);
   VitalWireDelay (DIB_ipd(3), DIB3, tipd_DIB3);
   VitalWireDelay (DIA_ipd(4), DIA4, tipd_DIA4);
   VitalWireDelay (DIB_ipd(4), DIB4, tipd_DIB4);
   VitalWireDelay (DIA_ipd(5), DIA5, tipd_DIA5);
   VitalWireDelay (DIB_ipd(5), DIB5, tipd_DIB5);
   VitalWireDelay (DIA_ipd(6), DIA6, tipd_DIA6);
   VitalWireDelay (DIB_ipd(6), DIB6, tipd_DIB6);
   VitalWireDelay (DIA_ipd(7), DIA7, tipd_DIA7);
   VitalWireDelay (DIB_ipd(7), DIB7, tipd_DIB7);
   VitalWireDelay (DIA_ipd(8), DIA8, tipd_DIA8);
   VitalWireDelay (DIB_ipd(8), DIB8, tipd_DIB8);
   VitalWireDelay (DIA_ipd(9), DIA9, tipd_DIA9);
   VitalWireDelay (DIB_ipd(9), DIB9, tipd_DIB9);
   VitalWireDelay (DIA_ipd(10), DIA10, tipd_DIA10);
   VitalWireDelay (DIB_ipd(10), DIB10, tipd_DIB10);
   VitalWireDelay (DIA_ipd(11), DIA11, tipd_DIA11);
   VitalWireDelay (DIB_ipd(11), DIB11, tipd_DIB11);
   VitalWireDelay (DIA_ipd(12), DIA12, tipd_DIA12);
   VitalWireDelay (DIB_ipd(12), DIB12, tipd_DIB12);
   VitalWireDelay (DIA_ipd(13), DIA13, tipd_DIA13);
   VitalWireDelay (DIB_ipd(13), DIB13, tipd_DIB13);
   VitalWireDelay (DIA_ipd(14), DIA14, tipd_DIA14);
   VitalWireDelay (DIB_ipd(14), DIB14, tipd_DIB14);
   VitalWireDelay (DIA_ipd(15), DIA15, tipd_DIA15);
   VitalWireDelay (DIB_ipd(15), DIB15, tipd_DIB15);
   VitalWireDelay (DIA_ipd(16), DIA16, tipd_DIA16);
   VitalWireDelay (DIB_ipd(16), DIB16, tipd_DIB16);
   VitalWireDelay (DIA_ipd(17), DIA17, tipd_DIA17);
   VitalWireDelay (DIB_ipd(17), DIB17, tipd_DIB17);
   VitalWireDelay (DIA_ipd(18), DIA18, tipd_DIA18);
   VitalWireDelay (DIB_ipd(18), DIB18, tipd_DIB18);
   VitalWireDelay (DIA_ipd(19), DIA19, tipd_DIA19);
   VitalWireDelay (DIB_ipd(19), DIB19, tipd_DIB19);
   VitalWireDelay (DIA_ipd(20), DIA20, tipd_DIA20);
   VitalWireDelay (DIB_ipd(20), DIB20, tipd_DIB20);
   VitalWireDelay (DIA_ipd(21), DIA21, tipd_DIA21);
   VitalWireDelay (DIB_ipd(21), DIB21, tipd_DIB21);
   VitalWireDelay (DIA_ipd(22), DIA22, tipd_DIA22);
   VitalWireDelay (DIB_ipd(22), DIB22, tipd_DIB22);
   VitalWireDelay (DIA_ipd(23), DIA23, tipd_DIA23);
   VitalWireDelay (DIB_ipd(23), DIB23, tipd_DIB23);
   VitalWireDelay (DIA_ipd(24), DIA24, tipd_DIA24);
   VitalWireDelay (DIB_ipd(24), DIB24, tipd_DIB24);
   VitalWireDelay (DIA_ipd(25), DIA25, tipd_DIA25);
   VitalWireDelay (DIB_ipd(25), DIB25, tipd_DIB25);
   VitalWireDelay (DIA_ipd(26), DIA26, tipd_DIA26);
   VitalWireDelay (DIB_ipd(26), DIB26, tipd_DIB26);
   VitalWireDelay (DIA_ipd(27), DIA27, tipd_DIA27);
   VitalWireDelay (DIB_ipd(27), DIB27, tipd_DIB27);
   VitalWireDelay (DIA_ipd(28), DIA28, tipd_DIA28);
   VitalWireDelay (DIB_ipd(28), DIB28, tipd_DIB28);
   VitalWireDelay (DIA_ipd(29), DIA29, tipd_DIA29);
   VitalWireDelay (DIB_ipd(29), DIB29, tipd_DIB29);
   VitalWireDelay (DIA_ipd(30), DIA30, tipd_DIA30);
   VitalWireDelay (DIB_ipd(30), DIB30, tipd_DIB30);
   VitalWireDelay (DIA_ipd(31), DIA31, tipd_DIA31);
   VitalWireDelay (DIB_ipd(31), DIB31, tipd_DIB31);
   VitalWireDelay (DIA_ipd(32), DIA32, tipd_DIA32);
   VitalWireDelay (DIB_ipd(32), DIB32, tipd_DIB32);
   VitalWireDelay (DIA_ipd(33), DIA33, tipd_DIA33);
   VitalWireDelay (DIB_ipd(33), DIB33, tipd_DIB33);
   VitalWireDelay (DIA_ipd(34), DIA34, tipd_DIA34);
   VitalWireDelay (DIB_ipd(34), DIB34, tipd_DIB34);
   VitalWireDelay (DIA_ipd(35), DIA35, tipd_DIA35);
   VitalWireDelay (DIB_ipd(35), DIB35, tipd_DIB35);
   VitalWireDelay (DIA_ipd(36), DIA36, tipd_DIA36);
   VitalWireDelay (DIB_ipd(36), DIB36, tipd_DIB36);
   VitalWireDelay (DIA_ipd(37), DIA37, tipd_DIA37);
   VitalWireDelay (DIB_ipd(37), DIB37, tipd_DIB37);
   VitalWireDelay (DIA_ipd(38), DIA38, tipd_DIA38);
   VitalWireDelay (DIB_ipd(38), DIB38, tipd_DIB38);
   VitalWireDelay (DIA_ipd(39), DIA39, tipd_DIA39);
   VitalWireDelay (DIB_ipd(39), DIB39, tipd_DIB39);
   VitalWireDelay (DIA_ipd(40), DIA40, tipd_DIA40);
   VitalWireDelay (DIB_ipd(40), DIB40, tipd_DIB40);
   VitalWireDelay (DIA_ipd(41), DIA41, tipd_DIA41);
   VitalWireDelay (DIB_ipd(41), DIB41, tipd_DIB41);
   VitalWireDelay (DIA_ipd(42), DIA42, tipd_DIA42);
   VitalWireDelay (DIB_ipd(42), DIB42, tipd_DIB42);
   VitalWireDelay (DIA_ipd(43), DIA43, tipd_DIA43);
   VitalWireDelay (DIB_ipd(43), DIB43, tipd_DIB43);
   VitalWireDelay (DIA_ipd(44), DIA44, tipd_DIA44);
   VitalWireDelay (DIB_ipd(44), DIB44, tipd_DIB44);
   VitalWireDelay (DIA_ipd(45), DIA45, tipd_DIA45);
   VitalWireDelay (DIB_ipd(45), DIB45, tipd_DIB45);
   VitalWireDelay (DIA_ipd(46), DIA46, tipd_DIA46);
   VitalWireDelay (DIB_ipd(46), DIB46, tipd_DIB46);
   VitalWireDelay (DIA_ipd(47), DIA47, tipd_DIA47);
   VitalWireDelay (DIB_ipd(47), DIB47, tipd_DIB47);
   VitalWireDelay (DIA_ipd(48), DIA48, tipd_DIA48);
   VitalWireDelay (DIB_ipd(48), DIB48, tipd_DIB48);
   VitalWireDelay (DIA_ipd(49), DIA49, tipd_DIA49);
   VitalWireDelay (DIB_ipd(49), DIB49, tipd_DIB49);
   VitalWireDelay (DIA_ipd(50), DIA50, tipd_DIA50);
   VitalWireDelay (DIB_ipd(50), DIB50, tipd_DIB50);
   VitalWireDelay (DIA_ipd(51), DIA51, tipd_DIA51);
   VitalWireDelay (DIB_ipd(51), DIB51, tipd_DIB51);
   VitalWireDelay (DIA_ipd(52), DIA52, tipd_DIA52);
   VitalWireDelay (DIB_ipd(52), DIB52, tipd_DIB52);
   VitalWireDelay (DIA_ipd(53), DIA53, tipd_DIA53);
   VitalWireDelay (DIB_ipd(53), DIB53, tipd_DIB53);
   VitalWireDelay (DIA_ipd(54), DIA54, tipd_DIA54);
   VitalWireDelay (DIB_ipd(54), DIB54, tipd_DIB54);
   VitalWireDelay (DIA_ipd(55), DIA55, tipd_DIA55);
   VitalWireDelay (DIB_ipd(55), DIB55, tipd_DIB55);
   VitalWireDelay (DIA_ipd(56), DIA56, tipd_DIA56);
   VitalWireDelay (DIB_ipd(56), DIB56, tipd_DIB56);
   VitalWireDelay (DIA_ipd(57), DIA57, tipd_DIA57);
   VitalWireDelay (DIB_ipd(57), DIB57, tipd_DIB57);
   VitalWireDelay (DIA_ipd(58), DIA58, tipd_DIA58);
   VitalWireDelay (DIB_ipd(58), DIB58, tipd_DIB58);
   VitalWireDelay (DIA_ipd(59), DIA59, tipd_DIA59);
   VitalWireDelay (DIB_ipd(59), DIB59, tipd_DIB59);
   VitalWireDelay (DIA_ipd(60), DIA60, tipd_DIA60);
   VitalWireDelay (DIB_ipd(60), DIB60, tipd_DIB60);
   VitalWireDelay (DIA_ipd(61), DIA61, tipd_DIA61);
   VitalWireDelay (DIB_ipd(61), DIB61, tipd_DIB61);
   VitalWireDelay (DIA_ipd(62), DIA62, tipd_DIA62);
   VitalWireDelay (DIB_ipd(62), DIB62, tipd_DIB62);
   VitalWireDelay (DIA_ipd(63), DIA63, tipd_DIA63);
   VitalWireDelay (DIB_ipd(63), DIB63, tipd_DIB63);
   VitalWireDelay (DIA_ipd(64), DIA64, tipd_DIA64);
   VitalWireDelay (DIB_ipd(64), DIB64, tipd_DIB64);
   VitalWireDelay (DIA_ipd(65), DIA65, tipd_DIA65);
   VitalWireDelay (DIB_ipd(65), DIB65, tipd_DIB65);
   VitalWireDelay (DIA_ipd(66), DIA66, tipd_DIA66);
   VitalWireDelay (DIB_ipd(66), DIB66, tipd_DIB66);
   VitalWireDelay (DIA_ipd(67), DIA67, tipd_DIA67);
   VitalWireDelay (DIB_ipd(67), DIB67, tipd_DIB67);
   VitalWireDelay (DIA_ipd(68), DIA68, tipd_DIA68);
   VitalWireDelay (DIB_ipd(68), DIB68, tipd_DIB68);
   VitalWireDelay (DIA_ipd(69), DIA69, tipd_DIA69);
   VitalWireDelay (DIB_ipd(69), DIB69, tipd_DIB69);
   VitalWireDelay (DIA_ipd(70), DIA70, tipd_DIA70);
   VitalWireDelay (DIB_ipd(70), DIB70, tipd_DIB70);
   VitalWireDelay (DIA_ipd(71), DIA71, tipd_DIA71);
   VitalWireDelay (DIB_ipd(71), DIB71, tipd_DIB71);
   VitalWireDelay (DIA_ipd(72), DIA72, tipd_DIA72);
   VitalWireDelay (DIB_ipd(72), DIB72, tipd_DIB72);
   VitalWireDelay (DIA_ipd(73), DIA73, tipd_DIA73);
   VitalWireDelay (DIB_ipd(73), DIB73, tipd_DIB73);
   VitalWireDelay (DIA_ipd(74), DIA74, tipd_DIA74);
   VitalWireDelay (DIB_ipd(74), DIB74, tipd_DIB74);
   VitalWireDelay (DIA_ipd(75), DIA75, tipd_DIA75);
   VitalWireDelay (DIB_ipd(75), DIB75, tipd_DIB75);
   VitalWireDelay (DIA_ipd(76), DIA76, tipd_DIA76);
   VitalWireDelay (DIB_ipd(76), DIB76, tipd_DIB76);
   VitalWireDelay (DIA_ipd(77), DIA77, tipd_DIA77);
   VitalWireDelay (DIB_ipd(77), DIB77, tipd_DIB77);
   VitalWireDelay (DIA_ipd(78), DIA78, tipd_DIA78);
   VitalWireDelay (DIB_ipd(78), DIB78, tipd_DIB78);
   VitalWireDelay (DIA_ipd(79), DIA79, tipd_DIA79);
   VitalWireDelay (DIB_ipd(79), DIB79, tipd_DIB79);
   VitalWireDelay (DIA_ipd(80), DIA80, tipd_DIA80);
   VitalWireDelay (DIB_ipd(80), DIB80, tipd_DIB80);
   VitalWireDelay (DIA_ipd(81), DIA81, tipd_DIA81);
   VitalWireDelay (DIB_ipd(81), DIB81, tipd_DIB81);
   VitalWireDelay (DIA_ipd(82), DIA82, tipd_DIA82);
   VitalWireDelay (DIB_ipd(82), DIB82, tipd_DIB82);
   VitalWireDelay (DIA_ipd(83), DIA83, tipd_DIA83);
   VitalWireDelay (DIB_ipd(83), DIB83, tipd_DIB83);
   VitalWireDelay (DIA_ipd(84), DIA84, tipd_DIA84);
   VitalWireDelay (DIB_ipd(84), DIB84, tipd_DIB84);
   VitalWireDelay (DIA_ipd(85), DIA85, tipd_DIA85);
   VitalWireDelay (DIB_ipd(85), DIB85, tipd_DIB85);
   VitalWireDelay (DIA_ipd(86), DIA86, tipd_DIA86);
   VitalWireDelay (DIB_ipd(86), DIB86, tipd_DIB86);
   VitalWireDelay (DIA_ipd(87), DIA87, tipd_DIA87);
   VitalWireDelay (DIB_ipd(87), DIB87, tipd_DIB87);
   VitalWireDelay (DIA_ipd(88), DIA88, tipd_DIA88);
   VitalWireDelay (DIB_ipd(88), DIB88, tipd_DIB88);
   VitalWireDelay (DIA_ipd(89), DIA89, tipd_DIA89);
   VitalWireDelay (DIB_ipd(89), DIB89, tipd_DIB89);
   VitalWireDelay (DIA_ipd(90), DIA90, tipd_DIA90);
   VitalWireDelay (DIB_ipd(90), DIB90, tipd_DIB90);
   VitalWireDelay (DIA_ipd(91), DIA91, tipd_DIA91);
   VitalWireDelay (DIB_ipd(91), DIB91, tipd_DIB91);
   VitalWireDelay (DIA_ipd(92), DIA92, tipd_DIA92);
   VitalWireDelay (DIB_ipd(92), DIB92, tipd_DIB92);
   VitalWireDelay (DIA_ipd(93), DIA93, tipd_DIA93);
   VitalWireDelay (DIB_ipd(93), DIB93, tipd_DIB93);
   VitalWireDelay (DIA_ipd(94), DIA94, tipd_DIA94);
   VitalWireDelay (DIB_ipd(94), DIB94, tipd_DIB94);
   VitalWireDelay (DIA_ipd(95), DIA95, tipd_DIA95);
   VitalWireDelay (DIB_ipd(95), DIB95, tipd_DIB95);
   VitalWireDelay (DIA_ipd(96), DIA96, tipd_DIA96);
   VitalWireDelay (DIB_ipd(96), DIB96, tipd_DIB96);
   VitalWireDelay (DIA_ipd(97), DIA97, tipd_DIA97);
   VitalWireDelay (DIB_ipd(97), DIB97, tipd_DIB97);
   VitalWireDelay (DIA_ipd(98), DIA98, tipd_DIA98);
   VitalWireDelay (DIB_ipd(98), DIB98, tipd_DIB98);
   VitalWireDelay (DIA_ipd(99), DIA99, tipd_DIA99);
   VitalWireDelay (DIB_ipd(99), DIB99, tipd_DIB99);
   VitalWireDelay (DIA_ipd(100), DIA100, tipd_DIA100);
   VitalWireDelay (DIB_ipd(100), DIB100, tipd_DIB100);
   VitalWireDelay (DIA_ipd(101), DIA101, tipd_DIA101);
   VitalWireDelay (DIB_ipd(101), DIB101, tipd_DIB101);
   VitalWireDelay (DIA_ipd(102), DIA102, tipd_DIA102);
   VitalWireDelay (DIB_ipd(102), DIB102, tipd_DIB102);
   VitalWireDelay (DIA_ipd(103), DIA103, tipd_DIA103);
   VitalWireDelay (DIB_ipd(103), DIB103, tipd_DIB103);
   VitalWireDelay (DIA_ipd(104), DIA104, tipd_DIA104);
   VitalWireDelay (DIB_ipd(104), DIB104, tipd_DIB104);
   VitalWireDelay (DIA_ipd(105), DIA105, tipd_DIA105);
   VitalWireDelay (DIB_ipd(105), DIB105, tipd_DIB105);
   VitalWireDelay (DIA_ipd(106), DIA106, tipd_DIA106);
   VitalWireDelay (DIB_ipd(106), DIB106, tipd_DIB106);
   VitalWireDelay (DIA_ipd(107), DIA107, tipd_DIA107);
   VitalWireDelay (DIB_ipd(107), DIB107, tipd_DIB107);
   VitalWireDelay (DIA_ipd(108), DIA108, tipd_DIA108);
   VitalWireDelay (DIB_ipd(108), DIB108, tipd_DIB108);
   VitalWireDelay (DIA_ipd(109), DIA109, tipd_DIA109);
   VitalWireDelay (DIB_ipd(109), DIB109, tipd_DIB109);
   VitalWireDelay (DIA_ipd(110), DIA110, tipd_DIA110);
   VitalWireDelay (DIB_ipd(110), DIB110, tipd_DIB110);
   VitalWireDelay (DIA_ipd(111), DIA111, tipd_DIA111);
   VitalWireDelay (DIB_ipd(111), DIB111, tipd_DIB111);
   VitalWireDelay (DIA_ipd(112), DIA112, tipd_DIA112);
   VitalWireDelay (DIB_ipd(112), DIB112, tipd_DIB112);
   VitalWireDelay (DIA_ipd(113), DIA113, tipd_DIA113);
   VitalWireDelay (DIB_ipd(113), DIB113, tipd_DIB113);
   VitalWireDelay (DIA_ipd(114), DIA114, tipd_DIA114);
   VitalWireDelay (DIB_ipd(114), DIB114, tipd_DIB114);
   VitalWireDelay (DIA_ipd(115), DIA115, tipd_DIA115);
   VitalWireDelay (DIB_ipd(115), DIB115, tipd_DIB115);
   VitalWireDelay (DIA_ipd(116), DIA116, tipd_DIA116);
   VitalWireDelay (DIB_ipd(116), DIB116, tipd_DIB116);
   VitalWireDelay (DIA_ipd(117), DIA117, tipd_DIA117);
   VitalWireDelay (DIB_ipd(117), DIB117, tipd_DIB117);
   VitalWireDelay (DIA_ipd(118), DIA118, tipd_DIA118);
   VitalWireDelay (DIB_ipd(118), DIB118, tipd_DIB118);
   VitalWireDelay (DIA_ipd(119), DIA119, tipd_DIA119);
   VitalWireDelay (DIB_ipd(119), DIB119, tipd_DIB119);
   VitalWireDelay (DIA_ipd(120), DIA120, tipd_DIA120);
   VitalWireDelay (DIB_ipd(120), DIB120, tipd_DIB120);
   VitalWireDelay (DIA_ipd(121), DIA121, tipd_DIA121);
   VitalWireDelay (DIB_ipd(121), DIB121, tipd_DIB121);
   VitalWireDelay (DIA_ipd(122), DIA122, tipd_DIA122);
   VitalWireDelay (DIB_ipd(122), DIB122, tipd_DIB122);
   VitalWireDelay (DIA_ipd(123), DIA123, tipd_DIA123);
   VitalWireDelay (DIB_ipd(123), DIB123, tipd_DIB123);
   VitalWireDelay (DIA_ipd(124), DIA124, tipd_DIA124);
   VitalWireDelay (DIB_ipd(124), DIB124, tipd_DIB124);
   VitalWireDelay (DIA_ipd(125), DIA125, tipd_DIA125);
   VitalWireDelay (DIB_ipd(125), DIB125, tipd_DIB125);
   VitalWireDelay (DIA_ipd(126), DIA126, tipd_DIA126);
   VitalWireDelay (DIB_ipd(126), DIB126, tipd_DIB126);
   VitalWireDelay (DIA_ipd(127), DIA127, tipd_DIA127);
   VitalWireDelay (DIB_ipd(127), DIB127, tipd_DIB127);

   end block;

   VitalBUFIF1 (q      => DOA0,
                data   => DOA_int(0),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA0);
   VitalBUFIF1 (q      => DOA1,
                data   => DOA_int(1),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA1);
   VitalBUFIF1 (q      => DOA2,
                data   => DOA_int(2),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA2);
   VitalBUFIF1 (q      => DOA3,
                data   => DOA_int(3),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA3);
   VitalBUFIF1 (q      => DOA4,
                data   => DOA_int(4),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA4);
   VitalBUFIF1 (q      => DOA5,
                data   => DOA_int(5),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA5);
   VitalBUFIF1 (q      => DOA6,
                data   => DOA_int(6),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA6);
   VitalBUFIF1 (q      => DOA7,
                data   => DOA_int(7),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA7);
   VitalBUFIF1 (q      => DOA8,
                data   => DOA_int(8),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA8);
   VitalBUFIF1 (q      => DOA9,
                data   => DOA_int(9),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA9);
   VitalBUFIF1 (q      => DOA10,
                data   => DOA_int(10),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA10);
   VitalBUFIF1 (q      => DOA11,
                data   => DOA_int(11),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA11);
   VitalBUFIF1 (q      => DOA12,
                data   => DOA_int(12),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA12);
   VitalBUFIF1 (q      => DOA13,
                data   => DOA_int(13),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA13);
   VitalBUFIF1 (q      => DOA14,
                data   => DOA_int(14),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA14);
   VitalBUFIF1 (q      => DOA15,
                data   => DOA_int(15),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA15);
   VitalBUFIF1 (q      => DOA16,
                data   => DOA_int(16),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA16);
   VitalBUFIF1 (q      => DOA17,
                data   => DOA_int(17),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA17);
   VitalBUFIF1 (q      => DOA18,
                data   => DOA_int(18),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA18);
   VitalBUFIF1 (q      => DOA19,
                data   => DOA_int(19),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA19);
   VitalBUFIF1 (q      => DOA20,
                data   => DOA_int(20),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA20);
   VitalBUFIF1 (q      => DOA21,
                data   => DOA_int(21),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA21);
   VitalBUFIF1 (q      => DOA22,
                data   => DOA_int(22),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA22);
   VitalBUFIF1 (q      => DOA23,
                data   => DOA_int(23),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA23);
   VitalBUFIF1 (q      => DOA24,
                data   => DOA_int(24),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA24);
   VitalBUFIF1 (q      => DOA25,
                data   => DOA_int(25),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA25);
   VitalBUFIF1 (q      => DOA26,
                data   => DOA_int(26),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA26);
   VitalBUFIF1 (q      => DOA27,
                data   => DOA_int(27),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA27);
   VitalBUFIF1 (q      => DOA28,
                data   => DOA_int(28),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA28);
   VitalBUFIF1 (q      => DOA29,
                data   => DOA_int(29),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA29);
   VitalBUFIF1 (q      => DOA30,
                data   => DOA_int(30),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA30);
   VitalBUFIF1 (q      => DOA31,
                data   => DOA_int(31),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA31);
   VitalBUFIF1 (q      => DOA32,
                data   => DOA_int(32),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA32);
   VitalBUFIF1 (q      => DOA33,
                data   => DOA_int(33),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA33);
   VitalBUFIF1 (q      => DOA34,
                data   => DOA_int(34),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA34);
   VitalBUFIF1 (q      => DOA35,
                data   => DOA_int(35),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA35);
   VitalBUFIF1 (q      => DOA36,
                data   => DOA_int(36),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA36);
   VitalBUFIF1 (q      => DOA37,
                data   => DOA_int(37),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA37);
   VitalBUFIF1 (q      => DOA38,
                data   => DOA_int(38),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA38);
   VitalBUFIF1 (q      => DOA39,
                data   => DOA_int(39),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA39);
   VitalBUFIF1 (q      => DOA40,
                data   => DOA_int(40),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA40);
   VitalBUFIF1 (q      => DOA41,
                data   => DOA_int(41),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA41);
   VitalBUFIF1 (q      => DOA42,
                data   => DOA_int(42),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA42);
   VitalBUFIF1 (q      => DOA43,
                data   => DOA_int(43),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA43);
   VitalBUFIF1 (q      => DOA44,
                data   => DOA_int(44),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA44);
   VitalBUFIF1 (q      => DOA45,
                data   => DOA_int(45),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA45);
   VitalBUFIF1 (q      => DOA46,
                data   => DOA_int(46),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA46);
   VitalBUFIF1 (q      => DOA47,
                data   => DOA_int(47),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA47);
   VitalBUFIF1 (q      => DOA48,
                data   => DOA_int(48),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA48);
   VitalBUFIF1 (q      => DOA49,
                data   => DOA_int(49),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA49);
   VitalBUFIF1 (q      => DOA50,
                data   => DOA_int(50),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA50);
   VitalBUFIF1 (q      => DOA51,
                data   => DOA_int(51),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA51);
   VitalBUFIF1 (q      => DOA52,
                data   => DOA_int(52),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA52);
   VitalBUFIF1 (q      => DOA53,
                data   => DOA_int(53),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA53);
   VitalBUFIF1 (q      => DOA54,
                data   => DOA_int(54),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA54);
   VitalBUFIF1 (q      => DOA55,
                data   => DOA_int(55),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA55);
   VitalBUFIF1 (q      => DOA56,
                data   => DOA_int(56),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA56);
   VitalBUFIF1 (q      => DOA57,
                data   => DOA_int(57),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA57);
   VitalBUFIF1 (q      => DOA58,
                data   => DOA_int(58),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA58);
   VitalBUFIF1 (q      => DOA59,
                data   => DOA_int(59),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA59);
   VitalBUFIF1 (q      => DOA60,
                data   => DOA_int(60),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA60);
   VitalBUFIF1 (q      => DOA61,
                data   => DOA_int(61),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA61);
   VitalBUFIF1 (q      => DOA62,
                data   => DOA_int(62),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA62);
   VitalBUFIF1 (q      => DOA63,
                data   => DOA_int(63),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA63);
   VitalBUFIF1 (q      => DOA64,
                data   => DOA_int(64),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA64);
   VitalBUFIF1 (q      => DOA65,
                data   => DOA_int(65),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA65);
   VitalBUFIF1 (q      => DOA66,
                data   => DOA_int(66),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA66);
   VitalBUFIF1 (q      => DOA67,
                data   => DOA_int(67),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA67);
   VitalBUFIF1 (q      => DOA68,
                data   => DOA_int(68),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA68);
   VitalBUFIF1 (q      => DOA69,
                data   => DOA_int(69),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA69);
   VitalBUFIF1 (q      => DOA70,
                data   => DOA_int(70),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA70);
   VitalBUFIF1 (q      => DOA71,
                data   => DOA_int(71),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA71);
   VitalBUFIF1 (q      => DOA72,
                data   => DOA_int(72),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA72);
   VitalBUFIF1 (q      => DOA73,
                data   => DOA_int(73),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA73);
   VitalBUFIF1 (q      => DOA74,
                data   => DOA_int(74),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA74);
   VitalBUFIF1 (q      => DOA75,
                data   => DOA_int(75),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA75);
   VitalBUFIF1 (q      => DOA76,
                data   => DOA_int(76),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA76);
   VitalBUFIF1 (q      => DOA77,
                data   => DOA_int(77),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA77);
   VitalBUFIF1 (q      => DOA78,
                data   => DOA_int(78),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA78);
   VitalBUFIF1 (q      => DOA79,
                data   => DOA_int(79),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA79);
   VitalBUFIF1 (q      => DOA80,
                data   => DOA_int(80),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA80);
   VitalBUFIF1 (q      => DOA81,
                data   => DOA_int(81),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA81);
   VitalBUFIF1 (q      => DOA82,
                data   => DOA_int(82),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA82);
   VitalBUFIF1 (q      => DOA83,
                data   => DOA_int(83),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA83);
   VitalBUFIF1 (q      => DOA84,
                data   => DOA_int(84),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA84);
   VitalBUFIF1 (q      => DOA85,
                data   => DOA_int(85),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA85);
   VitalBUFIF1 (q      => DOA86,
                data   => DOA_int(86),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA86);
   VitalBUFIF1 (q      => DOA87,
                data   => DOA_int(87),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA87);
   VitalBUFIF1 (q      => DOA88,
                data   => DOA_int(88),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA88);
   VitalBUFIF1 (q      => DOA89,
                data   => DOA_int(89),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA89);
   VitalBUFIF1 (q      => DOA90,
                data   => DOA_int(90),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA90);
   VitalBUFIF1 (q      => DOA91,
                data   => DOA_int(91),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA91);
   VitalBUFIF1 (q      => DOA92,
                data   => DOA_int(92),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA92);
   VitalBUFIF1 (q      => DOA93,
                data   => DOA_int(93),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA93);
   VitalBUFIF1 (q      => DOA94,
                data   => DOA_int(94),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA94);
   VitalBUFIF1 (q      => DOA95,
                data   => DOA_int(95),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA95);
   VitalBUFIF1 (q      => DOA96,
                data   => DOA_int(96),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA96);
   VitalBUFIF1 (q      => DOA97,
                data   => DOA_int(97),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA97);
   VitalBUFIF1 (q      => DOA98,
                data   => DOA_int(98),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA98);
   VitalBUFIF1 (q      => DOA99,
                data   => DOA_int(99),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA99);
   VitalBUFIF1 (q      => DOA100,
                data   => DOA_int(100),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA100);
   VitalBUFIF1 (q      => DOA101,
                data   => DOA_int(101),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA101);
   VitalBUFIF1 (q      => DOA102,
                data   => DOA_int(102),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA102);
   VitalBUFIF1 (q      => DOA103,
                data   => DOA_int(103),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA103);
   VitalBUFIF1 (q      => DOA104,
                data   => DOA_int(104),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA104);
   VitalBUFIF1 (q      => DOA105,
                data   => DOA_int(105),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA105);
   VitalBUFIF1 (q      => DOA106,
                data   => DOA_int(106),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA106);
   VitalBUFIF1 (q      => DOA107,
                data   => DOA_int(107),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA107);
   VitalBUFIF1 (q      => DOA108,
                data   => DOA_int(108),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA108);
   VitalBUFIF1 (q      => DOA109,
                data   => DOA_int(109),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA109);
   VitalBUFIF1 (q      => DOA110,
                data   => DOA_int(110),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA110);
   VitalBUFIF1 (q      => DOA111,
                data   => DOA_int(111),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA111);
   VitalBUFIF1 (q      => DOA112,
                data   => DOA_int(112),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA112);
   VitalBUFIF1 (q      => DOA113,
                data   => DOA_int(113),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA113);
   VitalBUFIF1 (q      => DOA114,
                data   => DOA_int(114),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA114);
   VitalBUFIF1 (q      => DOA115,
                data   => DOA_int(115),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA115);
   VitalBUFIF1 (q      => DOA116,
                data   => DOA_int(116),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA116);
   VitalBUFIF1 (q      => DOA117,
                data   => DOA_int(117),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA117);
   VitalBUFIF1 (q      => DOA118,
                data   => DOA_int(118),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA118);
   VitalBUFIF1 (q      => DOA119,
                data   => DOA_int(119),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA119);
   VitalBUFIF1 (q      => DOA120,
                data   => DOA_int(120),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA120);
   VitalBUFIF1 (q      => DOA121,
                data   => DOA_int(121),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA121);
   VitalBUFIF1 (q      => DOA122,
                data   => DOA_int(122),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA122);
   VitalBUFIF1 (q      => DOA123,
                data   => DOA_int(123),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA123);
   VitalBUFIF1 (q      => DOA124,
                data   => DOA_int(124),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA124);
   VitalBUFIF1 (q      => DOA125,
                data   => DOA_int(125),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA125);
   VitalBUFIF1 (q      => DOA126,
                data   => DOA_int(126),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA126);
   VitalBUFIF1 (q      => DOA127,
                data   => DOA_int(127),
                enable => OEA_ipd,
                tpd_enable_q => tpd_OEA_DOA127);

   VitalBUFIF1 (q      => DOB0,
                data   => DOB_int(0),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB0);
   VitalBUFIF1 (q      => DOB1,
                data   => DOB_int(1),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB1);
   VitalBUFIF1 (q      => DOB2,
                data   => DOB_int(2),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB2);
   VitalBUFIF1 (q      => DOB3,
                data   => DOB_int(3),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB3);
   VitalBUFIF1 (q      => DOB4,
                data   => DOB_int(4),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB4);
   VitalBUFIF1 (q      => DOB5,
                data   => DOB_int(5),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB5);
   VitalBUFIF1 (q      => DOB6,
                data   => DOB_int(6),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB6);
   VitalBUFIF1 (q      => DOB7,
                data   => DOB_int(7),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB7);
   VitalBUFIF1 (q      => DOB8,
                data   => DOB_int(8),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB8);
   VitalBUFIF1 (q      => DOB9,
                data   => DOB_int(9),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB9);
   VitalBUFIF1 (q      => DOB10,
                data   => DOB_int(10),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB10);
   VitalBUFIF1 (q      => DOB11,
                data   => DOB_int(11),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB11);
   VitalBUFIF1 (q      => DOB12,
                data   => DOB_int(12),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB12);
   VitalBUFIF1 (q      => DOB13,
                data   => DOB_int(13),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB13);
   VitalBUFIF1 (q      => DOB14,
                data   => DOB_int(14),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB14);
   VitalBUFIF1 (q      => DOB15,
                data   => DOB_int(15),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB15);
   VitalBUFIF1 (q      => DOB16,
                data   => DOB_int(16),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB16);
   VitalBUFIF1 (q      => DOB17,
                data   => DOB_int(17),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB17);
   VitalBUFIF1 (q      => DOB18,
                data   => DOB_int(18),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB18);
   VitalBUFIF1 (q      => DOB19,
                data   => DOB_int(19),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB19);
   VitalBUFIF1 (q      => DOB20,
                data   => DOB_int(20),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB20);
   VitalBUFIF1 (q      => DOB21,
                data   => DOB_int(21),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB21);
   VitalBUFIF1 (q      => DOB22,
                data   => DOB_int(22),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB22);
   VitalBUFIF1 (q      => DOB23,
                data   => DOB_int(23),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB23);
   VitalBUFIF1 (q      => DOB24,
                data   => DOB_int(24),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB24);
   VitalBUFIF1 (q      => DOB25,
                data   => DOB_int(25),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB25);
   VitalBUFIF1 (q      => DOB26,
                data   => DOB_int(26),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB26);
   VitalBUFIF1 (q      => DOB27,
                data   => DOB_int(27),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB27);
   VitalBUFIF1 (q      => DOB28,
                data   => DOB_int(28),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB28);
   VitalBUFIF1 (q      => DOB29,
                data   => DOB_int(29),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB29);
   VitalBUFIF1 (q      => DOB30,
                data   => DOB_int(30),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB30);
   VitalBUFIF1 (q      => DOB31,
                data   => DOB_int(31),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB31);
   VitalBUFIF1 (q      => DOB32,
                data   => DOB_int(32),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB32);
   VitalBUFIF1 (q      => DOB33,
                data   => DOB_int(33),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB33);
   VitalBUFIF1 (q      => DOB34,
                data   => DOB_int(34),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB34);
   VitalBUFIF1 (q      => DOB35,
                data   => DOB_int(35),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB35);
   VitalBUFIF1 (q      => DOB36,
                data   => DOB_int(36),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB36);
   VitalBUFIF1 (q      => DOB37,
                data   => DOB_int(37),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB37);
   VitalBUFIF1 (q      => DOB38,
                data   => DOB_int(38),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB38);
   VitalBUFIF1 (q      => DOB39,
                data   => DOB_int(39),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB39);
   VitalBUFIF1 (q      => DOB40,
                data   => DOB_int(40),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB40);
   VitalBUFIF1 (q      => DOB41,
                data   => DOB_int(41),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB41);
   VitalBUFIF1 (q      => DOB42,
                data   => DOB_int(42),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB42);
   VitalBUFIF1 (q      => DOB43,
                data   => DOB_int(43),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB43);
   VitalBUFIF1 (q      => DOB44,
                data   => DOB_int(44),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB44);
   VitalBUFIF1 (q      => DOB45,
                data   => DOB_int(45),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB45);
   VitalBUFIF1 (q      => DOB46,
                data   => DOB_int(46),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB46);
   VitalBUFIF1 (q      => DOB47,
                data   => DOB_int(47),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB47);
   VitalBUFIF1 (q      => DOB48,
                data   => DOB_int(48),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB48);
   VitalBUFIF1 (q      => DOB49,
                data   => DOB_int(49),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB49);
   VitalBUFIF1 (q      => DOB50,
                data   => DOB_int(50),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB50);
   VitalBUFIF1 (q      => DOB51,
                data   => DOB_int(51),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB51);
   VitalBUFIF1 (q      => DOB52,
                data   => DOB_int(52),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB52);
   VitalBUFIF1 (q      => DOB53,
                data   => DOB_int(53),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB53);
   VitalBUFIF1 (q      => DOB54,
                data   => DOB_int(54),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB54);
   VitalBUFIF1 (q      => DOB55,
                data   => DOB_int(55),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB55);
   VitalBUFIF1 (q      => DOB56,
                data   => DOB_int(56),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB56);
   VitalBUFIF1 (q      => DOB57,
                data   => DOB_int(57),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB57);
   VitalBUFIF1 (q      => DOB58,
                data   => DOB_int(58),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB58);
   VitalBUFIF1 (q      => DOB59,
                data   => DOB_int(59),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB59);
   VitalBUFIF1 (q      => DOB60,
                data   => DOB_int(60),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB60);
   VitalBUFIF1 (q      => DOB61,
                data   => DOB_int(61),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB61);
   VitalBUFIF1 (q      => DOB62,
                data   => DOB_int(62),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB62);
   VitalBUFIF1 (q      => DOB63,
                data   => DOB_int(63),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB63);
   VitalBUFIF1 (q      => DOB64,
                data   => DOB_int(64),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB64);
   VitalBUFIF1 (q      => DOB65,
                data   => DOB_int(65),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB65);
   VitalBUFIF1 (q      => DOB66,
                data   => DOB_int(66),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB66);
   VitalBUFIF1 (q      => DOB67,
                data   => DOB_int(67),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB67);
   VitalBUFIF1 (q      => DOB68,
                data   => DOB_int(68),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB68);
   VitalBUFIF1 (q      => DOB69,
                data   => DOB_int(69),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB69);
   VitalBUFIF1 (q      => DOB70,
                data   => DOB_int(70),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB70);
   VitalBUFIF1 (q      => DOB71,
                data   => DOB_int(71),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB71);
   VitalBUFIF1 (q      => DOB72,
                data   => DOB_int(72),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB72);
   VitalBUFIF1 (q      => DOB73,
                data   => DOB_int(73),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB73);
   VitalBUFIF1 (q      => DOB74,
                data   => DOB_int(74),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB74);
   VitalBUFIF1 (q      => DOB75,
                data   => DOB_int(75),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB75);
   VitalBUFIF1 (q      => DOB76,
                data   => DOB_int(76),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB76);
   VitalBUFIF1 (q      => DOB77,
                data   => DOB_int(77),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB77);
   VitalBUFIF1 (q      => DOB78,
                data   => DOB_int(78),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB78);
   VitalBUFIF1 (q      => DOB79,
                data   => DOB_int(79),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB79);
   VitalBUFIF1 (q      => DOB80,
                data   => DOB_int(80),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB80);
   VitalBUFIF1 (q      => DOB81,
                data   => DOB_int(81),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB81);
   VitalBUFIF1 (q      => DOB82,
                data   => DOB_int(82),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB82);
   VitalBUFIF1 (q      => DOB83,
                data   => DOB_int(83),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB83);
   VitalBUFIF1 (q      => DOB84,
                data   => DOB_int(84),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB84);
   VitalBUFIF1 (q      => DOB85,
                data   => DOB_int(85),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB85);
   VitalBUFIF1 (q      => DOB86,
                data   => DOB_int(86),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB86);
   VitalBUFIF1 (q      => DOB87,
                data   => DOB_int(87),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB87);
   VitalBUFIF1 (q      => DOB88,
                data   => DOB_int(88),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB88);
   VitalBUFIF1 (q      => DOB89,
                data   => DOB_int(89),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB89);
   VitalBUFIF1 (q      => DOB90,
                data   => DOB_int(90),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB90);
   VitalBUFIF1 (q      => DOB91,
                data   => DOB_int(91),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB91);
   VitalBUFIF1 (q      => DOB92,
                data   => DOB_int(92),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB92);
   VitalBUFIF1 (q      => DOB93,
                data   => DOB_int(93),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB93);
   VitalBUFIF1 (q      => DOB94,
                data   => DOB_int(94),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB94);
   VitalBUFIF1 (q      => DOB95,
                data   => DOB_int(95),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB95);
   VitalBUFIF1 (q      => DOB96,
                data   => DOB_int(96),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB96);
   VitalBUFIF1 (q      => DOB97,
                data   => DOB_int(97),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB97);
   VitalBUFIF1 (q      => DOB98,
                data   => DOB_int(98),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB98);
   VitalBUFIF1 (q      => DOB99,
                data   => DOB_int(99),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB99);
   VitalBUFIF1 (q      => DOB100,
                data   => DOB_int(100),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB100);
   VitalBUFIF1 (q      => DOB101,
                data   => DOB_int(101),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB101);
   VitalBUFIF1 (q      => DOB102,
                data   => DOB_int(102),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB102);
   VitalBUFIF1 (q      => DOB103,
                data   => DOB_int(103),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB103);
   VitalBUFIF1 (q      => DOB104,
                data   => DOB_int(104),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB104);
   VitalBUFIF1 (q      => DOB105,
                data   => DOB_int(105),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB105);
   VitalBUFIF1 (q      => DOB106,
                data   => DOB_int(106),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB106);
   VitalBUFIF1 (q      => DOB107,
                data   => DOB_int(107),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB107);
   VitalBUFIF1 (q      => DOB108,
                data   => DOB_int(108),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB108);
   VitalBUFIF1 (q      => DOB109,
                data   => DOB_int(109),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB109);
   VitalBUFIF1 (q      => DOB110,
                data   => DOB_int(110),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB110);
   VitalBUFIF1 (q      => DOB111,
                data   => DOB_int(111),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB111);
   VitalBUFIF1 (q      => DOB112,
                data   => DOB_int(112),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB112);
   VitalBUFIF1 (q      => DOB113,
                data   => DOB_int(113),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB113);
   VitalBUFIF1 (q      => DOB114,
                data   => DOB_int(114),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB114);
   VitalBUFIF1 (q      => DOB115,
                data   => DOB_int(115),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB115);
   VitalBUFIF1 (q      => DOB116,
                data   => DOB_int(116),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB116);
   VitalBUFIF1 (q      => DOB117,
                data   => DOB_int(117),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB117);
   VitalBUFIF1 (q      => DOB118,
                data   => DOB_int(118),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB118);
   VitalBUFIF1 (q      => DOB119,
                data   => DOB_int(119),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB119);
   VitalBUFIF1 (q      => DOB120,
                data   => DOB_int(120),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB120);
   VitalBUFIF1 (q      => DOB121,
                data   => DOB_int(121),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB121);
   VitalBUFIF1 (q      => DOB122,
                data   => DOB_int(122),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB122);
   VitalBUFIF1 (q      => DOB123,
                data   => DOB_int(123),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB123);
   VitalBUFIF1 (q      => DOB124,
                data   => DOB_int(124),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB124);
   VitalBUFIF1 (q      => DOB125,
                data   => DOB_int(125),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB125);
   VitalBUFIF1 (q      => DOB126,
                data   => DOB_int(126),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB126);
   VitalBUFIF1 (q      => DOB127,
                data   => DOB_int(127),
                enable => OEB_ipd,
                tpd_enable_q => tpd_OEB_DOB127);

   --------------------
   --  BEHAVIOR SECTION
   --------------------
   VITALBehavior : PROCESS (CSA_ipd,
                            CSB_ipd,
                            OEA_ipd,
                            OEB_ipd,
                            A_ipd,
                            B_ipd,
                            WEAN_ipd,
                            WEBN_ipd,
                            DIA_ipd,
                            DIB_ipd,
                            CKA_ipd,
                            CKB_ipd)

   -- timing check results
   VARIABLE Tviol_A_CKA_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_B_CKB_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_WEAN_CKA_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_WEBN_CKB_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_DIA_CKA_posedge   : STD_ULOGIC := '0';
   VARIABLE Tviol_DIB_CKB_posedge   : STD_ULOGIC := '0';
   VARIABLE Tviol_CSA_CKA_posedge  : STD_ULOGIC := '0';
   VARIABLE Tviol_CSB_CKB_posedge  : STD_ULOGIC := '0';

   VARIABLE Pviol_CKA    : STD_ULOGIC := '0';
   VARIABLE Pviol_CKB    : STD_ULOGIC := '0';
   VARIABLE Pdata_CKA    : VitalPeriodDataType := VitalPeriodDataInit;
   VARIABLE Pdata_CKB    : VitalPeriodDataType := VitalPeriodDataInit;

   VARIABLE Tmkr_A_CKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_B_CKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_WEAN_CKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_WEBN_CKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_DIA_CKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_DIB_CKB_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_CSA_CKA_posedge   : VitalTimingDataType := VitalTimingDataInit;
   VARIABLE Tmkr_CSB_CKB_posedge   : VitalTimingDataType := VitalTimingDataInit;

   VARIABLE DOA_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE DOB_zd : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE memoryCore  : memoryArray;

   VARIABLE cka_change   : std_logic_vector(1 downto 0);
   VARIABLE ckb_change   : std_logic_vector(1 downto 0);
   VARIABLE wea_csa      : std_logic_vector(1 downto 0);
   VARIABLE web_csb      : std_logic_vector(1 downto 0);

   -- previous latch data
   VARIABLE Latch_A        : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE Latch_B        : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE Latch_DIA       : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE Latch_DIB       : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE Latch_WEAN      : std_logic := 'X';
   VARIABLE Latch_WEBN      : std_logic := 'X';
   VARIABLE Latch_CSA       : std_logic := 'X';
   VARIABLE Latch_CSB       : std_logic := 'X';

   -- internal latch data
   VARIABLE A_i            : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE B_i            : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE DIA_i           : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE DIB_i           : std_logic_vector(Bits-1 downto 0) := (others => 'X');
   VARIABLE WEAN_i          : std_logic := 'X';
   VARIABLE WEBN_i          : std_logic := 'X';
   VARIABLE CSA_i           : std_logic := 'X';
   VARIABLE CSB_i           : std_logic := 'X';

   VARIABLE Last_WEAN_i      : std_logic := 'X';
   VARIABLE Last_WEBN_i      : std_logic := 'X';

   VARIABLE last_A         : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE last_B         : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');

   VARIABLE LastClkAEdge    : std_logic := 'X';
   VARIABLE LastClkBEdge    : std_logic := 'X';

   VARIABLE flag_A: integer   := True_flg;
   VARIABLE flag_B: integer   := True_flg;
   VARIABLE flag_CSA: integer   := True_flg;
   VARIABLE flag_CSB: integer   := True_flg;

   VARIABLE LastCycleAAddress  : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE LastCycleBAddress  : std_logic_vector(AddressSize-1 downto 0) := (others => 'X');
   VARIABLE Last_tc_ClkA_PosEdge     : time := 0 ns;
   VARIABLE Last_tc_ClkB_PosEdge     : time := 0 ns;

   begin

   ------------------------
   --  Timing Check Section
   ------------------------
   if (TimingChecksOn) then
         VitalSetupHoldCheck (
          Violation               => Tviol_A_CKA_posedge,
          TimingData              => Tmkr_A_CKA_posedge,
          TestSignal              => A_ipd,
          TestSignalName          => "A",
          TestDelay               => 0 ns,
          RefSignal               => CKA_ipd,
          RefSignalName           => "CKA",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_A0_CKA_posedge_posedge,
          SetupLow                => tsetup_A0_CKA_negedge_posedge,
          HoldHigh                => thold_A0_CKA_negedge_posedge,
          HoldLow                 => thold_A0_CKA_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSA_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_B_CKB_posedge,
          TimingData              => Tmkr_B_CKB_posedge,
          TestSignal              => B_ipd,
          TestSignalName          => "B",
          TestDelay               => 0 ns,
          RefSignal               => CKB_ipd,
          RefSignalName           => "CKB",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_B0_CKB_posedge_posedge,
          SetupLow                => tsetup_B0_CKB_negedge_posedge,
          HoldHigh                => thold_B0_CKB_negedge_posedge,
          HoldLow                 => thold_B0_CKB_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSB_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_WEAN_CKA_posedge,
          TimingData              => Tmkr_WEAN_CKA_posedge,
          TestSignal              => WEAN_ipd,
          TestSignalName          => "WEAN",
          TestDelay               => 0 ns,
          RefSignal               => CKA_ipd,
          RefSignalName           => "CKA",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_WEAN_CKA_posedge_posedge,
          SetupLow                => tsetup_WEAN_CKA_negedge_posedge,
          HoldHigh                => thold_WEAN_CKA_negedge_posedge,
          HoldLow                 => thold_WEAN_CKA_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSA_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_WEBN_CKB_posedge,
          TimingData              => Tmkr_WEBN_CKB_posedge,
          TestSignal              => WEBN_ipd,
          TestSignalName          => "WEBN",
          TestDelay               => 0 ns,
          RefSignal               => CKB_ipd,
          RefSignalName           => "CKB",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_WEBN_CKB_posedge_posedge,
          SetupLow                => tsetup_WEBN_CKB_negedge_posedge,
          HoldHigh                => thold_WEBN_CKB_negedge_posedge,
          HoldLow                 => thold_WEBN_CKB_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSB_ipd = '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_DIA_CKA_posedge,
          TimingData              => Tmkr_DIA_CKA_posedge,
          TestSignal              => DIA_ipd,
          TestSignalName          => "DIA",
          TestDelay               => 0 ns,
          RefSignal               => CKA_ipd,
          RefSignalName           => "CKA",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_DIA0_CKA_posedge_posedge,
          SetupLow                => tsetup_DIA0_CKA_negedge_posedge,
          HoldHigh                => thold_DIA0_CKA_negedge_posedge,
          HoldLow                 => thold_DIA0_CKA_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSA_ipd = '1' AND WEAN_ipd /= '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
         VitalSetupHoldCheck (
          Violation               => Tviol_DIB_CKB_posedge,
          TimingData              => Tmkr_DIB_CKB_posedge,
          TestSignal              => DIB_ipd,
          TestSignalName          => "DIB",
          TestDelay               => 0 ns,
          RefSignal               => CKB_ipd,
          RefSignalName           => "CKB",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_DIB0_CKB_posedge_posedge,
          SetupLow                => tsetup_DIB0_CKB_negedge_posedge,
          HoldHigh                => thold_DIB0_CKB_negedge_posedge,
          HoldLow                 => thold_DIB0_CKB_posedge_posedge,
          CheckEnabled            =>
                           NOW /= 0 ns AND CSB_ipd = '1' AND WEBN_ipd /= '1',
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_CSA_CKA_posedge,
          TimingData              => Tmkr_CSA_CKA_posedge,
          TestSignal              => CSA_ipd,
          TestSignalName          => "CSA",
          TestDelay               => 0 ns,
          RefSignal               => CKA_ipd,
          RefSignalName           => "CKA",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_CSA_CKA_posedge_posedge,
          SetupLow                => tsetup_CSA_CKA_negedge_posedge,
          HoldHigh                => thold_CSA_CKA_negedge_posedge,
          HoldLow                 => thold_CSA_CKA_posedge_posedge,
          CheckEnabled            => NOW /= 0 ns,
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalSetupHoldCheck (
          Violation               => Tviol_CSB_CKB_posedge,
          TimingData              => Tmkr_CSB_CKB_posedge,
          TestSignal              => CSB_ipd,
          TestSignalName          => "CSB",
          TestDelay               => 0 ns,
          RefSignal               => CKB_ipd,
          RefSignalName           => "CKB",
          RefDelay                => 0 ns,
          SetupHigh               => tsetup_CSB_CKB_posedge_posedge,
          SetupLow                => tsetup_CSB_CKB_negedge_posedge,
          HoldHigh                => thold_CSB_CKB_negedge_posedge,
          HoldLow                 => thold_CSB_CKB_posedge_posedge,
          CheckEnabled            => NOW /= 0 ns,
          RefTransition           => 'R',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalPeriodPulseCheck (
          Violation               => Pviol_CKA,
          PeriodData              => Pdata_CKA,
          TestSignal              => CKA_ipd,
          TestSignalName          => "CKA",
          TestDelay               => 0 ns,
          Period                  => tperiod_CKA,
          PulseWidthHigh          => tpw_CKA_posedge,
          PulseWidthLow           => tpw_CKA_negedge,
          CheckEnabled            => NOW /= 0 ns AND CSA_ipd = '1',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);

         VitalPeriodPulseCheck (
          Violation               => Pviol_CKB,
          PeriodData              => Pdata_CKB,
          TestSignal              => CKB_ipd,
          TestSignalName          => "CKB",
          TestDelay               => 0 ns,
          Period                  => tperiod_CKB,
          PulseWidthHigh          => tpw_CKB_posedge,
          PulseWidthLow           => tpw_CKB_negedge,
          CheckEnabled            => NOW /= 0 ns AND CSB_ipd = '1',
          HeaderMsg               => InstancePath & "/DUAL_512x128",
          Xon                     => Xon,
          MsgOn                   => MsgOn,
          MsgSeverity             => WARNING);
   end if;

   -------------------------
   --  Functionality Section
   -------------------------

       if (CKA_ipd'event) then
         cka_change := LastClkAEdge&CKA_ipd;
         case cka_change is
            when "01"   =>
                if (CS_monitor(CSA_ipd,flag_CSA) = True_flg) then
                   -- Reduce error message --
                   flag_CSA := True_flg;
                else
                   flag_CSA := False_flg;
                end if;

                Latch_A      := A_ipd;
                Latch_CSA    := CSA_ipd;
                Latch_DIA   := DIA_ipd;
                Latch_WEAN  := WEAN_ipd;

                -- memory_functionA
                A_i    := Latch_A;
                CSA_i  := Latch_CSA;
                DIA_i  := Latch_DIA;
                WEAN_i := Latch_WEAN;

                wea_csa    := WEAN_i&CSA_i;
                case wea_csa is
                   when "11" =>
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           if ((A_i = LastCycleBAddress) and
                               (Last_WEBN_i = '0') and
                               ((NOW-Last_tc_ClkB_PosEdge) < Tw2r)) then
                                 -- read and write the same address
                              assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                              DOA_zd := (OTHERS => 'X');
                              DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           else
                              DOA_zd := memoryCore(to_integer(A_i));
                              ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                              tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                              tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                              tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                              tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                              tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                              tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                              tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                              tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(8), DOA_zd(8),
                              tpd_CKA_DOA8_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(9), DOA_zd(9),
                              tpd_CKA_DOA9_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(10), DOA_zd(10),
                              tpd_CKA_DOA10_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(11), DOA_zd(11),
                              tpd_CKA_DOA11_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(12), DOA_zd(12),
                              tpd_CKA_DOA12_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(13), DOA_zd(13),
                              tpd_CKA_DOA13_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(14), DOA_zd(14),
                              tpd_CKA_DOA14_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(15), DOA_zd(15),
                              tpd_CKA_DOA15_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(16), DOA_zd(16),
                              tpd_CKA_DOA16_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(17), DOA_zd(17),
                              tpd_CKA_DOA17_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(18), DOA_zd(18),
                              tpd_CKA_DOA18_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(19), DOA_zd(19),
                              tpd_CKA_DOA19_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(20), DOA_zd(20),
                              tpd_CKA_DOA20_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(21), DOA_zd(21),
                              tpd_CKA_DOA21_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(22), DOA_zd(22),
                              tpd_CKA_DOA22_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(23), DOA_zd(23),
                              tpd_CKA_DOA23_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(24), DOA_zd(24),
                              tpd_CKA_DOA24_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(25), DOA_zd(25),
                              tpd_CKA_DOA25_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(26), DOA_zd(26),
                              tpd_CKA_DOA26_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(27), DOA_zd(27),
                              tpd_CKA_DOA27_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(28), DOA_zd(28),
                              tpd_CKA_DOA28_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(29), DOA_zd(29),
                              tpd_CKA_DOA29_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(30), DOA_zd(30),
                              tpd_CKA_DOA30_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(31), DOA_zd(31),
                              tpd_CKA_DOA31_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(32), DOA_zd(32),
                              tpd_CKA_DOA32_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(33), DOA_zd(33),
                              tpd_CKA_DOA33_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(34), DOA_zd(34),
                              tpd_CKA_DOA34_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(35), DOA_zd(35),
                              tpd_CKA_DOA35_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(36), DOA_zd(36),
                              tpd_CKA_DOA36_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(37), DOA_zd(37),
                              tpd_CKA_DOA37_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(38), DOA_zd(38),
                              tpd_CKA_DOA38_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(39), DOA_zd(39),
                              tpd_CKA_DOA39_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(40), DOA_zd(40),
                              tpd_CKA_DOA40_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(41), DOA_zd(41),
                              tpd_CKA_DOA41_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(42), DOA_zd(42),
                              tpd_CKA_DOA42_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(43), DOA_zd(43),
                              tpd_CKA_DOA43_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(44), DOA_zd(44),
                              tpd_CKA_DOA44_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(45), DOA_zd(45),
                              tpd_CKA_DOA45_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(46), DOA_zd(46),
                              tpd_CKA_DOA46_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(47), DOA_zd(47),
                              tpd_CKA_DOA47_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(48), DOA_zd(48),
                              tpd_CKA_DOA48_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(49), DOA_zd(49),
                              tpd_CKA_DOA49_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(50), DOA_zd(50),
                              tpd_CKA_DOA50_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(51), DOA_zd(51),
                              tpd_CKA_DOA51_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(52), DOA_zd(52),
                              tpd_CKA_DOA52_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(53), DOA_zd(53),
                              tpd_CKA_DOA53_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(54), DOA_zd(54),
                              tpd_CKA_DOA54_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(55), DOA_zd(55),
                              tpd_CKA_DOA55_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(56), DOA_zd(56),
                              tpd_CKA_DOA56_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(57), DOA_zd(57),
                              tpd_CKA_DOA57_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(58), DOA_zd(58),
                              tpd_CKA_DOA58_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(59), DOA_zd(59),
                              tpd_CKA_DOA59_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(60), DOA_zd(60),
                              tpd_CKA_DOA60_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(61), DOA_zd(61),
                              tpd_CKA_DOA61_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(62), DOA_zd(62),
                              tpd_CKA_DOA62_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(63), DOA_zd(63),
                              tpd_CKA_DOA63_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(64), DOA_zd(64),
                              tpd_CKA_DOA64_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(65), DOA_zd(65),
                              tpd_CKA_DOA65_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(66), DOA_zd(66),
                              tpd_CKA_DOA66_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(67), DOA_zd(67),
                              tpd_CKA_DOA67_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(68), DOA_zd(68),
                              tpd_CKA_DOA68_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(69), DOA_zd(69),
                              tpd_CKA_DOA69_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(70), DOA_zd(70),
                              tpd_CKA_DOA70_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(71), DOA_zd(71),
                              tpd_CKA_DOA71_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(72), DOA_zd(72),
                              tpd_CKA_DOA72_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(73), DOA_zd(73),
                              tpd_CKA_DOA73_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(74), DOA_zd(74),
                              tpd_CKA_DOA74_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(75), DOA_zd(75),
                              tpd_CKA_DOA75_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(76), DOA_zd(76),
                              tpd_CKA_DOA76_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(77), DOA_zd(77),
                              tpd_CKA_DOA77_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(78), DOA_zd(78),
                              tpd_CKA_DOA78_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(79), DOA_zd(79),
                              tpd_CKA_DOA79_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(80), DOA_zd(80),
                              tpd_CKA_DOA80_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(81), DOA_zd(81),
                              tpd_CKA_DOA81_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(82), DOA_zd(82),
                              tpd_CKA_DOA82_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(83), DOA_zd(83),
                              tpd_CKA_DOA83_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(84), DOA_zd(84),
                              tpd_CKA_DOA84_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(85), DOA_zd(85),
                              tpd_CKA_DOA85_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(86), DOA_zd(86),
                              tpd_CKA_DOA86_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(87), DOA_zd(87),
                              tpd_CKA_DOA87_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(88), DOA_zd(88),
                              tpd_CKA_DOA88_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(89), DOA_zd(89),
                              tpd_CKA_DOA89_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(90), DOA_zd(90),
                              tpd_CKA_DOA90_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(91), DOA_zd(91),
                              tpd_CKA_DOA91_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(92), DOA_zd(92),
                              tpd_CKA_DOA92_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(93), DOA_zd(93),
                              tpd_CKA_DOA93_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(94), DOA_zd(94),
                              tpd_CKA_DOA94_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(95), DOA_zd(95),
                              tpd_CKA_DOA95_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(96), DOA_zd(96),
                              tpd_CKA_DOA96_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(97), DOA_zd(97),
                              tpd_CKA_DOA97_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(98), DOA_zd(98),
                              tpd_CKA_DOA98_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(99), DOA_zd(99),
                              tpd_CKA_DOA99_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(100), DOA_zd(100),
                              tpd_CKA_DOA100_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(101), DOA_zd(101),
                              tpd_CKA_DOA101_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(102), DOA_zd(102),
                              tpd_CKA_DOA102_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(103), DOA_zd(103),
                              tpd_CKA_DOA103_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(104), DOA_zd(104),
                              tpd_CKA_DOA104_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(105), DOA_zd(105),
                              tpd_CKA_DOA105_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(106), DOA_zd(106),
                              tpd_CKA_DOA106_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(107), DOA_zd(107),
                              tpd_CKA_DOA107_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(108), DOA_zd(108),
                              tpd_CKA_DOA108_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(109), DOA_zd(109),
                              tpd_CKA_DOA109_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(110), DOA_zd(110),
                              tpd_CKA_DOA110_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(111), DOA_zd(111),
                              tpd_CKA_DOA111_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(112), DOA_zd(112),
                              tpd_CKA_DOA112_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(113), DOA_zd(113),
                              tpd_CKA_DOA113_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(114), DOA_zd(114),
                              tpd_CKA_DOA114_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(115), DOA_zd(115),
                              tpd_CKA_DOA115_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(116), DOA_zd(116),
                              tpd_CKA_DOA116_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(117), DOA_zd(117),
                              tpd_CKA_DOA117_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(118), DOA_zd(118),
                              tpd_CKA_DOA118_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(119), DOA_zd(119),
                              tpd_CKA_DOA119_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(120), DOA_zd(120),
                              tpd_CKA_DOA120_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(121), DOA_zd(121),
                              tpd_CKA_DOA121_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(122), DOA_zd(122),
                              tpd_CKA_DOA122_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(123), DOA_zd(123),
                              tpd_CKA_DOA123_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(124), DOA_zd(124),
                              tpd_CKA_DOA124_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(125), DOA_zd(125),
                              tpd_CKA_DOA125_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(126), DOA_zd(126),
                              tpd_CKA_DOA126_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(127), DOA_zd(127),
                              tpd_CKA_DOA127_posedge,last_A,A_i,NO_SER_TOH);
                           end if;
                           -- Reduce error message --
                           flag_A := True_flg;
                       end if;
                       LastCycleAAddress := A_i;

                   when "01" =>
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           if (A_i = LastCycleBAddress) then
                              if ((Last_WEBN_i = '1') and ((NOW-Last_tc_ClkB_PosEdge) < Tr2w)) then
                                 -- read and write the same address
                                 assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                                 DOB_zd := (OTHERS => 'X');
                                 DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                 memoryCore(to_integer(A_i)) := DIA_i;
                              elsif ((Last_WEBN_i = '0') and ((NOW-Last_tc_ClkB_PosEdge) < Tw2r)) then
                                 assert FALSE report "** MEM_Error: Port A and B write the same Address, core is unknown." severity WARNING;
                                 memoryCore(to_integer(A_i)) := (OTHERS => 'X');
                              else
                                 memoryCore(to_integer(A_i)) := DIA_i;
                              end if;
                           else
                              memoryCore(to_integer(A_i)) := DIA_i;
                           end if;
                           -- Reduce error message --
                           flag_A := True_flg;
                           -- write through --
                           DOA_zd := DIA_i;
                           ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                           tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                           tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                           tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                           tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                           tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                           tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                           tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                           tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(8), DOA_zd(8),
                           tpd_CKA_DOA8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(9), DOA_zd(9),
                           tpd_CKA_DOA9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(10), DOA_zd(10),
                           tpd_CKA_DOA10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(11), DOA_zd(11),
                           tpd_CKA_DOA11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(12), DOA_zd(12),
                           tpd_CKA_DOA12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(13), DOA_zd(13),
                           tpd_CKA_DOA13_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(14), DOA_zd(14),
                           tpd_CKA_DOA14_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(15), DOA_zd(15),
                           tpd_CKA_DOA15_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(16), DOA_zd(16),
                           tpd_CKA_DOA16_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(17), DOA_zd(17),
                           tpd_CKA_DOA17_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(18), DOA_zd(18),
                           tpd_CKA_DOA18_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(19), DOA_zd(19),
                           tpd_CKA_DOA19_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(20), DOA_zd(20),
                           tpd_CKA_DOA20_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(21), DOA_zd(21),
                           tpd_CKA_DOA21_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(22), DOA_zd(22),
                           tpd_CKA_DOA22_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(23), DOA_zd(23),
                           tpd_CKA_DOA23_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(24), DOA_zd(24),
                           tpd_CKA_DOA24_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(25), DOA_zd(25),
                           tpd_CKA_DOA25_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(26), DOA_zd(26),
                           tpd_CKA_DOA26_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(27), DOA_zd(27),
                           tpd_CKA_DOA27_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(28), DOA_zd(28),
                           tpd_CKA_DOA28_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(29), DOA_zd(29),
                           tpd_CKA_DOA29_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(30), DOA_zd(30),
                           tpd_CKA_DOA30_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(31), DOA_zd(31),
                           tpd_CKA_DOA31_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(32), DOA_zd(32),
                           tpd_CKA_DOA32_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(33), DOA_zd(33),
                           tpd_CKA_DOA33_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(34), DOA_zd(34),
                           tpd_CKA_DOA34_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(35), DOA_zd(35),
                           tpd_CKA_DOA35_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(36), DOA_zd(36),
                           tpd_CKA_DOA36_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(37), DOA_zd(37),
                           tpd_CKA_DOA37_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(38), DOA_zd(38),
                           tpd_CKA_DOA38_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(39), DOA_zd(39),
                           tpd_CKA_DOA39_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(40), DOA_zd(40),
                           tpd_CKA_DOA40_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(41), DOA_zd(41),
                           tpd_CKA_DOA41_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(42), DOA_zd(42),
                           tpd_CKA_DOA42_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(43), DOA_zd(43),
                           tpd_CKA_DOA43_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(44), DOA_zd(44),
                           tpd_CKA_DOA44_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(45), DOA_zd(45),
                           tpd_CKA_DOA45_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(46), DOA_zd(46),
                           tpd_CKA_DOA46_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(47), DOA_zd(47),
                           tpd_CKA_DOA47_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(48), DOA_zd(48),
                           tpd_CKA_DOA48_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(49), DOA_zd(49),
                           tpd_CKA_DOA49_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(50), DOA_zd(50),
                           tpd_CKA_DOA50_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(51), DOA_zd(51),
                           tpd_CKA_DOA51_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(52), DOA_zd(52),
                           tpd_CKA_DOA52_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(53), DOA_zd(53),
                           tpd_CKA_DOA53_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(54), DOA_zd(54),
                           tpd_CKA_DOA54_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(55), DOA_zd(55),
                           tpd_CKA_DOA55_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(56), DOA_zd(56),
                           tpd_CKA_DOA56_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(57), DOA_zd(57),
                           tpd_CKA_DOA57_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(58), DOA_zd(58),
                           tpd_CKA_DOA58_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(59), DOA_zd(59),
                           tpd_CKA_DOA59_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(60), DOA_zd(60),
                           tpd_CKA_DOA60_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(61), DOA_zd(61),
                           tpd_CKA_DOA61_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(62), DOA_zd(62),
                           tpd_CKA_DOA62_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(63), DOA_zd(63),
                           tpd_CKA_DOA63_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(64), DOA_zd(64),
                           tpd_CKA_DOA64_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(65), DOA_zd(65),
                           tpd_CKA_DOA65_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(66), DOA_zd(66),
                           tpd_CKA_DOA66_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(67), DOA_zd(67),
                           tpd_CKA_DOA67_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(68), DOA_zd(68),
                           tpd_CKA_DOA68_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(69), DOA_zd(69),
                           tpd_CKA_DOA69_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(70), DOA_zd(70),
                           tpd_CKA_DOA70_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(71), DOA_zd(71),
                           tpd_CKA_DOA71_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(72), DOA_zd(72),
                           tpd_CKA_DOA72_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(73), DOA_zd(73),
                           tpd_CKA_DOA73_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(74), DOA_zd(74),
                           tpd_CKA_DOA74_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(75), DOA_zd(75),
                           tpd_CKA_DOA75_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(76), DOA_zd(76),
                           tpd_CKA_DOA76_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(77), DOA_zd(77),
                           tpd_CKA_DOA77_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(78), DOA_zd(78),
                           tpd_CKA_DOA78_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(79), DOA_zd(79),
                           tpd_CKA_DOA79_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(80), DOA_zd(80),
                           tpd_CKA_DOA80_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(81), DOA_zd(81),
                           tpd_CKA_DOA81_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(82), DOA_zd(82),
                           tpd_CKA_DOA82_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(83), DOA_zd(83),
                           tpd_CKA_DOA83_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(84), DOA_zd(84),
                           tpd_CKA_DOA84_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(85), DOA_zd(85),
                           tpd_CKA_DOA85_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(86), DOA_zd(86),
                           tpd_CKA_DOA86_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(87), DOA_zd(87),
                           tpd_CKA_DOA87_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(88), DOA_zd(88),
                           tpd_CKA_DOA88_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(89), DOA_zd(89),
                           tpd_CKA_DOA89_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(90), DOA_zd(90),
                           tpd_CKA_DOA90_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(91), DOA_zd(91),
                           tpd_CKA_DOA91_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(92), DOA_zd(92),
                           tpd_CKA_DOA92_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(93), DOA_zd(93),
                           tpd_CKA_DOA93_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(94), DOA_zd(94),
                           tpd_CKA_DOA94_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(95), DOA_zd(95),
                           tpd_CKA_DOA95_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(96), DOA_zd(96),
                           tpd_CKA_DOA96_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(97), DOA_zd(97),
                           tpd_CKA_DOA97_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(98), DOA_zd(98),
                           tpd_CKA_DOA98_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(99), DOA_zd(99),
                           tpd_CKA_DOA99_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(100), DOA_zd(100),
                           tpd_CKA_DOA100_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(101), DOA_zd(101),
                           tpd_CKA_DOA101_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(102), DOA_zd(102),
                           tpd_CKA_DOA102_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(103), DOA_zd(103),
                           tpd_CKA_DOA103_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(104), DOA_zd(104),
                           tpd_CKA_DOA104_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(105), DOA_zd(105),
                           tpd_CKA_DOA105_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(106), DOA_zd(106),
                           tpd_CKA_DOA106_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(107), DOA_zd(107),
                           tpd_CKA_DOA107_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(108), DOA_zd(108),
                           tpd_CKA_DOA108_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(109), DOA_zd(109),
                           tpd_CKA_DOA109_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(110), DOA_zd(110),
                           tpd_CKA_DOA110_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(111), DOA_zd(111),
                           tpd_CKA_DOA111_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(112), DOA_zd(112),
                           tpd_CKA_DOA112_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(113), DOA_zd(113),
                           tpd_CKA_DOA113_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(114), DOA_zd(114),
                           tpd_CKA_DOA114_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(115), DOA_zd(115),
                           tpd_CKA_DOA115_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(116), DOA_zd(116),
                           tpd_CKA_DOA116_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(117), DOA_zd(117),
                           tpd_CKA_DOA117_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(118), DOA_zd(118),
                           tpd_CKA_DOA118_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(119), DOA_zd(119),
                           tpd_CKA_DOA119_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(120), DOA_zd(120),
                           tpd_CKA_DOA120_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(121), DOA_zd(121),
                           tpd_CKA_DOA121_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(122), DOA_zd(122),
                           tpd_CKA_DOA122_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(123), DOA_zd(123),
                           tpd_CKA_DOA123_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(124), DOA_zd(124),
                           tpd_CKA_DOA124_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(125), DOA_zd(125),
                           tpd_CKA_DOA125_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(126), DOA_zd(126),
                           tpd_CKA_DOA126_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(127), DOA_zd(127),
                           tpd_CKA_DOA127_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           -- write through --
                           DOA_zd := DIA_i;
                           ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                           tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                           tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                           tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                           tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                           tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                           tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                           tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                           tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(8), DOA_zd(8),
                           tpd_CKA_DOA8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(9), DOA_zd(9),
                           tpd_CKA_DOA9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(10), DOA_zd(10),
                           tpd_CKA_DOA10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(11), DOA_zd(11),
                           tpd_CKA_DOA11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(12), DOA_zd(12),
                           tpd_CKA_DOA12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(13), DOA_zd(13),
                           tpd_CKA_DOA13_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(14), DOA_zd(14),
                           tpd_CKA_DOA14_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(15), DOA_zd(15),
                           tpd_CKA_DOA15_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(16), DOA_zd(16),
                           tpd_CKA_DOA16_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(17), DOA_zd(17),
                           tpd_CKA_DOA17_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(18), DOA_zd(18),
                           tpd_CKA_DOA18_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(19), DOA_zd(19),
                           tpd_CKA_DOA19_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(20), DOA_zd(20),
                           tpd_CKA_DOA20_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(21), DOA_zd(21),
                           tpd_CKA_DOA21_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(22), DOA_zd(22),
                           tpd_CKA_DOA22_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(23), DOA_zd(23),
                           tpd_CKA_DOA23_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(24), DOA_zd(24),
                           tpd_CKA_DOA24_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(25), DOA_zd(25),
                           tpd_CKA_DOA25_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(26), DOA_zd(26),
                           tpd_CKA_DOA26_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(27), DOA_zd(27),
                           tpd_CKA_DOA27_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(28), DOA_zd(28),
                           tpd_CKA_DOA28_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(29), DOA_zd(29),
                           tpd_CKA_DOA29_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(30), DOA_zd(30),
                           tpd_CKA_DOA30_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(31), DOA_zd(31),
                           tpd_CKA_DOA31_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(32), DOA_zd(32),
                           tpd_CKA_DOA32_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(33), DOA_zd(33),
                           tpd_CKA_DOA33_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(34), DOA_zd(34),
                           tpd_CKA_DOA34_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(35), DOA_zd(35),
                           tpd_CKA_DOA35_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(36), DOA_zd(36),
                           tpd_CKA_DOA36_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(37), DOA_zd(37),
                           tpd_CKA_DOA37_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(38), DOA_zd(38),
                           tpd_CKA_DOA38_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(39), DOA_zd(39),
                           tpd_CKA_DOA39_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(40), DOA_zd(40),
                           tpd_CKA_DOA40_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(41), DOA_zd(41),
                           tpd_CKA_DOA41_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(42), DOA_zd(42),
                           tpd_CKA_DOA42_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(43), DOA_zd(43),
                           tpd_CKA_DOA43_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(44), DOA_zd(44),
                           tpd_CKA_DOA44_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(45), DOA_zd(45),
                           tpd_CKA_DOA45_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(46), DOA_zd(46),
                           tpd_CKA_DOA46_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(47), DOA_zd(47),
                           tpd_CKA_DOA47_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(48), DOA_zd(48),
                           tpd_CKA_DOA48_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(49), DOA_zd(49),
                           tpd_CKA_DOA49_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(50), DOA_zd(50),
                           tpd_CKA_DOA50_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(51), DOA_zd(51),
                           tpd_CKA_DOA51_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(52), DOA_zd(52),
                           tpd_CKA_DOA52_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(53), DOA_zd(53),
                           tpd_CKA_DOA53_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(54), DOA_zd(54),
                           tpd_CKA_DOA54_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(55), DOA_zd(55),
                           tpd_CKA_DOA55_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(56), DOA_zd(56),
                           tpd_CKA_DOA56_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(57), DOA_zd(57),
                           tpd_CKA_DOA57_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(58), DOA_zd(58),
                           tpd_CKA_DOA58_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(59), DOA_zd(59),
                           tpd_CKA_DOA59_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(60), DOA_zd(60),
                           tpd_CKA_DOA60_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(61), DOA_zd(61),
                           tpd_CKA_DOA61_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(62), DOA_zd(62),
                           tpd_CKA_DOA62_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(63), DOA_zd(63),
                           tpd_CKA_DOA63_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(64), DOA_zd(64),
                           tpd_CKA_DOA64_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(65), DOA_zd(65),
                           tpd_CKA_DOA65_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(66), DOA_zd(66),
                           tpd_CKA_DOA66_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(67), DOA_zd(67),
                           tpd_CKA_DOA67_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(68), DOA_zd(68),
                           tpd_CKA_DOA68_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(69), DOA_zd(69),
                           tpd_CKA_DOA69_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(70), DOA_zd(70),
                           tpd_CKA_DOA70_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(71), DOA_zd(71),
                           tpd_CKA_DOA71_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(72), DOA_zd(72),
                           tpd_CKA_DOA72_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(73), DOA_zd(73),
                           tpd_CKA_DOA73_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(74), DOA_zd(74),
                           tpd_CKA_DOA74_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(75), DOA_zd(75),
                           tpd_CKA_DOA75_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(76), DOA_zd(76),
                           tpd_CKA_DOA76_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(77), DOA_zd(77),
                           tpd_CKA_DOA77_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(78), DOA_zd(78),
                           tpd_CKA_DOA78_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(79), DOA_zd(79),
                           tpd_CKA_DOA79_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(80), DOA_zd(80),
                           tpd_CKA_DOA80_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(81), DOA_zd(81),
                           tpd_CKA_DOA81_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(82), DOA_zd(82),
                           tpd_CKA_DOA82_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(83), DOA_zd(83),
                           tpd_CKA_DOA83_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(84), DOA_zd(84),
                           tpd_CKA_DOA84_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(85), DOA_zd(85),
                           tpd_CKA_DOA85_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(86), DOA_zd(86),
                           tpd_CKA_DOA86_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(87), DOA_zd(87),
                           tpd_CKA_DOA87_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(88), DOA_zd(88),
                           tpd_CKA_DOA88_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(89), DOA_zd(89),
                           tpd_CKA_DOA89_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(90), DOA_zd(90),
                           tpd_CKA_DOA90_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(91), DOA_zd(91),
                           tpd_CKA_DOA91_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(92), DOA_zd(92),
                           tpd_CKA_DOA92_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(93), DOA_zd(93),
                           tpd_CKA_DOA93_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(94), DOA_zd(94),
                           tpd_CKA_DOA94_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(95), DOA_zd(95),
                           tpd_CKA_DOA95_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(96), DOA_zd(96),
                           tpd_CKA_DOA96_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(97), DOA_zd(97),
                           tpd_CKA_DOA97_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(98), DOA_zd(98),
                           tpd_CKA_DOA98_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(99), DOA_zd(99),
                           tpd_CKA_DOA99_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(100), DOA_zd(100),
                           tpd_CKA_DOA100_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(101), DOA_zd(101),
                           tpd_CKA_DOA101_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(102), DOA_zd(102),
                           tpd_CKA_DOA102_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(103), DOA_zd(103),
                           tpd_CKA_DOA103_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(104), DOA_zd(104),
                           tpd_CKA_DOA104_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(105), DOA_zd(105),
                           tpd_CKA_DOA105_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(106), DOA_zd(106),
                           tpd_CKA_DOA106_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(107), DOA_zd(107),
                           tpd_CKA_DOA107_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(108), DOA_zd(108),
                           tpd_CKA_DOA108_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(109), DOA_zd(109),
                           tpd_CKA_DOA109_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(110), DOA_zd(110),
                           tpd_CKA_DOA110_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(111), DOA_zd(111),
                           tpd_CKA_DOA111_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(112), DOA_zd(112),
                           tpd_CKA_DOA112_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(113), DOA_zd(113),
                           tpd_CKA_DOA113_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(114), DOA_zd(114),
                           tpd_CKA_DOA114_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(115), DOA_zd(115),
                           tpd_CKA_DOA115_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(116), DOA_zd(116),
                           tpd_CKA_DOA116_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(117), DOA_zd(117),
                           tpd_CKA_DOA117_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(118), DOA_zd(118),
                           tpd_CKA_DOA118_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(119), DOA_zd(119),
                           tpd_CKA_DOA119_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(120), DOA_zd(120),
                           tpd_CKA_DOA120_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(121), DOA_zd(121),
                           tpd_CKA_DOA121_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(122), DOA_zd(122),
                           tpd_CKA_DOA122_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(123), DOA_zd(123),
                           tpd_CKA_DOA123_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(124), DOA_zd(124),
                           tpd_CKA_DOA124_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(125), DOA_zd(125),
                           tpd_CKA_DOA125_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(126), DOA_zd(126),
                           tpd_CKA_DOA126_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(127), DOA_zd(127),
                           tpd_CKA_DOA127_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DOA_zd := (OTHERS => 'X');
                           DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                       LastCycleAAddress := A_i;
                   when "1X" |
                        "1U" |
                        "1Z"   =>
                       DOA_zd := (OTHERS => 'X');
                       DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;

                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                       DOA_zd := (OTHERS => 'X');
                       DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           memoryCore(to_integer(A_i)) := (OTHERS => 'X');
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                       else
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                end case;
                Last_WEAN_i := WEAN_i;
                -- end memory_functionA

                last_A := A_ipd;

                if (CSA_i = '1') then
                   Last_tc_ClkA_PosEdge := NOW;
                end if;
            when "10"   => -- do nothing
            when others => if (NOW /= 0 ns and CSA_ipd /= '0') then
                              assert FALSE report "** MEM_Error: Abnormal transition occurred." severity WARNING;
                              if (WEAN_ipd /= '1') then
                                 DOA_zd := (OTHERS => 'X');
                                 DOA_int <= TRANSPORT (OTHERS => 'X');
                                 FOR i IN Words-1 downto 0 LOOP
                                   memoryCore(i) := (OTHERS => 'X');
                                 END LOOP;
			      else
                                 DOA_int <= TRANSPORT (OTHERS => 'X');			      	
			      end if;	
                           end if;
         end case;
         LastClkAEdge := CKA_ipd;
       end if;

       if (CKB_ipd'event) then
         ckb_change := LastClkBEdge&CKB_ipd;
         case ckb_change is
            when "01"   =>
                if (CS_monitor(CSB_ipd,flag_CSB) = True_flg) then
                   -- Reduce error message --
                   flag_CSB := True_flg;
                else
                   flag_CSB := False_flg;
                end if;

                Latch_B      := B_ipd;
                Latch_CSB    := CSB_ipd;
                Latch_DIB   := DIB_ipd;
                Latch_WEBN  := WEBN_ipd;

                -- memory_functionB
                B_i    := Latch_B;
                CSB_i  := Latch_CSB;
                DIB_i  := Latch_DIB;
                WEBN_i := Latch_WEBN;

                web_csb    := WEBN_i&CSB_i;
                case web_csb is
                   when "11" =>
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           if ((B_i = LastCycleAAddress) and
                               (Last_WEAN_i = '0') and
                               ((NOW-Last_tc_ClkA_PosEdge) < Tw2r)) then
                                 -- read and write the same address
                              assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                              DOB_zd := (OTHERS => 'X');
                              DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           else
                              DOB_zd := memoryCore(to_integer(B_i));
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(8), DOB_zd(8),
                              tpd_CKB_DOB8_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(9), DOB_zd(9),
                              tpd_CKB_DOB9_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(10), DOB_zd(10),
                              tpd_CKB_DOB10_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(11), DOB_zd(11),
                              tpd_CKB_DOB11_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(12), DOB_zd(12),
                              tpd_CKB_DOB12_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(13), DOB_zd(13),
                              tpd_CKB_DOB13_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(14), DOB_zd(14),
                              tpd_CKB_DOB14_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(15), DOB_zd(15),
                              tpd_CKB_DOB15_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(16), DOB_zd(16),
                              tpd_CKB_DOB16_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(17), DOB_zd(17),
                              tpd_CKB_DOB17_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(18), DOB_zd(18),
                              tpd_CKB_DOB18_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(19), DOB_zd(19),
                              tpd_CKB_DOB19_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(20), DOB_zd(20),
                              tpd_CKB_DOB20_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(21), DOB_zd(21),
                              tpd_CKB_DOB21_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(22), DOB_zd(22),
                              tpd_CKB_DOB22_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(23), DOB_zd(23),
                              tpd_CKB_DOB23_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(24), DOB_zd(24),
                              tpd_CKB_DOB24_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(25), DOB_zd(25),
                              tpd_CKB_DOB25_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(26), DOB_zd(26),
                              tpd_CKB_DOB26_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(27), DOB_zd(27),
                              tpd_CKB_DOB27_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(28), DOB_zd(28),
                              tpd_CKB_DOB28_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(29), DOB_zd(29),
                              tpd_CKB_DOB29_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(30), DOB_zd(30),
                              tpd_CKB_DOB30_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(31), DOB_zd(31),
                              tpd_CKB_DOB31_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(32), DOB_zd(32),
                              tpd_CKB_DOB32_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(33), DOB_zd(33),
                              tpd_CKB_DOB33_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(34), DOB_zd(34),
                              tpd_CKB_DOB34_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(35), DOB_zd(35),
                              tpd_CKB_DOB35_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(36), DOB_zd(36),
                              tpd_CKB_DOB36_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(37), DOB_zd(37),
                              tpd_CKB_DOB37_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(38), DOB_zd(38),
                              tpd_CKB_DOB38_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(39), DOB_zd(39),
                              tpd_CKB_DOB39_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(40), DOB_zd(40),
                              tpd_CKB_DOB40_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(41), DOB_zd(41),
                              tpd_CKB_DOB41_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(42), DOB_zd(42),
                              tpd_CKB_DOB42_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(43), DOB_zd(43),
                              tpd_CKB_DOB43_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(44), DOB_zd(44),
                              tpd_CKB_DOB44_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(45), DOB_zd(45),
                              tpd_CKB_DOB45_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(46), DOB_zd(46),
                              tpd_CKB_DOB46_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(47), DOB_zd(47),
                              tpd_CKB_DOB47_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(48), DOB_zd(48),
                              tpd_CKB_DOB48_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(49), DOB_zd(49),
                              tpd_CKB_DOB49_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(50), DOB_zd(50),
                              tpd_CKB_DOB50_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(51), DOB_zd(51),
                              tpd_CKB_DOB51_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(52), DOB_zd(52),
                              tpd_CKB_DOB52_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(53), DOB_zd(53),
                              tpd_CKB_DOB53_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(54), DOB_zd(54),
                              tpd_CKB_DOB54_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(55), DOB_zd(55),
                              tpd_CKB_DOB55_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(56), DOB_zd(56),
                              tpd_CKB_DOB56_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(57), DOB_zd(57),
                              tpd_CKB_DOB57_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(58), DOB_zd(58),
                              tpd_CKB_DOB58_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(59), DOB_zd(59),
                              tpd_CKB_DOB59_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(60), DOB_zd(60),
                              tpd_CKB_DOB60_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(61), DOB_zd(61),
                              tpd_CKB_DOB61_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(62), DOB_zd(62),
                              tpd_CKB_DOB62_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(63), DOB_zd(63),
                              tpd_CKB_DOB63_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(64), DOB_zd(64),
                              tpd_CKB_DOB64_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(65), DOB_zd(65),
                              tpd_CKB_DOB65_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(66), DOB_zd(66),
                              tpd_CKB_DOB66_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(67), DOB_zd(67),
                              tpd_CKB_DOB67_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(68), DOB_zd(68),
                              tpd_CKB_DOB68_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(69), DOB_zd(69),
                              tpd_CKB_DOB69_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(70), DOB_zd(70),
                              tpd_CKB_DOB70_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(71), DOB_zd(71),
                              tpd_CKB_DOB71_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(72), DOB_zd(72),
                              tpd_CKB_DOB72_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(73), DOB_zd(73),
                              tpd_CKB_DOB73_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(74), DOB_zd(74),
                              tpd_CKB_DOB74_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(75), DOB_zd(75),
                              tpd_CKB_DOB75_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(76), DOB_zd(76),
                              tpd_CKB_DOB76_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(77), DOB_zd(77),
                              tpd_CKB_DOB77_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(78), DOB_zd(78),
                              tpd_CKB_DOB78_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(79), DOB_zd(79),
                              tpd_CKB_DOB79_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(80), DOB_zd(80),
                              tpd_CKB_DOB80_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(81), DOB_zd(81),
                              tpd_CKB_DOB81_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(82), DOB_zd(82),
                              tpd_CKB_DOB82_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(83), DOB_zd(83),
                              tpd_CKB_DOB83_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(84), DOB_zd(84),
                              tpd_CKB_DOB84_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(85), DOB_zd(85),
                              tpd_CKB_DOB85_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(86), DOB_zd(86),
                              tpd_CKB_DOB86_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(87), DOB_zd(87),
                              tpd_CKB_DOB87_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(88), DOB_zd(88),
                              tpd_CKB_DOB88_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(89), DOB_zd(89),
                              tpd_CKB_DOB89_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(90), DOB_zd(90),
                              tpd_CKB_DOB90_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(91), DOB_zd(91),
                              tpd_CKB_DOB91_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(92), DOB_zd(92),
                              tpd_CKB_DOB92_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(93), DOB_zd(93),
                              tpd_CKB_DOB93_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(94), DOB_zd(94),
                              tpd_CKB_DOB94_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(95), DOB_zd(95),
                              tpd_CKB_DOB95_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(96), DOB_zd(96),
                              tpd_CKB_DOB96_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(97), DOB_zd(97),
                              tpd_CKB_DOB97_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(98), DOB_zd(98),
                              tpd_CKB_DOB98_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(99), DOB_zd(99),
                              tpd_CKB_DOB99_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(100), DOB_zd(100),
                              tpd_CKB_DOB100_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(101), DOB_zd(101),
                              tpd_CKB_DOB101_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(102), DOB_zd(102),
                              tpd_CKB_DOB102_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(103), DOB_zd(103),
                              tpd_CKB_DOB103_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(104), DOB_zd(104),
                              tpd_CKB_DOB104_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(105), DOB_zd(105),
                              tpd_CKB_DOB105_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(106), DOB_zd(106),
                              tpd_CKB_DOB106_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(107), DOB_zd(107),
                              tpd_CKB_DOB107_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(108), DOB_zd(108),
                              tpd_CKB_DOB108_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(109), DOB_zd(109),
                              tpd_CKB_DOB109_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(110), DOB_zd(110),
                              tpd_CKB_DOB110_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(111), DOB_zd(111),
                              tpd_CKB_DOB111_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(112), DOB_zd(112),
                              tpd_CKB_DOB112_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(113), DOB_zd(113),
                              tpd_CKB_DOB113_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(114), DOB_zd(114),
                              tpd_CKB_DOB114_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(115), DOB_zd(115),
                              tpd_CKB_DOB115_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(116), DOB_zd(116),
                              tpd_CKB_DOB116_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(117), DOB_zd(117),
                              tpd_CKB_DOB117_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(118), DOB_zd(118),
                              tpd_CKB_DOB118_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(119), DOB_zd(119),
                              tpd_CKB_DOB119_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(120), DOB_zd(120),
                              tpd_CKB_DOB120_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(121), DOB_zd(121),
                              tpd_CKB_DOB121_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(122), DOB_zd(122),
                              tpd_CKB_DOB122_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(123), DOB_zd(123),
                              tpd_CKB_DOB123_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(124), DOB_zd(124),
                              tpd_CKB_DOB124_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(125), DOB_zd(125),
                              tpd_CKB_DOB125_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(126), DOB_zd(126),
                              tpd_CKB_DOB126_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(127), DOB_zd(127),
                              tpd_CKB_DOB127_posedge,last_B,B_i,NO_SER_TOH);
                           end if;
                           -- Reduce error message --
                           flag_B := True_flg;
                       end if;
                       LastCycleBAddress := B_i;

                   when "01" =>
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           if (B_i = LastCycleAAddress) then
                              if ((Last_WEAN_i = '1') and ((NOW-Last_tc_ClkA_PosEdge) < Tr2w)) then
                                 -- read and write the same address
                                 assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                                 DOA_zd := (OTHERS => 'X');
                                 DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                 memoryCore(to_integer(B_i)) := DIB_i;
                              elsif ((Last_WEAN_i = '0') and ((NOW-Last_tc_ClkA_PosEdge) < Tw2r)) then
                                 assert FALSE report "** MEM_Error: Port A and B write the same Address, core is unknown." severity WARNING;
                                 memoryCore(to_integer(B_i)) := (OTHERS => 'X');
                              else
                                 memoryCore(to_integer(B_i)) := DIB_i;
                              end if;
                           else
                              memoryCore(to_integer(B_i)) := DIB_i;
                           end if;
                           -- Reduce error message --
                           flag_B := True_flg;
                           -- write through --
                           DOB_zd := DIB_i;
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(8), DOB_zd(8),
                              tpd_CKB_DOB8_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(9), DOB_zd(9),
                              tpd_CKB_DOB9_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(10), DOB_zd(10),
                              tpd_CKB_DOB10_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(11), DOB_zd(11),
                              tpd_CKB_DOB11_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(12), DOB_zd(12),
                              tpd_CKB_DOB12_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(13), DOB_zd(13),
                              tpd_CKB_DOB13_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(14), DOB_zd(14),
                              tpd_CKB_DOB14_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(15), DOB_zd(15),
                              tpd_CKB_DOB15_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(16), DOB_zd(16),
                              tpd_CKB_DOB16_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(17), DOB_zd(17),
                              tpd_CKB_DOB17_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(18), DOB_zd(18),
                              tpd_CKB_DOB18_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(19), DOB_zd(19),
                              tpd_CKB_DOB19_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(20), DOB_zd(20),
                              tpd_CKB_DOB20_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(21), DOB_zd(21),
                              tpd_CKB_DOB21_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(22), DOB_zd(22),
                              tpd_CKB_DOB22_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(23), DOB_zd(23),
                              tpd_CKB_DOB23_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(24), DOB_zd(24),
                              tpd_CKB_DOB24_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(25), DOB_zd(25),
                              tpd_CKB_DOB25_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(26), DOB_zd(26),
                              tpd_CKB_DOB26_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(27), DOB_zd(27),
                              tpd_CKB_DOB27_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(28), DOB_zd(28),
                              tpd_CKB_DOB28_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(29), DOB_zd(29),
                              tpd_CKB_DOB29_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(30), DOB_zd(30),
                              tpd_CKB_DOB30_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(31), DOB_zd(31),
                              tpd_CKB_DOB31_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(32), DOB_zd(32),
                              tpd_CKB_DOB32_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(33), DOB_zd(33),
                              tpd_CKB_DOB33_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(34), DOB_zd(34),
                              tpd_CKB_DOB34_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(35), DOB_zd(35),
                              tpd_CKB_DOB35_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(36), DOB_zd(36),
                              tpd_CKB_DOB36_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(37), DOB_zd(37),
                              tpd_CKB_DOB37_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(38), DOB_zd(38),
                              tpd_CKB_DOB38_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(39), DOB_zd(39),
                              tpd_CKB_DOB39_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(40), DOB_zd(40),
                              tpd_CKB_DOB40_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(41), DOB_zd(41),
                              tpd_CKB_DOB41_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(42), DOB_zd(42),
                              tpd_CKB_DOB42_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(43), DOB_zd(43),
                              tpd_CKB_DOB43_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(44), DOB_zd(44),
                              tpd_CKB_DOB44_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(45), DOB_zd(45),
                              tpd_CKB_DOB45_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(46), DOB_zd(46),
                              tpd_CKB_DOB46_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(47), DOB_zd(47),
                              tpd_CKB_DOB47_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(48), DOB_zd(48),
                              tpd_CKB_DOB48_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(49), DOB_zd(49),
                              tpd_CKB_DOB49_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(50), DOB_zd(50),
                              tpd_CKB_DOB50_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(51), DOB_zd(51),
                              tpd_CKB_DOB51_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(52), DOB_zd(52),
                              tpd_CKB_DOB52_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(53), DOB_zd(53),
                              tpd_CKB_DOB53_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(54), DOB_zd(54),
                              tpd_CKB_DOB54_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(55), DOB_zd(55),
                              tpd_CKB_DOB55_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(56), DOB_zd(56),
                              tpd_CKB_DOB56_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(57), DOB_zd(57),
                              tpd_CKB_DOB57_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(58), DOB_zd(58),
                              tpd_CKB_DOB58_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(59), DOB_zd(59),
                              tpd_CKB_DOB59_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(60), DOB_zd(60),
                              tpd_CKB_DOB60_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(61), DOB_zd(61),
                              tpd_CKB_DOB61_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(62), DOB_zd(62),
                              tpd_CKB_DOB62_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(63), DOB_zd(63),
                              tpd_CKB_DOB63_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(64), DOB_zd(64),
                              tpd_CKB_DOB64_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(65), DOB_zd(65),
                              tpd_CKB_DOB65_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(66), DOB_zd(66),
                              tpd_CKB_DOB66_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(67), DOB_zd(67),
                              tpd_CKB_DOB67_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(68), DOB_zd(68),
                              tpd_CKB_DOB68_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(69), DOB_zd(69),
                              tpd_CKB_DOB69_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(70), DOB_zd(70),
                              tpd_CKB_DOB70_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(71), DOB_zd(71),
                              tpd_CKB_DOB71_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(72), DOB_zd(72),
                              tpd_CKB_DOB72_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(73), DOB_zd(73),
                              tpd_CKB_DOB73_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(74), DOB_zd(74),
                              tpd_CKB_DOB74_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(75), DOB_zd(75),
                              tpd_CKB_DOB75_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(76), DOB_zd(76),
                              tpd_CKB_DOB76_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(77), DOB_zd(77),
                              tpd_CKB_DOB77_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(78), DOB_zd(78),
                              tpd_CKB_DOB78_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(79), DOB_zd(79),
                              tpd_CKB_DOB79_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(80), DOB_zd(80),
                              tpd_CKB_DOB80_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(81), DOB_zd(81),
                              tpd_CKB_DOB81_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(82), DOB_zd(82),
                              tpd_CKB_DOB82_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(83), DOB_zd(83),
                              tpd_CKB_DOB83_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(84), DOB_zd(84),
                              tpd_CKB_DOB84_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(85), DOB_zd(85),
                              tpd_CKB_DOB85_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(86), DOB_zd(86),
                              tpd_CKB_DOB86_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(87), DOB_zd(87),
                              tpd_CKB_DOB87_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(88), DOB_zd(88),
                              tpd_CKB_DOB88_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(89), DOB_zd(89),
                              tpd_CKB_DOB89_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(90), DOB_zd(90),
                              tpd_CKB_DOB90_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(91), DOB_zd(91),
                              tpd_CKB_DOB91_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(92), DOB_zd(92),
                              tpd_CKB_DOB92_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(93), DOB_zd(93),
                              tpd_CKB_DOB93_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(94), DOB_zd(94),
                              tpd_CKB_DOB94_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(95), DOB_zd(95),
                              tpd_CKB_DOB95_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(96), DOB_zd(96),
                              tpd_CKB_DOB96_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(97), DOB_zd(97),
                              tpd_CKB_DOB97_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(98), DOB_zd(98),
                              tpd_CKB_DOB98_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(99), DOB_zd(99),
                              tpd_CKB_DOB99_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(100), DOB_zd(100),
                              tpd_CKB_DOB100_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(101), DOB_zd(101),
                              tpd_CKB_DOB101_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(102), DOB_zd(102),
                              tpd_CKB_DOB102_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(103), DOB_zd(103),
                              tpd_CKB_DOB103_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(104), DOB_zd(104),
                              tpd_CKB_DOB104_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(105), DOB_zd(105),
                              tpd_CKB_DOB105_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(106), DOB_zd(106),
                              tpd_CKB_DOB106_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(107), DOB_zd(107),
                              tpd_CKB_DOB107_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(108), DOB_zd(108),
                              tpd_CKB_DOB108_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(109), DOB_zd(109),
                              tpd_CKB_DOB109_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(110), DOB_zd(110),
                              tpd_CKB_DOB110_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(111), DOB_zd(111),
                              tpd_CKB_DOB111_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(112), DOB_zd(112),
                              tpd_CKB_DOB112_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(113), DOB_zd(113),
                              tpd_CKB_DOB113_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(114), DOB_zd(114),
                              tpd_CKB_DOB114_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(115), DOB_zd(115),
                              tpd_CKB_DOB115_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(116), DOB_zd(116),
                              tpd_CKB_DOB116_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(117), DOB_zd(117),
                              tpd_CKB_DOB117_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(118), DOB_zd(118),
                              tpd_CKB_DOB118_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(119), DOB_zd(119),
                              tpd_CKB_DOB119_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(120), DOB_zd(120),
                              tpd_CKB_DOB120_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(121), DOB_zd(121),
                              tpd_CKB_DOB121_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(122), DOB_zd(122),
                              tpd_CKB_DOB122_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(123), DOB_zd(123),
                              tpd_CKB_DOB123_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(124), DOB_zd(124),
                              tpd_CKB_DOB124_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(125), DOB_zd(125),
                              tpd_CKB_DOB125_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(126), DOB_zd(126),
                              tpd_CKB_DOB126_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(127), DOB_zd(127),
                              tpd_CKB_DOB127_posedge,last_B,B_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(B_i,flag_B) = Range_flg) then
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                           -- write through --
                           DOB_zd := DIB_i;
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(8), DOB_zd(8),
                              tpd_CKB_DOB8_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(9), DOB_zd(9),
                              tpd_CKB_DOB9_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(10), DOB_zd(10),
                              tpd_CKB_DOB10_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(11), DOB_zd(11),
                              tpd_CKB_DOB11_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(12), DOB_zd(12),
                              tpd_CKB_DOB12_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(13), DOB_zd(13),
                              tpd_CKB_DOB13_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(14), DOB_zd(14),
                              tpd_CKB_DOB14_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(15), DOB_zd(15),
                              tpd_CKB_DOB15_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(16), DOB_zd(16),
                              tpd_CKB_DOB16_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(17), DOB_zd(17),
                              tpd_CKB_DOB17_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(18), DOB_zd(18),
                              tpd_CKB_DOB18_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(19), DOB_zd(19),
                              tpd_CKB_DOB19_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(20), DOB_zd(20),
                              tpd_CKB_DOB20_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(21), DOB_zd(21),
                              tpd_CKB_DOB21_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(22), DOB_zd(22),
                              tpd_CKB_DOB22_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(23), DOB_zd(23),
                              tpd_CKB_DOB23_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(24), DOB_zd(24),
                              tpd_CKB_DOB24_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(25), DOB_zd(25),
                              tpd_CKB_DOB25_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(26), DOB_zd(26),
                              tpd_CKB_DOB26_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(27), DOB_zd(27),
                              tpd_CKB_DOB27_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(28), DOB_zd(28),
                              tpd_CKB_DOB28_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(29), DOB_zd(29),
                              tpd_CKB_DOB29_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(30), DOB_zd(30),
                              tpd_CKB_DOB30_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(31), DOB_zd(31),
                              tpd_CKB_DOB31_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(32), DOB_zd(32),
                              tpd_CKB_DOB32_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(33), DOB_zd(33),
                              tpd_CKB_DOB33_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(34), DOB_zd(34),
                              tpd_CKB_DOB34_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(35), DOB_zd(35),
                              tpd_CKB_DOB35_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(36), DOB_zd(36),
                              tpd_CKB_DOB36_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(37), DOB_zd(37),
                              tpd_CKB_DOB37_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(38), DOB_zd(38),
                              tpd_CKB_DOB38_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(39), DOB_zd(39),
                              tpd_CKB_DOB39_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(40), DOB_zd(40),
                              tpd_CKB_DOB40_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(41), DOB_zd(41),
                              tpd_CKB_DOB41_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(42), DOB_zd(42),
                              tpd_CKB_DOB42_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(43), DOB_zd(43),
                              tpd_CKB_DOB43_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(44), DOB_zd(44),
                              tpd_CKB_DOB44_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(45), DOB_zd(45),
                              tpd_CKB_DOB45_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(46), DOB_zd(46),
                              tpd_CKB_DOB46_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(47), DOB_zd(47),
                              tpd_CKB_DOB47_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(48), DOB_zd(48),
                              tpd_CKB_DOB48_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(49), DOB_zd(49),
                              tpd_CKB_DOB49_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(50), DOB_zd(50),
                              tpd_CKB_DOB50_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(51), DOB_zd(51),
                              tpd_CKB_DOB51_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(52), DOB_zd(52),
                              tpd_CKB_DOB52_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(53), DOB_zd(53),
                              tpd_CKB_DOB53_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(54), DOB_zd(54),
                              tpd_CKB_DOB54_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(55), DOB_zd(55),
                              tpd_CKB_DOB55_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(56), DOB_zd(56),
                              tpd_CKB_DOB56_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(57), DOB_zd(57),
                              tpd_CKB_DOB57_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(58), DOB_zd(58),
                              tpd_CKB_DOB58_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(59), DOB_zd(59),
                              tpd_CKB_DOB59_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(60), DOB_zd(60),
                              tpd_CKB_DOB60_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(61), DOB_zd(61),
                              tpd_CKB_DOB61_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(62), DOB_zd(62),
                              tpd_CKB_DOB62_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(63), DOB_zd(63),
                              tpd_CKB_DOB63_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(64), DOB_zd(64),
                              tpd_CKB_DOB64_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(65), DOB_zd(65),
                              tpd_CKB_DOB65_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(66), DOB_zd(66),
                              tpd_CKB_DOB66_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(67), DOB_zd(67),
                              tpd_CKB_DOB67_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(68), DOB_zd(68),
                              tpd_CKB_DOB68_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(69), DOB_zd(69),
                              tpd_CKB_DOB69_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(70), DOB_zd(70),
                              tpd_CKB_DOB70_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(71), DOB_zd(71),
                              tpd_CKB_DOB71_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(72), DOB_zd(72),
                              tpd_CKB_DOB72_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(73), DOB_zd(73),
                              tpd_CKB_DOB73_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(74), DOB_zd(74),
                              tpd_CKB_DOB74_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(75), DOB_zd(75),
                              tpd_CKB_DOB75_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(76), DOB_zd(76),
                              tpd_CKB_DOB76_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(77), DOB_zd(77),
                              tpd_CKB_DOB77_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(78), DOB_zd(78),
                              tpd_CKB_DOB78_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(79), DOB_zd(79),
                              tpd_CKB_DOB79_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(80), DOB_zd(80),
                              tpd_CKB_DOB80_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(81), DOB_zd(81),
                              tpd_CKB_DOB81_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(82), DOB_zd(82),
                              tpd_CKB_DOB82_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(83), DOB_zd(83),
                              tpd_CKB_DOB83_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(84), DOB_zd(84),
                              tpd_CKB_DOB84_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(85), DOB_zd(85),
                              tpd_CKB_DOB85_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(86), DOB_zd(86),
                              tpd_CKB_DOB86_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(87), DOB_zd(87),
                              tpd_CKB_DOB87_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(88), DOB_zd(88),
                              tpd_CKB_DOB88_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(89), DOB_zd(89),
                              tpd_CKB_DOB89_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(90), DOB_zd(90),
                              tpd_CKB_DOB90_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(91), DOB_zd(91),
                              tpd_CKB_DOB91_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(92), DOB_zd(92),
                              tpd_CKB_DOB92_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(93), DOB_zd(93),
                              tpd_CKB_DOB93_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(94), DOB_zd(94),
                              tpd_CKB_DOB94_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(95), DOB_zd(95),
                              tpd_CKB_DOB95_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(96), DOB_zd(96),
                              tpd_CKB_DOB96_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(97), DOB_zd(97),
                              tpd_CKB_DOB97_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(98), DOB_zd(98),
                              tpd_CKB_DOB98_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(99), DOB_zd(99),
                              tpd_CKB_DOB99_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(100), DOB_zd(100),
                              tpd_CKB_DOB100_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(101), DOB_zd(101),
                              tpd_CKB_DOB101_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(102), DOB_zd(102),
                              tpd_CKB_DOB102_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(103), DOB_zd(103),
                              tpd_CKB_DOB103_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(104), DOB_zd(104),
                              tpd_CKB_DOB104_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(105), DOB_zd(105),
                              tpd_CKB_DOB105_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(106), DOB_zd(106),
                              tpd_CKB_DOB106_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(107), DOB_zd(107),
                              tpd_CKB_DOB107_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(108), DOB_zd(108),
                              tpd_CKB_DOB108_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(109), DOB_zd(109),
                              tpd_CKB_DOB109_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(110), DOB_zd(110),
                              tpd_CKB_DOB110_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(111), DOB_zd(111),
                              tpd_CKB_DOB111_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(112), DOB_zd(112),
                              tpd_CKB_DOB112_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(113), DOB_zd(113),
                              tpd_CKB_DOB113_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(114), DOB_zd(114),
                              tpd_CKB_DOB114_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(115), DOB_zd(115),
                              tpd_CKB_DOB115_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(116), DOB_zd(116),
                              tpd_CKB_DOB116_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(117), DOB_zd(117),
                              tpd_CKB_DOB117_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(118), DOB_zd(118),
                              tpd_CKB_DOB118_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(119), DOB_zd(119),
                              tpd_CKB_DOB119_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(120), DOB_zd(120),
                              tpd_CKB_DOB120_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(121), DOB_zd(121),
                              tpd_CKB_DOB121_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(122), DOB_zd(122),
                              tpd_CKB_DOB122_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(123), DOB_zd(123),
                              tpd_CKB_DOB123_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(124), DOB_zd(124),
                              tpd_CKB_DOB124_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(125), DOB_zd(125),
                              tpd_CKB_DOB125_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(126), DOB_zd(126),
                              tpd_CKB_DOB126_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(127), DOB_zd(127),
                              tpd_CKB_DOB127_posedge,last_B,B_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                           DOB_zd := (OTHERS => 'X');
                           DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                       LastCycleBAddress := B_i;
                   when "1X" |
                        "1U" |
                        "1Z"   =>
                       DOB_zd := (OTHERS => 'X');
                       DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;

                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                       DOB_zd := (OTHERS => 'X');
                       DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           memoryCore(to_integer(B_i)) := (OTHERS => 'X');
                       elsif (AddressRangeCheck(B_i,flag_B) = Range_flg) then
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                       else
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                end case;
                Last_WEBN_i := WEBN_i;
                -- end memory_functionB

                last_B := B_ipd;

                if (CSB_i = '1') then
                   Last_tc_ClkB_PosEdge := NOW;
                end if;
            when "10"   => -- do nothing
            when others => if (NOW /= 0 ns and CSB_ipd /= '0') then
                              assert FALSE report "** MEM_Error: Abnormal transition occurred." severity WARNING;
                              if (WEBN_ipd /= '1') then
                                 DOB_zd := (OTHERS => 'X');
                                 DOB_int <= TRANSPORT (OTHERS => 'X');
                                 FOR i IN Words-1 downto 0 LOOP
                                   memoryCore(i) := (OTHERS => 'X');
                                 END LOOP;
			      else
                                 DOB_int <= TRANSPORT (OTHERS => 'X');			      	
			      end if;
                           end if; 
         end case;
         LastClkBEdge := CKB_ipd;
       end if;

       -- timingcheck_violationA
       if (Tviol_A_CKA_posedge      = 'X' or
           Tviol_WEAN_CKA_posedge  = 'X' or
           Tviol_DIA_CKA_posedge   = 'X' or
           Tviol_CSA_CKA_posedge    = 'X' or
           Pviol_CKA                = 'X'
          ) then

         if (Pviol_CKA = 'X') then
            if (CSA_ipd /= '0') then
               if (WEAN_ipd /= '1') then
                  FOR i IN Words-1 downto 0 LOOP
                     memoryCore(i) := (OTHERS => 'X');
                  END LOOP;
               else
                  DOA_zd := (OTHERS => 'X');
                  DOA_int <= TRANSPORT (OTHERS => 'X');
               end if;
            end if;
         else
            FOR i IN AddressSize-1 downto 0 LOOP
              if (Tviol_A_CKA_posedge = 'X') then
                 Latch_A(i) := 'X';
              else
                 Latch_A(i) := Latch_A(i);
              end if;
            END LOOP;

            FOR i IN Bits-1 downto 0 LOOP
              if (Tviol_DIA_CKA_posedge = 'X') then
                 Latch_DIA(i) := 'X';
              else
                 Latch_DIA(i) := Latch_DIA(i);
              end if;
            END LOOP;

            if (Tviol_CSA_CKA_posedge = 'X') then
               Latch_CSA := 'X';
            else
               Latch_CSA := Latch_CSA;
            end if;
            if (Tviol_WEAN_CKA_posedge = 'X') then
               Latch_WEAN := 'X';
            else
               Latch_WEAN := Latch_WEAN;
            end if;
                -- memory_functionA
                A_i    := Latch_A;
                CSA_i  := Latch_CSA;
                DIA_i  := Latch_DIA;
                WEAN_i := Latch_WEAN;

                wea_csa    := WEAN_i&CSA_i;
                case wea_csa is
                   when "11" =>
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           if ((A_i = LastCycleBAddress) and
                               (Last_WEBN_i = '0') and
                               ((NOW-Last_tc_ClkB_PosEdge) < Tw2r)) then
                                 -- read and write the same address
                              assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                              DOA_zd := (OTHERS => 'X');
                              DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           else
                              DOA_zd := memoryCore(to_integer(A_i));
                              ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                              tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                              tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                              tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                              tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                              tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                              tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                              tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                              tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(8), DOA_zd(8),
                              tpd_CKA_DOA8_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(9), DOA_zd(9),
                              tpd_CKA_DOA9_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(10), DOA_zd(10),
                              tpd_CKA_DOA10_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(11), DOA_zd(11),
                              tpd_CKA_DOA11_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(12), DOA_zd(12),
                              tpd_CKA_DOA12_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(13), DOA_zd(13),
                              tpd_CKA_DOA13_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(14), DOA_zd(14),
                              tpd_CKA_DOA14_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(15), DOA_zd(15),
                              tpd_CKA_DOA15_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(16), DOA_zd(16),
                              tpd_CKA_DOA16_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(17), DOA_zd(17),
                              tpd_CKA_DOA17_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(18), DOA_zd(18),
                              tpd_CKA_DOA18_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(19), DOA_zd(19),
                              tpd_CKA_DOA19_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(20), DOA_zd(20),
                              tpd_CKA_DOA20_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(21), DOA_zd(21),
                              tpd_CKA_DOA21_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(22), DOA_zd(22),
                              tpd_CKA_DOA22_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(23), DOA_zd(23),
                              tpd_CKA_DOA23_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(24), DOA_zd(24),
                              tpd_CKA_DOA24_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(25), DOA_zd(25),
                              tpd_CKA_DOA25_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(26), DOA_zd(26),
                              tpd_CKA_DOA26_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(27), DOA_zd(27),
                              tpd_CKA_DOA27_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(28), DOA_zd(28),
                              tpd_CKA_DOA28_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(29), DOA_zd(29),
                              tpd_CKA_DOA29_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(30), DOA_zd(30),
                              tpd_CKA_DOA30_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(31), DOA_zd(31),
                              tpd_CKA_DOA31_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(32), DOA_zd(32),
                              tpd_CKA_DOA32_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(33), DOA_zd(33),
                              tpd_CKA_DOA33_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(34), DOA_zd(34),
                              tpd_CKA_DOA34_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(35), DOA_zd(35),
                              tpd_CKA_DOA35_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(36), DOA_zd(36),
                              tpd_CKA_DOA36_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(37), DOA_zd(37),
                              tpd_CKA_DOA37_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(38), DOA_zd(38),
                              tpd_CKA_DOA38_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(39), DOA_zd(39),
                              tpd_CKA_DOA39_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(40), DOA_zd(40),
                              tpd_CKA_DOA40_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(41), DOA_zd(41),
                              tpd_CKA_DOA41_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(42), DOA_zd(42),
                              tpd_CKA_DOA42_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(43), DOA_zd(43),
                              tpd_CKA_DOA43_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(44), DOA_zd(44),
                              tpd_CKA_DOA44_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(45), DOA_zd(45),
                              tpd_CKA_DOA45_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(46), DOA_zd(46),
                              tpd_CKA_DOA46_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(47), DOA_zd(47),
                              tpd_CKA_DOA47_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(48), DOA_zd(48),
                              tpd_CKA_DOA48_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(49), DOA_zd(49),
                              tpd_CKA_DOA49_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(50), DOA_zd(50),
                              tpd_CKA_DOA50_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(51), DOA_zd(51),
                              tpd_CKA_DOA51_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(52), DOA_zd(52),
                              tpd_CKA_DOA52_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(53), DOA_zd(53),
                              tpd_CKA_DOA53_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(54), DOA_zd(54),
                              tpd_CKA_DOA54_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(55), DOA_zd(55),
                              tpd_CKA_DOA55_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(56), DOA_zd(56),
                              tpd_CKA_DOA56_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(57), DOA_zd(57),
                              tpd_CKA_DOA57_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(58), DOA_zd(58),
                              tpd_CKA_DOA58_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(59), DOA_zd(59),
                              tpd_CKA_DOA59_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(60), DOA_zd(60),
                              tpd_CKA_DOA60_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(61), DOA_zd(61),
                              tpd_CKA_DOA61_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(62), DOA_zd(62),
                              tpd_CKA_DOA62_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(63), DOA_zd(63),
                              tpd_CKA_DOA63_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(64), DOA_zd(64),
                              tpd_CKA_DOA64_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(65), DOA_zd(65),
                              tpd_CKA_DOA65_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(66), DOA_zd(66),
                              tpd_CKA_DOA66_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(67), DOA_zd(67),
                              tpd_CKA_DOA67_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(68), DOA_zd(68),
                              tpd_CKA_DOA68_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(69), DOA_zd(69),
                              tpd_CKA_DOA69_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(70), DOA_zd(70),
                              tpd_CKA_DOA70_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(71), DOA_zd(71),
                              tpd_CKA_DOA71_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(72), DOA_zd(72),
                              tpd_CKA_DOA72_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(73), DOA_zd(73),
                              tpd_CKA_DOA73_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(74), DOA_zd(74),
                              tpd_CKA_DOA74_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(75), DOA_zd(75),
                              tpd_CKA_DOA75_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(76), DOA_zd(76),
                              tpd_CKA_DOA76_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(77), DOA_zd(77),
                              tpd_CKA_DOA77_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(78), DOA_zd(78),
                              tpd_CKA_DOA78_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(79), DOA_zd(79),
                              tpd_CKA_DOA79_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(80), DOA_zd(80),
                              tpd_CKA_DOA80_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(81), DOA_zd(81),
                              tpd_CKA_DOA81_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(82), DOA_zd(82),
                              tpd_CKA_DOA82_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(83), DOA_zd(83),
                              tpd_CKA_DOA83_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(84), DOA_zd(84),
                              tpd_CKA_DOA84_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(85), DOA_zd(85),
                              tpd_CKA_DOA85_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(86), DOA_zd(86),
                              tpd_CKA_DOA86_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(87), DOA_zd(87),
                              tpd_CKA_DOA87_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(88), DOA_zd(88),
                              tpd_CKA_DOA88_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(89), DOA_zd(89),
                              tpd_CKA_DOA89_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(90), DOA_zd(90),
                              tpd_CKA_DOA90_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(91), DOA_zd(91),
                              tpd_CKA_DOA91_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(92), DOA_zd(92),
                              tpd_CKA_DOA92_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(93), DOA_zd(93),
                              tpd_CKA_DOA93_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(94), DOA_zd(94),
                              tpd_CKA_DOA94_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(95), DOA_zd(95),
                              tpd_CKA_DOA95_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(96), DOA_zd(96),
                              tpd_CKA_DOA96_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(97), DOA_zd(97),
                              tpd_CKA_DOA97_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(98), DOA_zd(98),
                              tpd_CKA_DOA98_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(99), DOA_zd(99),
                              tpd_CKA_DOA99_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(100), DOA_zd(100),
                              tpd_CKA_DOA100_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(101), DOA_zd(101),
                              tpd_CKA_DOA101_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(102), DOA_zd(102),
                              tpd_CKA_DOA102_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(103), DOA_zd(103),
                              tpd_CKA_DOA103_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(104), DOA_zd(104),
                              tpd_CKA_DOA104_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(105), DOA_zd(105),
                              tpd_CKA_DOA105_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(106), DOA_zd(106),
                              tpd_CKA_DOA106_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(107), DOA_zd(107),
                              tpd_CKA_DOA107_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(108), DOA_zd(108),
                              tpd_CKA_DOA108_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(109), DOA_zd(109),
                              tpd_CKA_DOA109_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(110), DOA_zd(110),
                              tpd_CKA_DOA110_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(111), DOA_zd(111),
                              tpd_CKA_DOA111_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(112), DOA_zd(112),
                              tpd_CKA_DOA112_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(113), DOA_zd(113),
                              tpd_CKA_DOA113_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(114), DOA_zd(114),
                              tpd_CKA_DOA114_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(115), DOA_zd(115),
                              tpd_CKA_DOA115_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(116), DOA_zd(116),
                              tpd_CKA_DOA116_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(117), DOA_zd(117),
                              tpd_CKA_DOA117_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(118), DOA_zd(118),
                              tpd_CKA_DOA118_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(119), DOA_zd(119),
                              tpd_CKA_DOA119_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(120), DOA_zd(120),
                              tpd_CKA_DOA120_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(121), DOA_zd(121),
                              tpd_CKA_DOA121_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(122), DOA_zd(122),
                              tpd_CKA_DOA122_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(123), DOA_zd(123),
                              tpd_CKA_DOA123_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(124), DOA_zd(124),
                              tpd_CKA_DOA124_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(125), DOA_zd(125),
                              tpd_CKA_DOA125_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(126), DOA_zd(126),
                              tpd_CKA_DOA126_posedge,last_A,A_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOA_int(127), DOA_zd(127),
                              tpd_CKA_DOA127_posedge,last_A,A_i,NO_SER_TOH);
                           end if;
                           -- Reduce error message --
                           flag_A := True_flg;
                       end if;
                       LastCycleAAddress := A_i;

                   when "01" =>
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           if (A_i = LastCycleBAddress) then
                              if ((Last_WEBN_i = '1') and ((NOW-Last_tc_ClkB_PosEdge) < Tr2w)) then
                                 -- read and write the same address
                                 assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                                 DOB_zd := (OTHERS => 'X');
                                 DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                 memoryCore(to_integer(A_i)) := DIA_i;
                              elsif ((Last_WEBN_i = '0') and ((NOW-Last_tc_ClkB_PosEdge) < Tw2r)) then
                                 assert FALSE report "** MEM_Error: Port A and B write the same Address, core is unknown." severity WARNING;
                                 memoryCore(to_integer(A_i)) := (OTHERS => 'X');
                              else
                                 memoryCore(to_integer(A_i)) := DIA_i;
                              end if;
                           else
                              memoryCore(to_integer(A_i)) := DIA_i;
                           end if;
                           -- Reduce error message --
                           flag_A := True_flg;
                           -- write through --
                           DOA_zd := DIA_i;
                           ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                           tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                           tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                           tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                           tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                           tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                           tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                           tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                           tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(8), DOA_zd(8),
                           tpd_CKA_DOA8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(9), DOA_zd(9),
                           tpd_CKA_DOA9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(10), DOA_zd(10),
                           tpd_CKA_DOA10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(11), DOA_zd(11),
                           tpd_CKA_DOA11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(12), DOA_zd(12),
                           tpd_CKA_DOA12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(13), DOA_zd(13),
                           tpd_CKA_DOA13_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(14), DOA_zd(14),
                           tpd_CKA_DOA14_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(15), DOA_zd(15),
                           tpd_CKA_DOA15_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(16), DOA_zd(16),
                           tpd_CKA_DOA16_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(17), DOA_zd(17),
                           tpd_CKA_DOA17_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(18), DOA_zd(18),
                           tpd_CKA_DOA18_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(19), DOA_zd(19),
                           tpd_CKA_DOA19_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(20), DOA_zd(20),
                           tpd_CKA_DOA20_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(21), DOA_zd(21),
                           tpd_CKA_DOA21_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(22), DOA_zd(22),
                           tpd_CKA_DOA22_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(23), DOA_zd(23),
                           tpd_CKA_DOA23_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(24), DOA_zd(24),
                           tpd_CKA_DOA24_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(25), DOA_zd(25),
                           tpd_CKA_DOA25_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(26), DOA_zd(26),
                           tpd_CKA_DOA26_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(27), DOA_zd(27),
                           tpd_CKA_DOA27_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(28), DOA_zd(28),
                           tpd_CKA_DOA28_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(29), DOA_zd(29),
                           tpd_CKA_DOA29_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(30), DOA_zd(30),
                           tpd_CKA_DOA30_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(31), DOA_zd(31),
                           tpd_CKA_DOA31_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(32), DOA_zd(32),
                           tpd_CKA_DOA32_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(33), DOA_zd(33),
                           tpd_CKA_DOA33_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(34), DOA_zd(34),
                           tpd_CKA_DOA34_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(35), DOA_zd(35),
                           tpd_CKA_DOA35_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(36), DOA_zd(36),
                           tpd_CKA_DOA36_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(37), DOA_zd(37),
                           tpd_CKA_DOA37_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(38), DOA_zd(38),
                           tpd_CKA_DOA38_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(39), DOA_zd(39),
                           tpd_CKA_DOA39_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(40), DOA_zd(40),
                           tpd_CKA_DOA40_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(41), DOA_zd(41),
                           tpd_CKA_DOA41_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(42), DOA_zd(42),
                           tpd_CKA_DOA42_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(43), DOA_zd(43),
                           tpd_CKA_DOA43_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(44), DOA_zd(44),
                           tpd_CKA_DOA44_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(45), DOA_zd(45),
                           tpd_CKA_DOA45_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(46), DOA_zd(46),
                           tpd_CKA_DOA46_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(47), DOA_zd(47),
                           tpd_CKA_DOA47_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(48), DOA_zd(48),
                           tpd_CKA_DOA48_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(49), DOA_zd(49),
                           tpd_CKA_DOA49_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(50), DOA_zd(50),
                           tpd_CKA_DOA50_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(51), DOA_zd(51),
                           tpd_CKA_DOA51_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(52), DOA_zd(52),
                           tpd_CKA_DOA52_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(53), DOA_zd(53),
                           tpd_CKA_DOA53_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(54), DOA_zd(54),
                           tpd_CKA_DOA54_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(55), DOA_zd(55),
                           tpd_CKA_DOA55_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(56), DOA_zd(56),
                           tpd_CKA_DOA56_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(57), DOA_zd(57),
                           tpd_CKA_DOA57_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(58), DOA_zd(58),
                           tpd_CKA_DOA58_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(59), DOA_zd(59),
                           tpd_CKA_DOA59_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(60), DOA_zd(60),
                           tpd_CKA_DOA60_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(61), DOA_zd(61),
                           tpd_CKA_DOA61_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(62), DOA_zd(62),
                           tpd_CKA_DOA62_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(63), DOA_zd(63),
                           tpd_CKA_DOA63_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(64), DOA_zd(64),
                           tpd_CKA_DOA64_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(65), DOA_zd(65),
                           tpd_CKA_DOA65_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(66), DOA_zd(66),
                           tpd_CKA_DOA66_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(67), DOA_zd(67),
                           tpd_CKA_DOA67_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(68), DOA_zd(68),
                           tpd_CKA_DOA68_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(69), DOA_zd(69),
                           tpd_CKA_DOA69_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(70), DOA_zd(70),
                           tpd_CKA_DOA70_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(71), DOA_zd(71),
                           tpd_CKA_DOA71_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(72), DOA_zd(72),
                           tpd_CKA_DOA72_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(73), DOA_zd(73),
                           tpd_CKA_DOA73_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(74), DOA_zd(74),
                           tpd_CKA_DOA74_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(75), DOA_zd(75),
                           tpd_CKA_DOA75_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(76), DOA_zd(76),
                           tpd_CKA_DOA76_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(77), DOA_zd(77),
                           tpd_CKA_DOA77_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(78), DOA_zd(78),
                           tpd_CKA_DOA78_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(79), DOA_zd(79),
                           tpd_CKA_DOA79_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(80), DOA_zd(80),
                           tpd_CKA_DOA80_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(81), DOA_zd(81),
                           tpd_CKA_DOA81_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(82), DOA_zd(82),
                           tpd_CKA_DOA82_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(83), DOA_zd(83),
                           tpd_CKA_DOA83_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(84), DOA_zd(84),
                           tpd_CKA_DOA84_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(85), DOA_zd(85),
                           tpd_CKA_DOA85_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(86), DOA_zd(86),
                           tpd_CKA_DOA86_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(87), DOA_zd(87),
                           tpd_CKA_DOA87_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(88), DOA_zd(88),
                           tpd_CKA_DOA88_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(89), DOA_zd(89),
                           tpd_CKA_DOA89_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(90), DOA_zd(90),
                           tpd_CKA_DOA90_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(91), DOA_zd(91),
                           tpd_CKA_DOA91_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(92), DOA_zd(92),
                           tpd_CKA_DOA92_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(93), DOA_zd(93),
                           tpd_CKA_DOA93_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(94), DOA_zd(94),
                           tpd_CKA_DOA94_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(95), DOA_zd(95),
                           tpd_CKA_DOA95_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(96), DOA_zd(96),
                           tpd_CKA_DOA96_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(97), DOA_zd(97),
                           tpd_CKA_DOA97_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(98), DOA_zd(98),
                           tpd_CKA_DOA98_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(99), DOA_zd(99),
                           tpd_CKA_DOA99_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(100), DOA_zd(100),
                           tpd_CKA_DOA100_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(101), DOA_zd(101),
                           tpd_CKA_DOA101_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(102), DOA_zd(102),
                           tpd_CKA_DOA102_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(103), DOA_zd(103),
                           tpd_CKA_DOA103_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(104), DOA_zd(104),
                           tpd_CKA_DOA104_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(105), DOA_zd(105),
                           tpd_CKA_DOA105_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(106), DOA_zd(106),
                           tpd_CKA_DOA106_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(107), DOA_zd(107),
                           tpd_CKA_DOA107_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(108), DOA_zd(108),
                           tpd_CKA_DOA108_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(109), DOA_zd(109),
                           tpd_CKA_DOA109_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(110), DOA_zd(110),
                           tpd_CKA_DOA110_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(111), DOA_zd(111),
                           tpd_CKA_DOA111_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(112), DOA_zd(112),
                           tpd_CKA_DOA112_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(113), DOA_zd(113),
                           tpd_CKA_DOA113_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(114), DOA_zd(114),
                           tpd_CKA_DOA114_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(115), DOA_zd(115),
                           tpd_CKA_DOA115_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(116), DOA_zd(116),
                           tpd_CKA_DOA116_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(117), DOA_zd(117),
                           tpd_CKA_DOA117_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(118), DOA_zd(118),
                           tpd_CKA_DOA118_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(119), DOA_zd(119),
                           tpd_CKA_DOA119_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(120), DOA_zd(120),
                           tpd_CKA_DOA120_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(121), DOA_zd(121),
                           tpd_CKA_DOA121_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(122), DOA_zd(122),
                           tpd_CKA_DOA122_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(123), DOA_zd(123),
                           tpd_CKA_DOA123_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(124), DOA_zd(124),
                           tpd_CKA_DOA124_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(125), DOA_zd(125),
                           tpd_CKA_DOA125_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(126), DOA_zd(126),
                           tpd_CKA_DOA126_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(127), DOA_zd(127),
                           tpd_CKA_DOA127_posedge,last_A,A_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           -- write through --
                           DOA_zd := DIA_i;
                           ScheduleOutputDelay(DOA_int(0), DOA_zd(0),
                           tpd_CKA_DOA0_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(1), DOA_zd(1),
                           tpd_CKA_DOA1_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(2), DOA_zd(2),
                           tpd_CKA_DOA2_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(3), DOA_zd(3),
                           tpd_CKA_DOA3_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(4), DOA_zd(4),
                           tpd_CKA_DOA4_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(5), DOA_zd(5),
                           tpd_CKA_DOA5_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(6), DOA_zd(6),
                           tpd_CKA_DOA6_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(7), DOA_zd(7),
                           tpd_CKA_DOA7_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(8), DOA_zd(8),
                           tpd_CKA_DOA8_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(9), DOA_zd(9),
                           tpd_CKA_DOA9_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(10), DOA_zd(10),
                           tpd_CKA_DOA10_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(11), DOA_zd(11),
                           tpd_CKA_DOA11_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(12), DOA_zd(12),
                           tpd_CKA_DOA12_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(13), DOA_zd(13),
                           tpd_CKA_DOA13_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(14), DOA_zd(14),
                           tpd_CKA_DOA14_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(15), DOA_zd(15),
                           tpd_CKA_DOA15_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(16), DOA_zd(16),
                           tpd_CKA_DOA16_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(17), DOA_zd(17),
                           tpd_CKA_DOA17_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(18), DOA_zd(18),
                           tpd_CKA_DOA18_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(19), DOA_zd(19),
                           tpd_CKA_DOA19_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(20), DOA_zd(20),
                           tpd_CKA_DOA20_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(21), DOA_zd(21),
                           tpd_CKA_DOA21_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(22), DOA_zd(22),
                           tpd_CKA_DOA22_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(23), DOA_zd(23),
                           tpd_CKA_DOA23_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(24), DOA_zd(24),
                           tpd_CKA_DOA24_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(25), DOA_zd(25),
                           tpd_CKA_DOA25_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(26), DOA_zd(26),
                           tpd_CKA_DOA26_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(27), DOA_zd(27),
                           tpd_CKA_DOA27_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(28), DOA_zd(28),
                           tpd_CKA_DOA28_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(29), DOA_zd(29),
                           tpd_CKA_DOA29_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(30), DOA_zd(30),
                           tpd_CKA_DOA30_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(31), DOA_zd(31),
                           tpd_CKA_DOA31_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(32), DOA_zd(32),
                           tpd_CKA_DOA32_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(33), DOA_zd(33),
                           tpd_CKA_DOA33_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(34), DOA_zd(34),
                           tpd_CKA_DOA34_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(35), DOA_zd(35),
                           tpd_CKA_DOA35_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(36), DOA_zd(36),
                           tpd_CKA_DOA36_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(37), DOA_zd(37),
                           tpd_CKA_DOA37_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(38), DOA_zd(38),
                           tpd_CKA_DOA38_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(39), DOA_zd(39),
                           tpd_CKA_DOA39_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(40), DOA_zd(40),
                           tpd_CKA_DOA40_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(41), DOA_zd(41),
                           tpd_CKA_DOA41_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(42), DOA_zd(42),
                           tpd_CKA_DOA42_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(43), DOA_zd(43),
                           tpd_CKA_DOA43_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(44), DOA_zd(44),
                           tpd_CKA_DOA44_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(45), DOA_zd(45),
                           tpd_CKA_DOA45_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(46), DOA_zd(46),
                           tpd_CKA_DOA46_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(47), DOA_zd(47),
                           tpd_CKA_DOA47_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(48), DOA_zd(48),
                           tpd_CKA_DOA48_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(49), DOA_zd(49),
                           tpd_CKA_DOA49_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(50), DOA_zd(50),
                           tpd_CKA_DOA50_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(51), DOA_zd(51),
                           tpd_CKA_DOA51_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(52), DOA_zd(52),
                           tpd_CKA_DOA52_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(53), DOA_zd(53),
                           tpd_CKA_DOA53_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(54), DOA_zd(54),
                           tpd_CKA_DOA54_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(55), DOA_zd(55),
                           tpd_CKA_DOA55_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(56), DOA_zd(56),
                           tpd_CKA_DOA56_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(57), DOA_zd(57),
                           tpd_CKA_DOA57_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(58), DOA_zd(58),
                           tpd_CKA_DOA58_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(59), DOA_zd(59),
                           tpd_CKA_DOA59_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(60), DOA_zd(60),
                           tpd_CKA_DOA60_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(61), DOA_zd(61),
                           tpd_CKA_DOA61_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(62), DOA_zd(62),
                           tpd_CKA_DOA62_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(63), DOA_zd(63),
                           tpd_CKA_DOA63_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(64), DOA_zd(64),
                           tpd_CKA_DOA64_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(65), DOA_zd(65),
                           tpd_CKA_DOA65_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(66), DOA_zd(66),
                           tpd_CKA_DOA66_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(67), DOA_zd(67),
                           tpd_CKA_DOA67_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(68), DOA_zd(68),
                           tpd_CKA_DOA68_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(69), DOA_zd(69),
                           tpd_CKA_DOA69_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(70), DOA_zd(70),
                           tpd_CKA_DOA70_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(71), DOA_zd(71),
                           tpd_CKA_DOA71_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(72), DOA_zd(72),
                           tpd_CKA_DOA72_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(73), DOA_zd(73),
                           tpd_CKA_DOA73_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(74), DOA_zd(74),
                           tpd_CKA_DOA74_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(75), DOA_zd(75),
                           tpd_CKA_DOA75_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(76), DOA_zd(76),
                           tpd_CKA_DOA76_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(77), DOA_zd(77),
                           tpd_CKA_DOA77_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(78), DOA_zd(78),
                           tpd_CKA_DOA78_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(79), DOA_zd(79),
                           tpd_CKA_DOA79_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(80), DOA_zd(80),
                           tpd_CKA_DOA80_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(81), DOA_zd(81),
                           tpd_CKA_DOA81_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(82), DOA_zd(82),
                           tpd_CKA_DOA82_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(83), DOA_zd(83),
                           tpd_CKA_DOA83_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(84), DOA_zd(84),
                           tpd_CKA_DOA84_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(85), DOA_zd(85),
                           tpd_CKA_DOA85_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(86), DOA_zd(86),
                           tpd_CKA_DOA86_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(87), DOA_zd(87),
                           tpd_CKA_DOA87_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(88), DOA_zd(88),
                           tpd_CKA_DOA88_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(89), DOA_zd(89),
                           tpd_CKA_DOA89_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(90), DOA_zd(90),
                           tpd_CKA_DOA90_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(91), DOA_zd(91),
                           tpd_CKA_DOA91_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(92), DOA_zd(92),
                           tpd_CKA_DOA92_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(93), DOA_zd(93),
                           tpd_CKA_DOA93_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(94), DOA_zd(94),
                           tpd_CKA_DOA94_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(95), DOA_zd(95),
                           tpd_CKA_DOA95_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(96), DOA_zd(96),
                           tpd_CKA_DOA96_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(97), DOA_zd(97),
                           tpd_CKA_DOA97_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(98), DOA_zd(98),
                           tpd_CKA_DOA98_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(99), DOA_zd(99),
                           tpd_CKA_DOA99_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(100), DOA_zd(100),
                           tpd_CKA_DOA100_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(101), DOA_zd(101),
                           tpd_CKA_DOA101_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(102), DOA_zd(102),
                           tpd_CKA_DOA102_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(103), DOA_zd(103),
                           tpd_CKA_DOA103_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(104), DOA_zd(104),
                           tpd_CKA_DOA104_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(105), DOA_zd(105),
                           tpd_CKA_DOA105_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(106), DOA_zd(106),
                           tpd_CKA_DOA106_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(107), DOA_zd(107),
                           tpd_CKA_DOA107_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(108), DOA_zd(108),
                           tpd_CKA_DOA108_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(109), DOA_zd(109),
                           tpd_CKA_DOA109_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(110), DOA_zd(110),
                           tpd_CKA_DOA110_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(111), DOA_zd(111),
                           tpd_CKA_DOA111_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(112), DOA_zd(112),
                           tpd_CKA_DOA112_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(113), DOA_zd(113),
                           tpd_CKA_DOA113_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(114), DOA_zd(114),
                           tpd_CKA_DOA114_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(115), DOA_zd(115),
                           tpd_CKA_DOA115_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(116), DOA_zd(116),
                           tpd_CKA_DOA116_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(117), DOA_zd(117),
                           tpd_CKA_DOA117_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(118), DOA_zd(118),
                           tpd_CKA_DOA118_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(119), DOA_zd(119),
                           tpd_CKA_DOA119_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(120), DOA_zd(120),
                           tpd_CKA_DOA120_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(121), DOA_zd(121),
                           tpd_CKA_DOA121_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(122), DOA_zd(122),
                           tpd_CKA_DOA122_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(123), DOA_zd(123),
                           tpd_CKA_DOA123_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(124), DOA_zd(124),
                           tpd_CKA_DOA124_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(125), DOA_zd(125),
                           tpd_CKA_DOA125_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(126), DOA_zd(126),
                           tpd_CKA_DOA126_posedge,last_A,A_i,NO_SER_TOH);
                           ScheduleOutputDelay(DOA_int(127), DOA_zd(127),
                           tpd_CKA_DOA127_posedge,last_A,A_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                           DOA_zd := (OTHERS => 'X');
                           DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                       LastCycleAAddress := A_i;
                   when "1X" |
                        "1U" |
                        "1Z"   =>
                       DOA_zd := (OTHERS => 'X');
                       DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;

                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                       DOA_zd := (OTHERS => 'X');
                       DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       if (AddressRangeCheck(A_i,flag_A) = True_flg) then
                           memoryCore(to_integer(A_i)) := (OTHERS => 'X');
                       elsif (AddressRangeCheck(A_i,flag_A) = Range_flg) then
                           -- Reduce error message --
                           flag_A := False_flg;
                           --------------------------
                       else
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                end case;
                Last_WEAN_i := WEAN_i;
                -- end memory_functionA
         end if;
       end if;
       -- end timingcheck_violationA

       -- timingcheck_violationB
       if (Tviol_B_CKB_posedge      = 'X' or
           Tviol_WEBN_CKB_posedge  = 'X' or
           Tviol_DIB_CKB_posedge   = 'X' or
           Tviol_CSB_CKB_posedge    = 'X' or
           Pviol_CKB                = 'X'
          ) then

         if (Pviol_CKB = 'X') then
            if (CSB_ipd /= '0') then
               if (WEBN_ipd /= '1') then
                  FOR i IN Words-1 downto 0 LOOP
                     memoryCore(i) := (OTHERS => 'X');
                  END LOOP;
               else
                  DOB_zd := (OTHERS => 'X');
                  DOB_int <= TRANSPORT (OTHERS => 'X');
               end if;
            end if;
         else
            FOR i IN AddressSize-1 downto 0 LOOP
              if (Tviol_B_CKB_posedge = 'X') then
                 Latch_B(i) := 'X';
              else
                 Latch_B(i) := Latch_B(i);
              end if;
            END LOOP;

            FOR i IN Bits-1 downto 0 LOOP
              if (Tviol_DIB_CKB_posedge = 'X') then
                 Latch_DIB(i) := 'X';
              else
                 Latch_DIB(i) := Latch_DIB(i);
              end if;
            END LOOP;

            if (Tviol_CSB_CKB_posedge = 'X') then
               Latch_CSB := 'X';
            else
               Latch_CSB := Latch_CSB;
            end if;
            if (Tviol_WEBN_CKB_posedge = 'X') then
               Latch_WEBN := 'X';
            else
               Latch_WEBN := Latch_WEBN;
            end if;
                -- memory_functionB
                B_i    := Latch_B;
                CSB_i  := Latch_CSB;
                DIB_i  := Latch_DIB;
                WEBN_i := Latch_WEBN;

                web_csb    := WEBN_i&CSB_i;
                case web_csb is
                   when "11" =>
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           if ((B_i = LastCycleAAddress) and
                               (Last_WEAN_i = '0') and
                               ((NOW-Last_tc_ClkA_PosEdge) < Tw2r)) then
                                 -- read and write the same address
                              assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                              DOB_zd := (OTHERS => 'X');
                              DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           else
                              DOB_zd := memoryCore(to_integer(B_i));
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(8), DOB_zd(8),
                              tpd_CKB_DOB8_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(9), DOB_zd(9),
                              tpd_CKB_DOB9_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(10), DOB_zd(10),
                              tpd_CKB_DOB10_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(11), DOB_zd(11),
                              tpd_CKB_DOB11_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(12), DOB_zd(12),
                              tpd_CKB_DOB12_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(13), DOB_zd(13),
                              tpd_CKB_DOB13_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(14), DOB_zd(14),
                              tpd_CKB_DOB14_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(15), DOB_zd(15),
                              tpd_CKB_DOB15_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(16), DOB_zd(16),
                              tpd_CKB_DOB16_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(17), DOB_zd(17),
                              tpd_CKB_DOB17_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(18), DOB_zd(18),
                              tpd_CKB_DOB18_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(19), DOB_zd(19),
                              tpd_CKB_DOB19_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(20), DOB_zd(20),
                              tpd_CKB_DOB20_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(21), DOB_zd(21),
                              tpd_CKB_DOB21_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(22), DOB_zd(22),
                              tpd_CKB_DOB22_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(23), DOB_zd(23),
                              tpd_CKB_DOB23_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(24), DOB_zd(24),
                              tpd_CKB_DOB24_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(25), DOB_zd(25),
                              tpd_CKB_DOB25_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(26), DOB_zd(26),
                              tpd_CKB_DOB26_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(27), DOB_zd(27),
                              tpd_CKB_DOB27_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(28), DOB_zd(28),
                              tpd_CKB_DOB28_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(29), DOB_zd(29),
                              tpd_CKB_DOB29_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(30), DOB_zd(30),
                              tpd_CKB_DOB30_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(31), DOB_zd(31),
                              tpd_CKB_DOB31_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(32), DOB_zd(32),
                              tpd_CKB_DOB32_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(33), DOB_zd(33),
                              tpd_CKB_DOB33_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(34), DOB_zd(34),
                              tpd_CKB_DOB34_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(35), DOB_zd(35),
                              tpd_CKB_DOB35_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(36), DOB_zd(36),
                              tpd_CKB_DOB36_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(37), DOB_zd(37),
                              tpd_CKB_DOB37_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(38), DOB_zd(38),
                              tpd_CKB_DOB38_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(39), DOB_zd(39),
                              tpd_CKB_DOB39_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(40), DOB_zd(40),
                              tpd_CKB_DOB40_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(41), DOB_zd(41),
                              tpd_CKB_DOB41_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(42), DOB_zd(42),
                              tpd_CKB_DOB42_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(43), DOB_zd(43),
                              tpd_CKB_DOB43_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(44), DOB_zd(44),
                              tpd_CKB_DOB44_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(45), DOB_zd(45),
                              tpd_CKB_DOB45_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(46), DOB_zd(46),
                              tpd_CKB_DOB46_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(47), DOB_zd(47),
                              tpd_CKB_DOB47_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(48), DOB_zd(48),
                              tpd_CKB_DOB48_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(49), DOB_zd(49),
                              tpd_CKB_DOB49_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(50), DOB_zd(50),
                              tpd_CKB_DOB50_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(51), DOB_zd(51),
                              tpd_CKB_DOB51_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(52), DOB_zd(52),
                              tpd_CKB_DOB52_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(53), DOB_zd(53),
                              tpd_CKB_DOB53_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(54), DOB_zd(54),
                              tpd_CKB_DOB54_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(55), DOB_zd(55),
                              tpd_CKB_DOB55_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(56), DOB_zd(56),
                              tpd_CKB_DOB56_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(57), DOB_zd(57),
                              tpd_CKB_DOB57_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(58), DOB_zd(58),
                              tpd_CKB_DOB58_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(59), DOB_zd(59),
                              tpd_CKB_DOB59_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(60), DOB_zd(60),
                              tpd_CKB_DOB60_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(61), DOB_zd(61),
                              tpd_CKB_DOB61_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(62), DOB_zd(62),
                              tpd_CKB_DOB62_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(63), DOB_zd(63),
                              tpd_CKB_DOB63_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(64), DOB_zd(64),
                              tpd_CKB_DOB64_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(65), DOB_zd(65),
                              tpd_CKB_DOB65_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(66), DOB_zd(66),
                              tpd_CKB_DOB66_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(67), DOB_zd(67),
                              tpd_CKB_DOB67_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(68), DOB_zd(68),
                              tpd_CKB_DOB68_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(69), DOB_zd(69),
                              tpd_CKB_DOB69_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(70), DOB_zd(70),
                              tpd_CKB_DOB70_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(71), DOB_zd(71),
                              tpd_CKB_DOB71_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(72), DOB_zd(72),
                              tpd_CKB_DOB72_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(73), DOB_zd(73),
                              tpd_CKB_DOB73_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(74), DOB_zd(74),
                              tpd_CKB_DOB74_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(75), DOB_zd(75),
                              tpd_CKB_DOB75_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(76), DOB_zd(76),
                              tpd_CKB_DOB76_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(77), DOB_zd(77),
                              tpd_CKB_DOB77_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(78), DOB_zd(78),
                              tpd_CKB_DOB78_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(79), DOB_zd(79),
                              tpd_CKB_DOB79_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(80), DOB_zd(80),
                              tpd_CKB_DOB80_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(81), DOB_zd(81),
                              tpd_CKB_DOB81_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(82), DOB_zd(82),
                              tpd_CKB_DOB82_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(83), DOB_zd(83),
                              tpd_CKB_DOB83_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(84), DOB_zd(84),
                              tpd_CKB_DOB84_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(85), DOB_zd(85),
                              tpd_CKB_DOB85_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(86), DOB_zd(86),
                              tpd_CKB_DOB86_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(87), DOB_zd(87),
                              tpd_CKB_DOB87_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(88), DOB_zd(88),
                              tpd_CKB_DOB88_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(89), DOB_zd(89),
                              tpd_CKB_DOB89_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(90), DOB_zd(90),
                              tpd_CKB_DOB90_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(91), DOB_zd(91),
                              tpd_CKB_DOB91_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(92), DOB_zd(92),
                              tpd_CKB_DOB92_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(93), DOB_zd(93),
                              tpd_CKB_DOB93_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(94), DOB_zd(94),
                              tpd_CKB_DOB94_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(95), DOB_zd(95),
                              tpd_CKB_DOB95_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(96), DOB_zd(96),
                              tpd_CKB_DOB96_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(97), DOB_zd(97),
                              tpd_CKB_DOB97_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(98), DOB_zd(98),
                              tpd_CKB_DOB98_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(99), DOB_zd(99),
                              tpd_CKB_DOB99_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(100), DOB_zd(100),
                              tpd_CKB_DOB100_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(101), DOB_zd(101),
                              tpd_CKB_DOB101_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(102), DOB_zd(102),
                              tpd_CKB_DOB102_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(103), DOB_zd(103),
                              tpd_CKB_DOB103_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(104), DOB_zd(104),
                              tpd_CKB_DOB104_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(105), DOB_zd(105),
                              tpd_CKB_DOB105_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(106), DOB_zd(106),
                              tpd_CKB_DOB106_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(107), DOB_zd(107),
                              tpd_CKB_DOB107_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(108), DOB_zd(108),
                              tpd_CKB_DOB108_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(109), DOB_zd(109),
                              tpd_CKB_DOB109_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(110), DOB_zd(110),
                              tpd_CKB_DOB110_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(111), DOB_zd(111),
                              tpd_CKB_DOB111_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(112), DOB_zd(112),
                              tpd_CKB_DOB112_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(113), DOB_zd(113),
                              tpd_CKB_DOB113_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(114), DOB_zd(114),
                              tpd_CKB_DOB114_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(115), DOB_zd(115),
                              tpd_CKB_DOB115_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(116), DOB_zd(116),
                              tpd_CKB_DOB116_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(117), DOB_zd(117),
                              tpd_CKB_DOB117_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(118), DOB_zd(118),
                              tpd_CKB_DOB118_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(119), DOB_zd(119),
                              tpd_CKB_DOB119_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(120), DOB_zd(120),
                              tpd_CKB_DOB120_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(121), DOB_zd(121),
                              tpd_CKB_DOB121_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(122), DOB_zd(122),
                              tpd_CKB_DOB122_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(123), DOB_zd(123),
                              tpd_CKB_DOB123_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(124), DOB_zd(124),
                              tpd_CKB_DOB124_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(125), DOB_zd(125),
                              tpd_CKB_DOB125_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(126), DOB_zd(126),
                              tpd_CKB_DOB126_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(127), DOB_zd(127),
                              tpd_CKB_DOB127_posedge,last_B,B_i,NO_SER_TOH);
                           end if;
                           -- Reduce error message --
                           flag_B := True_flg;
                       end if;
                       LastCycleBAddress := B_i;

                   when "01" =>
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           if (B_i = LastCycleAAddress) then
                              if ((Last_WEAN_i = '1') and ((NOW-Last_tc_ClkA_PosEdge) < Tr2w)) then
                                 -- read and write the same address
                                 assert FALSE report "** MEM_Warning: Read and Write the same address." severity WARNING;
                                 DOA_zd := (OTHERS => 'X');
                                 DOA_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                                 memoryCore(to_integer(B_i)) := DIB_i;
                              elsif ((Last_WEAN_i = '0') and ((NOW-Last_tc_ClkA_PosEdge) < Tw2r)) then
                                 assert FALSE report "** MEM_Error: Port A and B write the same Address, core is unknown." severity WARNING;
                                 memoryCore(to_integer(B_i)) := (OTHERS => 'X');
                              else
                                 memoryCore(to_integer(B_i)) := DIB_i;
                              end if;
                           else
                              memoryCore(to_integer(B_i)) := DIB_i;
                           end if;
                           -- Reduce error message --
                           flag_B := True_flg;
                           -- write through --
                           DOB_zd := DIB_i;
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(8), DOB_zd(8),
                              tpd_CKB_DOB8_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(9), DOB_zd(9),
                              tpd_CKB_DOB9_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(10), DOB_zd(10),
                              tpd_CKB_DOB10_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(11), DOB_zd(11),
                              tpd_CKB_DOB11_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(12), DOB_zd(12),
                              tpd_CKB_DOB12_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(13), DOB_zd(13),
                              tpd_CKB_DOB13_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(14), DOB_zd(14),
                              tpd_CKB_DOB14_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(15), DOB_zd(15),
                              tpd_CKB_DOB15_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(16), DOB_zd(16),
                              tpd_CKB_DOB16_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(17), DOB_zd(17),
                              tpd_CKB_DOB17_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(18), DOB_zd(18),
                              tpd_CKB_DOB18_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(19), DOB_zd(19),
                              tpd_CKB_DOB19_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(20), DOB_zd(20),
                              tpd_CKB_DOB20_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(21), DOB_zd(21),
                              tpd_CKB_DOB21_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(22), DOB_zd(22),
                              tpd_CKB_DOB22_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(23), DOB_zd(23),
                              tpd_CKB_DOB23_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(24), DOB_zd(24),
                              tpd_CKB_DOB24_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(25), DOB_zd(25),
                              tpd_CKB_DOB25_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(26), DOB_zd(26),
                              tpd_CKB_DOB26_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(27), DOB_zd(27),
                              tpd_CKB_DOB27_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(28), DOB_zd(28),
                              tpd_CKB_DOB28_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(29), DOB_zd(29),
                              tpd_CKB_DOB29_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(30), DOB_zd(30),
                              tpd_CKB_DOB30_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(31), DOB_zd(31),
                              tpd_CKB_DOB31_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(32), DOB_zd(32),
                              tpd_CKB_DOB32_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(33), DOB_zd(33),
                              tpd_CKB_DOB33_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(34), DOB_zd(34),
                              tpd_CKB_DOB34_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(35), DOB_zd(35),
                              tpd_CKB_DOB35_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(36), DOB_zd(36),
                              tpd_CKB_DOB36_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(37), DOB_zd(37),
                              tpd_CKB_DOB37_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(38), DOB_zd(38),
                              tpd_CKB_DOB38_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(39), DOB_zd(39),
                              tpd_CKB_DOB39_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(40), DOB_zd(40),
                              tpd_CKB_DOB40_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(41), DOB_zd(41),
                              tpd_CKB_DOB41_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(42), DOB_zd(42),
                              tpd_CKB_DOB42_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(43), DOB_zd(43),
                              tpd_CKB_DOB43_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(44), DOB_zd(44),
                              tpd_CKB_DOB44_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(45), DOB_zd(45),
                              tpd_CKB_DOB45_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(46), DOB_zd(46),
                              tpd_CKB_DOB46_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(47), DOB_zd(47),
                              tpd_CKB_DOB47_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(48), DOB_zd(48),
                              tpd_CKB_DOB48_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(49), DOB_zd(49),
                              tpd_CKB_DOB49_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(50), DOB_zd(50),
                              tpd_CKB_DOB50_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(51), DOB_zd(51),
                              tpd_CKB_DOB51_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(52), DOB_zd(52),
                              tpd_CKB_DOB52_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(53), DOB_zd(53),
                              tpd_CKB_DOB53_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(54), DOB_zd(54),
                              tpd_CKB_DOB54_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(55), DOB_zd(55),
                              tpd_CKB_DOB55_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(56), DOB_zd(56),
                              tpd_CKB_DOB56_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(57), DOB_zd(57),
                              tpd_CKB_DOB57_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(58), DOB_zd(58),
                              tpd_CKB_DOB58_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(59), DOB_zd(59),
                              tpd_CKB_DOB59_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(60), DOB_zd(60),
                              tpd_CKB_DOB60_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(61), DOB_zd(61),
                              tpd_CKB_DOB61_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(62), DOB_zd(62),
                              tpd_CKB_DOB62_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(63), DOB_zd(63),
                              tpd_CKB_DOB63_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(64), DOB_zd(64),
                              tpd_CKB_DOB64_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(65), DOB_zd(65),
                              tpd_CKB_DOB65_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(66), DOB_zd(66),
                              tpd_CKB_DOB66_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(67), DOB_zd(67),
                              tpd_CKB_DOB67_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(68), DOB_zd(68),
                              tpd_CKB_DOB68_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(69), DOB_zd(69),
                              tpd_CKB_DOB69_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(70), DOB_zd(70),
                              tpd_CKB_DOB70_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(71), DOB_zd(71),
                              tpd_CKB_DOB71_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(72), DOB_zd(72),
                              tpd_CKB_DOB72_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(73), DOB_zd(73),
                              tpd_CKB_DOB73_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(74), DOB_zd(74),
                              tpd_CKB_DOB74_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(75), DOB_zd(75),
                              tpd_CKB_DOB75_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(76), DOB_zd(76),
                              tpd_CKB_DOB76_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(77), DOB_zd(77),
                              tpd_CKB_DOB77_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(78), DOB_zd(78),
                              tpd_CKB_DOB78_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(79), DOB_zd(79),
                              tpd_CKB_DOB79_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(80), DOB_zd(80),
                              tpd_CKB_DOB80_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(81), DOB_zd(81),
                              tpd_CKB_DOB81_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(82), DOB_zd(82),
                              tpd_CKB_DOB82_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(83), DOB_zd(83),
                              tpd_CKB_DOB83_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(84), DOB_zd(84),
                              tpd_CKB_DOB84_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(85), DOB_zd(85),
                              tpd_CKB_DOB85_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(86), DOB_zd(86),
                              tpd_CKB_DOB86_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(87), DOB_zd(87),
                              tpd_CKB_DOB87_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(88), DOB_zd(88),
                              tpd_CKB_DOB88_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(89), DOB_zd(89),
                              tpd_CKB_DOB89_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(90), DOB_zd(90),
                              tpd_CKB_DOB90_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(91), DOB_zd(91),
                              tpd_CKB_DOB91_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(92), DOB_zd(92),
                              tpd_CKB_DOB92_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(93), DOB_zd(93),
                              tpd_CKB_DOB93_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(94), DOB_zd(94),
                              tpd_CKB_DOB94_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(95), DOB_zd(95),
                              tpd_CKB_DOB95_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(96), DOB_zd(96),
                              tpd_CKB_DOB96_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(97), DOB_zd(97),
                              tpd_CKB_DOB97_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(98), DOB_zd(98),
                              tpd_CKB_DOB98_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(99), DOB_zd(99),
                              tpd_CKB_DOB99_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(100), DOB_zd(100),
                              tpd_CKB_DOB100_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(101), DOB_zd(101),
                              tpd_CKB_DOB101_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(102), DOB_zd(102),
                              tpd_CKB_DOB102_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(103), DOB_zd(103),
                              tpd_CKB_DOB103_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(104), DOB_zd(104),
                              tpd_CKB_DOB104_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(105), DOB_zd(105),
                              tpd_CKB_DOB105_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(106), DOB_zd(106),
                              tpd_CKB_DOB106_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(107), DOB_zd(107),
                              tpd_CKB_DOB107_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(108), DOB_zd(108),
                              tpd_CKB_DOB108_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(109), DOB_zd(109),
                              tpd_CKB_DOB109_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(110), DOB_zd(110),
                              tpd_CKB_DOB110_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(111), DOB_zd(111),
                              tpd_CKB_DOB111_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(112), DOB_zd(112),
                              tpd_CKB_DOB112_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(113), DOB_zd(113),
                              tpd_CKB_DOB113_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(114), DOB_zd(114),
                              tpd_CKB_DOB114_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(115), DOB_zd(115),
                              tpd_CKB_DOB115_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(116), DOB_zd(116),
                              tpd_CKB_DOB116_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(117), DOB_zd(117),
                              tpd_CKB_DOB117_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(118), DOB_zd(118),
                              tpd_CKB_DOB118_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(119), DOB_zd(119),
                              tpd_CKB_DOB119_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(120), DOB_zd(120),
                              tpd_CKB_DOB120_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(121), DOB_zd(121),
                              tpd_CKB_DOB121_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(122), DOB_zd(122),
                              tpd_CKB_DOB122_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(123), DOB_zd(123),
                              tpd_CKB_DOB123_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(124), DOB_zd(124),
                              tpd_CKB_DOB124_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(125), DOB_zd(125),
                              tpd_CKB_DOB125_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(126), DOB_zd(126),
                              tpd_CKB_DOB126_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(127), DOB_zd(127),
                              tpd_CKB_DOB127_posedge,last_B,B_i,NO_SER_TOH);
                       elsif (AddressRangeCheck(B_i,flag_B) = Range_flg) then
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                           -- write through --
                           DOB_zd := DIB_i;
                              ScheduleOutputDelay(DOB_int(0), DOB_zd(0),
                              tpd_CKB_DOB0_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(1), DOB_zd(1),
                              tpd_CKB_DOB1_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(2), DOB_zd(2),
                              tpd_CKB_DOB2_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(3), DOB_zd(3),
                              tpd_CKB_DOB3_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(4), DOB_zd(4),
                              tpd_CKB_DOB4_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(5), DOB_zd(5),
                              tpd_CKB_DOB5_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(6), DOB_zd(6),
                              tpd_CKB_DOB6_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(7), DOB_zd(7),
                              tpd_CKB_DOB7_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(8), DOB_zd(8),
                              tpd_CKB_DOB8_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(9), DOB_zd(9),
                              tpd_CKB_DOB9_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(10), DOB_zd(10),
                              tpd_CKB_DOB10_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(11), DOB_zd(11),
                              tpd_CKB_DOB11_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(12), DOB_zd(12),
                              tpd_CKB_DOB12_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(13), DOB_zd(13),
                              tpd_CKB_DOB13_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(14), DOB_zd(14),
                              tpd_CKB_DOB14_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(15), DOB_zd(15),
                              tpd_CKB_DOB15_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(16), DOB_zd(16),
                              tpd_CKB_DOB16_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(17), DOB_zd(17),
                              tpd_CKB_DOB17_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(18), DOB_zd(18),
                              tpd_CKB_DOB18_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(19), DOB_zd(19),
                              tpd_CKB_DOB19_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(20), DOB_zd(20),
                              tpd_CKB_DOB20_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(21), DOB_zd(21),
                              tpd_CKB_DOB21_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(22), DOB_zd(22),
                              tpd_CKB_DOB22_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(23), DOB_zd(23),
                              tpd_CKB_DOB23_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(24), DOB_zd(24),
                              tpd_CKB_DOB24_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(25), DOB_zd(25),
                              tpd_CKB_DOB25_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(26), DOB_zd(26),
                              tpd_CKB_DOB26_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(27), DOB_zd(27),
                              tpd_CKB_DOB27_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(28), DOB_zd(28),
                              tpd_CKB_DOB28_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(29), DOB_zd(29),
                              tpd_CKB_DOB29_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(30), DOB_zd(30),
                              tpd_CKB_DOB30_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(31), DOB_zd(31),
                              tpd_CKB_DOB31_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(32), DOB_zd(32),
                              tpd_CKB_DOB32_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(33), DOB_zd(33),
                              tpd_CKB_DOB33_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(34), DOB_zd(34),
                              tpd_CKB_DOB34_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(35), DOB_zd(35),
                              tpd_CKB_DOB35_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(36), DOB_zd(36),
                              tpd_CKB_DOB36_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(37), DOB_zd(37),
                              tpd_CKB_DOB37_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(38), DOB_zd(38),
                              tpd_CKB_DOB38_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(39), DOB_zd(39),
                              tpd_CKB_DOB39_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(40), DOB_zd(40),
                              tpd_CKB_DOB40_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(41), DOB_zd(41),
                              tpd_CKB_DOB41_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(42), DOB_zd(42),
                              tpd_CKB_DOB42_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(43), DOB_zd(43),
                              tpd_CKB_DOB43_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(44), DOB_zd(44),
                              tpd_CKB_DOB44_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(45), DOB_zd(45),
                              tpd_CKB_DOB45_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(46), DOB_zd(46),
                              tpd_CKB_DOB46_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(47), DOB_zd(47),
                              tpd_CKB_DOB47_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(48), DOB_zd(48),
                              tpd_CKB_DOB48_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(49), DOB_zd(49),
                              tpd_CKB_DOB49_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(50), DOB_zd(50),
                              tpd_CKB_DOB50_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(51), DOB_zd(51),
                              tpd_CKB_DOB51_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(52), DOB_zd(52),
                              tpd_CKB_DOB52_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(53), DOB_zd(53),
                              tpd_CKB_DOB53_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(54), DOB_zd(54),
                              tpd_CKB_DOB54_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(55), DOB_zd(55),
                              tpd_CKB_DOB55_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(56), DOB_zd(56),
                              tpd_CKB_DOB56_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(57), DOB_zd(57),
                              tpd_CKB_DOB57_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(58), DOB_zd(58),
                              tpd_CKB_DOB58_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(59), DOB_zd(59),
                              tpd_CKB_DOB59_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(60), DOB_zd(60),
                              tpd_CKB_DOB60_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(61), DOB_zd(61),
                              tpd_CKB_DOB61_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(62), DOB_zd(62),
                              tpd_CKB_DOB62_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(63), DOB_zd(63),
                              tpd_CKB_DOB63_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(64), DOB_zd(64),
                              tpd_CKB_DOB64_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(65), DOB_zd(65),
                              tpd_CKB_DOB65_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(66), DOB_zd(66),
                              tpd_CKB_DOB66_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(67), DOB_zd(67),
                              tpd_CKB_DOB67_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(68), DOB_zd(68),
                              tpd_CKB_DOB68_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(69), DOB_zd(69),
                              tpd_CKB_DOB69_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(70), DOB_zd(70),
                              tpd_CKB_DOB70_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(71), DOB_zd(71),
                              tpd_CKB_DOB71_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(72), DOB_zd(72),
                              tpd_CKB_DOB72_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(73), DOB_zd(73),
                              tpd_CKB_DOB73_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(74), DOB_zd(74),
                              tpd_CKB_DOB74_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(75), DOB_zd(75),
                              tpd_CKB_DOB75_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(76), DOB_zd(76),
                              tpd_CKB_DOB76_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(77), DOB_zd(77),
                              tpd_CKB_DOB77_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(78), DOB_zd(78),
                              tpd_CKB_DOB78_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(79), DOB_zd(79),
                              tpd_CKB_DOB79_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(80), DOB_zd(80),
                              tpd_CKB_DOB80_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(81), DOB_zd(81),
                              tpd_CKB_DOB81_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(82), DOB_zd(82),
                              tpd_CKB_DOB82_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(83), DOB_zd(83),
                              tpd_CKB_DOB83_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(84), DOB_zd(84),
                              tpd_CKB_DOB84_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(85), DOB_zd(85),
                              tpd_CKB_DOB85_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(86), DOB_zd(86),
                              tpd_CKB_DOB86_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(87), DOB_zd(87),
                              tpd_CKB_DOB87_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(88), DOB_zd(88),
                              tpd_CKB_DOB88_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(89), DOB_zd(89),
                              tpd_CKB_DOB89_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(90), DOB_zd(90),
                              tpd_CKB_DOB90_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(91), DOB_zd(91),
                              tpd_CKB_DOB91_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(92), DOB_zd(92),
                              tpd_CKB_DOB92_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(93), DOB_zd(93),
                              tpd_CKB_DOB93_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(94), DOB_zd(94),
                              tpd_CKB_DOB94_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(95), DOB_zd(95),
                              tpd_CKB_DOB95_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(96), DOB_zd(96),
                              tpd_CKB_DOB96_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(97), DOB_zd(97),
                              tpd_CKB_DOB97_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(98), DOB_zd(98),
                              tpd_CKB_DOB98_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(99), DOB_zd(99),
                              tpd_CKB_DOB99_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(100), DOB_zd(100),
                              tpd_CKB_DOB100_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(101), DOB_zd(101),
                              tpd_CKB_DOB101_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(102), DOB_zd(102),
                              tpd_CKB_DOB102_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(103), DOB_zd(103),
                              tpd_CKB_DOB103_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(104), DOB_zd(104),
                              tpd_CKB_DOB104_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(105), DOB_zd(105),
                              tpd_CKB_DOB105_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(106), DOB_zd(106),
                              tpd_CKB_DOB106_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(107), DOB_zd(107),
                              tpd_CKB_DOB107_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(108), DOB_zd(108),
                              tpd_CKB_DOB108_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(109), DOB_zd(109),
                              tpd_CKB_DOB109_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(110), DOB_zd(110),
                              tpd_CKB_DOB110_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(111), DOB_zd(111),
                              tpd_CKB_DOB111_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(112), DOB_zd(112),
                              tpd_CKB_DOB112_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(113), DOB_zd(113),
                              tpd_CKB_DOB113_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(114), DOB_zd(114),
                              tpd_CKB_DOB114_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(115), DOB_zd(115),
                              tpd_CKB_DOB115_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(116), DOB_zd(116),
                              tpd_CKB_DOB116_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(117), DOB_zd(117),
                              tpd_CKB_DOB117_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(118), DOB_zd(118),
                              tpd_CKB_DOB118_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(119), DOB_zd(119),
                              tpd_CKB_DOB119_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(120), DOB_zd(120),
                              tpd_CKB_DOB120_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(121), DOB_zd(121),
                              tpd_CKB_DOB121_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(122), DOB_zd(122),
                              tpd_CKB_DOB122_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(123), DOB_zd(123),
                              tpd_CKB_DOB123_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(124), DOB_zd(124),
                              tpd_CKB_DOB124_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(125), DOB_zd(125),
                              tpd_CKB_DOB125_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(126), DOB_zd(126),
                              tpd_CKB_DOB126_posedge,last_B,B_i,NO_SER_TOH);
                              ScheduleOutputDelay(DOB_int(127), DOB_zd(127),
                              tpd_CKB_DOB127_posedge,last_B,B_i,NO_SER_TOH);
                       else
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                           DOB_zd := (OTHERS => 'X');
                           DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                       LastCycleBAddress := B_i;
                   when "1X" |
                        "1U" |
                        "1Z"   =>
                       DOB_zd := (OTHERS => 'X');
                       DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;

                   when "10" |
                        "00" |
                        "X0" |
                        "U0" |
                        "Z0"   => -- do nothing
                   when others =>
                       DOB_zd := (OTHERS => 'X');
                       DOB_int <= TRANSPORT (OTHERS => 'X') AFTER TOH;
                       if (AddressRangeCheck(B_i,flag_B) = True_flg) then
                           memoryCore(to_integer(B_i)) := (OTHERS => 'X');
                       elsif (AddressRangeCheck(B_i,flag_B) = Range_flg) then
                           -- Reduce error message --
                           flag_B := False_flg;
                           --------------------------
                       else
                           FOR i IN Words-1 downto 0 LOOP
                              memoryCore(i) := (OTHERS => 'X');
                           END LOOP;
                       end if;
                end case;
                Last_WEBN_i := WEBN_i;
                -- end memory_functionB
         end if;
       end if;
       -- end timingcheck_violationB

   end PROCESS;
end behavior;
