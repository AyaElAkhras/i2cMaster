# i2cMaster
This program implements an i2c master that supports only writing to a slave.
The master provides the following interfaces with the CPU:

| Port  | Size | Direction |      Description   |
| ----- | ---- | --------- |--------------------|
| ADDR  |  2   |    In     |I/O register address|
| DataIn|  8   |    In     |   Data Bus         |
|DataOut|  8   |    Out    |   Data Bus         |
|  R/W  |  1   |    In     |   Control          |
