//<?php
/**
 * bDebug 
 * 
 * just make MODx evo is easy
 *
 * @category    plugin
 * @version     0.1
 * @author		By Bumkaka from modx.im
 * @internal    @properties 
 * @internal    @events OnWebPageInit,OnWebPagePrerender
 * @internal	@properties 
 * @internal    @modx_category Manager and Admin
 * @internal    @installset base
 */
 
 if (empty($_SESSION['mgrInternalKey'])) return;

$e = &$modx->event; 
switch ($e->name){
	case 'OnPageNotFound':
	switch($_GET['q']){
		case 'bdebugGetResult':	
		$tstart = $modx->getMicroTime();
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
	break;
	
	
	case 'OnWebPagePrerender':
	$modx->dumpSQL = false;
	$Temp1 = explode('</legend>',$modx->queryCode); 
	
	foreach($Temp1 as $key=>$value){
		$Temp2 = explode('<',$value);
		if (!empty($Temp2[0])) $SQL[] = trim($Temp2[0]);	
	}
	
	$_SESSION['SQL'] = $SQL;
	
	$modx->CustomDebug = print_r($SQL,true);
	
	ob_start();
?>



<div id="bDebug">
	<div class="bDebugPopup"><?=$modx->CustomDebu1g;?><?=$modx->queryCode;?></div>
	
	<a id="bDebugPop">&hellip;</a>
	Mem : [^m^], MySQL: [^qt^], [^q^] request(s), PHP: [^p^], total: [^t^], document from [^s^]
</div>


<script>
	(function($){
		//$SQLs = $('.bDebugPopup fieldset').clone();
		SQL = [];
		$('.bDebugPopup>br').remove();
		$('.bDebugPopup fieldset').each(function(){
			index = $(this).index();
			tmp = $(this).clone();
			time = parseFloat( $('legend',tmp).html().split('-')[1].replace(' ','').replace('s','').replace(',','.') ) / 1000;
			time = time.toFixed(5);
			$('legend',tmp).remove();
			ind = index+1;
			SQL.push( '<div class="query"><div class="time" time="'+time+'">Query #'+ind+' - '+time+' sec</div><div class="SQL">'+tmp.html()+'</div></div>' )
		});
		
		$('.bDebugPopup').html( $( SQL.join(' ') ) );
		
		
		
		
		$('.time').click(function(){
			$(this).parent().find('.SQL').slideToggle("fast");
		});
		
		
		$('.bDebugPopup .SQL').click(function(){
			window.open('/bdebugGetResult?sql='+$(this).parent().index(), 'SQL Result', "height=400,width=600,scrollbars=yes");
		})
		
		
		$('#bDebugPop').click(function(){
			$('#bDebug').toggleClass('DebugOpened');
		})
		
		$('.bDebugPopup .query').each(function(){
			percent = parseFloat( $('.time',this).attr('time') ) / (0.5 / 100);
			console.log(percent)
			$('.time',this).css('background-color','rgba(255,0,0,'+(percent/100)+')');
		})
	})(jQuery);
</script>


<style>
	.query{
		border: 1px solid grey;
		border-radius: 3px;
		box-shadow: 1px 1px 2px 1px rgba(0, 0, 0, 0.11);
		background:rgba(0,255,0,0.25);
		overflow:hidden;
		margin: 0 0 3px 0;
	}
	.time{
		font-weight:bold;
		padding: 4px 4px 4px 4px;
	}
	.SQL{
		background: none repeat scroll 0 0 white;
		border-top: 1px solid gray;
		display: block;
		display:none;
		padding: 0px 4px 4px 4px;
	}
	.bDebugPopup .query:hover{
		cursor:pointer;
		background:rgba(0, 0, 0, 0.09);;
	}
	.bDebugPopup{
		display:none;
		background: none repeat scroll 0 0 #eee;
		bottom: 20px;
		box-shadow: 0 0 6px 5px rgba(0, 0, 0, 0.18);
		font-size: 10px;
		height: 300px;
		left: 20px;
		overflow-y: auto;
		padding: 3px;
		position: absolute;
		width: 700px;
		border-radius: 4px;
		border: 2px solid rgba(0,0,0,0.56);
	}
	
	.DebugOpened .bDebugPopup{
		display:block;
		
	}
	
	#bDebug{
		background: none repeat scroll 0 0 rgba(0, 0, 0, 0.3);
		bottom: 0;
		color: black;
		font-family: arial;
		font-size: 10px;
		height: 14px;
		left: 0;
		line-height: 14px;
		padding: 0 0 0 40px;
		position: fixed;
		right: 0;
		z-index:9999;
	}
	#bDebug a{
		background: none repeat scroll 0 0 yellow;
		border-radius: 2px;
		cursor: pointer;
		display: block;
		font-size: 13px;
		font-weight: bold;
		height: 10px;
		left: 5px;
		line-height: 4px;
		padding: 0 0 0 7px;
		position: absolute;
		text-decoration: none;
		top: 2px;
		width: 20px;
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