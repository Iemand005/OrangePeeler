<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Technical reports</title>
<link href="image/top_logo.gif" type="image/gif" rel="icon">
<link href="css/allcss.css" rel="stylesheet" type="text/css" />
<link href="css/overview.css" rel="stylesheet" type="text/css" />
<link href="css/specialPages.css" rel="stylesheet" type="text/css" />
<link href="css/technicalreports.css" rel="stylesheet" type="text/css" />
<link href="css/font.css" rel="stylesheet" type="text/css" media="none" onload="this.media='all';" />
<script src="js/jquery-3.2.1.min.js" type="text/javascript"></script>
<script src="js/jquery.min.js" type="text/javascript"></script>
<script src="js/alljquery.js" type="text/javascript"></script>
<style>
.longbutton{
	width:210px;
	font-size:14px;
}
</style>
<script src='js/dict_nl.js'></script>
<script>

var isVolumeMeterOn = true;

$(function() {
    $('#ExportFile').on('click', function() {
        $('#AskConfiguration').val("1");
        var filename = 'TechnicalreportsInfo.log';
        window.location = filename;
    });

    $('#ClearPage').on('click', function() {
        document.getElementById('LogsArea').value = "";
    });

    $('#ExitPage').on('click', function() {
        /*
        var dest_page = '/';
        window.location = dest_page;
        */
        window.close();
    });

    $('#SpectrumDumpPage').on('click', function() {
        var hostname=window.location.hostname;
        var WanManIP = '0.0.0.0';
        var IPStack3 = 'http://0.0.0.0:8089';
        if(hostname==WanManIP)
        {
	        window.open(IPStack3, '_blank');
        }
        else if((hostname=="192.168.100.1")||(hostname=="192.168.0.1"))
        {
            var SpectrumLink = 'http://192.168.100.1:8080'
	        window.open(SpectrumLink, '_blank');
        }
    });
});

function refreshDiv(iface) {
	$("#VolumeMeter").load(location.href + " #VolumeMeter");
}

$(document).ready(function(){
    if (isVolumeMeterOn)
        $('#VolumeMeter').show();
    else
        $('#VolumeMeter').hide();
});
</script>
</head>

<body>
<div id="top_box">
    <div id="minbox">
        <div id="minbox_inside">
            <div id="top_content">
                <div id="top_content_up">
                    <div class="logo"><img src="image/top_logo.gif" width="69" height="69" /></div>
                    <div class="lang">
                        <form action="/goform/OrgLanguages" id="languageform" method="post" style="display: inline;"><input type="hidden" value="0" name="OrgCgnOptOutValue" id="OrgCgnOptOutValue"/><select name="OrgLanguageSelect" onchange="this.form.submit();"><option value='8'  >EN</option><option value='9'  >DE</option><option value='10' selected >NL</option><option value='11'  >FR</option></select></form>
                    </div>
                </div><!--top_content_up-->

            </div><!--top_content-->
        </div><!--minbox_inside-->
    </div><!--minbox-->
</div><!--top_box-->

