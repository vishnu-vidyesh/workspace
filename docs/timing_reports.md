## Type - 1
### The raw snippet
```
 8 Path 1: VIOLATED (-0.893 ns) Setup Check with Pin u_digital_core/u_sdio_axireg_0/u_ar_slave_port_chan_slice/u_ful_regd_slice/payload_reg_a_reg[0] /CK->TD
 9                View: sfunc_ss0p81v125c_RCmax
10               Group: bus_sdio_gclk
11          Startpoint: (F) u_digital_core/u_nic_coms/u_cd_clk_sdio/u_ib_SDIO_ib_s/u_ar_fifo_wr/ts_lockup_latchn_clkc185_intno24275_i/GB
12               Clock: (F) bus_sdio_gclk
13            Endpoint: (R) u_digital_core/u_sdio_axireg_0/u_ar_slave_port_chan_slice/u_ful_regd_slice/payload_reg_a_reg[0]/TD
14               Clock: (R) bus_sdio_gclk
15 
16                        Capture       Launch
17          Clock Edge:+    2.500        1.250
18         Src Latency:+    0.000        0.000
19         Net Latency:+    0.000 (I)   -0.150 (I)
20             Arrival:=    2.500        1.100
21 
22               Setup:-    0.079
23         Uncertainty:-    0.625
24       Required Time:=    1.796
25        Launch Clock:=    1.100
26           Data Path:+    1.590
27               Slack:=   -0.893
28      Timing Path:
```
### Explanation
#### Line 8: Path header
```
Path 1: VIOLATED (-0.893 ns) Setup Check
```

Path 1 = this is the first reported path. </br>
VIOLATED = this path doesn’t meet timing. </br>
(-0.893 ns) = slack (negative means failing by 0.893 ns). </br>
Setup Check = tool is checking that data arrives before the capture clock edge. </br>
/CK->TD → tool is describing the clock pin → data pin timing arc of the endpoint register. </br>

#### Line 9: View
```
View: sfunc_ss0p81v125c_RCmax
```
This is the corner (timing library + RC parasitic view). </br>
ss0p81v125c = slow-slow corner at 0.81V, 125°C (pessimistic). </br>
RCmax = max RC parasitics corner. </br>
### Line 10: Group
```
Group: bus_sdio_gclk
```
This path belongs to the clock group defined on bus_sdio_gclk. </br>
Paths are grouped per clock domain for reporting. </br>

#### Lines 11–14: Startpoint / Endpoint
```
Startpoint: (F) .../GB
Clock: (F) bus_sdio_gclk

Endpoint: (R) .../payload_reg_a_reg[0]/TD
Clock: (R) bus_sdio_gclk
```
Startpoint = launch flip-flop (or latch). </br>
(F) = “functional” (as opposed to test, false, etc). </br>
/GB = the Q output pin of the launching register. </br>
Endpoint = capture register’s data pin (TD). </br>
Both driven by the same clock bus_sdio_gclk. </br>
So it’s a reg-to-reg path within the same clock domain. </br>

#### Lines 16–20: Timing origin
```
Capture       Launch
Clock Edge:+    2.500        1.250
Src Latency:+    0.000        0.000
Net Latency:+    0.000 (I)   -0.150 (I)
Arrival:=        2.500        1.100
```
Clock Edge = capture happens at 2.500 ns, launch at 1.250 ns. </br>
→ This is your clock period division. Likely period = 1.25 ns * 2 = 2.5 ns (400 MHz). </br>
Src Latency = no additional modeled source latency. </br>
Net Latency (I) = insertion delay from clock tree. </br>
Launch clock arrives earlier than ideal (negative 0.150). </br>
Capture clock arrives at 0.000. </br>
→ So there is clock skew helping or hurting. </br>
Arrival = the effective clock edge time used for timing math: </br>
Launch edge at 1.100 ns (1.250 – 0.150). </br>
Capture edge at 2.500 ns (2.500 + 0.000). </br>

#### Lines 22–24: Requirements
```
Setup:-    0.079
Uncertainty:-    0.625
Required Time:=    1.796
```
Setup 0.079 = library setup time of the endpoint flop (time before clock edge data must be stable). </br>
Uncertainty 0.625 = clock uncertainty (jitter, variation) applied → shrinks available timing window. </br>
Required Time 1.796 = Capture edge (2.500) - setup (0.079) - uncertainty (0.625) = 1.796 ns. </br>
This is the latest the data can arrive and still meet setup. </br>

#### Lines 25–26: Actual arrival
```
Launch Clock:=    1.100
Data Path:+       1.590
```
Launch Clock 1.100 = when data starts launching from the source register. </br>
Data Path 1.590 = how long the combinational + routing takes. </br>
Arrival time = 1.100 + 1.590 = 2.690 ns. </br>
(but you see 2.500 in the table because of formatting; detailed report shows actual accumulation). </br>

#### Line 27: Slack
```
Slack:= -0.893
```
Slack = Required – Arrival = 1.796 – 2.689 ≈ -0.893 ns. </br>
Means the data arrives ~0.9 ns too late. </br>

### Summary
- Launch flop launches data at 1.100 ns. </br>
- Data takes 1.590 ns to travel through logic/nets. </br>
- So it arrives at capture flop at 2.689 ns. </br>

