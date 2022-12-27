-----------------------------------------------------------------------------
-- Title      : FPGA TDC
-- Copyright © 2015 Harald Homulle / Edoardo Charbon
-----------------------------------------------------------------------------
-- This file is part of FPGA TDC.

-- FPGA TDC is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- FPGA TDC is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with FPGA TDC.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------------
-- File       : fine_tdc.vhd
-- Author     : <h.a.r.homulle@tudelft.nl>
-- Company    : TU Delft
-- Last update: 2015-01-01
-- Platform   : FPGA (tested on Spartan 6 and Artix 7)
-----------------------------------------------------------------------------
-- Description: 
-- The main part of the system, i.e. the delayline based TDC. 
-- Generating the carrychains and double latching of the output for better stability. 
-----------------------------------------------------------------------------
-- Revisions  :
-- Date			Version		Author		Description
-- 2006  		1.0      	Claudio		Created
-- 2014  		2.0      	Homulle		Rewrote core code and added the Therm2bin with counter
-----------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.math_real.ALL;

LIBRARY unisim;
USE unisim.vcomponents.ALL;

ENTITY fine_tdc IS
	GENERIC (
		STAGES 	: INTEGER := 512;
		Xoff	: INTEGER := 44;
		Yoff	: INTEGER := 24);
	PORT (
		trigger			: IN std_logic;		-- START signal input (triggers carrychain)
		reset			: IN std_logic;
		clock			: IN std_logic;		-- STOP signal input (assumed to be clock synchronous)
		latched_output	: OUT std_logic_vector(STAGES-1 DOWNTO 0));		-- Carrychain output, to be converted to binary
END fine_tdc;

ARCHITECTURE behaviour OF fine_tdc IS

	-- To place the delayline in a particular spot (best for linearities and resolution), the LOC constraint is used.
	ATTRIBUTE LOC			 	: string;
	ATTRIBUTE keep_hierarchy 	: string;
	ATTRIBUTE keep_hierarchy OF behaviour	: ARCHITECTURE IS "true";

	SIGNAL unreg		: std_logic_vector(STAGES-1 DOWNTO 0);
	SIGNAL reg			: std_logic_vector(STAGES-1 DOWNTO 0);

BEGIN

	-- Generation of the carrychain, starting at the specified X, Y coordinate. 
	carry_delay_line: FOR i IN 0 TO STAGES/4-1 GENERATE
	
		first_carry4: IF i = 0 GENERATE
		
			ATTRIBUTE LOC OF delayblock : LABEL IS "SLICE_X"&INTEGER'image(Xoff)&"Y"&INTEGER'image(Yoff+i);
			
		BEGIN
		
			delayblock: CARRY4 
				PORT MAP(
					CO 		=> unreg(3 DOWNTO 0),
					CI 		=> '0',
					CYINIT 	=> trigger,
					DI 		=> "0000",
					S 		=> "1111");
         END GENERATE;
		 
         next_carry4: IF i > 0 GENERATE
		 
			ATTRIBUTE LOC OF delayblock : LABEL IS "SLICE_X"&INTEGER'image(Xoff)&"Y"&INTEGER'image(Yoff+i);
			
		BEGIN
		
            delayblock: CARRY4 
				PORT MAP(
					CO 		=> unreg(4*(i+1)-1 DOWNTO 4*i),
					CI 		=> unreg(4*i-1),
					CYINIT 	=> '0',
					DI 		=> "0000",
					S 		=> "1111");
         END GENERATE;
    END GENERATE;
    
    -- The output is latched two times for stability reasons. 
	latch: FOR j IN 0 TO STAGES-1 GENERATE
	
		--ATTRIBUTE LOC OF FDR_1 : LABEL IS "SLICE_X"&INTEGER'image(Xoff)&"Y"&INTEGER'image(Yoff+integer(floor(real(j/4))));
		--ATTRIBUTE LOC OF FDR_2 : LABEL IS "SLICE_X"&INTEGER'image(Xoff+1)&"Y"&INTEGER'image(Yoff+integer(floor(real(j/4))));
		
	BEGIN
	
		FDR_1: FDR 
			GENERIC MAP(
				INIT 	=> '0')
			PORT MAP(
				C 		=> clock,
				R 		=> reset,
				D 		=> unreg(j),
				Q 		=> reg(j));
		FDR_2: FDR	
			GENERIC MAP(
				INIT 	=> '0')
			PORT MAP(
				C 		=> clock,
				R 		=> reset,
				D 		=> reg(j),
				Q 		=> latched_output(j));
	END GENERATE;

END behaviour;