<div style="clear:both;"></div>
<form action="/goform/OrgTechnicalreports" method="post" name="OrgTechnicalreports" id="OrgTechnicalreports">
<div id="minbox">
    <div id="minbox_inside">
        <div id="center">
            <div id="center_Cbox">
                <div class="pageTitle"><span title="d70001">Technical reports</span></div>
                <div class="technicalreports_box">
                    <div class="tableBox07">
                        <div class="T_Left"><span title="d70002">Modem Management IP</span>:</div>
                        <div class="T_Right ss">
                            <span id="to_clipboard">0.0.0.0</span>
                            &nbsp;&nbsp;<input class="buttonStyle03 longbutton jq_apply" data-clipboard-action="copy" data-clipboard-target="#to_clipboard" type="button" value="Copy to clipboard" id="jp_clipboard" style="float: none;" title="btn026" />
                        </div>
                        <div class="T_Left"><span title="d70003">Modem Public IP</span>:</div>
                        <div class="T_Right">::</div>
                    </div>
                </div>
                <div style="clear:both;"></div>

                <div id="VolumeMeter">
                    <div class="itemTitle"><span title="d70013">Volume Meter</span></div>
                    <div class="CS_table">
                        <div class="CS_tr">
                            <div class="CS_td first top"><span title="d70014">Month</span></div>
                            <div class="CS_td top"><span title="c1111">Nov</span></div><div class="CS_td top"><span title="c1112">Dec</span></div><div class="CS_td top"><span title="c1101">Jan</span></div>
                        </div>
                        <div class="CS_tr">
                            <div class="CS_td first"><span title="d70015">Renew</span></div>
                            <div class="CS_td ">2025/11/30</div><div class="CS_td ">2025/12/31</div><div class="CS_td ">2026/01/31</div>
                        </div>
                        <div class="CS_tr">
                            <div class="CS_td first"><span title="d70016">Transmitted</span></div>
                            <div class="CS_td ">68.87GB</div><div class="CS_td ">33.90GB</div><div class="CS_td ">36.83GB</div>
                        </div>
                        <div class="CS_tr">
                            <div class="CS_td first"><span title="d70017">Received</span></div>
                            <div class="CS_td ">1019.35GB</div><div class="CS_td ">963.88GB</div><div class="CS_td ">980.11GB</div>
                        </div>
                    </div>
                    <!--
                    <input class="buttonStyle03" type="button" value="Update" title="btn030" style="float: none;" onclick="refreshDiv();" />
                    -->
                </div>
                <div style="clear:both;"></div>

                <div class="itemTitle"><span title="d70004">Current</span></div>
                <div class="itemTitle3"><span title="d70006">Upstream</span></div>
                <div class="CS_table">
                    <div class="CS_tr">
                        <div class="CS_td first top"><span title="d70008">Channel</span></div>
                        <div class="CS_td top">1</div>
                        <div class="CS_td top">2</div>
                        <div class="CS_td top">3</div>
                        <div class="CS_td top">4</div>
                        <div class="CS_td top">5</div>
                        <div class="CS_td top">6</div>
                        <div class="CS_td top">7</div>
                        <div class="CS_td top">8</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70009">Frequency</span></div>
                        <div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70010">Power</span></div>
                        <div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70011">Modulation</span></div>
                        <div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70018">Status</span></div>
                        <div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div>
                    </div>
                </div>

                <div style="clear:both;"></div>

                <div class="itemTitle3"><span title="d70007">Downstream</span></div>
                <div class="CS_table">
                    <div class="CS_tr">
                        <div class="CS_td first top"><span title="d70008">Channel</span></div>
                        <div class="CS_td top">1</div>
                        <div class="CS_td top">2</div>
                        <div class="CS_td top">3</div>
                        <div class="CS_td top">4</div>
                        <div class="CS_td top">5</div>
                        <div class="CS_td top">6</div>
                        <div class="CS_td top">7</div>
                        <div class="CS_td top">8</div>
                        <div class="CS_td top">9</div>
                        <div class="CS_td top">10</div>
                        <div class="CS_td top">11</div>
                        <div class="CS_td top">12</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70009">Frequency</span></div>
                        <div class="CS_td ">626000000</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70010">Power</span></div>
                        <div class="CS_td ">-44.9</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70012">SNR</span></div>
                        <div class="CS_td "> 9.2</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70011">Modulation</span></div>
                        <div class="CS_td ">d34016</div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70018">Status</span></div>
                        <div class="CS_td "><span title="d34013">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div>
                    </div>
                </div>

                <div style="clear:both; height:30px;"></div>
                <div class="CS_table">
                    <div class="CS_tr">
                        <div class="CS_td first top"><span title="d70008">Channel</span></div>
                        <div class="CS_td top">13</div>
                        <div class="CS_td top">14</div>
                        <div class="CS_td top">15</div>
                        <div class="CS_td top">16</div>
                        <div class="CS_td top">17</div>
                        <div class="CS_td top">18</div>
                        <div class="CS_td top">19</div>
                        <div class="CS_td top">20</div>
                        <div class="CS_td top">21</div>
                        <div class="CS_td top">22</div>
                        <div class="CS_td top">23</div>
                        <div class="CS_td top">24</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70009">Frequency</span></div>
                        <div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div><div class="CS_td ">0</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70010">Power</span></div>
                        <div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70012">SNR</span></div>
                        <div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div><div class="CS_td ">0.0</div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70011">Modulation</span></div>
                        <div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div><div class="CS_td "><span title="d34016">Unknown</span></div>
                    </div>
                    <div class="CS_tr">
                        <div class="CS_td first "><span title="d70018">Status</span></div>
                        <div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div><div class="CS_td "><span title="d34015">Unlocked</span></div>
                    </div>
                </div>

                <div style="clear:both;"></div>
                <div class="itemTitle"><span title="d70005">Signal logs</span></div>
                <div class="tableBox02">
                    <!--add wrap="off"-->
                    <textarea readonly id="LogsArea" name="LogsArea" style="width:100%; height:150px;" wrap="off">2026:09:26 21:11:15       | CM State is UpstreamPartialService; ID 30; frequency 30500000
