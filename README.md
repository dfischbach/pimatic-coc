pimatic-coc
==============

This is a pimatic plugin which allows you to connect a [busware COC module](http://busware.de/tiki-index.php?page=COC) or a [busware CUL](http://busware.de/tiki-index.php?page=CUL) to the [pimatic home automation framework](http://pimatic.org).

##Installation

###Add the plugin
To enable the COC plugin add this section to your config.json file.

```
...
{
  "plugin": "coc"
}
...
```

To use a CUL device connected to an USB port instead of an internally connected COC module, you need to set the hardware type and the serial device name.

```
...
{
  "plugin": "coc",
  "hardwareType": "CUL",
  "serialDeviceName": "/dev/tty_your_name_here"
}
...
```
Use 
```
dmesg | grep tty
```
to find the serial device name of the CUL.
  
###Add devices 

The COC plugin currently defines two types of devices.

* The COCSwitch device supports the COC generic commands for on and off. You can use it for all supported protocols.  
* The COCSwitchFS20 device is a specialized version which controls FS20 devices. It creates the needed on/off commands internally.

This is an example for the devices section in the config.json file.

```
...
  "devices": [
    {
      "class": "COCSwitch",
      "id": "socket2",
      "name": "Socket 2",
      "commandOn": "F1234A811",
      "commandOff": "F1234A810"
    },
    {
      "class": "COCSwitchFS20",
      "id": "socketF1",
      "name": "Socket FS20",
      "houseid": "1234",
      "deviceid": "A8"
    }
  ],

```

