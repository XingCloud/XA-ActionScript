package com.xingcloud.xa.suport
{

	/**
	 * 行云XA Event列表，详见：www.xingcloud.com 
	 */
	public class XAEvent
	{
		/**
		 * 
		 */
		public static const BUY_ITEM:String = "buy.item" ;
		
		/**
		 * 
		 */
		public static const BUY_ITEM_RESOURCE:String = "resource" ;
		
		/**
		 * 
		 */
		public static const BUY_ITEM_PAY_TYPE:String = "pay_type" ;
		
		/**
		 * 
		 */
		public static const BUY_ITEM_AMOUNT:String = "amount" ;
		
		/**
		 * 
		 */
		public static const BUY_ITEM_COUNT:String = "count" ;
		
		/**
		 * 
		 */
		public static const MILESTONE:String = "milestone" ;
		
		/**
		 * 
		 */
		public static const MILESTONE_NAME:String = "name" ;

		/**
		 * 记录用户付费情况。
		 */
		public static const PAY_COMPLETE:String = "pay.complete" ;
		
		/**
		 * 游戏币数量。
		 */
		public static const PAY_COMPLETE_VAMOUNT:String = "pay.complete" ;
		
		/**
		 * 游戏币单位。
		 */
		public static const PAY_COMPLETE_VCURRENTCY:String = "pay.complete" ;
		
		/**
		 * 支付金额，必填参数。
		 */
		public static const PAY_COMPLETE_GROSS:String = "gross" ;
		
		/**
		 * 目前系统支持普通的国际货币，货币必须大写: 如：EUR、USD。必填参数。</br>
		 * 如果平台使用货币过于特殊，例如津巴布韦元，请转换成USD或EUR等国际通用货币。
		 * 具体支持的货币种类参见行云在线文档 http://hk.usd.exchangerates24.com/convert/
		 * @see http://hk.usd.exchangerates24.com/convert/ 具体支持的货币种类参见行云在线文档
		 */
		public static const PAY_COMPLETE_GCURRENCY:String = "gcurrency" ;
		
		/**
		 * 第三方支付渠道的名称，如：paypal、google、checkout
		 */
		public static const PAY_COMPLETE_CHANNEL:String = "channel" ;
		
		/**
		 * 交易号
		 */
		public static const PAY_COMPLETE_TRANS_ID:String = "trans_id" ; 
		
		/**
		 * 本方法是记录新手引导步骤中，每步完成的数量，从而查看新手引导过程中的用户流失率。
		 */
		public static const TUTORIAL:String = "tutorial" ;
		
		/**
		 * 第几步。
		 */
		public static const TUTORIAL_INDEX:String = "index" ;
		
		/**
		 * 
		 */
		public static const TUTORIAL_ID:String = "tid" ;
		
		/**
		 * 步骤名称。
		 */
		public static const TUTORIAL_STEP_NAME:String = "step_name" ;
		
		/**
		 * 
		 */
		public static const USER_HEART_BEAT:String = "user.heartbeat" ;
		
		/**
		 * 用于更新这个用户在系统上的对于统计项有影响的信息。
		 */
		public static const USER_UPDATE:String = "user.update" ;
		
		/**
		 * 用于对用户属性的值做累加计算。如访问好友次数。
		 */
		public static const USER_INCRMENT:String = "user.increment" ;
		
		/**
		 * 记录游戏出错的信息。
		 */
		public static const USER_ERROR:String = "user.error" ;
		
		/**
		 * 错误的详细信息。
		 */
		public static const USER_ERROR_MESSAGE:String = "message" ;
		
		/**
		 * 错误代码。
		 */
		public static const USER_ERROR_CODE:String = "code" ;
		
		/**
		 * 记录用户加载游戏的时间。
		 */
		public static const USER_LOGIN:String = "user.login" ;
		
		/**
		 * 代表加载的步骤。0表示开始加载，无需配置time。
		 */
		public static const USER_LOGIN_INDEX:String = "index" ;
		
		/**
		 * 代表上一步到这一步的耗时，以毫秒为单位。
		 */
		public static const USER_LOGIN_TIME:String = "time" ;
		
		/**
		 * 用户退出事件，用以记录用户使用应用的在线时长。
		 */
		public static const USER_QUIT:String = "user.quit" ;
		
		/**
		 * 用户使用时长。
		 */
		public static const USER_QUIT_DURATION_TIME:String = "duration_time" ;
		
		
		public static const ALL_EVENTS:Array = [
				BUY_ITEM,
				MILESTONE,
				PAY_COMPLETE,
				TUTORIAL,
				USER_ERROR,
				USER_HEART_BEAT,
				USER_INCRMENT,
				USER_LOGIN,
				USER_QUIT,
				USER_UPDATE
		] ;
		
	}
}