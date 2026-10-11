function BJAJSZGlobalVariable() {
    this.blacklist = new Array();
    this.blacklistMode=-1;
    this.appThemeMode=-1;
    this.sysThemeDarkMode=-1;
    this.uatype = 0;
    this.themeInit = false;
    this.themedoing = false;
    this.extensionJsDoing = false;
    this.themeUpdateCount = 0;
    this.themeUpdatedCount = 0;
    this.images = new Array();
    this.addImageClickEvent = true;
    this.imageCount = 0;
    this.lazyImageCount = 0;
    this.lazyImageShowIndex = 0;
    this.lazyImgAttrFilters = [];
    this.imageMode = -1;
    this.imgAttrs = [];
    this.imgUrlFilters = [];
    this.imgContentSels = [];
    this.addImageContentSels = ['img'];
    this.autoImageGallery = true;
    this.domReady = false;
    this.handleBlacklistCount = 0;
    this.callBackList = new Array();
    this.callBackMap = new Map();
    this.zcsAddEventListenerCount = 0;
    this.lazyThrottleFunc = null;
    this.lazyShowThrottleFunc = null;
    this.observer = null;
    this.observerObjects= [];
    this.kv = new Map();
    this.siteConfig=null;
    this.isImageDocument =null,
    this.isImageURI =null
}
function BJA_ObserverObject(e,t,fn,dt,imd,attrs) {
    this.e=e;
    this.t=t;
    this.fn=fn;
    this.attrs = attrs;
    this.run =imd? fn: BJA_run_debounce(this.fn, dt, imd);
}
BJA_ObserverObject.prototype.oid = function() {
    var l= this.attrs!=null?this.attrs.join('_'):'';
    return ''+this.t+'_'+l;
};
const varAttr_addclickevent ='_addclickevent';
const varAttr_addlazy ='addlazy';
const varAttr_imageMode ='imageMode';
const varAttr_onclick = 'onclick';
const varAttr_bkonclick = 'bk_onclick';
const varAttr_zjsfilter ='_zjsfilter';
const varMap_blacklistModeLast ='blacklistMode';

function _jszGVarsKV(kvObject,keys=[]){
    var r=null;
    try{
        if(keys!=null && keys.length>0){
            r = kvObject;
            for(var i=0; i< keys.length; i++){
                var key = keys[i];
                r = BJA_VarsKVFromArrayOrMap(r,key);
                if( r==null){
                    break;
                }
            }
        }
    }catch(e){r=null;};
    return r;
}
function _jszGVarsKVMap(){
    var r=null;
    try{r=_jszGVarsKV(window.jszGVars.kv,['map']);}catch(e){r=null;};
    return r;
}
function _jszGVarsKVMapForKey(key,defVal=null){
    var rs = defVal;
    var r = _jszGVarsKVMap();
    if(key!=null && r!=null && r.has(key)){
        rs= r.get(key);
    }
    return rs;
}
function _jszGVarsKVMapSet(key=null,value=null){
    var ret=false;
    if(key!=null){
        var r= _jszGVarsKVMap();
        if(r!=null){
            if(value!=null){
                r.set(key,value);
            }
            else{
               r.delete(key);
            }
            ret=true;
        }
    }
    return ret;
}
function _bja_sdk_initVariable(){}
function _app_sub_ov_initVariable(){}
function _app_sub_ov_initFunc(){}
function _app_sub_ov_headOrBodyReadyFunc(){}
function _app_sub_ov_updateParam(list){}
function _app_sub_ov_currentSiteType(){return 0;}
function _app_sub_ov_ThemeEncodeCss(isMobile){return "";}
function _app_sub_ov_ThemeExtensionEncodeCss(isMobile){return "";}
function _app_sub_ov_SiteExtensionJS(){return"";}
function _app_sub_ov_ThemeInstalled(isMobile,isDark){}
function _app_sub_ov_lazyImageUrl(){return '';}
function _app_sub_ov_ImageClick(e,u){_app_sub_ov_sendMsgToApp([{'tapImage': u!=null?u:'' }]);}
function _app_sub_ov_image_handler(img,imgUrl){}
function _app_sub_ov_imgContentSels(){return [];}
function _app_sub_ov_imgNodes(){return [];};
function _app_sub_ov_sendMsgToApp(args){
    var r = null;
    try{
        r=window.flutter_inappwebview.callHandler('__jszHandler__', ...args);
    }catch (e){
    }
    return r;
}
function _app_sub_ov_sendMsgToAppAndResult(args,resultFunc){
    try{
        window.flutter_inappwebview.callHandler('__jszHandler__', ...args).then(function(result){
            resultFunc(result);
        });
    }catch (e){

    }
}

function _bja_private_OnScrollFunc(w,e){
    try{window.jszGVars.lazyShowThrottleFunc();}catch(e){}
}

function _bja_private_safeInitVars() {
    try {
        if (!window.jszGVars) {
            window.jszGVars = new BJAJSZGlobalVariable();
            window.jszGVars.kv.set('map',new Map());
            try{_bja_sdk_initVariable();}catch(e){}
            try{_app_sub_ov_initVariable();}catch(e){}
        }
    } catch (e) {}
}

function _bja_private_headOrBodyReadyFunc(){
    if(window.jszGVars.lazyShowThrottleFunc==null)
    {
        window.jszGVars.lazyShowThrottleFunc=BJA_run_throttle(_bja_private_ImageLazyloadShow, 500);
    }
    window.addEventListener('scroll', function(w,e) {
        try{_bja_private_OnScrollFunc(w,e);}catch(e){}
        if (typeof _app_sub_def_OnScrollFunc === 'function') {
            try{_app_sub_def_OnScrollFunc(w,e);}catch(e){}
        }
    }); 
}

function  _bja_private_domReadyFunc(type){
    if( !window.jszGVars.domReady){
        if(BJA_DocumentHead()!=null || BJA_DocumentBody()!=null){
            window.jszGVars.domReady=true;
            try{_bja_private_headOrBodyReadyFunc();}catch(e){}
            try{_app_sub_ov_headOrBodyReadyFunc();}catch(e){}
            if (typeof _app_sub_def_headOrBodyReadyFunc === 'function') {
                try{_app_sub_def_headOrBodyReadyFunc();}catch(e){}
            }
        }
    }
    else{
    }
    if(window.jszGVars.imageMode >-1){
        if(window.jszGVars.lazyThrottleFunc==null)
        {
            window.jszGVars.lazyThrottleFunc=BJA_run_throttle(_bja_private_setLazyLoadingImages, 400);
        }
        try{window.jszGVars.lazyThrottleFunc();}catch(e){}
    }
    if (typeof _app_sub_def_domReadyFunc === 'function') {
        try{_app_sub_def_domReadyFunc(type);}catch(e){}
    }
}

function _bja_safeListenerDOMContentLoaded(){
    if (!window) {
        return false;
    }
    try{
        if (window.document ==null) {
            return false;
        }
    }catch (e){
        return false;
    }
    _bja_private_safeInitVars();
    try{
        if(window.jszGVars.zcsAddEventListenerCount>0){
            return true;
        }
    }catch (e){
        return false;
    }
    if(document.readyState === "complete"){
        window.jszGVars.zcsAddEventListenerCount +=1;
        _bja_private_domReadyFunc(0);
    }else {
        try{
            window.document.addEventListener('DOMContentLoaded', function() {
                _bja_private_domReadyFunc(1);
            });
            window.jszGVars.zcsAddEventListenerCount +=1;
        }catch (ex) {
        
        }
        try{
            document.onreadystatechange = function () {
                if (document.readyState === "complete") {
                    _bja_private_domReadyFunc(2);
                }
            };
            window.jszGVars.zcsAddEventListenerCount +=1;
        }
        catch (ex){
         
        }
        try{
            window.addEventListener('DOMContentLoaded', function() {
                _bja_private_domReadyFunc(3);
            });
            window.jszGVars.zcsAddEventListenerCount+=1;
        }catch (ex) {
      
        }
    }
    return true;
}
var __vscaddtimerid=-1;
function  _bja_safeInitSDK(){
    function timerhandle(){
        if(_bja_safeListenerDOMContentLoaded() && (__vscaddtimerid != -1) ){
            clearInterval(__vscaddtimerid);
            __vscaddtimerid = -1;
        }
    }
    timerhandle();
    var c = 0;
    try{
        c = window.jszGVars.zcsAddEventListenerCount;
    }catch(e){}
    if(c==0){
        __vscaddtimerid = setInterval(timerhandle, 300);
    }
    try{_app_sub_ov_initFunc();}catch(e){}
    if (typeof _app_sub_def_initFunc === 'function') {
        try{_app_sub_def_initFunc();}catch(e){}
    }
}

