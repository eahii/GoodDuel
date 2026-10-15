# Good Duel

**Don't forget your manners while dueling!**

A tiny World of Warcraft: Forever addon that says **gl hf** in /say when a duel
starts (the 3-2-1 countdown) and **gd** when the duel ends. Nothing is said on
declined requests.

## Custom messages

Open **Esc → Options → AddOns → Good Duel** (or type `/goodduel`) and edit the duel
start and end messages. Changes save as you type and are shared by all your
characters. Leave a field empty to say nothing at that point; **Reset to defaults**
brings back "gl hf" and "gd".

Line breaks and `|` characters are removed before sending (`|` starts WoW's color and
link codes), and messages are capped at chat's 255-byte limit.

## How it sends /say

Since patch 8.2.5 the game only lets addons send `/say` outdoors from inside a real
keypress or click. Good Duel therefore queues the message and sends it on your very
next keypress or click in the world, which during a duel is effectively instant.
A queued message older than 20 seconds is dropped so nothing is said out of context.

## Install

Easiest: install from [CurseForge](https://www.curseforge.com/wow/addons/good-duel) or an addon manager.

Manual: 
Copy the `GoodDuel` folder to `World of Warcraft\_classic_beta_\Interface\AddOns\`
(or the matching folder for your client) and `/reload`.

## Files

- `GoodDuel/GoodDuel.toc` – addon manifest (`## Interface: 16001` for the Forever beta)
- `GoodDuel/GoodDuel.lua` – the addon
- `GoodDuel/Options.lua` – the Options panel and `/goodduel`
- `assets/logo.png` – CurseForge project logo
- `build.sh` – builds `dist/GoodDuel-<version>.zip` for upload
