echo "resetting coc..."
if test ! -d /sys/class/gpio/gpio17; then echo 17 > /sys/class/gpio/export; fi
if test ! -d /sys/class/gpio/gpio18; then echo 18 > /sys/class/gpio/export; fi
echo out > /sys/class/gpio/gpio17/direction
echo out > /sys/class/gpio/gpio18/direction
echo 1 > /sys/class/gpio/gpio18/value
echo 0 > /sys/class/gpio/gpio17/value
sleep 1
echo 1 > /sys/class/gpio/gpio17/value
sleep 1
