pimatic-coc
==============

This is a pimatic plugin which allows you to connect a [busware COC module](http://busware.de/tiki-index.php?page=COC) to the [pimatic home automation framework](http://pimatic.org).

##Installation
To enable the COC plugin add this section to your config.json file.

```
...
{
  "plugin": "coc"
}
...
```

The COCSwitch device supports the COC generic commands for on and off. You can use it for all supported protocols.  
The COCSwitchFS20 device is a specialized version which controls FS20 devices. It creates the needs on/off command internally.

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

If you are owner of a [busware CUL](http://busware.de/tiki-index.php?page=CUL) and want to get it running with pimatic, please contact me. This plugin should work with the CUL with minimal changes, but I have no device for testing.
