package
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class ProcesarTexto
	{

		private static var loader:URLLoader = new URLLoader;
		private static var _request:URLRequest = new URLRequest("http://sistemasrequena.com/apps/hipico/carreras/guardar.php");
		private static var _vars:URLVariables = new URLVariables;
		
		public function ProcesarTexto()
		{
			
		}
		
		public static function parseCarreras(pdfText:String,fecha:String,hipodromo:String,complete:Function) : void
		{
			var _loc4_:Object = null;
			var _loc6_:String = null;
			var _loc7_:* = 0;
			var _loc8_:String = null;
			var _loc2_:Array = [];
			var _loc3_:Array = [];
			var lineas:Array = pdfText.split(File.lineEnding);
			var linea:int = 0; var n:String;
			while(linea < lineas.length)
			{
				_loc6_ = lineas[linea];
				if(_loc6_.indexOf("mts") > -1)
				{
					if(_loc7_ > 0)
					{
						_loc2_.push(_loc3_);
						_loc3_ = [];
					}
					_loc7_++;
				}
				if(_loc6_.split(" ")[0] == "PP") {
					n = lineas[linea + 3];
					n = n.split("'").join("");
					_loc4_ = {
						"Numero":lineas[linea + 1],
						"Nombre":n
					};
					_loc3_.push(_loc4_);
				}
				linea++;
			}
			_loc2_.push(_loc3_);
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			_request.method = URLRequestMethod.POST;
			_vars.hipodromo = hipodromo;
			_vars.fecha = fecha;
			_vars.ejemplares = JSON.stringify(_loc2_).split(File.lineEnding).join("");
			_request.data = _vars;
			loader.addEventListener(Event.COMPLETE,complete,false,0,true);
			
			loader.load(_request);
		}
	}
}