# LP-CA: Emergent Left-Periphery Word Order Simulation

This repository contains a **NetLogo** implementation of a local-interaction model for left-peripheral word order.  
It tests whether correct surface configurations can emerge **without** a fixed global template, using only local precedence rules and local compatibility constraints.

The simulation implements two reference models:

- **Frascarelli (2012)**
- **Rizzi & Bocci (2017)**

and two update modes:

- **Cascade** – revisits earlier constituents; can revisit earlier pairs
- **Pairwise** – evaluates one fixed adjacent pair per step; earlier placements remain fixed

---

## Running the Model

### Option 1 – NetLogo Desktop
1. Download and install [NetLogo](https://ccl.northwestern.edu/netlogo/) (version 6.x or later).
2. Download this repository:
   ```bash
   git clone https://github.com/linguisticsnet/netlogo-anon-model.git
or click **Code → Download ZIP** and extract it.
3. Open the `.nlogo` file in NetLogo.  
4. In the **Interface** tab:

   - Set `reference-model` to **Frascarelli 2012** or **Rizzi & Bocci 2017**  
   - Set `update-method` to **Cascade** or **Pairwise**  
   - Click `setup` (or `setup-manual` to enter your own sequence)  
   - Click `go` to run the simulation

---

## Option 2 – NetLogo Web

Run the model directly in your browser:

1. Go to [NetLogo Web](https://www.netlogoweb.org/launch#)
2. Click **Upload model**
3. Select the `.nlogo` file from this repository
4. Run the simulation as in the desktop version

> **Note:** If labels do not display correctly, uncomment the web-compatible `update-label` procedure included in the code.

---

## Controls

- `setup` – create a random valid starting row  
- `setup-manual` – manually enter an initial sequence  
- `setup-predefined` – load a fixed test pattern  
- `go` – run the simulation in the selected update mode

---

Happy modeling!
