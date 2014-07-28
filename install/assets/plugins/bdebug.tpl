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
	case 'OnWebPageInit':
		$modx->dumpSQL = true;
	break;
	
	
	case 'OnWebPagePrerender':
		$modx->dumpSQL = false;
		ob_start();
?>



<div id="bDebug">
	<div class="bDebugPopup"><?=$modx->queryCode;?></div>
	<a id="bDebugPop">&hellip;</a>
	Mem : [^m^], MySQL: [^qt^], [^q^] request(s), PHP: [^p^], total: [^t^], document from [^s^]
</div>



<script>
	document.getElementById("bDebugPop").onclick = function() {
		if (document.getElementById("bDebug").classList.contains("DebugOpened")) {
			document.getElementById("bDebug").classList.remove("DebugOpened"); 
		} else {
			document.getElementById("bDebug").classList.add("DebugOpened"); 
		}
	}
</script>


<style>
	
	.bDebugPopup{
		display:none;
		background: none repeat scroll 0 0 #eee;
		bottom: 20px;
		box-shadow: 0 0 6px 5px rgba(0, 0, 0, 0.38);
		font-size: 10px;
		height: 300px;
		left: 20px;
		overflow-y: auto;
		padding: 9px;
		position: absolute;
		width: 700px;
		border-radius: 7px;
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
	$modx->documentOutput = str_replace($modx->queryCode,'',$modx->documentOutput);
	$modx->documentOutput = str_replace('</body>',$out.'</body>',$modx->documentOutput);
	break;
}