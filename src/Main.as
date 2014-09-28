package
{
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.NumericStepper;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.themes.MetalWorksDesktopTheme;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.getTimer;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Main extends Sprite
	{		
		private var date:Date;
		private var pdfPath:String = "/carreras/retrospectos/pdf/";
		//UI
		private var top:LayoutGroup;
		private var anio:NumericStepper;
		private var mes:NumericStepper;
		private var dia:NumericStepper;
		private var iniciar:Button;
		private var log:List;
		private var url:TextInput;
		private var dias:NumericStepper;

		private var scan:ScanPDF;
		private var logData:ListCollection;
		
		public function Main()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		private function onAdded():void {
			new MetalWorksDesktopTheme;
			
			date = new Date;
			
			top = new LayoutGroup;
			top.layout = new HorizontalLayout;
			top.width = stage.stageWidth;
			addChild(top);
			
			anio = new NumericStepper();
			anio.minimum = 2000;
			anio.maximum = 9999;
			anio.value = date.fullYear;
			anio.width = 100;
			top.addChild(anio);
			
			mes = new NumericStepper();
			mes.minimum = 1;
			mes.maximum = 12;
			mes.value = date.month+1;
			top.addChild(mes);
			
			dia = new NumericStepper();
			dia.minimum = 1;
			dia.maximum = 31;
			dia.value = date.date;
			top.addChild(dia);
			
			dias = new NumericStepper();
			dias.minimum = 1;
			dias.maximum = 7;
			dias.value = 5;
			top.addChild(dias);
			
			iniciar = new Button();
			iniciar.label = "Iniciar";
			iniciar.layoutData = new HorizontalLayoutData(NaN,100);
			iniciar.addEventListener(Event.TRIGGERED,iniciar_click);
			top.addChild(iniciar);
			
			url = new TextInput;
			url.text = "http://142.4.205.207";
			url.layoutData = new HorizontalLayoutData(100,100);
			top.addChild(url);
			
			logData = new ListCollection;
			
			log = new List;
			log.y = 30;
			log.width = stage.stageWidth;
			log.height = stage.stageHeight-log.y;
			log.dataProvider = logData;
			addChild(log);
						
			scan = new ScanPDF;
			scan.addEventListener(ScanPDF.SCANNING,scaningURL);
			scan.addEventListener("noexiste",url_noExiste);
			scan.addEventListener("existe",url_existe);
			scan.addEventListener(ProgressEvent.PROGRESS,descargando);
			scan.addEventListener(Event.COMPLETE,descargaCompleta);
			scan.addEventListener(Event.CLOSE,carrerasCargadas);
		}
		
		private function carrerasCargadas():void {
			logs("No hay mas carreras que cargar");
		}
		
		private var currentPDF:File;
		private var currentHipodromo:String;
		private var currentFecha:String;
		
		private function descargaCompleta(e:Event,data:Object):void {
			logs("Descarga completa...");
			logs("Iniciando pdftotext en ",data.pdf.name);
			var pdfTxt:String = String(data.pdf.name).replace(".pdf",".txt");
			currentHipodromo = data.hipodromo;
			currentFecha = data.fecha;
			
			var npi:NativeProcessStartupInfo = new NativeProcessStartupInfo;
			
			var pdfexe:File = File.applicationDirectory.resolvePath("bin").resolvePath("pdftotext.exe");
			npi.arguments = new <String>[
				(data.pdf as File).nativePath,
				"-raw"
			];
			npi.executable = pdfexe;
			
			currentPDF = File.applicationStorageDirectory.resolvePath(pdfTxt);
			var p:NativeProcess = new NativeProcess;
			p.addEventListener(NativeProcessExitEvent.EXIT,nativeProcess_exit);
			p.start(npi);
		}
		
		protected function nativeProcess_exit(event:NativeProcessExitEvent):void {
			logs("Analizando carreras en",currentPDF.name);
			var text:String;
			var fs:FileStream = new FileStream;
			fs.open(currentPDF,FileMode.READ);
			text = fs.readMultiByte(fs.bytesAvailable,File.systemCharset);
			fs.close();
						
			ProcesarTexto.parseCarreras(text,currentFecha,currentHipodromo,onComplete);
		}
		
		private function onComplete(e:*):void {
			logs("Carrera cargada con exito...");
			scan.nextUrl();
		}
		
		private function descargando(e:Event,data:Object):void {
			logData.getItemAt(0).label = data.name.split("/").pop()+": "+data.loaded+" / "+data.total;
			logData.updateItemAt(0);
		}
		
		private function url_existe(e:Event,data:String):void {
			logs("Carrera encontrada:",data.split("/").pop());
		}
		
		private function url_noExiste(e:Event,data:String):void {
			logs("No existe:",data.split("/").pop());
			scan.nextUrl();
		}
		
		private function scaningURL(e:Event,data:String):void {
			logs("Buscando en:",data);
		}
		
		private function iniciar_click(e:Event):void {
			date = new Date(anio.value,mes.value-1,dia.value);
			
			scan.url = url.text+pdfPath;
			scan.fecha = date;
			scan.dias = dias.value;
			scan.prepare();
			scan.nextUrl();
		}
		private function logs (...string):void {
			logData.addItemAt({
				time:getTimer(),
				label:string.join(" ")
			},0);
		}
	}
}