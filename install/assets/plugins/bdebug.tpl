//<?php
/**
 * bDebug 
 * 
 * just make MODx evo is easy
 *
 * @category    plugin
 * @version     0.3
 * @author		By Bumkaka from modx.im
 * @internal    @properties 
 * @internal    @events OnWebPageInit,OnWebPagePrerender,OnPageNotFound
 * @internal	@properties 
 * @internal    @modx_category Manager and Admin
 * @internal    @installset base
 */
if ( !function_exists('bLog') ){
	function bLog($title,$code){
		$code = is_array($code)?'<pre>'.print_r($code,true).'</pre>':$code;
		$_SESSION['bDebug'][] = array('title'=>$title, 'code'=>$code);
	}	
}


if (empty($_SESSION['mgrInternalKey'])) return;

$e = &$modx->event; 
switch ($e->name){
	case 'OnPageNotFound':
	switch($_GET['q']){
		case 'bdebugGetResult':	
		$tstart = $modx->getMicroTime();
		//echo $_SESSION['SQL'][$_GET['sql']].'<br/>';
		if (!$result = @$modx->db->query($_SESSION['SQL'][$_GET['sql']])){//@ mysql_query($_POST['sql'], $modx->db->conn)) {
			echo  mysql_error($modx->db->conn);
		} else {
			$tend = $modx->getMicroTime();
			$totaltime = $tend - $tstart;
			$i=0;
			while($row=$modx->db->GetRow($result) ){
				if ($i==0){
					foreach($row as $key=>$value){
						$head .= '<th>'.$key.'</th>';
					}
					$head = '<tr>'.$head.'</tr>';
					$i=1;
				}
				$ROW='';
				foreach($row as $key=>$value){
					$ROW .= '<td><pre>'.    $text=mb_substr($value,0,30).'</pre></td>';
				}
				
				$body.='<tr '.($i % 2 == 0?'class="even"':'').'>'.$ROW.'</tr>';								
				$i++;
			}
			
			$table = '<div style="width:auto;"><table class="MySql" border=1 cellspacing=0 cellpadding=3>'.$head.$body.'</table></div>';
			echo 'Результат вернул '.$modx->db->getAffectedRows().' строк за '.$totaltime.' сек.<br/>';
			echo $table;
		}
		
		if (!$result = @$modx->db->query('EXPLAIN '.$_SESSION['SQL'][$_GET['sql']])){//@ mysql_query($_POST['sql'], $modx->db->conn)) {
			echo  mysql_error($modx->db->conn);
		} else {
			$tend = $modx->getMicroTime();
			$totaltime = $tend - $tstart;
			$i=0;
			$head ='';
			$body = '';
			while($row=$modx->db->GetRow($result) ){
				if ($i==0){
					foreach($row as $key=>$value){
						$head .= '<th>'.$key.'</th>';
					}
					$head = '<tr>'.$head.'</tr>';
					$i=1;
				}
				$ROW='';
				foreach($row as $key=>$value){
					$ROW .= '<td><pre>'.    $text=mb_substr($value,0,30).'</pre></td>';
				}
				
				$body.='<tr '.($i % 2 == 0?'class="even"':'').'>'.$ROW.'</tr>';								
				$i++;
			}
			
			$table = '<div style="width:auto;"><table class="MySql" border=1 cellspacing=0 cellpadding=3>'.$head.$body.'</table></div>';
			echo 'EXPLAIN Результат вернул '.$modx->db->getAffectedRows().' строк за '.$totaltime.' сек.<br/>';
			echo $table;
		}
		
		
		
		die();
		
		break;
	}
	
	break;
	
	case 'OnWebPageInit':
	
	$modx->dumpSQL = true;
	$_SESSION['bDebug'] = array();
	
	
	break;
	
	
	case 'OnWebPagePrerender':
	$modx->dumpSQL = false;
	$Temp1 = explode('</legend>',$modx->queryCode); 
	
	foreach($Temp1 as $key=>$value){
		$Temp2 = explode('<br',$value);
		if (!empty($Temp2[0])) $SQL[] = trim($Temp2[0]);	
	}
	
	$_SESSION['SQL'] = $SQL;
	
	//$modx->CustomDebug = print_r($SQL,true);
	
	ob_start();
?>



<div id="bDebug">
	<div class="bPopup bDebugPopup"><?=$modx->queryCode;?></div>
	<div class="bPopup bCustomPopup"><?php
	if ( !empty($_SESSION['bDebug'])){
		echo '<fieldset><legend>Logs</legend>';
		foreach($_SESSION['bDebug'] as $log){
			echo '<div class="bCodeBlock"><div class="bTitle">'.$log['title'].'</div><div class="bCode">'.$log['code'].'</div></div>';
		}
		echo '</fieldset>';
	}
	$_SESSION['bDebug'] = array();
	bLog('$_SESSION',$_SESSION);
	bLog('$_COOKIE',$_COOKIE);
	bLog('$_GET',$_GET);
	bLog('$_POST',$_POST);
	bLog('$_SERVER',$_SERVER);
	
	if ( !empty($_SESSION['bDebug'])){
		echo '<fieldset><legend>GLOBALS</legend>';

		foreach($_SESSION['bDebug'] as $log){
			echo '<div class="bCodeBlock" style="background:#ddd"><div class="bTitle">'.$log['title'].'</div><div class="bCode">'.$log['code'].'</div></div>';
		}
		echo '</fieldset>';
	}
		?></div>
	<a class="bButton bCustomPopupA" href=".bCustomPopup">Logs</a>
	<a class="bButton" href=".bDebugPopup" style="margin-right:10px">Query</a>
	Mem : [^m^], MySQL: [^qt^], [^q^] request(s), PHP: [^p^], total: [^t^], document from [^s^]
</div>


<script>
	(function($){
		if ( $('.bCustomPopup').html() == '' ) $('.bCustomPopupA').remove();
		/*
		* Create new formated list
		*/
		SQL = [];
		$('.bDebugPopup>br').remove();
		$('.bDebugPopup fieldset').each(function(){
			index = $(this).index();
			tmp = $(this).clone();
			time = parseFloat( $('legend',tmp).html().split('-')[1].replace(' ','').replace('s','').replace(',','.') ) ;
			time = $('legend',tmp).html().indexOf('ms') < 1? time :time / 1000;
			time = time.toFixed(5)
			$('legend',tmp).remove();
			ind = index+1;
			SQL.push( '<div class="bCodeBlock"><div class="bTitle" time="'+time+'">Query #'+ind+' - '+time+' sec</div><div class="bCode">'+tmp.html()+'</div></div>' )
		});
		$('.bDebugPopup').html( '<fieldset><legend>SQL query`s</legend>'+$('<div></div>').append( $( SQL.join(' ')).clone() ).html() +'</fieldset>' );
		
		
		/*
		* Slide by click on .bTitle
		*/
		$('.bTitle').click(function(){
			$(this).parent().find('.bCode').slideToggle("fast");
		});
		
		
		/*
		* Get modal executed query
		*/
		$('.bDebugPopup .bCode').click(function(){
			window.open('/bdebugGetResult?sql='+$(this).parent().index(), 'SQL Result', "height=400,width=600,scrollbars=yes");
		})
		
		
		/*
		* Show/hide popup
		*/
		$('.bButton').click(function(){
			$( $(this).attr('href') ).siblings('.bPopup').removeClass('DebugOpened');
			$( $(this).attr('href') ).toggleClass('DebugOpened');
			return false;
		})
		
		/*
		* Higlight block with slow query
		*/
		$('.bDebugPopup .bCodeBlock').each(function(){
			percent = parseFloat( $('.bTitle',this).attr('time') ) / (0.5 / 100);
			$('.bTitle',this).css('background-color','rgba(255,0,0,'+(percent/100)+')');
		});
		
		
		/*
		* Set popup to  max-height
		*/
		$('.bPopup').css('max-height', $(window).height()-40);
		$(window).resize(function(){
			$('.bPopup').css('max-height', $(window).height()-40);
		})
	})(jQuery);
</script>


<style>
	.bCodeBlock{
		border: 1px solid grey;
		border-radius: 3px;
		box-shadow: 1px 1px 2px 1px rgba(0, 0, 0, 0.11);
		background:rgba(0,255,0,0.25);
		overflow:hidden;
		margin: 0 0 3px 0;
	}
	.bTitle{
		font-weight:bold;
		padding: 4px 4px 4px 4px;
		cursor:pointer;
	}
	.bCode{
		background: none repeat scroll 0 0 white;
		border-top: 1px solid gray;
		display: block;
		display:none;
		padding: 0px 4px 4px 4px;
	}
	.bDebugPopup .bCodeBlock:hover{
		cursor:pointer;
		background:rgba(0, 0, 0, 0.09);;
	}
	
	
	
	.bPopup{
		display:none;
		background: none repeat scroll 0 0 #eee;
		bottom: 20px;
		box-shadow: 0 0 6px 5px rgba(0, 0, 0, 0.18);
		font-size: 10px;
		height: auto;
		left: 20px;
		overflow-y: auto;
		padding: 3px;
		position: absolute;
		width: 700px;
		border-radius: 4px;
		border: 1px solid rgba(0,0,0,0.56);
	}
	
	
	
	
	.bPopup{
		display:none;
	}
	
	.bPopup.DebugOpened{
		display:block;		
	}
	#bDebug fieldset{
		border:2px groove grey;
		background:threedface;
	}
	
	#bDebug{
		background: none repeat scroll 0 0 #B2B2B2;
		bottom: 0;
		color: black;
		font-family: arial;
		font-size: 10px;
		height: 14px;
		left: 0;
		line-height: 14px;
		
		position: fixed;
		right: 0;
		z-index:9999;
	}
	.bButton{
		background: none repeat scroll 0 0 yellow;
		border-radius: 2px;
		cursor: pointer;
		display: block;
		float: left;
		font-size: 9px;
		font-weight: bold;
		height: 10px;
		line-height: 8px;
		margin: 0 0 0 10px;
		padding: 0 7px 0 7px;
		position: relative;
		text-decoration: none;
		top: 2px;
		color: black;
		-webkit-touch-callout: none;
		-webkit-user-select: none;
		-khtml-user-select: none;
		-moz-user-select: none;
		-ms-user-select: none;
		user-select: none;
	}
</style>



<?php
	$out =  ob_get_contents();
	ob_end_clean();	
	
	
	$stats = $modx->getTimerStats($modx->tstart);  
	$out= str_replace("[^q^]", $stats['queries'] , $out);
	$out= str_replace("[^qt^]", $stats['queryTime'] , $out);
	$out= str_replace("[^p^]", $stats['phpTime'] , $out);
	$out= str_replace("[^t^]", $stats['totalTime'] , $out);
	$out= str_replace("[^s^]", $stats['source'] , $out);
	$out= str_replace("[^m^]", $stats['phpMemory'], $out);
	
	//echo $out;
	
	if ( strpos( $modx->documentOutput,'jquery') == false ) {
		$out = '<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
				<script>jQuery.noConflict()</script>
		'.$out;
	}
	
	$modx->documentOutput = str_replace($modx->queryCode,'',$modx->documentOutput);
	$modx->documentOutput = str_replace('</body>',$out.'</body>',$modx->documentOutput);
	break;
}