## Type - 2
### The raw snippet
```
171 Path 3: VIOLATED (-0.407 ns) Path Delay Check with Pin u_digital_core/u_gic/u_icb_cache/gic500_0_T1_tessent_mbist_c1_controller_inst/MEM_SELECT_REG_reg[0]/SB
172                View: sfunc_ss0p81v125c_RCmax
173               Group: Reg2Reg
174          Startpoint: (R) u_digital_core/u_gic/gic500_0_T1_tessent_sib_sti_inst/ltest_to_reset_reg/CK
175               Clock: (R) cpu_gclk
176            Endpoint: (R) u_digital_core/u_gic/u_icb_cache/gic500_0_T1_tessent_mbist_c1_controller_inst/MEM_SELECT_REG_reg[0]/SB
177               Clock: (R) cpu_gclk
178 
179                        Capture       Launch
180          Path Delay:+    1.667            -
181         Src Latency:+    0.000        0.000
182         Net Latency:+    0.000 (I)    0.000 (I)
183             Arrival:=    1.667        0.000
184 
185            Recovery:-   -0.004
186         Uncertainty:-    0.625
187       Required Time:=    1.046
188        Launch Clock:=    0.000
189           Data Path:+    1.453
190               Slack:=   -0.407
```
### Explanation
#### Line 171: Path header
```
Path 3: VIOLATED (-0.407 ns) Path Delay Check
```
This is not a normal setup check. </br>
It’s a Recovery check (for asynchronous control signals like reset, set, scan enable). </br>
Slack = -0.407 ns → the async control signal arrives too late relative to the clock requirement. </br>
Endpoint pin: </br>
.../MEM_SELECT_REG_reg[0]/SB → This is the Set/Reset/Scan/Secondary pin of the flop (SB = set/reset bar). </br>
So the tool is checking how the reset release (or set deassertion) meets timing with respect to the clock. </br>

#### Line 172: View
```
View: sfunc_ss0p81v125c_RCmax
```
Same as before: slow-slow corner, 0.81 V, 125 °C, max RC parasitics. </br>
#### Line 173: Group
```
Group: Reg2Reg
```
Tool grouped this check into the register-to-register group. </br>
In this context, it really means "timing between async control and clock domain". </br>

#### Lines 174–177: Startpoint and Endpoint
```
Startpoint: (R) .../ltest_to_reset_reg/CK
Clock: (R) cpu_gclk

Endpoint: (R) .../MEM_SELECT_REG_reg[0]/SB
Clock: (R) cpu_gclk
```
Startpoint = some flop driving the reset logic (ltest_to_reset_reg). </br>
Endpoint = the async set/reset input (SB) of the capture flop. </br>
Both in cpu_gclk domain, but the check is Recovery. </br>

#### Lines 179–183: Timing origin
```
Capture       Launch
Path Delay:+    1.667            -
Src Latency:+    0.000        0.000
Net Latency:+    0.000 (I)    0.000 (I)
Arrival:=        1.667        0.000
```
Path Delay 1.667 = reset release signal takes 1.667 ns to propagate from startpoint to endpoint. </br>
Arrival = 1.667 ns (launch at 0.000 ns + 1.667 ns of delay). </br>
This is when reset is deasserted at the endpoint. </br>

#### Lines 185–187: Requirements
```
Recovery:-   -0.004
Uncertainty:-    0.625
Required Time:=    1.046
```
Recovery -0.004 = the library recovery time (similar to setup for async signals: reset must be stable some time before the active clock edge). </br>
Uncertainty 0.625 = jitter margin applied. </br>
Required Time 1.046 ns = the latest the reset signal can safely deassert. </br>
(Calculated as: capture clock edge - recovery - uncertainty). </br>

#### Lines 188–189: Launch and data path
```
Launch Clock:=    0.000
Data Path:+       1.453
```
Reset is launched at time 0.
Propagates through ~1.45 ns of combinational logic. </br>
Plus clock alignment → arrival ~1.667 ns. </br>
#### Line 190: Slack
```
Slack:=   -0.407
```
Slack = Required Time – Arrival = 1.046 – 1.453 ≈ -0.407 ns. </br>
Reset deasserts 0.4 ns too late relative to the clock → potential metastability risk. </br>
TL;DR in plain words </br>
This isn’t a normal data setup violation — it’s a Recovery violation on the reset path: </br>
The reset release signal to MEM_SELECT_REG_reg[0] is deasserting too late. </br>
The flop requires reset to be stable 1.046 ns before the next clock edge, but the reset is only stable at 1.453 ns → late by 0.407 ns. </br>
This means at silicon, the flop could come out of reset right near a clock edge → unsafe, could cause metastability. </br>

What you can do </br>
Check if reset should be timed: </br>
Often async resets are excluded from STA with: </br>
```
set_false_path -from [get_ports reset_n]
```
or similar. Many flows don’t require reset recovery/removal checks in signoff. </br>
If you do want to time reset paths: </br>
Make sure reset deassertion is synchronized to the clock (two-flop synchronizer). </br>
Or pipeline reset signals to meet recovery requirements. </br>
Or apply a multicycle/false path exception if reset doesn’t need cycle-accurate timing. </br>

