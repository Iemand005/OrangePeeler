<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta id="vp" name="viewport" content="width=720,initial-scale=0.5,maximum-scale=0.5,minimum-scale=0.5,user-scalable=no">
<title>login</title>
<link href="image/top_logo.gif" type="image/gif" rel="icon">
<link href="css/allcss.css" rel="stylesheet" type="text/css"/>
<link href="css/login.css" rel="stylesheet" type="text/css" />
<link href="css/font.css" rel="stylesheet" type="text/css" media="none" onload="this.media='all';" />
<script src="js/functions.js" type="text/javascript"></script>
<script src='js/dict_nl.js'></script>
<script>
var w1=Math.min(window.innerWidth,screen.width*window.devicePixelRatio),scale=w1/720*0.5;
document.getElementById('vp').content='width=720,initial-scale='+scale+',maximum-scale='+scale+',minimum-scale='+scale+',user-scalable=no';

fromLAN = 1;
default_embedded_cmImage = "image/login_05.gif";
cmImageURL_1 = '';
cmImageURL_2 = '';
cmImageURL_3 = '';
advertiseURL_1 = '';
advertiseURL_2 = '';
advertiseURL_3 = '';
checkImgExist_1 = false;
checkImgExist_2 = false;
checkImgExist_3 = false;
activeCmImageURL = "";
activeAdURL = "";
activeCmImageURL_Updated = false;

if (! fromLAN)
{
    activeCmImageURL = default_embedded_cmImage;
    activeAdURL = "";
    //if (default_embedded_cmImage != "")
    //    document.getElementById('CmPicture').src = default_embedded_cmImage;
    activeCmImageURL_Updated = true;
}
else if ((fromLAN) && (! activeCmImageURL_Updated))
{
    if (cmImageURL_1 != "")
        CheckImage(cmImageURL_1, function(){ checkImgExist_1 = true; }, function(){ console.log("cmImageURL_1: bad"); } );

    if (cmImageURL_2 != "")
        CheckImage(cmImageURL_2, function(){ checkImgExist_2 = true; }, function(){ console.log("cmImageURL_2: bad"); } );

    if (cmImageURL_3 != "")
        CheckImage(cmImageURL_3, function(){ checkImgExist_3 = true; }, function(){ console.log("cmImageURL_3: bad"); } );

    //delay a while before check result
    setTimeout(function () {
        UpdateImgAdURLs();
    }, 1000);

    if (! activeCmImageURL_Updated)
    {
        //check result again
        setTimeout(function () {
            UpdateImgAdURLs();
        }, 1500);
    }
}

function UpdateImgAdURLs() {
    if (checkImgExist_1) //ImageURL 1 have first priority
    {
        activeCmImageURL = cmImageURL_1;
        activeAdURL = advertiseURL_1;
    }

    if ((checkImgExist_2) && (!checkImgExist_1))
    {
        activeCmImageURL = cmImageURL_2;
        activeAdURL = advertiseURL_2;
    }

    if ((checkImgExist_3) && (!checkImgExist_2) && (!checkImgExist_1))
    {
        activeCmImageURL = cmImageURL_3;
        activeAdURL = advertiseURL_3;
    }

    if ((!checkImgExist_1) && (!checkImgExist_2) && (!checkImgExist_3))
    {
        if (default_embedded_cmImage != "")
            document.getElementById('CmPicture').src = default_embedded_cmImage;
        activeCmImageURL = default_embedded_cmImage;
        activeAdURL = "";
    }
    else
    {
        if (activeCmImageURL != "")
            document.getElementById('CmPicture').src = activeCmImageURL;
    }
    activeCmImageURL_Updated = true;
}

function CheckImage(img_url, good, bad) {
    var img = new Image();
    img.onload = good;
    img.onerror = bad;
    img.src = img_url;
}

function openAdWindow()
{
    if (activeAdURL != "")
    {
        window.open(activeAdURL, '_blank');
    }
}

function tglInput (obj, value) {
    if(obj.className.indexOf('active') != -1) {
        if(obj.value == '') {
            obj.value = value;
            obj.classList.toggle('active')
        }
    }
    else {
        if(obj.value == value) {
            obj.value = '';
            obj.classList.toggle('active')
        }
    }
}

function window_PwdForgot() {
   scrollToTop(10);
   var win = document.getElementById('window_PwdForgot');
   var bg =  document.getElementById('blackBackground');
   //showimg(win);
   var img = document.getElementsByClassName("password_forgotten_left")[0].querySelector("img");

   if(img.hasAttribute('large-src'))
   {
       img.src = img.getAttribute('large-src');
       img.removeAttribute('large-src');
   }
   show(win);
   show(bg);
}

function window_MoreInfo() {
   scrollToTop(10);
   var win = document.getElementById('window_MoreInfo');
   var bg =  document.getElementById('blackBackground');
   showimg_MoreInfo(win);
   show(win);
   show(bg);
}

function window_QRcode() {
    scrollToTop(10);
    var win = document.getElementById('window_QRcode');
    var bg =  document.getElementById('blackBackground');
    showimg(win);
    show(win);
    show(bg);
}

