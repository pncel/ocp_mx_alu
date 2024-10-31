# ocp_mx_alu
preliminary designs

##### Current focus: MXINT8 and interactions with FP32 (IEEE 754)

#### MXINT8 Status Table 

| function                      | C++ model |Verilog | Testbench    |
| --------                      | -------   |------- | -------- |
| add (vector)                  | 🫡       | ❌     | ❌     |
| subtract (vector)             | 🫡       | ❌     | ❌     |
| multiply (vector)             | ❌       | ❌     | ❌     |
| divide (vector) (optional)    | ❌       | ❌     | ❌     |
| dot product (vector)    | ❌       | ❌     | ❌     |
| broadcast (scalar -> vector)  | 😐       | ✅     | ✅     |
| conversion vector(fp32 -> mxint8) | ❌       | ❌     | ❌     |
| conversion vector(mxint8 -> fp32) | ❌       | ❌     | ❌     |
| sum (vector -> scalar)        | 😐       | 🤔 (ignores unused encoding)     | ✅     |
| negate (vector -> vector)     | 😐       | ✅     | ✅     |
###### (😐=NA, 🤔=UNSURE, 🫡=WIP, ❌=TODO, ✅=DONE)

For vector add, subtract, multiply, divide, inspiration can be taken from the scalar equivalents in FP32 implemented [here](https://github.com/pncel/float_by_hand) in C++.
