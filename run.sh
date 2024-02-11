#!/bin/bash
yosys -p "synth_gowin -json synth.json" app.v

if [ $? -eq 0 ]; then
    echo "--- DONE SYNTH ---"
else
    echo "ERR $?."
    exit 1
fi


nextpnr-gowin --json synth.json --write pnr_output.json --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst const.cst --top top

echo "--- DONE PNR ---"

gowin_pack -d GW1N-9C -o output.fs pnr_output.json

echo "--- DONE PACKING ---"

openFPGALoader -b tangnano9k -f ./output.fs