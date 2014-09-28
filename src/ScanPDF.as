package
{
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	import utils.DateUtil;
	
	public class ScanPDF extends EventDispatcher
	{		
		public static const SCANNING:String = "scanning";
		
		public static const hipodromos:Array = ["LR","VL","SR","RA"];
		public static const hipodromos_full:Array = ["RINCONADA","VALENCIA","SANTA RITA","RANCHO ALEGRE"];	
		
		public var url:String;
		public var fecha:Date;
		public var dias:int;
		
		private var _pdfs:Array;
		public function get pdfs():Array { return _pdfs; }
				
		private var urlLoader:URLLoader;
		private var urlRequest:URLRequest;
		private var urlCurrent:int;
		private var urlCurrentName:String;
		
		private var fs:FileStream;
		private var file:File;
		private var bytes:ByteArray;
		
		public function ScanPDF()
		{
			super();
			
			urlLoader = new URLLoader;
			urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			urlRequest = new URLRequest;
			
			urlLoader.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS,responseStatus);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,errorIO);
			
			fs = new FileStream;
		}
		
		protected function onProgress(event:ProgressEvent):void {
			dispatchEventWith(event.type,false,{
				name:_pdfs[urlCurrent],
				loaded:event.bytesLoaded,
				total:event.bytesTotal
			});
		}
		
		protected function errorIO(event:IOErrorEvent):void {
			dispatchEventWith("noexiste",false,_pdfs[urlCurrent]);
		}
		
		protected function responseStatus(event:HTTPStatusEvent):void {
			if (event.status==404) {
				dispatchEventWith("noexiste",false,_pdfs[urlCurrent]);
			} else if (event.status==200) {
				urlLoader.addEventListener(ProgressEvent.PROGRESS,onProgress);
				urlLoader.addEventListener(flash.events.Event.COMPLETE,onComplete);
				dispatchEventWith("existe",false,_pdfs[urlCurrent]);
			}
		}
		protected function onComplete(event:flash.events.Event):void {
			urlLoader.removeEventListener(ProgressEvent.PROGRESS,onProgress);
			urlLoader.removeEventListener(flash.events.Event.COMPLETE,onComplete);
			
			var name:Array = urlCurrentName.split("_");
			var h:int = hipodromos.indexOf((name.pop() as String).split(".").shift());
			var n:String = name.pop();
			name = [n.slice(0,4),n.slice(4,6),n.slice(6,8)];
			
			file = File.applicationStorageDirectory.resolvePath(urlCurrentName);
			fs.open(file,FileMode.WRITE);
			bytes = event.target.data as ByteArray;
			fs.writeBytes(bytes,0,bytes.length);
			fs.close();	
			
			dispatchEventWith(event.type,false,{
				pdf:file,
				hipodromo:hipodromos_full[h],
				fecha:name.join("-")
			});
		}
		
		public function nextUrl():void {
			if (urlCurrent>0) {
				urlRequest.url = _pdfs[--urlCurrent];
				urlCurrentName = (_pdfs[urlCurrent] as String).split("/").pop();
				dispatchEventWith(SCANNING,false,(_pdfs[urlCurrent] as String).split("/").pop());
				urlLoader.load(urlRequest);
			} else {
				dispatchEventWith(starling.events.Event.CLOSE);
			}
		}
		
		
		public function prepare():void {
			var len:int = dias*hipodromos.length;
			_pdfs = new Array(len);
			var i:int=0;
			while (i<len) { 
				for each (var h:String in hipodromos) {
					_pdfs[i++] = url+DateUtil.dateToString(fecha,"YYYY/MM/")+DateUtil.dateToString(fecha,"YYYYMMDD")+"_"+h+".pdf";
				}
				fecha.date++;
			}
			_pdfs.reverse();
			urlCurrent = _pdfs.length;
		}
	}
}