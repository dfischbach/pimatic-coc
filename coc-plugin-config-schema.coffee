# Declare your config option for your plugin here.

# Defines a `node-convict` config-schema and exports it.
module.exports =

  # defaults to Raspberry Pi build in serial port
  serialDeviceName:
    doc: "The name of the serial device to use"
    format: String
    default: "/dev/ttyAMA0"
