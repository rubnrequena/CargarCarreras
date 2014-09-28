package
{
	import flash.display.Sprite;
	
	import starling.core.Starling;
	
	[SWF(frameRate="30",height="400",width="600")]
	public class Carreras extends Sprite
	{
		private var _starling:Starling;
		public function Carreras() {
			_starling = new Starling(Main,stage);
			_starling.start();
		} 
				
	}
}