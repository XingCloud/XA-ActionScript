package com.xingcloud.xa
{
	import com.xingcloud.xa.suport.Json;
	import com.xingcloud.xa.suport.XAEvent;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.setInterval;

	/**
	 * XA是Xingcloud Analytics的缩写，XA类是行云统计系统接口类。通过静态实例的 trackEvent 方法来获取平台服务。</br>
	 * 如发送用户登陆事件 <code>trackEvent("user.login", {step_name:"level_1", time:10});</code>
	 * @see #trackEvent()
	 * @author XingCloudly
	 */
	public class XA
	{
		private static var _instance:XA = null ;
		private const XA_VERSION:String = "2.0.0.120216";
		private const ENGINE_INTERVAL:Number = 500 ;
		private const TRACK_INTERVAL:Number = 5000 ;
		private const HEART_BEAT_INTERVAL:Number = 5 * 60 * 1000 ;
		private var _trackTimeCache:Number = 0 ;
		private var _heartBeatTimeCache:Number = 0 ;

		private var _uid:String;
		private var _appid:String;
		private var _xaLoader:URLLoader;
		private var _xaRequest:URLRequest;		
		private var _stockEvents:Array = [] ;
		private var _readyEvents:Array = [] ;
		
		private var _uidSet:Boolean = false;
		private var _processing:Boolean = false ;
		private var _userVisitEventTracked:Boolean = false ;
		
		/**
		 * 是否开启debug模式，默认为true，会自动输出XA的所有trace信息。
		 */
		public var debug:Boolean = true ;
		
		/**
		 * 是否等待设置用户ID后，再自动发送应用访问和心跳事件，默认为true。
		 */
		public var waitForUid:Boolean = true;
		
		/**
		 * 是否自动发用户心跳事件，默认为true。
		 */
		public var autoHeartBeat:Boolean = true;
		
		/**
		 * 用户来源，默认为""。
		 */
		public var refrence:String = "" ;
		
		// @throws Error 在生成asdoc后会抢注释正文内容，故删除
		/**
		 * 用户ID，用以确保事件的唯一性。【重要】如果不设置，将生成唯一随机ID；如果设置，其值不能设置为空。
		 */
		public function get uid():String
		{
			return _uid ;
		}
		public function set uid(uid:String):void
		{
			if(uid == null || uid.length == 0) 
			{
				addDebugInfo("uid set failed for uid is empty");
				return;
			}
			
			_uid = uid ;
			_uidSet = true ;
			checkUserVisitEvent() ;
			addDebugInfo("uid set: " + _uid);
		}
		
		private function checkUserVisitEvent():void
		{
			if(!_userVisitEventTracked)
			{			
				trackEvent("user.visit", {ref:refrence});
				_userVisitEventTracked = true ;
			}
		}
		
		private function get _currentTime():Number
		{
			return new Date().time ;
		}
		
		/**
		 * XA实例，可以通过该静态实例的trackEvent方法，记录应用中的各种事件。
		 * @see #trackEvent() 
		 */
		public static function get instance():XA
		{
			if(_instance == null)
				_instance = new XA(new Enforcer()) ;
			
			return _instance ;
		}
		
		/**
		 * 单例模式，无需显式调用。
		 * 直接通过 <code>XA.instance.trackEvent(eventName, params)</code> 来记录应用中的各种事件。 
		 * @throws Error XA: Please access by XA.instance!
		 * @see #trackEvent() 
		 */
		public function XA(enforcer:Enforcer)
		{
			trace("XA: version " + XA_VERSION) ;
			if(enforcer == null)
				throw new Error("XA: Please access by XA.instance!") ;
		}
		
		
		/**
		 * 初始化。启动行云统计分析模块。
		 * @param appid - String 应用的ID
		 * @param uid - String 用户ID，可以延后设置
		 * @throws Error XA: init failed for appid is null
		 * @throws Error XA: init can only exe one time
		 */
		public function init(appid:String, uid:String = null):void
		{
			if(appid == null || appid.length == 0) 
				throw new Error("XA: init failed for appid is null") ;
			
			if(_appid && _appid.length > 0)
				throw new Error("XA: init can only exe one time") ;
			
			_xaRequest = new URLRequest("http://analytic.xingcloud.com/index.php") ;
			_xaLoader = new URLLoader() ;
			_xaLoader.addEventListener(Event.COMPLETE, onComplete) ;
			_xaLoader.addEventListener(IOErrorEvent.IO_ERROR, onError) ;
			_xaLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError) ;
			
			_appid = appid ;
			if(uid && uid.length > 0)
				this.uid = uid ;
			
			if(!_uidSet)//防止已设置被冲掉
				_uid = getCookieUid() ;
				
			if(!waitForUid)
				checkUserVisitEvent() ;
			
			trace("XA:", "debug : ", debug) ;
			trackEvent("xa.init");
			
			processStockEvent();
			setInterval(engineTick, ENGINE_INTERVAL) ;
		}
		
		private function engineTick():void
		{
			var now:Number = _currentTime ;
			//trace(now, _stockEvents.length, "waitForUid:" +waitForUid, "uidSet:"+_uidSet) ;
			if(autoHeartBeat && (_uidSet || !waitForUid) && now - _heartBeatTimeCache > HEART_BEAT_INTERVAL)
			{
				trackEvent(XAEvent.USER_HEART_BEAT);
				addDebugInfo("auto track event: " + XAEvent.USER_HEART_BEAT);
				_heartBeatTimeCache = now;
			}
			
			if(_stockEvents.length > 0 && now - _trackTimeCache > TRACK_INTERVAL)
			{
				processStockEvent() ;
				addDebugInfo("auto track stock events") ;
				_trackTimeCache = now ;
			}
		}		
		
		/**
		 * 通过<code> XA.instance.trackEvent() </code>记录应用中的各种事件。
		 * 这些事件会在XA服务器中记录并统计分析，以各种图表呈现出来。示例如：
		 * <ul>
		 * <li>用户增量 <code>trackEvent("user.increment", {});</code></li>TODO
		 * <li>用户升级 <code>trackEvent("user.update", {});</code></li>TODO
		 * <li>用户登陆 <code>trackEvent("user.login", {step_name:"level_1", time:10});</code></li>
		 * <li>用户退出 <code>trackEvent("user.quit", {duration_time:10});</code></li>
		 * <li>用户出错 <code>trackEvent("user.error", {code:"400", message:"xx"});</code></li>
		 * <li>购买物品 <code>trackEvent("buy.item", {resource:"", pay_type:"income", amount:0.99, number:1});</code></li>
		 * <li>支付流程 <code>trackEvent("pay.complete", {gross:0.99, gcurrency:0.99, channel:"card", trans_id:"001"});</code></li>
		 * <li>任务引导 <code>trackEvent("tutorial", {index:0, tid:0, name:"level_1"});</code></li>
		 * <li>里程碑 <code>trackEvent("milestone", {name:"mName"});</code></li>
		 * <li>计数 <code>trackEvent("count", {});</code></li>
		 * <li>详情及更新  http://doc.xingcloud.com/pages/viewpage.action?pageId=4195455 </li>
		 * </ul>
		 * @param eventName - String 事件名称
		 * @param params - Object 事件所相关的参数
		 * @throws Error eventName can not be null or ""
		 * @see http://doc.xingcloud.com/pages/viewpage.action?pageId=4195455 行云XA在线文档
		 */
		public function trackEvent(eventName:String, params:Object=null):void
		{
			if (eventName == null || eventName.length < 1)
				throw new Error("XA: eventName can not be null or \"\"") ;
			
			addDebugInfo('trackEvent "' + eventName + '" and params-> ' + analyseObjectToString(params) ) ;
			if (params == null) 
				params = {} ;
			
			_stockEvents.push( {eventName:eventName, params:params, timestamp:_currentTime} ) ;
			if(_stockEvents.length >= 5)
				processStockEvent() ;
		}
		
		private function processStockEvent():void
		{
			if(_processing || _appid == null || _appid.length == 0)
				return ;
			
			_processing = true ;
			_readyEvents = _stockEvents ;
			_stockEvents = [] ;
			
			_xaRequest.data = getRequestVariables();
			_xaRequest.method = URLRequestMethod.POST ;
			_xaLoader.load(_xaRequest) ;
		}
		
		private function getRequestVariables():URLVariables
		{
			var jsonObject:Object = {
					signedParams : {appid:_appid, uid:_uid, timestamp:_currentTime},
					stats : _readyEvents
			}
			var variables:URLVariables = new URLVariables();
			variables.json = Json.encode(jsonObject) ;
			addDebugInfo("events to json: " + variables.json) ;
			
			return variables ;
		}
		
		private  function getCookieUid():String
		{
			var sharedObject:SharedObject = SharedObject.getLocal("xingcloud-xa") ;
			var uidKey:String = "xas_" + _appid + "_uid" ;
			var cookieUid:String = sharedObject.data[uidKey] ;
			
			if(cookieUid == null || cookieUid.length == 0)
			{
				cookieUid = Math.round(Math.random()*int.MAX_VALUE) + "_" + Math.round(Math.random()*int.MAX_VALUE);	
				sharedObject.data[uidKey] = cookieUid ;
				sharedObject.flush() ;
			}
			
			return cookieUid;
		}
		
		private function onError(event:ErrorEvent):void
		{
			_processing = false ;
			_stockEvents = _readyEvents.concat(_stockEvents) ;
			addDebugInfo("track event for error: " + event.toString()) ;
		}
		
		private function onComplete(event:Event):void
		{
			_processing = false ;
			addDebugInfo("track event complete") ;
		}
		
		/**
		 * like this: title-> | obj:object=[object Object] | ary:object=1,2,3 | id:string=uid | bool:boolean=true | count:number=1
		 * @return String format string
		 */
		private function analyseObjectToString(params:Object):String
		{
			var buf:Array = [] ;
			for (var key:String in params) 
			{
				var type:String = typeof(params[key]) ;
				if (type == "object")
					buf.push(key + ":" + type + "=" + analyseObjectToString(params[key])) ;
				else
					buf.push(key + ":" + type + "=" + params[key]) ;
			}
			return "{" + buf.join(" | ") + "}" ;
		}
		
		private function addDebugInfo(info:String):void
		{
			if(debug)
				trace("XA:", info) ;
			// call JSProxy.addDebugInfo(info) ;
		}
	}
}

class Enforcer{ }