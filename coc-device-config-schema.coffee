# Defines a `node-convict` config-schema and exports it.
module.exports =

COCSwitch:
  id:
    doc: "The id of a device"
    format: String
    default: "atHomeId"
  name:
    doc: "The name of a device"
    format: String
    default: "atHomeName"
  commandOn:
    doc: "The command string to send for on state"
    format: String
    default: null
  commandOff:
    doc: "The command string to send for off state"
    format: String
    default: null

  COCSwitchFS20:
    id:
      doc: "The id of a device"
      format: String
      default: "atHomeId"
    name:
      doc: "The name of a device"
      format: String
      default: "atHomeName"
    houseid:
      doc: "The house code"
      format: String
      default: "2525"
    deviceid:
      doc: "The fs20 device id"
      format: String
      default: "00"
