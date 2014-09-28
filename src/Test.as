package
{
	import feathers.controls.NumericStepper;
	import feathers.themes.MetalWorksMobileTheme;
	
	import flash.events.Event;
	
	import starling.display.Sprite;
	
	public class Test extends Sprite
	{
		public function Test()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded():void
		{
			new MetalWorksMobileTheme;
			
			var ns:NumericStepper = new NumericStepper;
			ns.minimum = 0;
			ns.maximum = 1000;
			ns.value = 100;
			ns.width = 100;
			ns.addEventListener(Event.CHANGE,function ():void {
				trace(ns.value);
			});
			addChild(ns);
		}
	}
}