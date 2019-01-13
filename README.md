# Closest First

Automatically adjusts personal roboport range to send construction bots from the player's inventory to the nearest ghosts instead of a kind of random ghost in range.

Works by scanning the surrounding area looking for constructible entities and finding the closest that satisfies the number of available bots. For performance, scanning and range calculations are done in separate ticks, and for only one player at a time in multiplayer. (I have never played multiplayer, so I don't know if it works. If you do, let me know how it goes)

The performance sensitive settings are for admins only so that a mischievous player cannot set it them to more than the server can handle.

If there are performance problems, you can use the manual Adjustable-Personal-Roboport-Range mod.

Idea and implementation tricks from ProfoundDisputes' brilliant Adjustable-Personal-Roboport-Range roboport swapping and Folk's Stop That, Silly Robot!.

## Map Settings (admin/single-player only)

### Search area

How big area to scan. If there are no constructible entities within this range, the range is set to the Max Roboport Area setting. A bigger area is more CPU intensive. If you notice any lag, turn down this until you can't notice it, or set range manually with the Adjustable-Personal-Roboport-Range mod.

 - 20x20
 - 30x30 (Roboport Mk1)
 - 40x40 (Roboport Mk2)
 - 50x50
 - 60x60 (4x Roboport Mk1)
 - 70x70
 - 80x80 (4x Roboport Mk2)
 - 90x90
 - 100x100 (6x Roboport Mk2)
 - 120×120 (9x Roboport Mk2)
 - No limit (up to equipped Roboport range)

### Update rate

 - Off - stay at current range (if it is reduced, it will go back to normal when you remove the roboports from your equipment)
 - Slow - update every two seconds
 - Normal - update up to once per second
 - Fast - update up to 2 times per second
 - Faster - update up to 6 times per second
 - Fastest - update up to 30 times per second

Note: If you notice lag, I recommend turning down the search range until you can't notice it anymore, or use the Adjustable-Personal-Roboport-Range mod. 

## Player Settings

### Max roboport area

Limit roboports to this range, useful to avoid construction bots spending lots of energy and time flying very far away when having many roboports. This setting has no CPU impact.

# Performance

To give an idea, these are the UPS ranges I get on each setting on my little test map with 5 Roboport Mk2's, ie. range 89x89, and 100x game speed.  Baseline idling, no construction bots, updates off: 5000 UPS. 

 - Updates off: 4500 idling, 900-2000 UPS building (vanilla style)
 - Slow: 3500 idling, 400-900 UPS building
 - Normal: 3100 UPS idling, 400-700 UPS building
 - Fast: 2600 UPS idling, 250-500 UPS building
 - Faster: 1500 UPS idling, 100-300 UPS building
 - Fastest: 600 UPS idling, 30-70 UPS building

# License

The Unlicense (Public Domain), do whatever you want with this.
