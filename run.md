# Commands ran in order:

- yosys -p "synth_gowin -json test.json" counter.v
- nextpnr-gowin --json test.json --write pnr_output.json --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst const.cst --top led
- gowin_pack -d GW1N-9C -o output.fs pnr_output.json
- openFPGALoader -b tangnano9k -f ./output.fs