# Testbenches pour le labo 2 de computer architecture

## Courtesy of Ectalite : https://github.com/LesFousDeLaPasserelle/CS200-TestbenchLab2

Pour importer dans votre lab:

`git clone https://github.com/LesFousDeLaPasserelle/CS200-TestbenchLab2.git testbench`

Ou (si vous aviez deja fait un repo git avec le labo2)

`git submodule add https://github.com/LesFousDeLaPasserelle/CS200-TestbenchLab2.git testbench`

Pour compiler et démarrer un testbench (par exemple pour l'IR.v):

`verilator --binary --trace -Wno-fatal --top-module tb_ir -o Vtb_ir -I testbench/* -I verilog/* && ./obj_dir/Vtb_ir`

ou

`make TOP_MODULE=tb_ir`

et regarder le tracé sur gtkwave:

`gtkwave dump/tb_ir.vcd`
