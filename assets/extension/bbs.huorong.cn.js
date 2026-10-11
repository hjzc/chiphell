(function(window) {
    var isdk =BJA_isDarkMode();
    var __sb_vshandleTimer=-1;
    function _sb_timerhandle(){
       try{
            var s= document.querySelectorAll("div#wp>style:not([mfd*=_check_])");
            if(s){
                for(var i=0;i< s.length; i++){
                    var it = s[i];
                    var tx = BJA_ele_getText(it);
                    if(tx){
                        var idx = tx.indexOf('.fl{ background:#f8f8f8 !important;}');
                        if(idx>-1){
                            var r = tx.replace('.fl{ background:#f8f8f8 !important;}','.fl{ background:#111 !important;}');
                            it.textContent = r;
                            it.setAttribute('mfd', '_check_');
                            clearInterval(__sb_vshandleTimer);
                            __sb_vshandleTimer = -1;
                        }
                    }
                }
            }
            
       }catch(e){}
    }
    if(isdk && (document.URL =="https://bbs.huorong.cn/forum.php" || 
        document.URL =="https://bbs.huorong.cn/" ||
        document.URL.startsWith("https://bbs.huorong.cn/forum.php?gid="))
    ){
        _sb_timerhandle();
        __sb_vshandleTimer = setInterval(_sb_timerhandle, 1500);     
    }
    
})(window);