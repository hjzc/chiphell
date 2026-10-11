(function(window) {
    function CPPromptObj() {
        this.uname =null;
        this.uid =null;
        this.uspace =null;
        this.isLogined = false;
        this.isSite = false;
        this.isSiteForum = false;
        this.isSitePromptForum = false;
        this.prompt_msg_count =0;
        this.prompt_msg_none ='https://www.chiphell.com/home.php?mod=space&do=notice';
        this.prompt_pc_enable = false;
        this.prompt_pc_sels = ['#myprompt'];
        this.prompt_sels = ['#avatar_pop > div.apop_con > div.ava_menu > ul > li:nth-child(6) > a > span'];
        this.prompt_new_reply_msg_enable =false;
        this.prompt_new_reply_msg_state =false;
        this.prompt_new_reply_sels =['#forumnewshow a'];
        this.vsprompt_msg_timer=-1;
    }
    try{
        if (!window.jszPromptMsg) {
            window.jszPromptMsg = new CPPromptObj();
        }
    }catch(e){
    }
    function _bja_var_handle_user_id(){
        var discuz_uid=null;
        try{
            discuz_uid=window.discuz_uid;
            if(BJA_isString(discuz_uid)){
                discuz_uid=discuz_uid.trim();
                if(discuz_uid.length<=0 || discuz_uid=='0'){
                    discuz_uid =null;
                }
            }
        }catch(e){discuz_uid=null;}
        return discuz_uid;
    }
    function _bja_var_handle_user_logined(){
        return _bja_var_handle_user_id()!=null;
    }
    function _bja_var_handle_user_space(){
        var r=null;
        var discuz_uid=_bja_var_handle_user_id();
        try{
            if(discuz_uid!=null){
                r= 'https://www.chiphell.com/space-uid-'+discuz_uid+'.html'
            }
        }catch(e){

        }
        return discuz_uid;
    }

    function _bja_var_handle_user_name(){
        var discuz_name = null;
        var discuz_uid=_bja_var_handle_user_id();
        if(discuz_uid!=null){
            var rgs = ['#avatar_pop div.ava_user a','#hd #um .vwmy a'];
            for(var i = 0; i<rgs.length; i++){
                var node =document.querySelector(rgs[i]);
                if(node!=null){
                    var dname=node.textContent;
                    if(BJA_isString(dname)){
                        dname = dname.trim();
                        if(dname.length>0){
                            discuz_name=dname;
                            break;
                        }
                    }
                }
            }
        }
        return discuz_name;
    }

    function _bja_handle_user_init(){
        window.jszPromptMsg.isSite = isSite(null); 
        window.jszPromptMsg.isSiteForum = isSiteForum(true); 
        window.jszPromptMsg.isSitePromptForum = isSiteForum(false);
        window.jszPromptMsg.uname = _bja_var_handle_user_name();
        window.jszPromptMsg.uid = _bja_var_handle_user_id();
        window.jszPromptMsg.uspace = _bja_var_handle_user_space();
        window.jszPromptMsg.isLogined = window.jszPromptMsg.uid!=null;
    }

    function _bja_handle_user_reminder_msg(){
        var r =false;
        var count = 0;
        if(window.jszPromptMsg.isSite && window.jszPromptMsg.isLogined ){
            var rlist = window.jszPromptMsg.prompt_sels;
            for(var i = 0; i<rlist.length; i++){
                var node =document.querySelector(rlist[i]);
                if(node){
                    //https://www.chiphell.com/home.php?mod=space&do=notice
                    var alink= BJA_ele_getStringAttribute(anode,"href");
                    if(alink!=null){
                       var userNoticeUrl= BJA_getEntireUrl(alink,BJA_GetURL());
                       if(userNoticeUrl!=null){
                            window.jszPromptMsg.prompt_msg_none =userNoticeUrl;
                       }
                    }
                    var msg = node.textContent.trim();
                    if(msg!=null && (msg.indexOf('有新提醒')>=0) ){
                        count = 1;
                    }else{
                        count=0;
                    }
                    break;
                }else{

                }
            }

            rlist = window.jszPromptMsg.prompt_pc_enable? window.jszPromptMsg.prompt_pc_sels:[];
            for(var i = 0; i<rlist.length; i++){
                var node =document.querySelector(rlist[i]);
                if(node){
                    //https://www.chiphell.com/home.php?mod=space&do=notice
                    var alink= BJA_ele_getStringAttribute(anode,"href");
                    if(alink!=null){
                       var userNoticeUrl= BJA_getEntireUrl(alink,BJA_GetURL());
                       if(userNoticeUrl!=null){
                            window.jszPromptMsg.prompt_msg_none =userNoticeUrl;
                       }
                    }
                    var msg = node.textContent.trim();
                    var ct = BJA_stringByMatch(msg,'[(](\\d+)[)]',1);
                    if(ct!=null && ct.length>0){
                       var ct = BJA_parseInt(ct);
                       if(ct !=null){
                        count= ct>0?ct:0;
                       }
                    }else{
                        count=0;
                    }
                    break;
                }
            }
        }
        if(count!= window.jszPromptMsg.prompt_msg_count){
            window.jszPromptMsg.prompt_msg_count =count;
            r= true;
        }
        return r;
    }

    function _bja_handle_user_current_forum_new_reply_msg(){
        var r =false;
        if(window.jszPromptMsg.prompt_new_reply_msg_enable &&  window.jszPromptMsg.isSite  && window.jszPromptMsg.isSitePromptForum ){
            var rlist = window.jszPromptMsg.prompt_new_reply_sels;
            var v =false;
            for(var i = 0; i<rlist.length; i++){
                var node =document.querySelector(rlist[i]);
                if(node){
                    v =true;
                    break;
                }
            }
            if(v!=window.jszPromptMsg.prompt_new_reply_msg_state){
                window.jszPromptMsg.prompt_new_reply_msg_state =v;
                r =true;
            }
        }
        return r;
    }

    function _bja_handle_user_prompt_to_notification(){
        if(window.jszPromptMsg.prompt_msg_count <=0){
            return;
        }
        var testNotification = new Notification(
            'Notification Title', 
            {
            body: 'Notification Body!', 
            icon: 'https://picsum.photos/150?random=' + Date.now(),
            vibrate: [200, 100, 200]}
        );
        testNotification.addEventListener('show', function(event) {
            console.log('show log');
        });
        testNotification.addEventListener('click', function(event) {
        
        });
        testNotification.addEventListener('close', function(event) {
            console.log('close log');
        });
    }

    function  _bja_safeWebPromptHandleMessager(){
        if(window.jszPromptMsg.vsprompt_msg_timer >=0) {
            return;
        }
        function _timerhandle(){
            var r =0;
            try{_bja_handle_user_init();}catch(e){}
            try{if(_bja_handle_user_reminder_msg()){r++;}}catch(e){}
            try{if(_bja_handle_user_current_forum_new_reply_msg()){r++;}}catch(e){}
            try{if(r>0){_bja_handle_user_prompt_to_notification();}}catch(e){}

        }
        _timerhandle();
        window.jszPromptMsg.vsprompt_msg_timer = setInterval(_timerhandle, 2000);
    }
    _bja_safeWebPromptHandleMessager();


})(window);