function showimg(element){
    if(element.childNodes[3].hasAttribute('large-src'))
    {
        var newNode = document.createElement('img');
        newNode.src = element.childNodes[3].getAttribute('large-src');
        element.replaceChild(newNode,  element.childNodes[3]);
    }
}

function showimg_MoreInfo(element){
    var img_arr=element.childNodes[1].querySelectorAll('img');
    for(var i=0; i<img_arr.length; i++)
    {
        if(img_arr[i].hasAttribute('large-src'))
        {
            var img = img_arr[i];
            img.src = img.getAttribute('large-src');
            img.removeAttribute('large-src');
        }
    }
}

</script>
</head>

<body>
<div id="top_box">
	<div id="minbox">
		<div id="minbox_inside">
			<div id="top_content">
                <div id="top_content_up">
                    <div class="logo">
                        <a target="_blank" href="https://www.orange.be/nl/">
                            <img src="image/top_logo.gif" width="69" height="69">
                        </a>
                    </div>
                    <div class="lang"><a target="_blank" href="https://www.orange.be/nl/gids/SlgModem/" title="c001">Help</a>&nbsp;-&nbsp;
                        <form action="/goform/OrgLanguages" id="languageform" method="post" style="display: inline;"><input type="hidden" value="0" name="OrgCgnOptOutValue" id="OrgCgnOptOutValue"/><select name="OrgLanguageSelect" onchange="this.form.submit();"><option value='8'  >EN</option><option value='9'  >DE</option><option value='10' selected >NL</option><option value='11'  >FR</option></select></form>
                    </div>
                </div><!--top_content_up-->
			</div><!--top_content-->
		</div><!--minbox_inside-->
	</div><!--minbox-->
</div><!--top_box-->
<div id="m_top" class="PC_hide">
    <div class="themod_mobile">
       <a href="#"><img src="image/top_logo.gif" class="logo_img"></a>
            <div class="mobile_lang">
                <a target="_blank" href="https://www.orange.be/nl/gids/SlgModem/" title="c001">Help</a>&nbsp;-&nbsp;
            <form action="/goform/OrgLanguages" id="languageform" method="post" style="display: inline;"><input type="hidden" value="0" name="OrgCgnOptOutValue" id="OrgCgnOptOutValue"/><select name="OrgLanguageSelect" onchange="this.form.submit();"><option value='8'  >EN</option><option value='9'  >DE</option><option value='10' selected >NL</option><option value='11'  >FR</option></select></form>
       </div>
    </div>
</div>
<div style="clear:both;"></div>
<div id="minbox">
    <div id="minbox_inside">
        <div id="center">
            <div id="center_Cbox">
                <div class="pageTitle">
                <span title="d00002">Hello</span>
                </div>
                <div id="login_content">
                    <div class="sever_img"><img name="CmPicture" id="CmPicture" src="image/login_05.gif" onclick="openAdWindow();" /></div>
                    <form action="/goform/OrgLogin" method="post" name="Login">
                    <div class="login_box">
                        <div class="login_inputbox">
                            <span class="description" title="d00003">Enter your password to access your configuration settings</span>
                            <input name="OrgPassword" id="OrgPassword" tabindex="2" type="password" class="input-example" onblur="tglInput(this, 'Password');" onfocus="tglInput(this, 'Password');" maxlength="20"/><input class="buttonStyle04" type="submit" value="Log In" title="btn001" />
                            <br />
                            <a href="javascript:window_PwdForgot();" title="d00004">Password forgotten</a>
                            
                            
                        </div>
                        <div class="yourWifi"><span title="d00010">Your WiFi</span><br /><span class="severFontSize fontStyle01" title="d00011">Active</span></div>
                        <div class="internetAccess">
                            <span title="d00013">Internet access</span>
                            <br /><span class="severFontSize fontStyle03" title="d00031">missing managment IP</span>
                        </div>
                        <div class="cableNetwork">
                            <span title="d00016">Cable network</span>
                            <br /><span class="severFontSize fontStyle03" title="d00018">Not connected <br/>Check the home 
            cabling - </span><a href="javascript:window_MoreInfo();" class="fontStyle04" title="d00019">more info</a> 
                        </div>
                    </div> <!-- login_box -->
                    </form>
                </div> <!-- login_content -->
                <div style="clear:both;"></div>
                <div id="login_speedtest"><a target="_blank" href="https://www.orange.be/nl/gids/SlgCableSpeedTest/" title="d00020">SpeedTest</a></div>
            </div><!--center_Cbox-->
        </div><!--center-->
        <div id="C_down">
            <div class="C_left">
                <!--
                <a href="Technicalreports.asp" title="d00021">Technical page</a>
                -->
                <a target="_blank" href="./Technicalreports.asp" title="d00021">Technical page</a>
            </div>
            <div class="C_right">
                <div>
                 <!--
                    <img src="image/login_04.gif" onclick="window_QRcode();" />
                  -->
                    <span title="d00032">
                        More information about your modem and the internet service on the Orage website <a target="_blank" href="https://www.orange.be/">www.orange.be</a> support section.
                    </span>
                </div>
            </div>
        </div><!--C_down-->
    </div><!--minbox_inside-->
