module.exports = {
  title: "coc device config schemas"
  COCSwitch: {
    title: "COCSwitch config options"
    type: "object"
    properties:
      id:
        description: "The id of a device"
        type: "string"
        default: "atHomeId"
      name:
        description: "The name of a device"
        type: "string"
        default: "atHomeName"
      commandOn:
        description: "The command string to send for on state"
        type: "string"
        default: "00"
      commandOff:
        description: "The command string to send for off state"
        type: "string"
        default: "00"
  }
  COCSwitchFS20: {
    title: "COCSwitchFS20 config options"
    type: "object"
    properties:
      id:
        description: "The id of a device"
        type: "string"
        default: "atHomeId"
      name:
        description: "The name of a device"
        type: "string"
        default: "atHomeName"
      houseid:
        description: "The house code"
        type: "string"
        default: "2525"
      deviceid:
        description: "The fs20 device id"
        type: "string"
        default: "00"
      commandOn:
        description: "The command string to send for on state"
        type: "string"
        default: "11"
      commandOff:
        description: "The command string to send for off state"
        type: "string"
        default: "00"
  }
  COCDoorWindowSensorFHT80TF: {
    title: "COCDoorWindowSensorFHT80TF config options"
    type: "object"
    properties:
      id:
        description: "The id of a device"
        type: "string"
        default: "atHomeId"
      name:
        description: "The name of a device"
        type: "string"
        default: "atHomeName"
      deviceid:
        description: "A kind of identification"
        type: "string"
        default: "001122"
  }
}
