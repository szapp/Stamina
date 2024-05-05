# Stamina

[![Scripts](https://github.com/szapp/Stamina/actions/workflows/scripts.yml/badge.svg)](https://github.com/szapp/Stamina/actions/workflows/scripts.yml)
[![Validation](https://github.com/szapp/Stamina/actions/workflows/validation.yml/badge.svg)](https://github.com/szapp/Stamina/actions/workflows/validation.yml)
[![Build](https://github.com/szapp/Stamina/actions/workflows/build.yml/badge.svg)](https://github.com/szapp/Stamina/actions/workflows/build.yml)
[![GitHub release](https://img.shields.io/github/v/release/szapp/Stamina.svg)](https://github.com/szapp/Stamina/releases/latest)

Extend the native dive bar to a wider range of stamina decreasing actions like fighting and sprinting.

This is a modular modification (a.k.a. patch or add-on) that can be installed and uninstalled at any time and is virtually compatible with any modification.
It supports <kbd>Gothic 1</kbd>, <kbd>Gothic Sequel</kbd>, <kbd>Gothic II (Classic)</kbd> and <kbd>Gothic II: NotR</kbd>.

###### Generated from [szapp/patch-template](https://github.com/szapp/patch-template).

![Screenshot](https://github.com/szapp/Stamina/assets/20203034/8c8d7037-0e28-49d8-86fa-ce57faa2bdbe)

## About

This patch introduces a simple, but highly-configurable stamina (endurance) system.
Sprinting, as well as, various actions in melee combat decrease the available breath, that is already familiar from diving (yellow oxygen bar).

Adjustable actions are

- Sprinting
- Fist and one-handed and two-handed weapon first hits
- Fist and one-handed and two-handed weapon combos
- Fist and one-handed and two-handed weapon blocks

The duration of sprinting and percentage-wise costs of weapon swings, combos and parades for fist, one-handed and two-handed combat are adjustable in the Gothic.ini, or may be disabled entirely.
This is especially useful, since some mods already implement a sprint system.
Additionally these adjustments allow for full freedom in personal interpretation and preference when it comes to endurance/stamina system in video games.

This patch can make the combat more challenging.
It offers no "advantages".

## Additional key bindings

<table>
  <tbody>
    <tr>
      <td><kbd>V</kbd>, <kbd>.</kbd> (dot)</td>
      <td>Hold to sprint (adjustable in the game menu or disabled in the Gothic.ini)</td>
    </tr>
  </tbody>
</table>

## INI settings

In your Gothic installation you find a file called Gothic.ini.
Adjustments are available in the Gothic.ini in the section `[STAMINA]`.
After first launch, this section created.
The costs for individual swings, combo hits and parades may be adjusted in percentages.
This is also the case of the total duration of sprinting in seconds.
Individual aspects can be disabled with a value of zero (0).
That means, if the sprinting duration is set to 0, this feature is not even initialized.
The same goes for the other aspects.

### Default configuration

These are the default settings.
These values correspond to 15 seconds of sprint, the first hit of a one-handed weapon cost 18% stamina, every following swing in a combo cost 10% and a parade 8%, and so on.
A modified sprint animation is supplied.

```ini
[STAMINA]
sprintTotalSec=15
supplySprintAni=1
fistFirstHitCost=10
fistComboCost=7
fistParadeCost=4
1hFirstHitCost=18
1hComboCost=10
1hParadeCost=8
2hFirstHitCost=25
2hComboCost=15
2hParadeCost=10
```

### Example configurations

> [!Tip]
> You can play around with the values to find your personal preference!

<details><summary>Disable stamina for all combat actions (click to expand)</summary>
<p>
    
```ini
[STAMINA]
sprintTotalSec=15
supplySprintAni=1
fistFirstHitCost=0
fistComboCost=0
fistParadeCost=0
1hFirstHitCost=0
1hComboCost=0
1hParadeCost=0
2hFirstHitCost=0
2hComboCost=0
2hParadeCost=0
```

</p></details>

<details><summary>Disable sprinting (e.g. if another mod already supplies it) and to disable stamina cost for weapon blocking (click to expand)</summary>
<p>
    
```ini
[STAMINA]
sprintTotalSec=0
supplySprintAni=1
fistFirstHitCost=10
fistComboCost=7
fistParadeCost=0
1hFirstHitCost=18
1hComboCost=10
1hParadeCost=0
2hFirstHitCost=25
2hComboCost=15
2hParadeCost=0
```

</p>
</details>

## Notes

- The patch is based on a simple endurance system that was introduced here: https://forum.worldofplayers.de/forum/thread/1558616
- For more information, visit https://forum.worldofplayers.de/forum/threads/1558617

## Installation

1. Download the latest release of `Stamina.vdf` from the [releases page](https://github.com/szapp/Stamina/releases/latest).

2. Copy the file `Stamina.vdf` to `[Gothic]\Data\`. To uninstall, remove the file again.

The patch is also available on
- [World of Gothic](https://www.worldofgothic.de/dl/download_639.htm) | [Forum thread](https://forum.worldofplayers.de/forum/threads/1558617)
- [Spine Mod-Manager](https://clockwork-origins.com/spine/)
- [Steam Workshop Gothic 1](https://steamcommunity.com/sharedfiles/filedetails/?id=2788242828)
- [Steam Workshop Gothic 2](https://steamcommunity.com/sharedfiles/filedetails/?id=2788242942)

### Requirements

<table><thead><tr><th>Gothic</th><th>Gothic Sequel</th><th>Gothic II (Classic)</th><th>Gothic II: NotR</th></tr></thead>
<tbody><tr><td><a href="https://www.worldofgothic.de/dl/download_6.htm">Version 1.08k_mod</a></td><td>Version 1.12f</td><td><a href="https://www.worldofgothic.de/dl/download_278.htm">Report version 1.30.0.0</a></td><td><a href="https://www.worldofgothic.de/dl/download_278.htm">Report version 2.6.0.0</a></td></tr></tbody>
<tbody><tr><td colspan="4" align="center"><a href="https://github.com/szapp/Ninja">Ninja 2</a> (or higher)</td></tr></tbody></table>

<!--

If you are interested in writing your own patch, please do not copy this patch!
Instead refer to the PATCH TEMPLATE to build a foundation that is customized to your needs!
The patch template can found at https://github.com/szapp/patch-template.

-->
