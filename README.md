# RAM 64x8 Project Documentation

## 1. Project Introduction
This project implements and verifies a basic single-port synchronous RAM using Verilog. A single-port RAM allows one read and one write operation, using a shared address/data bus, controlled by a single clock. Data written into a given address remains stored until it is overwritten.

The project contains the RTL design and a simple directed testbench that applies write and read operations and observes the RAM's output through simulation.

## 2. Design Specification

| Parameter        | Value                          |
|-------------------|---------------------------------|
| Design Type       | Single-Port Synchronous RAM     |
| Data Width        | 8 bits                          |
| Memory Depth      | 64 entries                      |
| Memory Size       | 64 x 8-bit                      |
| Address Width     | 6 bits                          |
| Clocking          | Positive edge triggered         |
| Reset Type        | None (no reset signal)          |
| Read Type         | Synchronous (registered output) |
| Write Type        | Synchronous                     |

## 3. RTL Interface
The RAM module is defined in `ram_64x8.v`.

| Signal    | Direction | Width  | Description                          |
|-----------|-----------|--------|---------------------------------------|
| clk       | Input     | 1 bit  | Clock signal                          |
| we        | Input     | 1 bit  | Write enable                          |
| wr_addr   | Input     | 6 bits | Write address (0–63)                  |
| rd_addr   | Input     | 6 bits | Read address (0–63)                   |
| data      | Input     | 8 bits | Data to be written into RAM           |
| q         | Output    | 8 bits | Data read from RAM (registered)       |

## 4. Internal Architecture
The RAM contains the following internal storage:

| Internal Signal | Width      | Purpose                    |
|-------------------|------------|-----------------------------|
| ram[63:0]         | 64 x 8-bit | Memory array                |
| q                 | 8 bits     | Registered read-data output |

The design uses separate read and write address ports (`rd_addr`, `wr_addr`), so a read and a write can target different locations in the same clock cycle. There is no dedicated reset; on power-up, memory contents and `q` are undefined (`x`) until a write and a corresponding read occur.

## 5. RAM Operation

### Write Operation
On the rising edge of `clk`, when `we` is high:
- `data` is stored into `ram[wr_addr]`.
- The write is non-blocking, so it takes effect after the clock edge, along with the read below.

Write is skipped when `we` is low.

### Read Operation
On every rising edge of `clk` (regardless of `we`):
- `q` is loaded with `ram[rd_addr]`.
- Since this assignment is inside the clocked `always` block, the read is **synchronous** — `q` reflects `rd_addr` one clock cycle later, not immediately.

### Read-During-Write Behavior
If `we` is high and `rd_addr == wr_addr` in the same cycle, `q` receives the **old** value of that location, not the value currently being written. This is standard "read-before-write" (old-data) behavior for this style of coding.

### Core Logic
```verilog
always @(posedge clk) begin
    if (we)
        ram[wr_addr] <= data;
    q <= ram[rd_addr];
end
```

## 6. Verification Approach
The verification environment is implemented in `ram_64x8_tb.v` as a simple directed (non-randomized) testbench.

```
stimulus (clk, we, wr_addr, rd_addr, data) -> DUT (ram_64x8) -> q -> $monitor
```

Unlike a class-based / mailbox-driven environment, this testbench directly drives the DUT inputs in an `initial` block and observes `q` via `$monitor`. There is no separate generator, driver, monitor, scoreboard, or coverage class in the current version.

## 7. Testbench Components

### Clock Generation
```verilog
always #5 clk = ~clk;   // 10 ns clock period
```

### Stimulus Sequence
| Step | Action |
|------|--------|
| 1 | Initialize `clk=0`, `we=0`, `data=0`, `rd_addr=0`, `wr_addr=0`. |
| 2 | Write `10101010` to address 5 (`we=1`, `wr_addr=5`). |
| 3 | Disable write, read back address 5 (`we=0`, `rd_addr=5`). |
| 4 | Write `11110000` to address 10 (`we=1`, `wr_addr=10`). |
| 5 | Disable write, read back address 10 (`we=0`, `rd_addr=10`). |
| 6 | `$finish` ends the simulation. |

### Monitor
```verilog
$monitor("Time=%0t clk=%b we=%b wr_addr=%d rd_addr=%d data=%b q=%b",
          $time, clk, we, wr_addr, rd_addr, data, q);
```
Prints the full signal state on every change, giving a cycle-by-cycle trace of the RAM's behavior.

## 8. Simulation Flow
The design was simulated using Icarus Verilog:

```bash
iverilog -o sim ram_64x8.v ram_64x8_tb.v
vvp sim
```

Total simulation run time: 50 ns (5 clock periods).

## 9. Expected Console Behavior
During simulation, `$monitor` prints one line per signal change, showing `clk`, `we`, addresses, `data`, and `q` at each time step. Key checkpoints to verify a correct run:
- `q` should be `xxxxxxxx` until the first read completes.
- `q` should show `10101010` starting one clock cycle after `rd_addr=5` is applied.
- `q` should show `11110000` starting one clock cycle after `rd_addr=10` is applied.
- Simulation ends via `$finish` at 50 ns with no unexpected `x` values in `q`.

## 10. Repository Artifacts
Suggested folder structure for saved outputs:

| Artifact | Purpose |
|----------|---------|
| `ram_64x8.v` | RTL design source |
| `ram_64x8_tb.v` | Testbench source |
| `simulation_log.txt` | Captured console/`$monitor` output |
| `waveform.png` | Simulation waveform capture (if using a VCD/GTKWave setup) |
| `schematic.png` | RTL schematic capture (if synthesized) |

## 11. Limitations and Future Improvements
Current design behavior:
- No reset signal — memory and `q` are undefined until explicitly written and read.
- Read-during-write to the same address returns old data (not tested in the current testbench).
- Testbench is fully directed; no randomization, scoreboard, or coverage is implemented.
- Only a handful of addresses (5 and 10) are exercised; the remaining 62 locations are untested.

Possible future improvements:
- Add a synchronous or asynchronous reset to clear memory/`q` on startup.
- Add a randomized testbench with a scoreboard to check all address locations.
- Add functional coverage for address ranges, `we`/read combinations, and read-during-write cases.
- Add assertions to check that `q` never holds stale/incorrect data after a read.
- Parameterize data width and memory depth for reuse in other projects.

## 12. Conclusion
This project demonstrates a basic single-port synchronous RAM design and a simple directed verification flow in Verilog. It covers RTL design, a clocked write/read mechanism, and a monitor-based testbench, serving as a good foundational project before moving on to more advanced memory designs (dual-port RAM, FIFOs) or class-based SystemVerilog verification environments.
