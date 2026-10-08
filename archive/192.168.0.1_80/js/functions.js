function CheckSSID(s_ssid) {
   if (s_ssid == undefined) {
        return false;
   }
   if(s_ssid.charAt(0)==' ' || s_ssid.charAt(s_ssid.length -1)==' ') {
       return false;
   }
   return true;
}

function passwordStrength(password) {
    var score = 0;

    //if password bigger than 6 give 1 point
    if (password.length > 6)
        score++;

    //if password has both lower and uppercase characters give 1 point
    if (( password.match(/[a-z]/) ) && ( password.match(/[A-Z]/) ))
        score++;

    //if password has at least one number give 1 point
    if (password.match(/\d+/))
        score++;

    //if password has at least one special caracther give 1 point
    if (password.match(/.[!,@,#,$,%,^,&,*,?,_,~,-,(,)]/))
        score++;

    //if password bigger than 12 give another 1 point
    if (password.length > 12)
        score++;

    return score;
}

function htmlXSSFilter(str) {
    return str.replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/'/g, '&#039;').replace(/"/g, '&quot;');
}

function ValidateNumberAvaliable(e, pnumber, min_val, max_val) {
    if (!/^\d+$/.test(pnumber))
        e.value = /^\d+/.exec(e.value);

    if (e.value != "") {
        if (e.value < min_val)
            e.value = min_val;

        if (e.value > max_val)
            e.value = max_val;
    }
}


function ValidateIPValue(e, pnumber) {
   if (!/^\d+$/.test(pnumber)){
       if (pnumber != "")
           e.value = /^\d+/.exec(e.value);
   }

   if( (e.value < 0) || (e.value > 255) ) {
      alert("Error : You are using forbidden IP address!");
      e.value = "";
   }
}

function ValidateIp(s_ip) {
    var re = /^\d+\.\d+\.\d+\.\d+/;
    if (re.test(s_ip))
        return true;
    else
        return false;
}

/*common function*/
function scrollToTop(scrollDuration) {
    var scrollStep = -window.scrollY / (scrollDuration / 10),
        scrollInterval = setInterval(function(){
        if ( window.scrollY != 0 ) {
            window.scrollBy( 0, scrollStep );
        }
        else clearInterval(scrollInterval);
    },10);
}
function show(element) {
    if(element.style.display == 'none')
        element.style.display = 'block';
}
function hide(element) {
    if(element.style.display == 'block')
        element.style.display = 'none';
}

function animation_show(element, duration) {
    var getHeight = function () {
        element.style.display = 'block';
        var height = element.scrollHeight + 'px';
        element.style.display = '';
        return height;
    };
    var height = getHeight();
    element.style.height = height;
    window.setTimeout(function () {
        element.style.height = '';
    }, duration);

}

function animation_hide(element, duration) {
    element.style.height = element.scrollHeight + 'px';
    window.setTimeout(function () {
        element.style.height = '0';
    }, duration);
}

function closeWinFn(element) {
    scrollToTop(10);
    var win = element.parentNode.parentNode;
    var bg =  document.getElementById('blackBackground');
    if(bg == null)
        bg = document.getElementsByClassName('blackBackground')[0];
    hide(win);
    hide(bg);
}

function closeWindow() {
    scrollToTop(10);
    var win = this.parentNode.parentNode;
    var bg =  document.getElementById('blackBackground');
    if(bg == null)
        bg = document.getElementsByClassName('blackBackground')[0];
    hide(win);
    hide(bg);
}

document.addEventListener("DOMContentLoaded", function() {
    var win = document.getElementById('closeWindow');
    if(win) {
        win.addEventListener('click', closeWindow, false);
    }

    var win1 = document.getElementById('closeWindow01');
    if(win1) {
        win1.addEventListener('click', closeWindow, false);
    }
    enableMobileBtn(false);
});

function isDomElement(element) {
    if (typeof element == 'object' && element.nodeType != undefined) {
        return true;
    } else {
        return false;
    }
}

function isElementHasClass(element, className) {
    //some old web browser not support classList (ex: IE9), use className instead of classList
    if (element.className.split(" ").indexOf(className) >= 0) {
        return true;
    } else {
        return false;
    }
}

function checkCancelBtnToReload(cancelBtn_obj) {
    if (  isElementHasClass(cancelBtn_obj, "buttonStyle02") &&
        ! isElementHasClass(cancelBtn_obj, "buttonStyle05") &&
        ! isElementHasClass(cancelBtn_obj, "disabled") ) {
        gUnloadByCancelBtnClicked = true;
        location.reload();
    }
    else if ( isElementHasClass(cancelBtn_obj, "m_R_button") )
    {
        gUnloadByCancelBtnClicked = true;
        location.reload();
    }
}

function addAttrToHostname(font){
    var hostnamelist=document.querySelectorAll(".hostname");
    var temp_canvas = document.createElement('canvas');
    var ctx = temp_canvas.getContext("2d");
    ctx.font = font;
    for(var i=0;i<hostnamelist.length;i++)
    {
        var c_hostname_width = ctx.measureText(hostnamelist[i].innerText).width;
        if(c_hostname_width > hostnamelist[i].clientWidth){
            hostnamelist[i].style.overflow="hidden";
            hostnamelist[i].setAttribute("data-name", hostnamelist[i].innerText);
        }
        else{
            if(!hostnamelist[i].classList.contains("no-after"))
               hostnamelist[i].className += " no-after";
        }
    }
}

function addAttrToInterface(font){
    var hostnamelist=document.querySelectorAll(".interface");
    var temp_canvas = document.createElement('canvas');
    var ctx = temp_canvas.getContext("2d");
    ctx.font = font;
    for(var i=0;i<hostnamelist.length;i++)
    {
        var c_hostname_width = ctx.measureText(hostnamelist[i].innerText).width;
        if(c_hostname_width > hostnamelist[i].clientWidth){
            hostnamelist[i].style.overflow="hidden";
            hostnamelist[i].setAttribute("data-name", hostnamelist[i].innerText);
        }
        else{
            if(!hostnamelist[i].classList.contains("no-after"))
               hostnamelist[i].className += " no-after";
        }
    }
}

function enableMobileBtn(enable){
    if(enable === undefined) {
        enable = true;
     }

    if (typeof window.orientation !== 'undefined') {
        var m_L_btn=document.querySelector(".m_buttonBox > .m_L_button[data-button='m_btn']");
        var m_R_btn=document.querySelector(".m_buttonBox > .m_R_button[data-button='m_btn']");
        if( !m_L_btn|| !m_R_btn)
            return;

        // Remove buttonStyle for mobile
        if(m_L_btn.className.indexOf("buttonStyle05") > 0){
            m_L_btn.className=m_L_btn.className.replace(/buttonStyle05/i,"").trim();
        }
        else if(m_L_btn.className.indexOf("buttonStyle01") > 0){
            m_L_btn.className=m_L_btn.className.replace(/buttonStyle01/i,"").trim();
        }

        if(m_R_btn.className.indexOf("buttonStyle05") > 0){
            m_R_btn.className=m_R_btn.className.replace(/buttonStyle05/i,"").trim();
        }
        else if(m_R_btn.className.indexOf("buttonStyle02") > 0){
            m_R_btn.className=m_R_btn.className.replace(/buttonStyle02/i,"").trim();
        }

        if(enable === true){
            if(m_L_btn.className.indexOf("disabled") > 0){
                m_L_btn.className=m_L_btn.className.replace(/disabled/i,"").trim();
            }
            if(m_R_btn.className.indexOf("disabled") > 0){
                m_R_btn.className=m_R_btn.className.replace(/disabled/i,"").trim();
            }
        }
        else{
            if(m_L_btn.hasAttribute("disabled")===true)
                m_L_btn.removeAttribute("disabled");

            if(m_R_btn.hasAttribute("disabled")===true)
                m_R_btn.removeAttribute("disabled");

            if(m_L_btn.className.indexOf("disabled") === -1){
                m_L_btn.className+=" disabled";
            }
            if(m_R_btn.className.indexOf("disabled") === -1){
                m_R_btn.className+=" disabled";
            }
        }
    }
}

//Fixed footer bar offset when screen resolution is too low but not mobile view.
window.onscroll = function(){
    if(document.querySelector(".PC_buttonBox2"))
    {
        document.querySelector(".PC_buttonBox2").style.left = "";
        if(document.documentElement.scrollLeft > 0)
        {
            if(document.getElementById("center_Cbox_up")){
                var cont_left=document.getElementById("center_Cbox_up").getBoundingClientRect().left;
                document.querySelector(".PC_buttonBox2").style.left = cont_left+"px";
            }
        }
    }
}

//Create loading page
function runLoadingPage() {
    var loadingTemplete = '<div class="desc">Loading...</div>\
    <div class="progress">\
        <div class="bar"></div>\
        <div class="text">0%</span>\
        </div>\
    </div>';

    var win = document.createElement('div');
    win.className = "progressbar";
    win.innerHTML = loadingTemplete
    document.querySelector('body').insertAdjacentElement('beforeend', win)
}

function progressRun(time, redirectPath, srcDesc) {
    var el = document.querySelector('.bar');
    var text = document.querySelector('.text');
    var desc = document.querySelector('.desc');
    if (!el || !text) return false;
    var range = Math.floor(1000 / time);
    var width = 0;
    var id = setInterval(frame, 1000);
    function frame() {
        if (width >= 1000) {
            clearInterval(id);
            location.href = redirectPath;
        } else {
            width += range;
            if (width > 1000) width = 1000;
            el.style.width = Math.floor(width / 10) + '%';
            text.innerText = Math.floor(width / 10) + '%';
        }
    }
    desc.innerText = srcDesc;
}

