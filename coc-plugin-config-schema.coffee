module.exports = {
  title: "pimatic-coc config"
  type: "object"
  properties:
    serialDeviceName:
      doc: "The name of the serial device to use"
      type: "string"
      default: "/dev/ttyAMA0"
}
