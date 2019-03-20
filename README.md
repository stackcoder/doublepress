doublepress
===========

Turns your power button into a multifunctional shortcut without additional hardware just using push sequences. Some devices especially headless servers are running without attached keyboards. Before any command can be executed you need plug in your keyboard, (hopefully) logon on the current box and do your work. This might be annoying for some non-destructive repeating tasks.

By adapting this simple script you can:
- Prevend accidental shutdowns
- Switch between standby and poweroff
- Trigger a backup
- Start bluetooth paring of your jukebox
- Set a monitoring signal
- Whatever you specify...

## How it works

The usual shutdown action is replaced with doublepress. On button press a new instance of the script is launched and waits a few seconds for further power button activity.

## Installation

```bash
sudo curl -L "https://raw.githubusercontent.com/stackcoder/doublepress/master/doublepress.sh" -o /usr/local/sbin/doublepress.sh
sudo chmod +x /usr/local/sbin/doublepress.sh
```

## Cofigure custom power button action

Tell systemd to ignore powerbutton actions

```bash
sed -i s/".*HandlePowerKey.*"/"HandlePowerKey=ignore"/ /etc/systemd/logind.conf
systemctl restart systemd-logind
```

Show power button actions using `acpi_listen`. May there some filtering on duplicated required:

```bash
acpi_listen
button/power PBTN 00000080 00000000
button/power LNXPWRBN:00 00000080 00000001
```

Configure acpid event and script

```bash
# /etc/acpi/events/powerbtn
event=button[ /]power
action=/etc/acpi/powerbtn.sh "%e"

# cat /etc/acpi/powerbtn.sh
if [ "$1" !=  "button/power PBTN 00000080 00000000" ]; then
  exit 0
fi

logger "Powerbutton pressed"
/usr/local/sbin/doublepress.sh &
```

Enable & restart acpid

```bash
systemctl enable acpid
systemctl restart acpid
```
