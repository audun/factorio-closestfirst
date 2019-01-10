
# Closest First

A collection of small hacks to get Factorio to send construction bots from the player's inventory to the nearest ghosts instead of random places.

Based on ProfoundDisputes' brilliant Adjustable-Personal-Roboport-Range swapping hack and Folk's Stop that, Silly Robot!

## Settings

### Constructable entity search area

The area that is scanned to find constructable/deconstructable entities. Only distances within this area is calculated, when everything has been built or deconstructed inside this area, use base Factorio method. - A high value will lead to lag.

### Update rate (ticks)

Probably fine to leave at 60+ unless you want to test performance. Set it to 2, if you notice any performance degradation, reduce search range and finally set it back to 60. Set to 0 to disable updates.

### Max roboport area

Limit roboports to this range, useful to avoid construction bots spending energy flying very far away when having many roboports - No performance impact.


