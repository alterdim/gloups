package assets;

import dn.heaps.assets.Aseprite;

/**
	Access to slice names present in Aseprite files (eg. `trace( tiles.fxStar )` ).
	This class only provides access to *names* (ie. String). To get actual h2d.Tile, use Assets class.

	Examples:
	```haxe
	Assets.tiles.getTile( AssetsDictionaries.tiles.mySlice );
	Assets.tiles.getTile( D.tiles.mySlice ); // uses "D" alias defined in "import.hx" file
	```
**/
class AssetsDictionaries {
	public static var tiles = dn.heaps.assets.Aseprite.getDict( hxd.Res.atlas.tiles );
	public static var player = Aseprite.getDict(hxd.Res.atlas.player);
	public static var entities = Aseprite.getDict(hxd.Res.atlas.entities);
}