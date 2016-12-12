
module.exports = (env) ->

  Promise   = env.require 'bluebird'
  serialport = require 'serialport'
  SerialPort = serialport.SerialPort

  Gpio = env.Gpio or require('onoff').Gpio
  Promise.promisifyAll(Gpio.prototype)

  _ = env.require 'lodash'

  # the plugin class
  class COCPlugin extends env.plugins.Plugin

    @transport

    init: (app, @framework, @config) ->
      env.logger.info "coc: init"

      serialName = @config.serialDeviceName
      env.logger.info("coc: init with serial device name #{serialName}@#{@config.baudrate}, hardwareType #{@config.hardwareType}")

      if @config.hardwareType is "COC"
        env.logger.info("init coc begin")
        gpio17 = new Gpio 17, 'out'
        gpio18 = new Gpio 18, 'out'
        gpio18.writeSync(1)
        gpio17.writeSync(0)
        @wait(1000)
        gpio17.writeSync(1)
        @wait(1000)
        env.logger.info("init coc end")


      @cmdReceivers = [];
      @transport = new COCTransport serialName, @config.baudrate, @receiveCommandCallback

      deviceConfigDef = require("./coc-device-config-schema")

      deviceClasses = [
        COCSwitch,
        COCSwitchFS20,
        COCDoorWindowSensorFHT80TF
      ]

      for Cl in deviceClasses
        do (Cl) =>
          @framework.deviceManager.registerDeviceClass(Cl.name, {
            configDef: deviceConfigDef[Cl.name]
            createCallback: (deviceConfig) =>
              device = new Cl(deviceConfig)
              if Cl in [COCSwitch, COCSwitchFS20, COCDoorWindowSensorFHT80TF]
                @cmdReceivers.push device
              return device
          })

    removeCmdReceiver: (device) ->
      env.logger.info "removeCmdReceiver #{device}"

      index = @cmdReceivers.indexOf(device)
      if index > -1
        @cmdReceivers.splice(index, 1)

    sendCommand: (id, cmdString) ->
      @transport.sendCommand id, cmdString

    receiveCommandCallback: (cmdString) =>
      for cmdReceiver in @cmdReceivers
        handled = cmdReceiver.handleReceivedCmd cmdString
        break if handled

      if (!handled)
        env.logger.info "received unhandled command string: #{cmdString}"

    wait: (millisec) ->
      date = Date.now()
      curDate = null
      loop
        curDate = Date.now()
        break if (curDate-date > millisec)


  # COCTransport handles the communication with the coc module
  class COCTransport

    @serial

    constructor: (serialPortName, baudrate, @receiveCommandHandler) ->

      @cmdString = ""
      @serial = new SerialPort serialPortName, baudrate: baudrate, false

      @serial.open (err) ->
        if ( err? )
          env.logger.info "open serialPort #{serialPortName} failed #{err}"
        else
          env.logger.info "open serialPort #{serialPortName}"


      @serial.on 'open', =>
        # enable receive mode of coc
        @serial.write('X01\n')

      @serial.on 'error', (err) ->
         env.logger.error "coc: serial error #{err}"

      @serial.on 'data', (data) =>
        env.logger.debug "coc: serial data received #{data}"
        dataString = "#{data}"

        # remove carriage return
        dataString = dataString.replace(/[\r]/g, '');

        # line feed ?
        if dataString.indexOf('\n') != -1
          parts = dataString.split '\n'
          @cmdString = @cmdString + parts[0]
          @receiveCommandHandler @cmdString
          if ( parts.length > 0 )
            @cmdString = parts[1]
          else
            @cmdString = ''
        else
          @cmdString = @cmdString + dataString

    sendCommand: (id, cmdString) ->
      env.logger.debug "COCTransport: #{id} sendCommand #{cmdString}"
      @serial.write(cmdString+'\n')

  # COCSwitch is a generic switch which works with on/off command strings
  class COCSwitch extends env.devices.PowerSwitch

    constructor: (@config) ->
      @id = @config.id
      @name = @config.name
      @commandOn = @config.commandOn
      @commandOff= @config.commandOff
      super()

    destroy: ->
      cocPlugin.removeCmdReceiver this
      super()

    changeStateTo: (state) ->
      if @_state is state then return Promise.resolve true
      else return Promise.try( =>
        if state is on then cocPlugin.sendCommand @id, @commandOn else cocPlugin.sendCommand @id, @commandOff
        @_setState state
      )

    handleReceivedCmd: (command) ->
      if ( command == @commandOn )
        @changeStateTo on
        return true
      else if ( command == @commandOff )
        @changeStateTo off
        return true
      return false


  # COCSwitchFS20 controls FS20 devices
  class COCSwitchFS20 extends env.devices.PowerSwitch

    constructor: (@config) ->
      @id = @config.id
      @name = @config.name
      @houseid = @config.houseid
      @deviceid = @config.deviceid
      super()

    destroy: ->
      cocPlugin.removeCmdReceiver this
      super()

    changeStateTo: (state) ->
      if @_state is state then return Promise.resolve true
      else return Promise.try( =>
        cmd = 'F'+@houseid+@deviceid
        if state is on
            cmd = cmd + @config.commandOn
        else
            cmd = cmd + @config.commandOff
        cocPlugin.sendCommand @id, cmd
        @_setState state
      )

    handleReceivedCmd: (command) ->
      len = command.length;
      return false if len < 9

      cmdid = command.substr(0,1)
      return false if cmdid != "F";

      houseid   = command.substr(1,4);
      deviceid  = command.substr(5,2);
      return false if houseid != @houseid or deviceid != @deviceid

      cmd = command.substr(7, len-7);
      if (cmd == @config.commandOn)
        @changeStateTo on
      else if (cmd == @config.commandOff)
        @changeStateTo off

      return true

  # COCDoorWindowSensorFHT80TF controls FHT80TF devices
  class COCDoorWindowSensorFHT80TF extends env.devices.ContactSensor

    constructor: (@config) ->
      @id = @config.id
      @name = @config.name
      @deviceid = @config.deviceid
      @_contact = true # closed
      super()

    destroy: ->
      cocPlugin.removeCmdReceiver this
      super()

    handleReceivedCmd: (command) ->
      len = command.length;
      return false if len < 9

      cmdid = command.substr(0,1)
      return false if cmdid != "T";

      deviceid  = command.substr(1,6);
      return false if deviceid != @deviceid

      cmd = command.substr(7, len-7);
      # window open
      if (cmd == "01" or cmd == "81")
        @_setContact false
      # window closed
      else if (cmd == "02" or cmd == "82")
        @_setContact true

      return true


  cocPlugin = new COCPlugin()
  return cocPlugin
