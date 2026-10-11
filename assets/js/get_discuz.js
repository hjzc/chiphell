function _get_discuz_site_info (){
    function vMatch(string, regex, capture) {
        var rc = null;
        try {
            var matches = string.match(regex);
            if ((matches != null) && (matches.length > capture)) {
                rc = matches[capture];
            }
        } catch (e) {
            rc = null;
        }
        return rc;
    }
    function vGetPageCharset() {
        var r=null;
        try{
            if (document.characterSet && (document.characterSet.length>2)) {
                r= document.characterSet;
            }
            else{
                const metaCharset = document.querySelector('meta[charset]');
                if (metaCharset) {
                    var v =metaCharset.getAttribute('charset');
                    if (v && (v.length>2)){
                        r=v;
                    }
                }
            }
            if(r==null){
                const metaContent = document.querySelector('meta[http-equiv="Content-Type"]');
                if (metaContent) {
                    const content = metaContent.getAttribute('content');
                    const match = content.match(/charset=([^;]+)/i);
                    if (match) {
                        var v= match[1].trim();
                        if (v && (v.length>2)){
                            r=v;
                        }
                    }
                }
            }
            r=r!=null?r.toLowerCase():null;
        }catch(e){}
        return r;
    }
    var r = 0;
    var curl = document.URL;
    var chost='';
    var cpath='';
    var corigin='';
    if(curl!=null){
        var uc = new URL(curl);
        chost=uc.host;
        cpath=uc.pathname;
        corigin=uc.origin;
    }
    var stt ='';
    var cd='';
    var cookiedm='';
    var cp='';
    var uid='';
    var host ='';
    var scm = '0';
    var isdiz = '0';
    var tcharset ='';
    try{
        var n = document.querySelector("head meta[name='apple-mobile-web-app-title']");
        if(n==null){
            n= document.querySelector("head meta[name='application-name']");
        }
        if(n==null){
            n= document.querySelector("head meta[name='msapplication-tooltip']");
        }
        if(n!=null){
            stt = n.content.trim();
            if(stt.indexOf(' - ')>=0){
                var rt= stt.split(' - ')[0];
                if(rt.length>=2){
                    stt =rt;
                }
            }
        }
    }catch(e){}
    var baseuri='';
    try{baseuri =  document.baseURI;}catch(e){}
    var su='';
    try{su =  SITEURL;}catch(e){}
    try{
        var u = new URL(su!=''?su:baseuri);
        host =u.host+'' + u.pathname;
        if(host.endsWith('/')){
            host= host.slice(0, host.length-1);
        }
        var protocolStr =u.protocol.toLowerCase();
        scm=(protocolStr=='https:')?'2':( (protocolStr=='http:')?'1':'0');
    }catch(e){}
    try{
        cookiedm=cookiedomain;
        cd=cookiedomain;
        if(cookiedomain.startsWith('.')){
            cd = cookiedomain.slice(1);
        }
        cp=cookiepre;
        uid=discuz_uid;
        isdiz ='1';
        tcharset=charset;
        if(stt==''){
            stt= vMatch(document.title, "-([^-\s]+论坛)",1);
        }
    }catch(e){
        tcharset=vGetPageCharset();
    }
    try{
        r={
            'host':host,
            'title':stt,
            'source':'2',
            'scheme':scm,
            'type':isdiz,
            'domain':cd,
            'cookiedomain':cookiedm,
            'cookiepre': cp,
            'uid':uid,
            'curl':curl,
            'chost':chost,
            'corigin':corigin,
            'cpath':cpath,
            'charset':tcharset,
        };
    }catch(e){r =-1;}
    return r;
}
_get_discuz_site_info ();