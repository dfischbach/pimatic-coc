
module.exports = (env) ->

  convict = env.require "convict"

  # Require the [Q](https://github.com/kriskowal/q) promise library
  Q = env.require 'q'

  # Require the [cassert library](https://github.com/rhoot/cassert).
  assert = env.require 'cassert'

  # Require the [SerialPort] (https://github.com/voodootikigod/node-serialport)
  {SerialPort} = require 'serialport'

  _ = env.require 'lodash'

  exec = Q.denodeify(require("child_process").exec)


  # the plugin class
  class COCPlugin extends env.plugins.Plugin

    @transport

    init: (app, @framework, config) ->
      @conf = convict _.cloneDeep(require("./coc-plugin-config-schema"))

      @conf.load config
      @conf.validate()

      exec("sh ./node_modules/pimatic-coc/cocinit.sh").then( (streams) =>
        stdout = streams[0]
        stderr = streams[1]
        env.logger.info stdout
        env.logger.error stderr if stderr.length isnt 0
      )

      serialName = @conf.get "serialDeviceName"
      env.logger.info "coc: init with serial device name #{serialName}"

      @cmdReceivers = [];

      @transport = new COCTransport serialName, @receiveCommandCallback


    createDevice: (deviceConfig) ->
      env.logger.info "coc: createDevice #{deviceConfig.id}"
      return switch deviceConfig.class
      when 'COCSwitch'
        @framework.registerDevice(new COCSwitch deviceConfig)
        true
      when 'COCSwitchFS20'
        @framework.registerDevice(new COCSwitchFS20 deviceConfig)
        true
        when 'COCSensorValue'
          value = new COCSensorValue deviceConfig, @isDemo
          @cmdReceivers.push value
          @framework.registerDevice(value)
          true
        else
          false

    sendCommand: (id, cmdString) ->
        @transport.sendCommand id, cmdString

    receiveCommandCallback: (cmdString) =>
      for cmdReceiver in @cmdReceivers
        handled = cmdReceiver.handleReceivedCmd cmdString
        break if handled

      if (!handled)
        env.logger.info "received unhandled command string: #{cmdString}"


  # COCTransport handles the communication with the coc module
  class COCTransport

    @serial

    constructor: (serialPortName, @receiveCommandHandler) ->

      @cmdString = ""
      @serial = new SerialPort serialPortName, baudrate: 38400, false

      @serial.open (err) ->
        if ( err? )
          env.logger.info "open serialPort #{serialPortName} failed #{err}"
        else
          env.logger.info "open serialPort #{serialPortName}"


      @serial.on 'open', ->
         @.write('echo\n');

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

  constructor: (deviceconfig) ->
    @conf = convict _.cloneDeep(require("./coc-device-config-schema").COCSwitch)
    @conf.load deviceconfig
    @conf.validate()

    @id = @conf.get "id"
    @name = @conf.get "name"
    @commandOn = @conf.get "commandOn"
    @commandOff= @conf.get "commandOff"

    super()


  changeStateTo: (state) ->
    if @_state is state then return Q true
    else return Q.fcall =>
      if state is on then cocPlugin.sendCommand @commandOn else cocPlugin.sendCommand @commandOff
      @_setState state


  # COCSwitchFS20 controls FS20 devices
  class COCSwitchFS20 extends env.devices.PowerSwitch

    constructor: (deviceconfig) ->
      @conf = convict _.cloneDeep(require("./coc-device-config-schema").COCSwitchFS20)
      @conf.load deviceconfig
      @conf.validate()

      @id = @conf.get "id"
      @name = @conf.get "name"
      @houseid = @conf.get "houseid"
      @deviceid = @conf.get "deviceid"

      super()


    changeStateTo: (state) ->
      if @_state is state then return Q true
      else return Q.fcall =>
      #cmd = 'F '+@houseid+@deviceid
        cmd = 'F'+@houseid+@deviceid
        cocPlugin.sendCommand @id, (if state is on then cmd+'11' else cmd+'00')
        @_setState state




  cocPlugin = new COCPlugin
  return cocPlugin