</div><!--minbox-->
<div class="password_forgottenStyle" id="window_PwdForgot" style="display: none;">
    <div style="clear:both;"></div>
    <div class="content">
        <div class="password_forgotten_left">
            <img src="image/loading.gif" large-src="image/password_forgotten.png"/>
        </div>
        <div class="password_forgotten_right">
            <br>
            <span title="d00025">You can find the <b>default</b> password on the sticker at the bottom of your modem.</span>
            <br>
            <span title="d00026">(below the WiFI default password).</span>
            <br>
            <br>
            <span title="d00027">If you have changed the default password of your modem,please call the support to obtain it.</span>
            <br>
            <br>
            <span title="d00028">Note: you can set back your password to the default value via a factory reset but you will lose all your configur
        </div>
    </div>
    <div class="PC_buttonBox">
        <input class="buttonStyle01" type="button" value="Close" title="btn033" onclick="closeWinFn(this);"/>
    </div>
</div>

<div style="clear:both;"></div>
<div class="customWindow" id="window_MoreInfo" style="display: none;">
    <div class="content">
        <div class="overviewPic0">
            <img src="image/loading.gif" large-src="image/overviewPic0.png"/>
        </div>
        <div class="title_main" title="d01021">No cable connectivity!</div>
        <div class="title_sub" title="d01022">If the internet <u><b>and</b></u> tv services are broken, check the signal amplifier</div>
        <div class="overviewPic1"><img src="image/loading.gif" large-src="image/overviewPic1.png"/></div>
        <div class="paragraph">
            <span title="d01023">Check that the signal amplifier has'nt been unplugged by mistake.</span>
            <br>
            <span title="d01024">- check the power cable of the signal amplifier (Point "a" in the picture above)</span>
            <br>
            <span title="d01025">- check if the coax cable is still correctly plugged in the signal amplifier. (Point "1" in the picture above)</span>
        </div>
        <div class="title_sub2" title="d01026">What is the signal amplifier?</div>
        <span title="d01027">The signal amplifier (also called NIU) does a last amplification in order to provide to your modem and to your TV decoder a strong signal. If the equipment is no more powered,
        internet and TV services are impacted.</span>
        <div class="title_sub2" title="d01028">Where is the signal amplifier?</div>
        <span title="d01029">The equipment is usually placed close from the arrival in your home of the coax cable.
        Often in the cave, if the coax cable in your street is underground or at the floor (or at the
        attic) if the cable is aerial or attached to your home. </span>
        <br/>
        <div class="paragraph">
        <span title="d01030">Several types of signal amplifiers are used (please find below the most common one) </span>
        </div>
        <div class="overviewPic2"><img src="image/loading.gif" large-src="image/overviewPic2.png"></div>
        <div class="overviewPic3"><img src="image/loading.gif" large-src="image/overviewPic3.png"></div>
        <div class="title_sub" title="d01031">If only your internet service is broken</div>
        <span title="d01032">Check the cable connection between the signal amplifier and your modem.
        At both sides the cable should be firmly connected (Point 2 and point 3 of the picture
        above). </span>
        <div class="title_sub" title="d01033">If the problem persists </div>
        <span title="d01034">Check if a re-start of the modem (power off/on) doesn't solve the problem. If not call the
        customer support. </span>
        <div class="title_sub" title="d01035">Tip</div>
        <span title="d01036">More information on our website (also accessible via the mobile data network of Orange)</span>
        <div class="footer">
            <div class="overviewPic4"><img src="image/loading.gif" large-src="image/overviewPic4.png"></div>
            <span title="d01037">Scan the QR code with your smartphone to access directly to www.orange.be (support section).</span>
        </div>
    </div>
  <div class="PC_buttonBox">
    <input class="buttonStyle01" type="button" title="btn002" value="OK" onclick="closeWinFn(this);"/>
    </div>
</div>
<div class="windowStyle01" id="window_QRcode" style="display: none; top:100px;">
    <div style="clear:both;"></div>
    <img src="image/loading.gif" large-src="image/login_003.png"/>
    <div class="PC_buttonBox">
        <input class="buttonStyle01" type="button" title="btn002" value="OK" onclick="closeWinFn(this);" />
    </div>
</div>
<div id="blackBackground" class="blackBackground" style="display: none;"></div>
<script>
document.addEventListener("DOMContentLoaded", function(){
    var win_title_sub = document.getElementsByClassName('title_sub')[0];
    win_title_sub.innerHTML = win_title_sub.innerText;

    var span_node = document.querySelectorAll('span');
    for(var i=0; i<span_node.length;i++)
        span_node[i].innerHTML = span_node[i].innerText;
});
</script>
<style>
    .pwd_wrong{
        color:#ff0000;
        margin-top: 20px;
        max-width: 350px;
    }
</style>
</body>
</html>