2026:09:26 21:11:15       | CM State is NotUpstreamPartialService; ID 30; frequency 30500000
2026:09:26 21:11:25       | CM State is UpstreamPartialService; ID 30; frequency 30500000
2026:09:26 21:11:25       | CM State is NotUpstreamPartialService; ID 30; frequency 30500000
2026:09:26 21:11:35       | CM State is UpstreamPartialService; ID 30; frequency 30500000
2026:09:26 21:11:36       | CM State is NotUpstreamPartialService; ID 30; frequency 30500000
2026:09:26 21:11:46       | CM State is UpstreamPartialService; ID 30; frequency 30500000
2026:09:26 21:11:46       | CM State is NotUpstreamPartialService; ID 30; frequency 30500000
2026:09:26 22:51:16       | CM State is UpstreamPartialService; ID 10; frequency 45700000
2026:09:26 22:51:17       | CM State is NotUpstreamPartialService; ID 10; frequency 45700000
2026:09:27 01:37:33       | Upstream Modulation Change - Channel=10; Frequency=45700000; Old Modulation=64QAM ; New Modulation=16QAM 
2026:09:27 01:38:34       | Upstream Modulation Change - Channel=10; Frequency=45700000; Old Modulation=16QAM ; New Modulation=64QAM 
2026:09:27 01:45:04       | Upstream Modulation Change - Channel=10; Frequency=45700000; Old Modulation=64QAM ; New Modulation=16QAM 
2026:09:27 02:38:35       | Upstream Modulation Change - Channel=10; Frequency=45700000; Old Modulation=16QAM ; New Modulation=64QAM 
2026:09:27 02:40:35       | Upstream Modulation Change - Channel=10; Frequency=45700000; Old Modulation=64QAM ; New Modulation=16QAM 
2026:09:27 03:38:36       | Upstream Modulation Change - Channel=10; Frequency=45700000; Old Modulation=16QAM ; New Modulation=64QAM 
Time Not Established      | Cable Modem Reboot due to power reset
2026:09:27 16:22:38       | REGISTRATION COMPLETE - Waiting for Operational status;CM-MAC=08:b0:55:2a:af:f0;CMTS-MAC=00:17:10:2b:66:11;CM-QOS=1.1;CM-VER=3.0;
</textarea>
                </div>

                <div style="clear:both;"></div>
                <div class="PC_buttonBox">
                    <input class="buttonStyle01 jq_apply" type="button" value="Exit" id="ExitPage" title="btn025" />
                    <input class="buttonStyle01 jq_apply" type="button" value="Reset" id="ClearPage" title="btn008" />
                    <input class="buttonStyle01 jq_apply" type="button" value="Export" id="ExportFile" title="btn024" />
                    <input class="buttonStyleSpectrum jq_apply m_hide" type="button" value="SpectrumDump" id="SpectrumDumpPage" title="btn032" />
                </div>
                <input value="0" type="hidden" name="AskConfiguration" id="AskConfiguration">
            </div><!--center_Cbox-->
        </div><!--center-->
    </div><!--minbox_inside-->
</div><!--minbox-->
</form>

<div class="loadingimg" style="display: none;"><img src="image/loading.gif" /></div>
<div id="blackBackground" class="blackBackground" style="display: none;"></div>
<style>
.buttonStyleSpectrum{
	border: 1px solid #595959;
	color:#000000;
	background-color: #FF7900;
	float: left;
	margin-left: 10px;
	margin-top:4px;
	margin-bottom:4px;
	font-family: HelvNeue55_W1G, HelvNeue75_W1G;
	font-size:14px;
	height: 30px;
	width: 150px;
	padding-left: 0px;
	padding-right: 0px;
	text-align: center;
	cursor: pointer;
}
</style>
<script src="js/clipboard.min.js"></script>
<script>
    var clipboard = new Clipboard('#jp_clipboard');

    clipboard.on('success', function(e) {
        e.clearSelection();
    });

    clipboard.on('error', function(e) {
    });
</script>
</body>
</html>
