module.exports = {
  title: "pimatic-coc config"
  type: "object"
  properties:
    serialDeviceName:
      doc: "The name of the serial device to use"
      type: "string"
      default: "/dev/ttyAMA0"
    baudrate:
      doc: "The baudrate to use for serial communication"
      type: "number"
      default: 38400
    hardwareType:
      doc: "The type of the hardware: COC or CUL"
      type: "string"
      default: "COC"
}
