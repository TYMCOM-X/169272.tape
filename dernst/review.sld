
			    DCP



		Capabilities as delivered


Asynchronous - 50 to 19200 bps, interrupt driven

DDCMP synchronous - interrupt driven, receiver CRC checking

T201 synchronous - interrupt driven, no checksum handling in DCP

Bootstrap - in private DCP memory, copied using DMA



		   Problems as delivered

1. Multiple T201 lines failed

2. Baud rate detection

3. Lost output interrupts

4. Interrupt "logjam"


		 Deficiencies as delivered

1. All I/O is interrupt driven

2. No on board transmit CRC generation

3. No on board T201 checksum handling

4. DDCMP mode incompatable with X.25 bisync mode

5. No SDLC (for X.25)

6. RS-232 only

7. Lacks full modem control (no RTS and RI)

8. Configuration restrictions

9. DCP bootstrap did not work



		Short range development

1. Baud rate detection in DCP

2. T201 checksum and DMA

3. DDCMP DMA

4. Async receive DMA




		Long range development

1. SDLC mode DMA

2. DL11 simulation

3. SCC in place of SIO

4. PIO in addition to SIO (SCC)

5. RS-422

6. Local network (broadcast technology with collision avoidance)




	Known problems with micronode V2.50

1. Parallel interface neighbor loading

2. No passthroughs

3. DDCMP link crash on configuration error

4. Host out of ports not handled correctly

 