function BJA_asynCall(fn,delay) {
  return new Promise((resolve, reject) => {
    if(delay <=0){
        try{
            var r = fn();
            resolve(r);
        }catch(e){
            reject(e);
        }
    }else{
        setTimeout(() => {
            try{
                var r= fn();
                resolve(r);
            }catch(e){
                reject(e);
            }   
        }, 1000);
    }
  });
}
function BJA_getEntireUrl(url, weburl) {
    var ret = null;
    if (url == null) {
        return ret;
    }
    if (url.toLowerCase().indexOf('http') == 0) {
        return url;
    }
    if (weburl != null) {
        try {
            var wURL = new URL(url, weburl);
            if (wURL != null) {
                ret = wURL.href;
            }
        } catch (e) { }
    }
    return ret;
}
function BJA_for(list,fn) {
    if(list==null||BJA_isArray(list)==false){
        try{
            fn(-1,-1,null);
        }catch(e){
        }
    }
    else{
        var lens =list.length;
        if(lens>0){
            for (var i = 0; i < list.length; i++) {
                try{
                    var r =fn(lens,i,list[i]);
                    if(r){
                        break;
                    }
                }catch(e){
                }
            }
        }
        else{
            try{
                fn(0,-1,null);
                return;
            }catch(e){
            }
        }
    }
}
function BJA_GetDomain() {
    var r = null;
    try {
        r = window.location.host;
    } catch (e) { }
    if (!r) {
        try {
            r = document.domain;
        } catch (e) { }
    }
    if (!r) {
        try {
            var url =new URL( document.URL);
            r =url.host;
        } catch (e) { }
    }
    return r;
}
function BJA_GetURL() {
    var turl = null;
    try {
        turl = window.location.href;
    } catch (e) { }
    if (!turl) {
        try {
            turl = self.location.href;
        } catch (e) { }
    }
    if (!turl) {
        try {
            turl = document.URL;
        } catch (e) { }
    }
    return turl;
}
function BJA_getAbsUrl(url) {
    var ret = null;
    if (url != null) {
        var weburl = BJA_GetURL();
        if (weburl != null) {
            try {
                var wURL = new URL(url, weburl);
                if (wURL != null) {
                    ret = wURL.href;
                }
            } catch (e) { }
        }
    }
    return ret;
}
function BJA_URI(url) {
    var ret = null;
    try {
        var weburl = BJA_GetURL();
        if (url != null) {
            ret = new URL(url, weburl);
        }else{
            ret = new URL(weburl);
        }
    } catch (e) { }
    return ret;
}
function BJA_URI_host(url){
    var r = BJA_URI(url);
    return r!=null?r.host:null;
}
function BJA_URI_hostname(url){
    var r = BJA_URI(url);
    return r!=null?r.hostname:null;
}
function BJA_URI_sheme(url){
    var r = BJA_URI(url);
    return r!=null?r.protocol:null;
}
function BJA_URI_origin(url){
    var r = BJA_URI(url);
    return r!=null?r.origin:null; 
}
function BJA_URI_pathname(url){
    var r = BJA_URI(url);
    return r!=null?r.pathname:null;
}
function BJA_URI_search(url){
    var r = BJA_URI(url);
    return r!=null?r.search:null; 
}
function BJA_URI_searchParams(url){
    var r = BJA_URI(url);
    return r!=null?r.searchParams:null;
}
function BJA_DocumentBody() {
    var bd = document.body;
    if (!bd) {
        var bodys = document.getElementsByTagName("body");
        if (!bodys || bodys.length <= 0) {
            bd = false;
        } else {
            bd = bodys[0];
        }
    }
    return bd;
}
function BJA_DocumentHead() {
    var header = false;
    var heads = [];
    try {
        heads = document.getElementsByTagName('head')
    } catch (ex) {
        heads = [];
    }
    if (heads && heads.length > 0) {
        header = heads[0];
    }
    return header;
}
function BJA_getPageCharset() {
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


function BJA_CreateStyleNode(css) {
    var styleElem = false;
    if (css) {
        try {
            var s = document.createElement('style');
            s.setAttribute('type', 'text/css');
            s.innerHTML = "";
            s.appendChild(document.createTextNode(css));
            if (s) {
                styleElem = s;
            }
        } catch (e) {
            styleElem = false;
        }
    }
    return styleElem;
}
function BJA_AddStyle(element, css) {
    var styleElem = false;
    if (element) {
        styleElem = BJA_CreateStyleNode(css);
        if (styleElem) {
            try {
                styleElem = element.appendChild(styleElem);
                if (!styleElem) {
                    styleElem = false;
                }
            } catch (e) {
                styleElem = false;
            }
        }
    }
    return styleElem;
}
function BJA_AddStyleAtHead(css) {
    var header = BJA_DocumentHead();
    if (header) {
        ret = BJA_AddStyle(header, css);
    }
    return ret;
}
function BJA_ele_getText(el,trim=true) {
    var r = null;
    try {
        if (el) {
            r = el.textContent;
            r =trim? r.trim():r;
        }
    } catch (e) {
        r = null;
    }
    return r
}
function BJA_ele_removeAttribute(el, name) {
    var r = 0;
    try {
        if (el && name) {
            el.removeAttribute(name);
            r = 1;
        }
    } catch (e) {
        r = 0;
    }
    return r;
}
function BJA_ele_setStringAttribute(el, name, strValue) {
    var r = 0;
    try {
        if (el && name && strValue) {
            el.setAttribute(name, strValue);
            r = 1;
        }
    } catch (e) {
        r = 0;
    }
    return r;
}
function BJA_ele_setIntAttribute(el, name, intvalue) {
    var r = 0;
    try {
        if (el && name) {
            var vv = "" + intvalue;
            el.setAttribute(name, vv);
            r = 1;
        }
    } catch (e) {
        r = 0;
    }
    return r;
}
function BJA_ele_hasAttribute(el, name) {
    var r = false;
    if (el && name) {
        r = el.hasAttribute(name);
    }
    return r;
}
function BJA_ele_getStringAttribute(el, name) {
    var r = null;
    try {
        if (el && name) {
            if (BJA_ele_hasAttribute(el, name)) {
                r = el.getAttribute(name);
                if (r && BJA_isString(r)) { } else {
                    r = null;
                }
            }
        }
    } catch (e) {
        r = null;
    }
    return r
}
function BJA_ele_getIntAttribute(el, name) {
    var r = BJA_ele_getStringAttribute(el, name);
    if (r && (r != null)) {
        r = BJA_parseInt(r);
        if (r === false) {
            r = null;
        }
    } else {
        r = null;
    }
    return r;
}
function BJA_nodeForXPath(xmlDom, xpath) {
    var node = null;
    var dc = xmlDom;
    var rn = xmlDom;
    if (!xmlDom) {
        dc =document;
        rn=document;
    }
    else if(typeof xmlDom.evaluate == 'undefined'){
        dc = document;
    }
    if (typeof dc.evaluate != 'undefined') {
        var result = dc.evaluate(xpath, rn, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
        if (result != null) {
            node = result.singleNodeValue;
        }
    }
    return node;
}
function BJA_nodesForXPath(xmlDom, xpath) {
    var nodes = [];
    if (!xpath || (typeof xpath == 'undefined') || xpath == null) {
        return nodes;
    }
    var dc = xmlDom;
    var rn = xmlDom;
    if (!xmlDom) {
        dc =document;
        rn=document;
    }
    else if(typeof xmlDom.evaluate == 'undefined'){
        dc = document;
    }
    if (typeof dc.evaluate != 'undefined') {
        var result = dc.evaluate(xpath, rn, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
        if (result != null) {
            var node = null;
            while ((node = result.iterateNext()) != null) {
                nodes.push(node);
            }
        }
    }
    return nodes;
}
function BJA_xPath(xmlDom, xpath,all=true) {
    var r =null;
    try{r=all?BJA_nodesForXPath(xmlDom,xpath):BJA_nodeForXPath(xmlDom,xpath);}catch(e){}
    return r;
}
function BJA_nodeDocumentForXPath(xpath) {
    return BJA_nodeForXPath(false, xpath);
}
function BJA_nodesDocumentForXPath(xpath) {
    return BJA_nodesForXPath(false, xpath);
}
function BJA_indexOfArray(array, val) {
    for (var i = 0; i < array.length; i++) {
        if (array[i] == val) {
            return i;
        }
    }
    return - 1;
}
function BJA_removeObjectInArray(array, val) {
    var index = BJA_indexOfArray(array, val);
    if (index > -1) {
        array.splice(index, 1);
    }
}

function BJA_ArrayDeduplication(arr) {
    return arr.reduce((acc, current) => {
        if (acc.indexOf(current) === -1) {
            acc.push(current);
        }
        return acc;
    }, []);
}

function BJA_isJSON(str) {
    if (str && (typeof str == 'string')) {
        try {
            if (typeof JSON.parse(str) == "object") {
                return true;
            }
        } catch (e) { }
    }
    return false;
}
function BJA_getJSON(str) {
    if (str && (typeof str == 'string')) {
        try {
            var ret = JSON.parse(str);
            if (typeof ret == "object") {
                return ret;
            }
        } catch (e) { }
    } else if (typeof str == "object") {
        return str;
    }
    return false;
}
function BJA_objToJSONString(jsObj) {
    var ret = null;
    try {
        ret = JSON.stringify(jsObj)
    } catch (e) { }
    return ret;
}
function BJA_isArray(obj) {
    var ret = false;
    try {
        if (Array.isArray(obj)) {
            ret = true;
        } else { }
    } catch (e) { }
    return ret;
}
function BJA_isNode(obj) {
    var ret = false;
    try {
        if (obj instanceof Node) {
            ret = true;
        } else { }
    } catch (e) { }
    return ret;
}
function BJA_isNodeList(obj) {
    var ret = false;
    try {
        if (obj instanceof NodeList) {
            ret = true;
        } else { }
    } catch (e) { }
    return ret;
}

function BJA_isHTMLCollection(obj) {
    var ret = false;
    try {
        if (obj instanceof HTMLCollection) {
            ret = true;
        } else { }
    } catch (e) { }
    return ret;
}

function BJA_arrayFromNodeList(obj) {
    if(obj==null){
        return null;
    }
    else if(BJA_isNodeList(obj)){
        return Array.from(obj);
    }else if(BJA_isArray(obj)){
        return obj;
    }else if(BJA_isNode(obj)){
        return [obj];
    }
    else if(BJA_isHTMLCollection(obj)){
        return Array.from(obj);
    }
    return [];
}

function BJA_VarsKVFromArrayOrMap(v, key){
    var r = null;
    if(v !=null){
        if(BJA_isArray(v)){
            var res =[];
            for(var i=0; i<v.length;i++){
                var obj = v[i];
                var vs = BJA_VarsKVFromArrayOrMap(obj,key);
                if(vs!=null){
                    res.push(vs);
                }
            }
            if(res.length==0){
                res=null;
            }
            r=res;
        }else if(v instanceof Map){
            r= v.has(key)? v.get(key):null;
        }else if(v instanceof Object){
            r = v.hasOwnProperty(key)?v[key]:null;
        }
    }
    return r;
}

function BJA_isfunction(FunName) {
    var ret = false;
    try {
        if (typeof FunName === "function") {
            ret = true;
        } else { }
    } catch (e) { }
    return ret;
}
function BJA_isString(str) {
    var ret = false;
    try {
        if (typeof str === 'string') {
            ret = true;
        } else { }
    } catch (e) { }
    return ret;
}
function BJA_StringLength(str) {
    var len = 0;
    for (var i = 0; i < str.length; i++) {
        var c = str.charCodeAt(i);
        if ((c >= 0x0001 && c <= 0x007e) || (0xff60 <= c && c <= 0xff9f)) {
            len++;
        } else {
            len += 2;
        }
    }
    return len;
}
function BJA_invalidString(str) {
    if (!str || str == null || !BJA_isString(str)) {
        return true;
    }
    return BJA_StringLength(str) == 0;
}
function BJA_nonullString(str) {
    return !BJA_invalidString(str);
}
function BJA_isObject(obj) {
    var ret = false;
    try {
        if (typeof obj === "object") {
            ret = true;
        } else { }
    } catch (e) { }
    return ret;
}
function BJA_isOnlyObject(val) {
    return (val != null) && (typeof val === 'object') && (Array.isArray(val) === false);
}
function BJA_convertToSting(v, callback) {
    var rt = null;
    if (v === undefined) { } else if (typeof v === 'string') {
        rt = v;
    } else if (typeof v == "object") {
        if (callback) {
            rt = callback(v);
        }
    } else if (BJA_isArray(v)) {
        if (callback) {
            rt = callback(v);
        }
    } else {
        rt = v + "";
        if (rt.length == 0) {
            rt = null;
        }
    }
    return rt;
}
function BJA_ToSting(v) {
    var rt = null;
    try {
        rt = BJA_convertToSting(v, false);
    } catch (e) {
        rt = null;
    }
    return rt;
}
function BJA_parseInt(text) {
    var num = -1;
    var str = "";
    if (text != null) {
        try {
            str = "" + text;
        } catch (e) { }
        var tnum = false;
        try {
            tnum = str.replace(/[^0-9]/ig, "");
        } catch (e) {
            tnum = false;
        }
        try {
            if (tnum === false) {
                num = parseInt(str);
            } else {
                if (tnum != "") {
                    num = parseInt(tnum);
                }
            }
            if (num == 'NaN') {
                num = -1;
            }
        } catch (e) {
            num = -1;
        }
    }
    return num;
}
function BJA_string_trim(str) {
    var ret = null;
    if (str != null) {
        try {
            ret = str.replace(/(^\\s*)|(\\s*$)/g, "");
        } catch (e) { }
    }
    return ret;
}
function BJA_string_trim_ctl(str) {
    var ret = null;
    if (str != null) {
        try {
            ret = str.replace(/(^[\\s\\n\\t]+|[\\s\\n\\t]+$)/g, "");
        } catch (e) { }
    }
    return ret;
}
function BJA_string_trim_all(str) {
    var result = BJA_string_trim(str);
    if (result != null) {
        try {
            result = result.replace(/\\s/g, "");
        } catch (e) { }
    }
    return result;
}
function BJA_ArrayContains(array, obj) {
    var i = array.length;
    while (i--) {
        if (array[i] === obj) {
            return true;
        }
    }
    return false;
}
function BJA_getImages() {
    var objs = document.getElementsByTagName("img");
    var imgSrcList = new Array();
    var j = 0;
    for (var i = 0; i < objs.length; i++) {
        var srcStr = objs[i].src;
        if (srcStr) {
            imgSrcList[j] = srcStr;
            j++;
        }
    };
    return imgSrcList;
}
function BJA_getImageCount() {
    var objs = document.getElementsByTagName("img");
    var j = 0;
    for (var i = 0; i < objs.length; i++) {
        if (objs[i].src) {
            j++;;
        }
    };
    return j;
}

function BJA_querySelector(node, sel){
    var r =null;
    try{
        if(node!=null&& sel!=null && sel.length>0){
            r = node.querySelector(sel);
        }
    }catch(e){
    }
    return r;
}

function BJA_querySelectorAll(node, sel){
    var r =[];
    const addSelSplitStr = '|';
    try{
        if(node!=null&& sel!=null && sel.length>0){
            if(sel.indexOf(addSelSplitStr)>-1){
                var subsels= sel.split(addSelSplitStr);
                for(var i=0;i<subsels.length;i++){
                    var s = subsels[i].trim();
                    if(s.length>0){
                        var nds=BJA_arrayFromNodeList(node.querySelectorAll(s));
                        if(nds && nds.length>0){
                            for(var j=0;j<nds.length;j++)
                            {
                                var n = nds[j];
                                if(r.indexOf(n)<0){
                                    r.push(n);
                                }
                            }
                        }
                    }
                }
            }else if(sel.length>0){
                r=BJA_arrayFromNodeList(node.querySelectorAll(sel));
            }
        }
    }catch(e){
    }
    return r;
}

function BJA_query(node, sel,all=true){
    return all?BJA_querySelectorAll(node,sel):BJA_querySelector(node,sel);
}

function BJA_xpathQuerySelector(ele, xqs,all=true){
    const orSplitStr = '||';
    const xpathPrefix = 'X:';
    var r =null;
    if(ele!=null && xqs !=null ){
        try{
            var xqsStr = xqs.trim();
            var isXPath =xqsStr.startsWith(xpathPrefix);
            if(isXPath){
                xqsStr = xqsStr.slice(xpathPrefix.length);
            }
            var list=[];
            if(xqsStr.indexOf(orSplitStr)>-1){
                list = xqsStr.split(orSplitStr);
            }else{
                list.push(xqsStr)
            }
            for(var i=0;i<list.length;i++){
                var s= list[i].trim();
                if(s.length>0){
                    var rs=null;
                    if(isXPath){
                        rs = BJA_xPath(ele,s,all);
                    }else{
                        rs =BJA_query(ele,s,all);
                    }
                    if(rs !=null){
                        if(all)
                        {   
                            if(BJA_isArray(rs) && (rs.length>0) ){
                                r=rs;
                                break;
                            }
                        }else{
                            r=rs;
                            break;
                        }
                    }
                }
            }
        }catch(e){
        }
    }
    return r;
}

function BJA_stringByMatch(string, regex, capture=1) {
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

function BJA_stringByMatchList(string, regexs, capture=1) {
    var r=null;
    if(BJA_isArray(regexs)){
        for(var i =0;i< regexs.length;i++){
            r = BJA_stringByMatch(string,regexs[i],capture);
            if(r!=null){
                break;
            }
        }
    }
    return r;
}

function BJA_stringByMatchOrString(string, regexStr, capture=1) {
    var r=null;
    const orSplitStr = '||';
    if(regexStr){
        if(regexStr.indexOf(orSplitStr)>-1){
            r= BJA_stringByMatchList(string,regexStr.split(orSplitStr),capture);
        }else{
            r = BJA_stringByMatch(string,regexStr,capture);
        }
    }
    return r;
}

function BJA_isMatchByString(string, regex) {
    var rc = 0;
    try {
        if (string != null && string != "") {
            var matches = string.match(regex);
            if ((matches != null) && (matches.length > 0)) {
                rc = 1;
            }
        }
    } catch (e) {
        rc = 0;
    }
    return rc;
}

function BJA_isMatchListByString(string, regexs) {
    var r=0;
    if(BJA_isArray(regexs)){
        for(var i =0;i<regexs.length;i++){
            r = BJA_isMatchByString(string,regexs[i]);
            if(r == 1 ){
                break;
            }
        }
    }
    return r;
}

function BJA_isMatchByOrString(string, regexStr) {
    var r=null;
    const orSplitStr = '||';
    if(regexStr ){
        if(regexStr.indexOf(orSplitStr)>-1){
            r= BJA_isMatchListByString(string,regexStr.split(orSplitStr));
        }else{
            r = BJA_isMatchByString(string,regexStr);
        }
    }
    return r;
}

function BJA_getImagesLinksString() {
    var objs = document.getElementsByTagName('img');
    var imgScr = "";
    for (var i = 0; i < objs.length; i++) {
        imgScr = imgScr + objs[i].src + '+';
    }
    return imgScr;
}
function BJA_isImageVisible(element) {
    return BJA_isVisible(element);
}
function BJA_isVisible(element) {
    return (element.style.display != "none") && (element.style.visibility != "hidden");
}
function BJA_getWindowHeight() {
    var windowHeight = 0;
    var isCSS1Compat = ((document.compatMode || "") === "CSS1Compat");
    if (isCSS1Compat) {
        windowHeight = document.documentElement.clientHeight;
    } else if ((document.body) && (document.body.clientHeight))
    {
        windowHeight = document.body.clientHeight;
    }else if (document.documentElement && document.documentElement.clientHeight && document.documentElement.clientWidth)
    {
        windowHeight = document.documentElement.clientHeight;
    }
    return windowHeight;
}
function BJA_getWindowWidth() {
    var w=0;
    if (window.innerWidth){
        w = window.innerWidth;
    }else if ((document.body) && (document.body.clientWidth))
    {
        w = document.body.clientWidth;
    }else if (document.documentElement && document.documentElement.clientHeight && document.documentElement.clientWidth)
    {
        w = document.documentElement.clientWidth;
    }
    return w;
}
function BJA_isVisibleInWindowTop(element) {
    return element && (element.getBoundingClientRect().top < 0);
}
function BJA_isVisibleInWindowBottom(element) {
    var wh = BJA_getWindowHeight();
    return element && (element.getBoundingClientRect().top < wh);
}
function BJA_isVisibleInWindow(element) {
    var wh = BJA_getWindowHeight();
    return element && element && (element.getBoundingClientRect().top >= 0) && (element.getBoundingClientRect().top < wh);
}
function BJA_getHTMLElementsAtPoint(x, y) {
    var tags = ",";
    var e = document.elementFromPoint(x, y);
    while (e) {
        if (e.tagName) {
            tags += e.tagName + ',';
        }
        e = e.parentNode;
    }
    return tags;
}
function BJA_setCssClassdisplayNone(cssclass) {
    if (cssclass) {
        var nv = "" + cssclass;
        var list = document.documentElement.getElementsByClassName(nv);
        var i = 0;
        for (i = 0; i < list.length; i++) {
            list[i].style.display = 'none';
        }
    }
}
function BJA_setDisplayElement(elem,val=null) {
    var ret = false;
    if (!elem) {
        return ret;
    }
    try {
        elem.style.display = val;
        ret = true;
    } catch (e) {
        ret = false;
    }
    return ret;
}

function BJA_hideElement(elem) {
    return BJA_setDisplayElement(elem,'none');
}

function BJA_setVisibilityElement(elem,val=null) {
    var ret = false;
    if (!elem) {
        return ret;
    }
    try {
        elem.style.visibility = val;
        ret = true;
    } catch (e) {
        ret = false;
    }
    return ret;
}

function BJA_setVisiableElement(elem) {
    return BJA_setVisibilityElement(elem,'visible');
}

function BJA_NoVisiableElement(elem) {
    return BJA_setVisibilityElement(elem,'hidden');
}

function BJA_visiableElement(elem) {
    var ret = false;
    if (!elem) {
        return ret;
    }
    try {
        elem.classList.remove("hidden");
        elem.style.display = 'block';
        ret = true;
    } catch (e) {
        ret = false;
    }
    return ret;
}
function BJA_removeNode(node) {
    var ret = false;
    try {
        if (node) {
            var pnode = node.parentNode;
            if (pnode) {
                pnode.removeChild(node);
            }
        }
        ret = true;
    } catch (e) {
        ret = false;
    }
    return ret;
}
function BJA_isContainsClassOfElement(e, cname) {
    var b = false;
    try {
        b = (e && cname && (e.classList.contains(cname) == true));
    } catch (e) { }
    return b;
}
function BJA_isContainsClassItemOfElement(e, cname) {
    var b = false;
    try {
        if (e && cname && e.classList) {
            var lowercname = cname.toLowerCase();
            for (var i = 0; i < e.classList.length; i++) {
                var classItem = e.classList.item(i);
                if (classItem) {
                    classItem = classItem.toLowerCase()
                }
                if (classItem.indexOf(lowercname) > 0) {
                    b = true;
                    break
                }
            }
        }
    } catch (e) { }
    return b;
}
function BJA_isMatchClassItemOfElement(e, regex) {
    var b = false;
    try {
        if (e && regex && e.classList) {
            for (var i = 0; i < e.classList.length; i++) {
                var classItem = e.classList.item(i);
                if (BJA_isMatchByString(classItem, regex)) {
                    b = true;
                    break
                }
            }
        }
    } catch (e) { }
    return b;
}
function BJA_elementClassNameEqual(e, cname) {
    var b = false;
    try {
        b = (e && cname && (e.className == cname));
    } catch (e) { }
    return b;
}
function BJA_isContainsClassListOfElement(node, cnamelist, allFlag) {
    var b = false;
    try {
        var ls = cnamelist.length;
        for (var i = 0; i < ls; i++) {
            var f = BJA_isContainsClassOfElement(node,cnamelist[i]);
            if (allFlag) {
                if (!f) {
                    break;
                } else if (i + 1 == ls) {
                    b = true;
                    break;
                }
            } else if (f) {
                b = true;
                break;
            }
        }
        if (allFlag) { }
    } catch (e) { }
    return b;
}
function BJA_getElementsByTagName(nodeName) {
    var rets = [];
    if (nodeName && BJA_isString(nodeName)) {
        try {
            rets = document.getElementsByTagName(nodeName);
        } catch (e) {
            rets = [];
        }
    }
    return rets;
}
function BJA_findAllFrameElements(name, fid) {
    var rets = new Array();
    if (fid) {
        var tt = document.getElementById(name);
        if (tt) {
            rets.push(tt);
        }
    } else {
        var as = BJA_getElementsByTagName(name);
        if (as.length > 0) {
            for (var i = 0; i < as.length; i++) {
                rets.push(as[i]);
            }
        }
    }
    var c = document.querySelectorAll("iframe");
    if (c == null) {
        c = [];
    }
    for (b = 0; b < c.length; ++b) {
        var iframe = c[b];
        var doc = false;
        try {
            doc = iframe.contentWindow.document;
        } catch (e) {
         
        }
        if (!doc) {
            try {
                doc = iframe.contentDocument;
            } catch (e) { }
        }
        if (doc) {
            try {
                if (fid) {
                    var tt = doc.getElementById(name);
                    if (tt) {
                        rets.push(tt);
                    }
                } else {
                    var as = doc.getElementsByTagName(name);
                    if (as.length > 0) {
                        for (var i = 0; i < as.length; i++) {
                            rets.push(as[i]);
                        }
                    }
                }
            } catch (e) {
             
            }
        }
    }
    return rets;
}
function BJA_AddToHeadStyle(cssStr, idStr) {
    rc = false;
    try {
        var cssnode = document.querySelector("style#" + idStr);
        if (cssnode != null && (cssnode.textContent != cssStr)) {
            BJA_removeNode(cssnode);
            cssnode = null;
        }
        if (cssnode == null) {
            var header = BJA_DocumentHead();
            if (header) {
                try {
                    var s = document.createElement('style');
                    s.setAttribute('type', 'text/css');
                    s.setAttribute('id', idStr);
                    s.innerHTML = "";
                    s.appendChild(document.createTextNode(cssStr));
                    header.appendChild(s);
                    rc = true;
                } catch (e) { }
            }
        } else {
            rc = true;
        }
    } catch (e) { }
    return rc;
}

function BJA_run_throttle(func, wait) {
    let time;
    let pre = 0;
    return function (...args) {
        const this_ = this;
        const cur = + new Date();
        const remaining = wait - (cur - pre);
        if (remaining <= 0) {
            pre = cur;
            func.apply(this_, args);
            if (time) {
                clearTimeout(time);
                time = null;
            };
        } else if (!time) {
            time = setTimeout(() => {
                pre = +new Date();
                time = null;
                func.apply(this_, args);
            }, remaining);
        }
    }
}

function BJA_addElementEventWithThrottle(element, event, realFunc, wait) {
    element.addEventListener(event, BJA_run_throttle(function () {
        if (realFunc) {
            realFunc(element);
        }
    }, wait));
}

function BJA_run_debounce(func, wait, immediate) {
    var timeout;
    return function () {
        var context = this;
        var args = arguments;
        var later = function () {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = wait>0?setTimeout(later, wait):null;
        if (callNow) func.apply(context, args);
    };
}

function BJA_addElementEventWithDebounce(element, event, realFunc, wait, immediate) {
    element.addEventListener(event, BJA_run_debounce(function () {
        if (realFunc) {
            realFunc(element);
        }
    }, wait, immediate));
}

function BJA_AddMutation(e,t, fn,dt,attrs) {
    var attrFlag = 'addObsFlag';
    if(window.jszGVars.observer == null){
        window.jszGVars.observer = new MutationObserver( function (mutationsList, observer) {
            for (var mutation of mutationsList) {
                for (var s of window.jszGVars.observerObjects) {
                    if(mutation.target==s.e){
                        if ((mutation.type === 'childList') && (s.t==0 || s.t==5) ) {
                            try{s.run(mutation);}catch(e){}
                        }
                        if ((mutation.type === 'subtree') && (s.t==1) ) {
                            try{s.run(mutation);}catch(e){}
                        }
                        if ((mutation.type === 'attributes') && (s.t==2 || s.t==5) ) {
                            try{s.run(mutation);}catch(e){}
                        }
                        if ((mutation.type === 'attributes') && (s.t==3) && (mutation.attributeName!=null)&& (s.attrs!=null) && (s.attrs.indexOf(mutation.attributeName)>-1) ) {
                            try{s.run(mutation);}catch(e){}
                        }
                        if ((mutation.type === 'characterData') && (s.t==4) ) {
                            try{s.run(mutation);}catch(e){}
                        }
                    }
                }
            }
        });
    }
    var s = new BJA_ObserverObject(e,t,fn,dt,dt<=0, attrs);
    var v=s.oid();
    if(BJA_ele_getStringAttribute(e,attrFlag)=== v){
        return true;
    }
    var config=null;
    if(t==0){
        config={childList: true};
    }else if(t==1){
        config={subtree: true};
    }else if(t==2){
        config={attributes: true};
    }else if(t==3){
        config={attributes: true,attributeFilter:attrs!=null?attrs:[]};
    }
    else if(t==4){
        config={characterData: true};
    }
    else if(t==5){
        config={childList: true,attributes: true};
    }
    if(config!=null)
    {
        window.jszGVars.observer.observe(s.e, config);
        BJA_ele_setStringAttribute(e,attrFlag,v);
        window.jszGVars.observerObjects.push(s);
        return true;
    }else{
        return false;
    }
}

function BJA_MutationNodeChildList(targetNode, changedFn) {
    var r =null;
    try {
        const config = {
            childList: true,
        };
        var rx = BJA_run_debounce(function () {
            try {
                if (changedFn) {
                    changedFn();
                }
            } catch (e) { }
        }, 1000, false);

        const callback = function (mutationsList, observer) {
            for (var mutation of mutationsList) {
                if (mutation.type === 'childList') {
                    rx();
                }
            }
        };
        const observer = new MutationObserver(callback);
        observer.observe(targetNode, config);
        r= observer;
    } catch (e) {
     
    }
    return r;
}

function BJA_MutationNodeAttributes(targetNode, changedFn) {
    var r =null;
    try {
        const config = {
            attributes: true,
        };
        var rax = BJA_run_debounce(function () {
            try {
                if (changedFn) {
                    changedFn();
                }
           
            } catch (e) { }
        },1000, false);

        const callback = function (mutationsList, observer) {
            for (let mutation of mutationsList) {
                if (mutation.type === 'attributes') {
                    rax();
                }
            }
        };
        const observer = new MutationObserver(callback);
        observer.observe(targetNode, config);
        r= observer;
    } catch (e) { }
    return r;
}

function BJA_getTheme() {
    const  uk = 'unkown';
    const  dk = 'dark';
    const  lt = 'light';
    var r =uk;
    try{
        if (window) {
            const darkThemeMq = window.matchMedia("(prefers-color-scheme: dark)").matches;
            const lightThemeMq = window.matchMedia("(prefers-color-scheme: light)").matches;
            if(darkThemeMq || lightThemeMq){
                r= darkThemeMq ?dk :lt;     
            }
            else if(window.jszGVars.sysThemeDarkMode==0){
                r= lt;
            }
            else if(window.jszGVars.sysThemeDarkMode==1){
                r =dk;
            }
        }
    } catch(e){}
    return r;
}

function BJA_isDarkMode(){
    var r =false;
    try{
        var sysThemeMode =BJA_getTheme();
        if(sysThemeMode){
            var addStyle = true;
            var md =window.jszGVars.appThemeMode;
            if(md==0){
                if( sysThemeMode == 'light'){
                    addStyle =false;
                }
            }else if(md ==1){
                addStyle =false; 
            }else if(md ==2) {
                if( sysThemeMode == 'light'){
                   
                }
            }
            r= addStyle;
        }
    }catch(e){}
    return r;
}

function BJA_isPrefersColorScheme(){
    var r =false;
    try{
        r=window.matchMedia("(prefers-color-scheme: dark)").matches || window.matchMedia("(prefers-color-scheme: light)").matches;
    }catch (e){

    }
    return r;
}

function BJA_removeCSSPerfersColorSchemePrefix(css,all=false){
    var r = css.replace('prefers-color-scheme: dark','');
    if(all){
        r = r.replace('prefers-color-scheme: light','');
    }
    r = r.trim();
    if((r.startsWith('@media')||r.startsWith('{')) && r.endsWith('}')){
        r=BJA_SubStringInBeginToLast(r,'{','}');
    }
    return r;
}

function BJA_mergeMediaCSS(mainCss,css){
    var r =mainCss.trim();
    var s = css.trim();
    if(s==null || s.length==0){
        return r;
    }
    if(r==null || r.length==0){
        return s;
    }
    if((s.startsWith('@media')||s.startsWith('{')) && s.endsWith('}')){
        s=BJA_SubStringInBeginToLast(s,'{','}');
    }
    if((r.startsWith('@media')||r.startsWith('{')) && r.endsWith('}')){
        r=BJA_StringInsert(r,s,r.length-1);
    }else{
        r = r.concat(s);
    }
    return r;
}

function BJA_StringInsert(str, insertStr, position) {
    return str.slice(0, position) + insertStr + str.slice(position);
}
function BJA_StringInsertRegex(str, pattern, insertStr) {
    const regex = new RegExp(pattern);
    return str.replace(regex, match => match + insertStr);
}
function BJA_StringFilterStartsWith(str, filter) {
    return str.startsWith(filter)?str.slice(filter.length):str;
}
function BJA_SubStringInBeginToLast(s, b, l) {
    var r=s;
    const idx = r.indexOf(b);
    if(idx>=0){
        r = r.slice(idx+1);
    }
    const lastIdx = r.lastIndexOf(l);
    if(lastIdx>=0){
        r = r.slice(0,lastIdx);
    }
    return r;
}
function BJA_isValidBase64(str) {
    str = str.trim();
    const base64Regex = /^[A-Za-z0-9+/]*={0,2}$/;
    if (!base64Regex.test(str)) {
        return false;
    }
    if (str.length % 4 !== 0) {
        return false;
    }
    const equalSignIndex = str.indexOf('=');
    if (equalSignIndex !== -1) {
        if (equalSignIndex < str.length - 2) {
            return false;
        }
        const equalCount = (str.match(/=/g) || []).length;
        if (equalCount > 2) {
            return false;
        }
    }
    return true;
}

function BJA_decodeBase64(s,defalutValue=null) {
    var r=null;
    try{
        r=atob(s);
    }catch(e){
        r=defalutValue;
    }
    return r;
}

function BJA_encodeToBase64(s,defalutValue=null) {
    var r =null;
    try{
        r=btoa(s);
    }catch(e){r=defalutValue;}
    return r;
}

function BJA_UpdateThemeCallback() {
 
}

function BJA_addThemeChangListener(callback) {
    var r = false;
    if (!window) {
 
        return r;
    }
    try {
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', callback != null ? callback : BJA_UpdateThemeCallback);
        window.matchMedia('(prefers-color-scheme: light)').addEventListener('change', callback != null ? callback : BJA_UpdateThemeCallback);
        r = true;

    } catch (e) {

    }
    return r;
}

function BJA_GetElementToTop(el) {
    var T = el.offsetTop;
    while(el = el.offsetParent) {
        T += el.offsetTop;
    }
    return T;
}


function BJA_getImageUrlAndConfigLazy(img, attrs,url,filters,addLazy){
    var imgUrl=null;
    const filterXpathPrefix = 'X:';
    var img_filters = filters!=null?filters:[];
    for (let v = 0; v < attrs.length; v++) {
        var att = attrs[v];
        var value= BJA_ele_getStringAttribute(img,att);
        if (BJA_isString(value) 
        && (value.length>5) && (!value.startsWith('data:image',0))
        ){
            var low_value=value.toLowerCase();
            for(var jj = 0; jj<img_filters.length; jj++){
                var fv = img_filters[jj];
                if(fv.startsWith(filterXpathPrefix)){
                   var rg = fv.slice(filterXpathPrefix.length);
                   if(BJA_isMatchByString(value,rg)||( (value!=low_value) && BJA_isMatchByString(low_value,rg))){
                        value=null;
                        break;
                    }
                }
                else if ( (value.indexOf(fv)>-1) || ((low_value!=value) &&(low_value.indexOf(fv)>-1))){
                    value=null;
                    break;
                }
            }
            if(value!=null){
                value = (url!=null)? BJA_getEntireUrl(value,url):value;
                if((value !=null) && (value.toLowerCase().startsWith('http') ) ){
                    imgUrl = value;
                }else{
                    value = null;
                }
            }
        }
        if(imgUrl){
            var defImg = '';
            if(addLazy && (window.jszGVars.imageMode > 0 )){
                if((BJA_ele_getStringAttribute(img,varAttr_addlazy) == null) ){
                    BJA_ele_setStringAttribute(img,'zj-src',imgUrl);
                    try{defImg=_app_sub_ov_lazyImageUrl();}catch(e){}
                    for(var i = 0; i< window.jszGVars.lazyImgAttrFilters.length; i++){
                        var attr = window.jszGVars.lazyImgAttrFilters[i];
                        if(BJA_ele_hasAttribute(img,attr)){
                            BJA_ele_setStringAttribute(img,attr,defImg);
                        }
                    }
                    BJA_ele_setStringAttribute(img,varAttr_addlazy,'1');
                    BJA_ele_setIntAttribute(img,varAttr_imageMode,window.jszGVars.imageMode);
                    window.jszGVars.lazyImageCount +=1;
                }
            }
            
            if (window.jszGVars.addImageClickEvent && (BJA_ele_getStringAttribute(img,varAttr_addclickevent) == null)){
                try{img.addEventListener('click', function(e) {e.preventDefault();e.stopPropagation();_app_sub_ov_ImageClick(img,imgUrl)});BJA_ele_setStringAttribute(img,varAttr_addclickevent,'1');}catch(e){}
            }
            break;
        }
    }
    if (typeof _app_sub_ov_image_handler === 'function') {
        try{_app_sub_ov_image_handler(img,imgUrl);}catch(e){}
    }
    return imgUrl;
}

function BJA_addPCSearchBar (form) {
    if(form==null || BJA_ele_getStringAttribute(form, 'addpcsearch')!=null){
        return;
    }
    var strMemo,strValue,localSearch;
    localSearch = localStorage.getItem('txtSearch');
    if(localSearch==null){
        localSearch='';
    }
    var objSel = document.createElement("select");
    objSel.id = "selSearch";
    objSel.options.add(new Option("百度","baidu"));
    objSel.options.add(new Option("必应","bing"));
    objSel.options.add(new Option("谷歌","google"));
    objSel.onchange = function() {
    strMemo = " " + objSel.value + "站内搜索";
        if (txtSearch.value == '' | txtSearch.value == " bing站内搜索" | txtSearch.value==" google站内搜索" |  txtSearch.value== " baidu站内搜索") {txtSearch.value=strMemo}
    }
    var txtSearch = document.getElementsByName('q')[0];
    form.insertBefore(objSel,txtSearch);
    BJA_ele_setStringAttribute(form,'addpcsearch','1');
    strMemo = " " + localSearch + "站内搜索";
    switch (localSearch) {
    case 'baidu':
        objSel.options[0].selected = true;
        break;
    case 'bing':
        objSel.options[1].selected = true;
        break;
    case 'google':
        objSel.options[2].selected = true;
        break;
    default:
        objSel.options[0].selected = true;
        break;
    }
    txtSearch.onfocus = function() {
        if(txtSearch.value==strMemo) {
            txtSearch.value='';
        }
    }
    txtSearch.onblur = function() {
        if (txtSearch.value=='') {
            txtSearch.value=strMemo;
        }
    }
    txtSearch.value=strMemo;
    var button = document.getElementsByName('sa')[0]
    button.onclick = function (){ 
        strValue = txtSearch.value;
        if (strValue == '' | strValue ==" google站内搜索" |  strValue == " baidu站内搜索"|txtSearch.value == " bing站内搜索") {return false;}
        localStorage.setItem('txtSearch',objSel.value)
        switch (objSel.value) {
            case 'baidu':
                window.open('https://www.baidu.com/s?wd= site:' + encodeURIComponent(location.hostname) + ' ' + encodeURIComponent(strValue),'','');
                break;
            case 'bing':
                window.open('https://cn.bing.com/search?q=site:' + encodeURIComponent(location.hostname) + ' ' + encodeURIComponent(strValue),'','');
                break;
            case 'google':
                window.open('https://www.google.com/search?hl=zh-CN&client=opera&q=site:' + encodeURIComponent(location.hostname) +' ' + encodeURIComponent(strValue),'','');
                break;
            default:
                window.open('https://www.baidu.com/s?wd= site:' + encodeURIComponent(location.hostname) + ' ' + encodeURIComponent(strValue),'','');
                break;
        }    
        return false;
    };
}

function BJA_isImageExtensionUrl(u=null) {
    var r=false;
    var imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'svg','webp','tiff','tif'];
    var path =BJA_URI_pathname(u);
    if(path!=null && (path.indexOf('.')>-1)){
        var extension = path.split('.').pop().toLowerCase();
        r = imageExtensions.indexOf(extension)>-1;
    }
    return r;
}
function BJA_isImagePage() {
    return BJA_isImageExtensionUrl();
}
function BJA_documentIsImage(){
    var r = null;
    try{
        var hcount = document.head.childElementCount;
        if((hcount >=1 && hcount <3)  && document.body.childElementCount == 1){
            var mx =0;
            var rhs = document.head.childNodes;
            var rbs = document.body.childNodes;
            for(var i=0; i< rhs.length; i++){
                if(rhs[i].tagName.toLowerCase() =='title'){
                    mx++;
                }else  if(rhs[i].tagName.toLowerCase() =='style'){
                    mx++;
                }
            }
            if( mx>=1 && rbs[0].tagName.toLowerCase() =='img'){
                r =true;
            }else{
                r=false;
            }
        }else{
            r=false;
        }
    }catch(e){}
    return r;
}
function _app_private_updateImageMode(val){
    var r = 0;
    try{
        if(val!=  window.jszGVars.imageMode){
            window.jszGVars.imageMode = val;
            r =1;
        }else{
            r =2;
        }
        if(window.jszGVars.imageMode >-1){
            if (typeof _app_sub_def_imageModeChanged === 'function') {
                _app_sub_def_imageModeChanged(val);
            } else {
           
            }
        }
    } catch(e){
  
    }
    return r;
}

function _app_private_updateAutoImageGallery(val){
    var r =0;
    try{
        if(val !=  window.jszGVars.autoImageGallery){
            window.jszGVars.autoImageGallery = val;
            r=1;
        }
        else{
            r=2;
        }
        if(r==1){
            if (typeof _app_sub_def_AutoImageGalleryChanged === 'function') {
                _app_sub_def_AutoImageGalleryChanged(val);
            } else {
           
            }
        }
    } catch(e){
  
    }
    return r;
}

function _app_private_updateBlacklistMode(val){
    var r =0;
    try{
        if(val>=0 && val<=3){
            if(val !=  window.jszGVars.blacklistMode){
                window.jszGVars.blacklistMode = val;
                r=1;
            }
            else{
                r=2;
            }
            if(window.jszGVars.blacklistMode >-1){
                if (typeof _app_sub_def_blacklistModeChanged === 'function') {
                    _app_sub_def_blacklistModeChanged(val);
                } else {
            
                }
            }
        }
    } catch(e){
  
    }
    return r;
}



function  _app_updateThemeMode(appThemeMode,sysThemeDarkMode,uatype,imageMode,param){
    var rc = 0;
    var update =0;

    var atm =  BJA_parseInt(appThemeMode);
    if((atm>=0) && (atm<=3)){
        try{
            if( atm!= window.jszGVars.appThemeMode  ){
                window.jszGVars.appThemeMode = atm;

                update ++;
            }
            rc ++;
        } catch (e){
     
        }
    }

    var stm =  BJA_parseInt(sysThemeDarkMode);
    if(stm==1 || stm==0){
        try{
            if( stm!= window.jszGVars.sysThemeDarkMode  ){
                window.jszGVars.sysThemeDarkMode = stm;
                update ++;
            }
            rc ++;
        } catch (e){
           
        }
    }

    var uam =  BJA_parseInt(uatype);
    if((uam>=1) && (uam<=2)){
        try{
            if( uam!= window.jszGVars.uatype ){
                window.jszGVars.uatype = uam;
                update ++;
            }
            rc ++;
        } catch (e){
  
        }
    }
    var md =  BJA_parseInt(imageMode);
    if(md>=0){
        try{
            if( md!= window.jszGVars.imageMode ){
                var st= _app_private_updateImageMode (md);
                if(st ==2){
                    update ++;
                }
            }
            rc ++;
        } catch (e){

        }
    }
    if((rc >0) && (window.jszGVars.themeInit==false)){
        window.jszGVars.themeInit =true;
        
    }
    _app_autoTheme();
   
    try{
        if(window.jszGVars.domReady==false){
            if(BJA_DocumentBody()!=null){
                _bja_private_domReadyFunc(4);
            }
        }
    } catch (e){

    }
    try{
        var obj = BJA_isJSON(param);
        if(obj && BJA_isArray(obj) && obj.length>0){
            var i= obj[0];
            var iv =  BJA_parseInt(i);
            var st= _app_private_updateAutoImageGallery (iv!=0?true:false);
            if(st ==2){
                update ++;
                rc++
            }else if(st==1){
                rc++;
            }

            i= obj[1];
            iv =  BJA_parseInt(i);
            var st= _app_private_updateBlacklistMode (iv);
            if(st ==2){
                update ++;
                rc++
            }else if(st==1){
                rc++;
            }
             _app_sub_ov_updateParam (obj);
        }
        
    } catch (e){

    }
    try{
       _app_autoExtensionJS();
    } catch (e){

    }
    var ret= new Object;
    ret.rc=rc;
    ret.update = update;
    return BJA_objToJSONString(ret);
}

function  _app_autoExtensionJS() {
    try{
        if(window.jszGVars.extensionJsDoing==false){
            window.jszGVars.extensionJsDoing=true;
            var pnode = BJA_DocumentBody();
            if(!pnode){
                pnode = BJA_DocumentHead();
            }
            if(pnode){
                var jsnode = document.querySelector("script[id='_app_extension_js']");
                if(jsnode==null){
                    var ejs = _app_sub_ov_SiteExtensionJS();
                    if(ejs && BJA_isString(ejs) &&  ejs.length>5){
                        var djs = BJA_decodeBase64(ejs);
                        if(djs&& BJA_isString(djs) &&  djs.length>5){
                            var s = document.createElement('script');
                            s.setAttribute('type','text/javascript');
                            s.setAttribute('id','_app_extension_js');
                            s.innerHTML = "";
                            s.appendChild(document.createTextNode(djs));
                            pnode.appendChild(s);
                        }
                    }
                }
            }
            window.jszGVars.extensionJsDoing=false;
        }
    } catch (e){
        window.jszGVars.extensionJsDoing=false;
    }
}

function  _app_autoTheme() {
    try{
        if(window.jszGVars.themeInit==false){
            return;
        }
    } catch (e){

    }
    if(window.jszGVars.themedoing){
        return false;
    }
    window.jszGVars.themedoing = true;
    window.jszGVars.themeUpdateCount +=1;

    if(document==null){
        window.jszGVars.themedoing =false;
        return false;
    }

    if(BJA_DocumentHead()==null){
        window.jszGVars.themedoing =false;
        return false;
    }
    
    var rc = _app_sub_ov_currentSiteType();
    if(rc<1){
        window.jszGVars.themedoing =false;
        return false;
    }

    var isPCS = BJA_isPrefersColorScheme();
    var sysThemeMode =BJA_getTheme();
    if(sysThemeMode){
 
    }

    var cssnode = document.querySelector("style[id='theme_css']");
    if(cssnode!=null){
        var ndel = true;
        var sysThemeModeValue= BJA_ele_getIntAttribute(cssnode,'sysThemeMode'); 
        var tcsflag= BJA_ele_getIntAttribute(cssnode,'tcsflag');
        if( (tcsflag !=null) && ( rc==tcsflag ) &&  (sysThemeModeValue !=null) && ( sysThemeModeValue==sysThemeMode )   ){
            ndel =false;
        }
        if(ndel){
            BJA_removeNode(cssnode);
            cssnode=null;

        }
    }
    var resourlt = false;
    var modifyStyleIsLight = false;
    var addStyle = true;
    var md =window.jszGVars.appThemeMode;
    if(md==0){
        if( sysThemeMode == 'light'){
            addStyle =false;
        }
    }else if(md ==1){
        addStyle =false; 
    }else if(md ==2) {
       if( sysThemeMode == 'light'){
           modifyStyleIsLight = true; 
       }
    }
    if(addStyle){
        if(cssnode){
            if(modifyStyleIsLight){
                var tmodifyflag= BJA_ele_getIntAttribute(cssnode,'tmodifyflag');
                if(tmodifyflag==null || tmodifyflag!=1){
                    var css=  cssnode.textContent;
                    if(css.length>=50){
                        css = css.slice(0,50);
                    }
                    if(css.indexOf('prefers-color-scheme: light') < 0){
                        BJA_removeNode(cssnode);
                        cssnode=null; 
                    }
                }
            }
        }
        if(cssnode==null){ 
            var header = BJA_DocumentHead();
            if (header) {
                try {
                    var subCss = _app_sub_ov_ThemeEncodeCss(rc==1);
                    if(subCss!=null && subCss.length>0){                   
                        var css = BJA_decodeBase64(subCss,subCss);
                        var exEncodeCss = _app_sub_ov_ThemeExtensionEncodeCss(rc==1);
                        if(exEncodeCss!=null && exEncodeCss.length>0){
                           css = BJA_mergeMediaCSS(css,exEncodeCss);
                        }
                        if(isPCS){
                            if(modifyStyleIsLight){ 
                                css =  css.replace('prefers-color-scheme: dark','prefers-color-scheme: light');
                            }
                        }else{
                            css=BJA_removeCSSPerfersColorSchemePrefix(css);
                        }
                        
                        var s = document.createElement('style');
                        s.setAttribute('type', 'text/css');
                        s.setAttribute('id','theme_css');
                        s.setAttribute('tcsflag',rc);
                        s.setAttribute('sysThemeMode',sysThemeMode?sysThemeMode:"");
                        if(modifyStyleIsLight){
                            s.setAttribute('tmodifyflag',1); 
                        }
                        s.innerHTML = "";
                        s.appendChild(document.createTextNode(css));
                        header.appendChild(s);
                        window.jszGVars.themeUpdatedCount += 1;
                        resourlt = true;
        
                        _app_sub_ov_sendMsgToApp([{'theme': '1'}]);
                        _app_sub_ov_ThemeInstalled(rc==1,true);
                    }
                } catch(e) {
             
                }
            }
        }else{
            _app_sub_ov_sendMsgToApp([{'theme': '2'}]);       
        }
    }else{
         if(cssnode){
            BJA_removeNode(cssnode);
            cssnode=null;
            window.jszGVars.themeUpdatedCount -=1;
             _app_sub_ov_sendMsgToApp([{'theme': '3'}]);
        }
        resourlt=true;
        _app_sub_ov_ThemeInstalled(rc==1,false);
    }
    window.jszGVars.themedoing =false;
    return resourlt;
}

function _bja_private_setLazyLoadingImages(){
    try{
        if(window.jszGVars.imageMode > 0 ){
            let url = BJA_GetURL ();
            var imagess = document.querySelectorAll("img");
            var count = 0;
            imagess.forEach((img) => {
                if((BJA_ele_getStringAttribute(img,varAttr_addlazy) == null) ){
                    var imgUrl = BJA_getImageUrlAndConfigLazy(img,window.jszGVars.imgAttrs,url,window.jszGVars.imgUrlFilters,true);
                    if(imgUrl!=null){
                        count ++;
                    }
                }
            });
         
        }else{
        
        }
        
    }catch(e){
  
    }
}

function _app_jsz_autoImages(force=false,addedNodes=null){
    var ret= new Object;
    var count = 0;
    ret.url = BJA_GetURL ();
    var imgs = [];
    var add=false;
    if (addedNodes !=null){
        add =true;
        addedNodes.forEach(node => {
             try{
                for(var i = 0; i<window.jszGVars.addImageContentSels.length; i++){
                    var selStr = window.jszGVars.addImageContentSels[i];
                    var images =BJA_xpathQuerySelector(node,selStr,true);
                    if(images!=null && images.length>0){
                        for (var k =0; k< images.length; k++){
                            var imgUrl = null;
                            imgUrl = BJA_getImageUrlAndConfigLazy(images[k],window.jszGVars.imgAttrs,ret.url,window.jszGVars.imgUrlFilters,true);
                            if(imgUrl!=null ){
                                if (imgs.indexOf(imgUrl)<0){
                                    imgs.push(imgUrl);
                                }
                            }
                        }
                    }  
                    
                }  
            }catch(e){
     
            }
        });
        if(imgs.length>0){
            window.jszGVars.images=window.jszGVars.images.concat(imgs);
            count = window.jszGVars.images.length;
            window.jszGVars.imageCount = count;
            _app_sub_ov_sendMsgToApp([{'imageCount': count}]);
      
        }
    }
    else if(force || window.jszGVars.images.length ==0) {
        try{
            var selList = [];
            var sels = _app_sub_ov_imgContentSels();
            if(sels!=null && BJA_isArray(sels)){
                selList=selList.concat(sels);
            }
            if(window.jszGVars.imgContentSels!=null &&  BJA_isArray(window.jszGVars.imgContentSels)){
                selList=selList.concat(window.jszGVars.imgContentSels);
            }
            selList=BJA_ArrayDeduplication(selList);
            for (var i =0; i< selList.length; i++){
                var selStr= selList[i];
                var imgNodes =BJA_xpathQuerySelector(document,selStr,true);    
                if((imgNodes!=null) && BJA_isArray(imgNodes) && (imgNodes.length>0) ){
                    for(var j = 0; j<imgNodes.length; j++){
                        var imgnode =  imgNodes[j];
                        var imgUrl = null;
                        imgUrl = BJA_getImageUrlAndConfigLazy(imgnode,window.jszGVars.imgAttrs,ret.url,window.jszGVars.imgUrlFilters,true);
                        if(imgUrl!=null ){
                            if  (imgs.indexOf(imgUrl)<0){
                                imgs.push(imgUrl);
                            }
                        }
                    }
                    break;
                }
            }
            try{

                var imgNodes =[];
                var tlist = BJA_arrayFromNodeList(_app_sub_ov_imgNodes());
                if(tlist!=null && tlist.length>0){
                    imgNodes.concat(tlist);
                }
                try{if (typeof _app_sub_def_imgNodesFunc === 'function') {
                    var temp = BJA_arrayFromNodeList(_app_sub_def_imgNodesFunc());
                    if(temp!=null && temp.length>0){
                        var hasNode = imgNodes.length>0;
                        imgNodes.concat(temp);
                        if(hasNode){
                            imgNodes=BJA_ArrayDeduplication(imgNodes);
                        }
                    }
                }
                }catch(e){}
                if(imgNodes && (imgNodes.length>0) ){
                    for(var j = 0; j<imgNodes.length; j++){
                        var imgnode =  imgNodes[j];
                        var imgUrl = null;
                        imgUrl = BJA_getImageUrlAndConfigLazy(imgnode,window.jszGVars.imgAttrs,ret.url,window.jszGVars.imgUrlFilters,true);
                        if(imgUrl!=null ){
                            if  (imgs.indexOf(imgUrl)<0){
                                imgs.push(imgUrl);
                            }
                        }
                    }
                }
            }catch (e){

            }
            window.jszGVars.images = imgs;
            count = imgs.length;
            if(window.jszGVars.imageCount != count ){
                window.jszGVars.imageCount = count;
                _app_sub_ov_sendMsgToApp([{'imageCount': count}]);
             
            }
        }catch (e){
              
        }
    }
    ret.images = window.jszGVars.images;
    ret.count = count >0 ?count:ret.images.length;
    return ret;
}



function _bja_private_ImageLazyloadShow() {
    if(window.jszGVars.imageMode < 2){
        return;
    }
    var imagess = document.querySelectorAll("img[addlazy='1']");
    let viewHeight = document.documentElement.clientHeight || document.body.clientHeight;
    let scrollTop = document.documentElement.scrollTop || document.body.scrollTop;
    for(let i = window.jszGVars.lazyImageShowIndex; i < imagess.length; i++) {
        var img = imagess[i];
        if(BJA_GetElementToTop(img) < scrollTop + viewHeight){
            var zjsrc = BJA_ele_getStringAttribute(img,'zj-src');
            var src = BJA_ele_getStringAttribute(img,'src');
            if(src !=  zjsrc){
                img.src = zjsrc;
            }
            for(let j = 0; j < window.jszGVars.lazyImgAttrFilters.length; j++) {
                var attr= window.jszGVars.lazyImgAttrFilters[j];
                if(BJA_ele_hasAttribute(img,attr)){
                    BJA_ele_setStringAttribute(img,attr,zjsrc);
                }
            }
            window.jszGVars.lazyImageShowIndex ++;
        } else {
            break;
        }
    }

}