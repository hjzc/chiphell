function BJAJSZGlobalVariable(){this.blacklist=new Array,this.blacklistMode=-1,this.appThemeMode=-1,this.sysThemeDarkMode=-1,this.uatype=0,this.themeInit=!1,this.themedoing=!1,this.extensionJsDoing=!1,this.themeUpdateCount=0,this.themeUpdatedCount=0,this.images=new Array,this.addImageClickEvent=!0,this.imageCount=0,this.lazyImageCount=0,this.lazyImageShowIndex=0,this.lazyImgAttrFilters=[],this.imageMode=-1,this.imgAttrs=[],this.imgUrlFilters=[],this.imgContentSels=[],this.addImageContentSels=["img"],this.autoImageGallery=!0,this.domReady=!1,this.handleBlacklistCount=0,this.callBackList=new Array,this.callBackMap=new Map,this.zcsAddEventListenerCount=0,this.lazyThrottleFunc=null,this.lazyShowThrottleFunc=null,this.observer=null,this.observerObjects=[],this.kv=new Map,this.siteConfig=null,this.isImageDocument=null,this.isImageURI=null}function BJA_ObserverObject(t,e,n,r,a,i){this.e=t,this.t=e,this.fn=n,this.attrs=i,this.run=a?n:BJA_run_debounce(this.fn,r,a)}BJA_ObserverObject.prototype.oid=function(){var t=null!=this.attrs?this.attrs.join("_"):"";return this.t+"_"+t};const varAttr_addclickevent="_addclickevent",varAttr_addlazy="addlazy",varAttr_imageMode="imageMode",varAttr_onclick="onclick",varAttr_bkonclick="bk_onclick",varAttr_zjsfilter="_zjsfilter",varMap_blacklistModeLast="blacklistMode";function _jszGVarsKV(t,e=[]){var n=null;try{if(null!=e&&e.length>0){n=t;for(var r=0;r<e.length;r++){if(null==(n=BJA_VarsKVFromArrayOrMap(n,e[r])))break}}}catch(t){n=null}return n}function _jszGVarsKVMap(){var t=null;try{t=_jszGVarsKV(window.jszGVars.kv,["map"])}catch(e){t=null}return t}function _jszGVarsKVMapForKey(t,e=null){var n=e,r=_jszGVarsKVMap();return null!=t&&null!=r&&r.has(t)&&(n=r.get(t)),n}function _jszGVarsKVMapSet(t=null,e=null){var n=!1;if(null!=t){var r=_jszGVarsKVMap();null!=r&&(null!=e?r.set(t,e):r.delete(t),n=!0)}return n}function _bja_sdk_initVariable(){}function _app_sub_ov_initVariable(){}function _app_sub_ov_initFunc(){}function _app_sub_ov_headOrBodyReadyFunc(){}function _app_sub_ov_updateParam(t){}function _app_sub_ov_currentSiteType(){return 0}function _app_sub_ov_ThemeEncodeCss(t){return""}function _app_sub_ov_ThemeExtensionEncodeCss(t){return""}function _app_sub_ov_SiteExtensionJS(){return""}function _app_sub_ov_ThemeInstalled(t,e){}function _app_sub_ov_lazyImageUrl(){return""}function _app_sub_ov_ImageClick(t,e){_app_sub_ov_sendMsgToApp([{tapImage:null!=e?e:""}])}function _app_sub_ov_image_handler(t,e){}function _app_sub_ov_imgContentSels(){return[]}function _app_sub_ov_imgNodes(){return[]}function _app_sub_ov_sendMsgToApp(t){var e=null;try{e=window.flutter_inappwebview.callHandler("__jszHandler__",...t)}catch(t){}return e}function _app_sub_ov_sendMsgToAppAndResult(t,e){try{window.flutter_inappwebview.callHandler("__jszHandler__",...t).then(function(t){e(t)})}catch(t){}}function _bja_private_OnScrollFunc(t,e){try{window.jszGVars.lazyShowThrottleFunc()}catch(e){}}function _bja_private_safeInitVars(){try{if(!window.jszGVars){window.jszGVars=new BJAJSZGlobalVariable,window.jszGVars.kv.set("map",new Map);try{_bja_sdk_initVariable()}catch(t){}try{_app_sub_ov_initVariable()}catch(t){}}}catch(t){}}function _bja_private_headOrBodyReadyFunc(){null==window.jszGVars.lazyShowThrottleFunc&&(window.jszGVars.lazyShowThrottleFunc=BJA_run_throttle(_bja_private_ImageLazyloadShow,500)),window.addEventListener("scroll",function(t,e){try{_bja_private_OnScrollFunc(t,e)}catch(e){}if("function"==typeof _app_sub_def_OnScrollFunc)try{_app_sub_def_OnScrollFunc(t,e)}catch(e){}})}function _bja_private_domReadyFunc(t){if(!window.jszGVars.domReady&&(null!=BJA_DocumentHead()||null!=BJA_DocumentBody())){window.jszGVars.domReady=!0;try{_bja_private_headOrBodyReadyFunc()}catch(t){}try{_app_sub_ov_headOrBodyReadyFunc()}catch(t){}if("function"==typeof _app_sub_def_headOrBodyReadyFunc)try{_app_sub_def_headOrBodyReadyFunc()}catch(t){}}if(window.jszGVars.imageMode>-1){null==window.jszGVars.lazyThrottleFunc&&(window.jszGVars.lazyThrottleFunc=BJA_run_throttle(_bja_private_setLazyLoadingImages,400));try{window.jszGVars.lazyThrottleFunc()}catch(t){}}if("function"==typeof _app_sub_def_domReadyFunc)try{_app_sub_def_domReadyFunc(t)}catch(t){}}function _bja_safeListenerDOMContentLoaded(){if(!window)return!1;try{if(null==window.document)return!1}catch(t){return!1}_bja_private_safeInitVars();try{if(window.jszGVars.zcsAddEventListenerCount>0)return!0}catch(t){return!1}if("complete"===document.readyState)window.jszGVars.zcsAddEventListenerCount+=1,_bja_private_domReadyFunc(0);else{try{window.document.addEventListener("DOMContentLoaded",function(){_bja_private_domReadyFunc(1)}),window.jszGVars.zcsAddEventListenerCount+=1}catch(t){}try{document.onreadystatechange=function(){"complete"===document.readyState&&_bja_private_domReadyFunc(2)},window.jszGVars.zcsAddEventListenerCount+=1}catch(t){}try{window.addEventListener("DOMContentLoaded",function(){_bja_private_domReadyFunc(3)}),window.jszGVars.zcsAddEventListenerCount+=1}catch(t){}}return!0}var __vscaddtimerid=-1;function _bja_safeInitSDK(){function t(){_bja_safeListenerDOMContentLoaded()&&-1!=__vscaddtimerid&&(clearInterval(__vscaddtimerid),__vscaddtimerid=-1)}t();var e=0;try{e=window.jszGVars.zcsAddEventListenerCount}catch(t){}0==e&&(__vscaddtimerid=setInterval(t,300));try{_app_sub_ov_initFunc()}catch(t){}if("function"==typeof _app_sub_def_initFunc)try{_app_sub_def_initFunc()}catch(t){}}function BJA_asynCall(t,e){return new Promise((n,r)=>{if(e<=0)try{var a=t();n(a)}catch(t){r(t)}else setTimeout(()=>{try{var e=t();n(e)}catch(t){r(t)}},1e3)})}function BJA_getEntireUrl(t,e){var n=null;if(null==t)return n;if(0==t.toLowerCase().indexOf("http"))return t;if(null!=e)try{var r=new URL(t,e);null!=r&&(n=r.href)}catch(t){}return n}function BJA_for(t,e){if(null==t||0==BJA_isArray(t))try{e(-1,-1,null)}catch(t){}else{var n=t.length;if(n>0)for(var r=0;r<t.length;r++)try{if(e(n,r,t[r]))break}catch(t){}else try{return void e(0,-1,null)}catch(t){}}}function BJA_GetDomain(){var t=null;try{t=window.location.host}catch(t){}if(!t)try{t=document.domain}catch(t){}if(!t)try{t=new URL(document.URL).host}catch(t){}return t}function BJA_GetURL(){var t=null;try{t=window.location.href}catch(t){}if(!t)try{t=self.location.href}catch(t){}if(!t)try{t=document.URL}catch(t){}return t}function BJA_getAbsUrl(t){var e=null;if(null!=t){var n=BJA_GetURL();if(null!=n)try{var r=new URL(t,n);null!=r&&(e=r.href)}catch(t){}}return e}function BJA_URI(t){var e=null;try{var n=BJA_GetURL();e=null!=t?new URL(t,n):new URL(n)}catch(t){}return e}function BJA_URI_host(t){var e=BJA_URI(t);return null!=e?e.host:null}function BJA_URI_hostname(t){var e=BJA_URI(t);return null!=e?e.hostname:null}function BJA_URI_sheme(t){var e=BJA_URI(t);return null!=e?e.protocol:null}function BJA_URI_origin(t){var e=BJA_URI(t);return null!=e?e.origin:null}function BJA_URI_pathname(t){var e=BJA_URI(t);return null!=e?e.pathname:null}function BJA_URI_search(t){var e=BJA_URI(t);return null!=e?e.search:null}function BJA_URI_searchParams(t){var e=BJA_URI(t);return null!=e?e.searchParams:null}function BJA_DocumentBody(){var t=document.body;if(!t){var e=document.getElementsByTagName("body");t=!(!e||e.length<=0)&&e[0]}return t}function BJA_DocumentHead(){var t=!1,e=[];try{e=document.getElementsByTagName("head")}catch(t){e=[]}return e&&e.length>0&&(t=e[0]),t}function BJA_getPageCharset(){var t=null;try{if(document.characterSet&&document.characterSet.length>2)t=document.characterSet;else{const n=document.querySelector("meta[charset]");if(n)(e=n.getAttribute("charset"))&&e.length>2&&(t=e)}if(null==t){const n=document.querySelector('meta[http-equiv="Content-Type"]');if(n){const r=n.getAttribute("content").match(/charset=([^;]+)/i);var e;if(r)(e=r[1].trim())&&e.length>2&&(t=e)}}t=null!=t?t.toLowerCase():null}catch(t){}return t}function BJA_CreateStyleNode(t){var e=!1;if(t)try{var n=document.createElement("style");n.setAttribute("type","text/css"),n.innerHTML="",n.appendChild(document.createTextNode(t)),n&&(e=n)}catch(t){e=!1}return e}function BJA_AddStyle(t,e){var n=!1;if(t&&(n=BJA_CreateStyleNode(e)))try{(n=t.appendChild(n))||(n=!1)}catch(t){n=!1}return n}function BJA_AddStyleAtHead(t){var e=BJA_DocumentHead();return e&&(ret=BJA_AddStyle(e,t)),ret}function BJA_ele_getText(t,e=!0){var n=null;try{t&&(n=t.textContent,n=e?n.trim():n)}catch(t){n=null}return n}function BJA_ele_removeAttribute(t,e){var n=0;try{t&&e&&(t.removeAttribute(e),n=1)}catch(t){n=0}return n}function BJA_ele_setStringAttribute(t,e,n){var r=0;try{t&&e&&n&&(t.setAttribute(e,n),r=1)}catch(t){r=0}return r}function BJA_ele_setIntAttribute(t,e,n){var r=0;try{if(t&&e){var a=""+n;t.setAttribute(e,a),r=1}}catch(t){r=0}return r}function BJA_ele_hasAttribute(t,e){var n=!1;return t&&e&&(n=t.hasAttribute(e)),n}function BJA_ele_getStringAttribute(t,e){var n=null;try{t&&e&&BJA_ele_hasAttribute(t,e)&&((n=t.getAttribute(e))&&BJA_isString(n)||(n=null))}catch(t){n=null}return n}function BJA_ele_getIntAttribute(t,e){var n=BJA_ele_getStringAttribute(t,e);return n&&null!=n?!1===(n=BJA_parseInt(n))&&(n=null):n=null,n}function BJA_nodeForXPath(t,e){var n=null,r=t,a=t;if(t?void 0===t.evaluate&&(r=document):(r=document,a=document),void 0!==r.evaluate){var i=r.evaluate(e,a,null,XPathResult.FIRST_ORDERED_NODE_TYPE,null);null!=i&&(n=i.singleNodeValue)}return n}function BJA_nodesForXPath(t,e){var n=[];if(!e||void 0===e||null==e)return n;var r=t,a=t;if(t?void 0===t.evaluate&&(r=document):(r=document,a=document),void 0!==r.evaluate){var i=r.evaluate(e,a,null,XPathResult.ORDERED_NODE_ITERATOR_TYPE,null);if(null!=i)for(var o=null;null!=(o=i.iterateNext());)n.push(o)}return n}function BJA_xPath(t,e,n=!0){var r=null;try{r=n?BJA_nodesForXPath(t,e):BJA_nodeForXPath(t,e)}catch(t){}return r}function BJA_nodeDocumentForXPath(t){return BJA_nodeForXPath(!1,t)}function BJA_nodesDocumentForXPath(t){return BJA_nodesForXPath(!1,t)}function BJA_indexOfArray(t,e){for(var n=0;n<t.length;n++)if(t[n]==e)return n;return-1}function BJA_removeObjectInArray(t,e){var n=BJA_indexOfArray(t,e);n>-1&&t.splice(n,1)}function BJA_ArrayDeduplication(t){return t.reduce((t,e)=>(-1===t.indexOf(e)&&t.push(e),t),[])}function BJA_isJSON(t){if(t&&"string"==typeof t)try{if("object"==typeof JSON.parse(t))return!0}catch(t){}return!1}function BJA_getJSON(t){if(t&&"string"==typeof t)try{var e=JSON.parse(t);if("object"==typeof e)return e}catch(t){}else if("object"==typeof t)return t;return!1}function BJA_objToJSONString(t){var e=null;try{e=JSON.stringify(t)}catch(t){}return e}function BJA_isArray(t){var e=!1;try{Array.isArray(t)&&(e=!0)}catch(t){}return e}function BJA_isNode(t){var e=!1;try{t instanceof Node&&(e=!0)}catch(t){}return e}function BJA_isNodeList(t){var e=!1;try{t instanceof NodeList&&(e=!0)}catch(t){}return e}function BJA_isHTMLCollection(t){var e=!1;try{t instanceof HTMLCollection&&(e=!0)}catch(t){}return e}function BJA_arrayFromNodeList(t){return null==t?null:BJA_isNodeList(t)?Array.from(t):BJA_isArray(t)?t:BJA_isNode(t)?[t]:BJA_isHTMLCollection(t)?Array.from(t):[]}function BJA_VarsKVFromArrayOrMap(t,e){var n=null;if(null!=t)if(BJA_isArray(t)){for(var r=[],a=0;a<t.length;a++){var i=BJA_VarsKVFromArrayOrMap(t[a],e);null!=i&&r.push(i)}0==r.length&&(r=null),n=r}else t instanceof Map?n=t.has(e)?t.get(e):null:t instanceof Object&&(n=t.hasOwnProperty(e)?t[e]:null);return n}function BJA_isfunction(t){var e=!1;try{"function"==typeof t&&(e=!0)}catch(t){}return e}function BJA_isString(t){var e=!1;try{"string"==typeof t&&(e=!0)}catch(t){}return e}function BJA_StringLength(t){for(var e=0,n=0;n<t.length;n++){var r=t.charCodeAt(n);r>=1&&r<=126||65376<=r&&r<=65439?e++:e+=2}return e}function BJA_invalidString(t){return!t||null==t||!BJA_isString(t)||0==BJA_StringLength(t)}function BJA_nonullString(t){return!BJA_invalidString(t)}function BJA_isObject(t){var e=!1;try{"object"==typeof t&&(e=!0)}catch(t){}return e}function BJA_isOnlyObject(t){return null!=t&&"object"==typeof t&&!1===Array.isArray(t)}function BJA_convertToSting(t,e){var n=null;return void 0===t||("string"==typeof t?n=t:"object"==typeof t?e&&(n=e(t)):BJA_isArray(t)?e&&(n=e(t)):0==(n=t+"").length&&(n=null)),n}function BJA_ToSting(t){var e=null;try{e=BJA_convertToSting(t,!1)}catch(t){e=null}return e}function BJA_parseInt(t){var e=-1,n="";if(null!=t){try{n=""+t}catch(t){}var r=!1;try{r=n.replace(/[^0-9]/gi,"")}catch(t){r=!1}try{!1===r?e=parseInt(n):""!=r&&(e=parseInt(r)),"NaN"==e&&(e=-1)}catch(t){e=-1}}return e}function BJA_string_trim(t){var e=null;if(null!=t)try{e=t.replace(/(^\\s*)|(\\s*$)/g,"")}catch(t){}return e}function BJA_string_trim_ctl(t){var e=null;if(null!=t)try{e=t.replace(/(^[\\s\\n\\t]+|[\\s\\n\\t]+$)/g,"")}catch(t){}return e}function BJA_string_trim_all(t){var e=BJA_string_trim(t);if(null!=e)try{e=e.replace(/\\s/g,"")}catch(t){}return e}function BJA_ArrayContains(t,e){for(var n=t.length;n--;)if(t[n]===e)return!0;return!1}function BJA_getImages(){for(var t=document.getElementsByTagName("img"),e=new Array,n=0,r=0;r<t.length;r++){var a=t[r].src;a&&(e[n]=a,n++)}return e}function BJA_getImageCount(){for(var t=document.getElementsByTagName("img"),e=0,n=0;n<t.length;n++)t[n].src&&e++;return e}function BJA_querySelector(t,e){var n=null;try{null!=t&&null!=e&&e.length>0&&(n=t.querySelector(e))}catch(t){}return n}function BJA_querySelectorAll(t,e){var n=[];try{if(null!=t&&null!=e&&e.length>0)if(e.indexOf("|")>-1)for(var r=e.split("|"),a=0;a<r.length;a++){var i=r[a].trim();if(i.length>0){var o=BJA_arrayFromNodeList(t.querySelectorAll(i));if(o&&o.length>0)for(var l=0;l<o.length;l++){var s=o[l];n.indexOf(s)<0&&n.push(s)}}}else e.length>0&&(n=BJA_arrayFromNodeList(t.querySelectorAll(e)))}catch(t){}return n}function BJA_query(t,e,n=!0){return n?BJA_querySelectorAll(t,e):BJA_querySelector(t,e)}function BJA_xpathQuerySelector(t,e,n=!0){var r=null;if(null!=t&&null!=e)try{var a=e.trim(),i=a.startsWith("X:");i&&(a=a.slice("X:".length));var o=[];a.indexOf("||")>-1?o=a.split("||"):o.push(a);for(var l=0;l<o.length;l++){var s=o[l].trim();if(s.length>0){var u=null;if(null!=(u=i?BJA_xPath(t,s,n):BJA_query(t,s,n))){if(!n){r=u;break}if(BJA_isArray(u)&&u.length>0){r=u;break}}}}}catch(t){}return r}function BJA_stringByMatch(t,e,n=1){var r=null;try{var a=t.match(e);null!=a&&a.length>n&&(r=a[n])}catch(t){r=null}return r}function BJA_stringByMatchList(t,e,n=1){var r=null;if(BJA_isArray(e))for(var a=0;a<e.length&&null==(r=BJA_stringByMatch(t,e[a],n));a++);return r}function BJA_stringByMatchOrString(t,e,n=1){var r=null;return e&&(r=e.indexOf("||")>-1?BJA_stringByMatchList(t,e.split("||"),n):BJA_stringByMatch(t,e,n)),r}function BJA_isMatchByString(t,e){var n=0;try{if(null!=t&&""!=t){var r=t.match(e);null!=r&&r.length>0&&(n=1)}}catch(t){n=0}return n}function BJA_isMatchListByString(t,e){var n=0;if(BJA_isArray(e))for(var r=0;r<e.length&&1!=(n=BJA_isMatchByString(t,e[r]));r++);return n}function BJA_isMatchByOrString(t,e){var n=null;return e&&(n=e.indexOf("||")>-1?BJA_isMatchListByString(t,e.split("||")):BJA_isMatchByString(t,e)),n}function BJA_getImagesLinksString(){for(var t=document.getElementsByTagName("img"),e="",n=0;n<t.length;n++)e=e+t[n].src+"+";return e}function BJA_isImageVisible(t){return BJA_isVisible(t)}function BJA_isVisible(t){return"none"!=t.style.display&&"hidden"!=t.style.visibility}function BJA_getWindowHeight(){var t=0;return"CSS1Compat"===(document.compatMode||"")?t=document.documentElement.clientHeight:document.body&&document.body.clientHeight?t=document.body.clientHeight:document.documentElement&&document.documentElement.clientHeight&&document.documentElement.clientWidth&&(t=document.documentElement.clientHeight),t}function BJA_getWindowWidth(){var t=0;return window.innerWidth?t=window.innerWidth:document.body&&document.body.clientWidth?t=document.body.clientWidth:document.documentElement&&document.documentElement.clientHeight&&document.documentElement.clientWidth&&(t=document.documentElement.clientWidth),t}function BJA_isVisibleInWindowTop(t){return t&&t.getBoundingClientRect().top<0}function BJA_isVisibleInWindowBottom(t){var e=BJA_getWindowHeight();return t&&t.getBoundingClientRect().top<e}function BJA_isVisibleInWindow(t){var e=BJA_getWindowHeight();return t&&t&&t.getBoundingClientRect().top>=0&&t.getBoundingClientRect().top<e}function BJA_getHTMLElementsAtPoint(t,e){for(var n=",",r=document.elementFromPoint(t,e);r;)r.tagName&&(n+=r.tagName+","),r=r.parentNode;return n}function BJA_setCssClassdisplayNone(t){if(t){var e=""+t,n=document.documentElement.getElementsByClassName(e),r=0;for(r=0;r<n.length;r++)n[r].style.display="none"}}function BJA_setDisplayElement(t,e=null){var n=!1;if(!t)return n;try{t.style.display=e,n=!0}catch(t){n=!1}return n}function BJA_hideElement(t){return BJA_setDisplayElement(t,"none")}function BJA_setVisibilityElement(t,e=null){var n=!1;if(!t)return n;try{t.style.visibility=e,n=!0}catch(t){n=!1}return n}function BJA_setVisiableElement(t){return BJA_setVisibilityElement(t,"visible")}function BJA_NoVisiableElement(t){return BJA_setVisibilityElement(t,"hidden")}function BJA_visiableElement(t){var e=!1;if(!t)return e;try{t.classList.remove("hidden"),t.style.display="block",e=!0}catch(t){e=!1}return e}function BJA_removeNode(t){var e=!1;try{if(t){var n=t.parentNode;n&&n.removeChild(t)}e=!0}catch(t){e=!1}return e}function BJA_isContainsClassOfElement(t,e){var n=!1;try{n=t&&e&&1==t.classList.contains(e)}catch(t){}return n}function BJA_isContainsClassItemOfElement(t,e){var n=!1;try{if(t&&e&&t.classList)for(var r=e.toLowerCase(),a=0;a<t.classList.length;a++){var i=t.classList.item(a);if(i&&(i=i.toLowerCase()),i.indexOf(r)>0){n=!0;break}}}catch(t){}return n}function BJA_isMatchClassItemOfElement(t,e){var n=!1;try{if(t&&e&&t.classList)for(var r=0;r<t.classList.length;r++){if(BJA_isMatchByString(t.classList.item(r),e)){n=!0;break}}}catch(t){}return n}function BJA_elementClassNameEqual(t,e){var n=!1;try{n=t&&e&&t.className==e}catch(t){}return n}function BJA_isContainsClassListOfElement(t,e,n){var r=!1;try{for(var a=e.length,i=0;i<a;i++){var o=BJA_isContainsClassOfElement(t,e[i]);if(n){if(!o)break;if(i+1==a){r=!0;break}}else if(o){r=!0;break}}}catch(t){}return r}function BJA_getElementsByTagName(t){var e=[];if(t&&BJA_isString(t))try{e=document.getElementsByTagName(t)}catch(t){e=[]}return e}function BJA_findAllFrameElements(t,e){var n=new Array;if(e)(l=document.getElementById(t))&&n.push(l);else if((s=BJA_getElementsByTagName(t)).length>0)for(var r=0;r<s.length;r++)n.push(s[r]);var a=document.querySelectorAll("iframe");for(null==a&&(a=[]),b=0;b<a.length;++b){var i=a[b],o=!1;try{o=i.contentWindow.document}catch(t){}if(!o)try{o=i.contentDocument}catch(t){}if(o)try{var l,s;if(e)(l=o.getElementById(t))&&n.push(l);else if((s=o.getElementsByTagName(t)).length>0)for(r=0;r<s.length;r++)n.push(s[r])}catch(t){}}return n}function BJA_AddToHeadStyle(t,e){rc=!1;try{var n=document.querySelector("style#"+e);if(null!=n&&n.textContent!=t&&(BJA_removeNode(n),n=null),null==n){var r=BJA_DocumentHead();if(r)try{var a=document.createElement("style");a.setAttribute("type","text/css"),a.setAttribute("id",e),a.innerHTML="",a.appendChild(document.createTextNode(t)),r.appendChild(a),rc=!0}catch(t){}}else rc=!0}catch(t){}return rc}function BJA_run_throttle(t,e){let n,r=0;return function(...a){const i=this,o=+new Date,l=e-(o-r);l<=0?(r=o,t.apply(i,a),n&&(clearTimeout(n),n=null)):n||(n=setTimeout(()=>{r=+new Date,n=null,t.apply(i,a)},l))}}function BJA_addElementEventWithThrottle(t,e,n,r){t.addEventListener(e,BJA_run_throttle(function(){n&&n(t)},r))}function BJA_run_debounce(t,e,n){var r;return function(){var a=this,i=arguments,o=n&&!r;clearTimeout(r),r=e>0?setTimeout(function(){r=null,n||t.apply(a,i)},e):null,o&&t.apply(a,i)}}function BJA_addElementEventWithDebounce(t,e,n,r,a){t.addEventListener(e,BJA_run_debounce(function(){n&&n(t)},r,a))}function BJA_AddMutation(t,e,n,r,a){null==window.jszGVars.observer&&(window.jszGVars.observer=new MutationObserver(function(t,e){for(var n of t)for(var r of window.jszGVars.observerObjects)if(n.target==r.e){if("childList"===n.type&&(0==r.t||5==r.t))try{r.run(n)}catch(t){}if("subtree"===n.type&&1==r.t)try{r.run(n)}catch(t){}if("attributes"===n.type&&(2==r.t||5==r.t))try{r.run(n)}catch(t){}if("attributes"===n.type&&3==r.t&&null!=n.attributeName&&null!=r.attrs&&r.attrs.indexOf(n.attributeName)>-1)try{r.run(n)}catch(t){}if("characterData"===n.type&&4==r.t)try{r.run(n)}catch(t){}}}));var i=new BJA_ObserverObject(t,e,n,r,r<=0,a),o=i.oid();if(BJA_ele_getStringAttribute(t,"addObsFlag")===o)return!0;var l=null;return 0==e?l={childList:!0}:1==e?l={subtree:!0}:2==e?l={attributes:!0}:3==e?l={attributes:!0,attributeFilter:null!=a?a:[]}:4==e?l={characterData:!0}:5==e&&(l={childList:!0,attributes:!0}),null!=l&&(window.jszGVars.observer.observe(i.e,l),BJA_ele_setStringAttribute(t,"addObsFlag",o),window.jszGVars.observerObjects.push(i),!0)}function BJA_MutationNodeChildList(t,e){var n=null;try{const a={childList:!0};var r=BJA_run_debounce(function(){try{e&&e()}catch(t){}},1e3,!1);const i=new MutationObserver(function(t,e){for(var n of t)"childList"===n.type&&r()});i.observe(t,a),n=i}catch(t){}return n}function BJA_MutationNodeAttributes(t,e){var n=null;try{const a={attributes:!0};var r=BJA_run_debounce(function(){try{e&&e()}catch(t){}},1e3,!1);const i=new MutationObserver(function(t,e){for(let e of t)"attributes"===e.type&&r()});i.observe(t,a),n=i}catch(t){}return n}function BJA_getTheme(){var t="unkown";try{if(window){const e=window.matchMedia("(prefers-color-scheme: dark)").matches,n=window.matchMedia("(prefers-color-scheme: light)").matches;e||n?t=e?"dark":"light":0==window.jszGVars.sysThemeDarkMode?t="light":1==window.jszGVars.sysThemeDarkMode&&(t="dark")}}catch(t){}return t}function BJA_isDarkMode(){var t=!1;try{var e=BJA_getTheme();if(e){var n=!0,r=window.jszGVars.appThemeMode;0==r?"light"==e&&(n=!1):1==r&&(n=!1),t=n}}catch(t){}return t}function BJA_isPrefersColorScheme(){var t=!1;try{t=window.matchMedia("(prefers-color-scheme: dark)").matches||window.matchMedia("(prefers-color-scheme: light)").matches}catch(t){}return t}function BJA_removeCSSPerfersColorSchemePrefix(t,e=!1){var n=t.replace("prefers-color-scheme: dark","");return e&&(n=n.replace("prefers-color-scheme: light","")),((n=n.trim()).startsWith("@media")||n.startsWith("{"))&&n.endsWith("}")&&(n=BJA_SubStringInBeginToLast(n,"{","}")),n}function BJA_mergeMediaCSS(t,e){var n=t.trim(),r=e.trim();return null==r||0==r.length?n:null==n||0==n.length?r:((r.startsWith("@media")||r.startsWith("{"))&&r.endsWith("}")&&(r=BJA_SubStringInBeginToLast(r,"{","}")),n=(n.startsWith("@media")||n.startsWith("{"))&&n.endsWith("}")?BJA_StringInsert(n,r,n.length-1):n.concat(r))}function BJA_StringInsert(t,e,n){return t.slice(0,n)+e+t.slice(n)}function BJA_StringInsertRegex(t,e,n){const r=new RegExp(e);return t.replace(r,t=>t+n)}function BJA_StringFilterStartsWith(t,e){return t.startsWith(e)?t.slice(e.length):t}function BJA_SubStringInBeginToLast(t,e,n){var r=t;const a=r.indexOf(e);a>=0&&(r=r.slice(a+1));const i=r.lastIndexOf(n);return i>=0&&(r=r.slice(0,i)),r}function BJA_isValidBase64(t){t=t.trim();if(!/^[A-Za-z0-9+/]*={0,2}$/.test(t))return!1;if(t.length%4!=0)return!1;const e=t.indexOf("=");if(-1!==e){if(e<t.length-2)return!1;if((t.match(/=/g)||[]).length>2)return!1}return!0}function BJA_decodeBase64(t,e=null){var n=null;try{n=atob(t)}catch(t){n=e}return n}function BJA_encodeToBase64(t,e=null){var n=null;try{n=btoa(t)}catch(t){n=e}return n}function BJA_UpdateThemeCallback(){}function BJA_addThemeChangListener(t){var e=!1;if(!window)return e;try{window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change",null!=t?t:BJA_UpdateThemeCallback),window.matchMedia("(prefers-color-scheme: light)").addEventListener("change",null!=t?t:BJA_UpdateThemeCallback),e=!0}catch(t){}return e}function BJA_GetElementToTop(t){for(var e=t.offsetTop;t=t.offsetParent;)e+=t.offsetTop;return e}function BJA_getImageUrlAndConfigLazy(t,e,n,r,a){var i=null;var o=null!=r?r:[];for(let r=0;r<e.length;r++){var l=e[r],s=BJA_ele_getStringAttribute(t,l);if(BJA_isString(s)&&s.length>5&&!s.startsWith("data:image",0)){for(var u=s.toLowerCase(),c=0;c<o.length;c++){var d=o[c];if(d.startsWith("X:")){var _=d.slice("X:".length);if(BJA_isMatchByString(s,_)||s!=u&&BJA_isMatchByString(u,_)){s=null;break}}else if(s.indexOf(d)>-1||u!=s&&u.indexOf(d)>-1){s=null;break}}null!=s&&(null!=(s=null!=n?BJA_getEntireUrl(s,n):s)&&s.toLowerCase().startsWith("http")?i=s:s=null)}if(i){var h="";if(a&&window.jszGVars.imageMode>0&&null==BJA_ele_getStringAttribute(t,varAttr_addlazy)){BJA_ele_setStringAttribute(t,"zj-src",i);try{h=_app_sub_ov_lazyImageUrl()}catch(t){}for(var f=0;f<window.jszGVars.lazyImgAttrFilters.length;f++){var m=window.jszGVars.lazyImgAttrFilters[f];BJA_ele_hasAttribute(t,m)&&BJA_ele_setStringAttribute(t,m,h)}BJA_ele_setStringAttribute(t,varAttr_addlazy,"1"),BJA_ele_setIntAttribute(t,varAttr_imageMode,window.jszGVars.imageMode),window.jszGVars.lazyImageCount+=1}if(window.jszGVars.addImageClickEvent&&null==BJA_ele_getStringAttribute(t,varAttr_addclickevent))try{t.addEventListener("click",function(e){e.preventDefault(),e.stopPropagation(),_app_sub_ov_ImageClick(t,i)}),BJA_ele_setStringAttribute(t,varAttr_addclickevent,"1")}catch(t){}break}}if("function"==typeof _app_sub_ov_image_handler)try{_app_sub_ov_image_handler(t,i)}catch(t){}return i}function BJA_addPCSearchBar(t){if(null!=t&&null==BJA_ele_getStringAttribute(t,"addpcsearch")){var e,n,r;null==(r=localStorage.getItem("txtSearch"))&&(r="");var a=document.createElement("select");a.id="selSearch",a.options.add(new Option("百度","baidu")),a.options.add(new Option("必应","bing")),a.options.add(new Option("谷歌","google")),a.onchange=function(){e=" "+a.value+"站内搜索",""==i.value|" bing站内搜索"==i.value|" google站内搜索"==i.value|" baidu站内搜索"==i.value&&(i.value=e)};var i=document.getElementsByName("q")[0];switch(t.insertBefore(a,i),BJA_ele_setStringAttribute(t,"addpcsearch","1"),e=" "+r+"站内搜索",r){case"baidu":a.options[0].selected=!0;break;case"bing":a.options[1].selected=!0;break;case"google":a.options[2].selected=!0;break;default:a.options[0].selected=!0}i.onfocus=function(){i.value==e&&(i.value="")},i.onblur=function(){""==i.value&&(i.value=e)},i.value=e,document.getElementsByName("sa")[0].onclick=function(){if(""==(n=i.value)|" google站内搜索"==n|" baidu站内搜索"==n|" bing站内搜索"==i.value)return!1;switch(localStorage.setItem("txtSearch",a.value),a.value){case"baidu":window.open("https://www.baidu.com/s?wd= site:"+encodeURIComponent(location.hostname)+" "+encodeURIComponent(n),"","");break;case"bing":window.open("https://cn.bing.com/search?q=site:"+encodeURIComponent(location.hostname)+" "+encodeURIComponent(n),"","");break;case"google":window.open("https://www.google.com/search?hl=zh-CN&client=opera&q=site:"+encodeURIComponent(location.hostname)+" "+encodeURIComponent(n),"","");break;default:window.open("https://www.baidu.com/s?wd= site:"+encodeURIComponent(location.hostname)+" "+encodeURIComponent(n),"","")}return!1}}}function BJA_isImageExtensionUrl(t=null){var e=!1,n=BJA_URI_pathname(t);if(null!=n&&n.indexOf(".")>-1){var r=n.split(".").pop().toLowerCase();e=["jpg","jpeg","png","gif","bmp","svg","webp","tiff","tif"].indexOf(r)>-1}return e}function BJA_isImagePage(){return BJA_isImageExtensionUrl()}function BJA_documentIsImage(){var t=null;try{var e=document.head.childElementCount;if(e>=1&&e<3&&1==document.body.childElementCount){for(var n=0,r=document.head.childNodes,a=document.body.childNodes,i=0;i<r.length;i++)"title"==r[i].tagName.toLowerCase()?n++:"style"==r[i].tagName.toLowerCase()&&n++;t=n>=1&&"img"==a[0].tagName.toLowerCase()}else t=!1}catch(t){}return t}function _app_private_updateImageMode(t){var e=0;try{t!=window.jszGVars.imageMode?(window.jszGVars.imageMode=t,e=1):e=2,window.jszGVars.imageMode>-1&&"function"==typeof _app_sub_def_imageModeChanged&&_app_sub_def_imageModeChanged(t)}catch(t){}return e}function _app_private_updateAutoImageGallery(t){var e=0;try{t!=window.jszGVars.autoImageGallery?(window.jszGVars.autoImageGallery=t,e=1):e=2,1==e&&"function"==typeof _app_sub_def_AutoImageGalleryChanged&&_app_sub_def_AutoImageGalleryChanged(t)}catch(t){}return e}function _app_private_updateBlacklistMode(t){var e=0;try{t>=0&&t<=3&&(t!=window.jszGVars.blacklistMode?(window.jszGVars.blacklistMode=t,e=1):e=2,window.jszGVars.blacklistMode>-1&&"function"==typeof _app_sub_def_blacklistModeChanged&&_app_sub_def_blacklistModeChanged(t))}catch(t){}return e}function _app_updateThemeMode(t,e,n,r,a){var i=0,o=0,l=BJA_parseInt(t);if(l>=0&&l<=3)try{l!=window.jszGVars.appThemeMode&&(window.jszGVars.appThemeMode=l,o++),i++}catch(t){}var s=BJA_parseInt(e);if(1==s||0==s)try{s!=window.jszGVars.sysThemeDarkMode&&(window.jszGVars.sysThemeDarkMode=s,o++),i++}catch(t){}var u=BJA_parseInt(n);if(u>=1&&u<=2)try{u!=window.jszGVars.uatype&&(window.jszGVars.uatype=u,o++),i++}catch(t){}var c=BJA_parseInt(r);if(c>=0)try{if(c!=window.jszGVars.imageMode)2==(_=_app_private_updateImageMode(c))&&o++;i++}catch(t){}i>0&&0==window.jszGVars.themeInit&&(window.jszGVars.themeInit=!0),_app_autoTheme();try{0==window.jszGVars.domReady&&null!=BJA_DocumentBody()&&_bja_private_domReadyFunc(4)}catch(t){}try{var d=BJA_isJSON(a);if(d&&BJA_isArray(d)&&d.length>0){var _,h=d[0],f=BJA_parseInt(h);2==(_=_app_private_updateAutoImageGallery(0!=f))?(o++,i++):1==_&&i++,2==(_=_app_private_updateBlacklistMode(f=BJA_parseInt(h=d[1])))?(o++,i++):1==_&&i++,_app_sub_ov_updateParam(d)}}catch(t){}try{_app_autoExtensionJS()}catch(t){}var m=new Object;return m.rc=i,m.update=o,BJA_objToJSONString(m)}function _app_autoExtensionJS(){try{if(0==window.jszGVars.extensionJsDoing){window.jszGVars.extensionJsDoing=!0;var t=BJA_DocumentBody();if(t||(t=BJA_DocumentHead()),t)if(null==document.querySelector("script[id='_app_extension_js']")){var e=_app_sub_ov_SiteExtensionJS();if(e&&BJA_isString(e)&&e.length>5){var n=BJA_decodeBase64(e);if(n&&BJA_isString(n)&&n.length>5){var r=document.createElement("script");r.setAttribute("type","text/javascript"),r.setAttribute("id","_app_extension_js"),r.innerHTML="",r.appendChild(document.createTextNode(n)),t.appendChild(r)}}}window.jszGVars.extensionJsDoing=!1}}catch(t){window.jszGVars.extensionJsDoing=!1}}function _app_autoTheme(){try{if(0==window.jszGVars.themeInit)return}catch(t){}if(window.jszGVars.themedoing)return!1;if(window.jszGVars.themedoing=!0,window.jszGVars.themeUpdateCount+=1,null==document)return window.jszGVars.themedoing=!1,!1;if(null==BJA_DocumentHead())return window.jszGVars.themedoing=!1,!1;var t=_app_sub_ov_currentSiteType();if(t<1)return window.jszGVars.themedoing=!1,!1;var e=BJA_isPrefersColorScheme(),n=BJA_getTheme(),r=document.querySelector("style[id='theme_css']");if(null!=r){var a=!0,i=BJA_ele_getIntAttribute(r,"sysThemeMode"),o=BJA_ele_getIntAttribute(r,"tcsflag");null!=o&&t==o&&null!=i&&i==n&&(a=!1),a&&(BJA_removeNode(r),r=null)}var l=!1,s=!1,u=!0,c=window.jszGVars.appThemeMode;if(0==c?"light"==n&&(u=!1):1==c?u=!1:2==c&&"light"==n&&(s=!0),u){if(r&&s){var d=BJA_ele_getIntAttribute(r,"tmodifyflag");if(null==d||1!=d)(f=r.textContent).length>=50&&(f=f.slice(0,50)),f.indexOf("prefers-color-scheme: light")<0&&(BJA_removeNode(r),r=null)}if(null==r){var _=BJA_DocumentHead();if(_)try{var h=_app_sub_ov_ThemeEncodeCss(1==t);if(null!=h&&h.length>0){var f=BJA_decodeBase64(h,h),m=_app_sub_ov_ThemeExtensionEncodeCss(1==t);null!=m&&m.length>0&&(f=BJA_mergeMediaCSS(f,m)),e?s&&(f=f.replace("prefers-color-scheme: dark","prefers-color-scheme: light")):f=BJA_removeCSSPerfersColorSchemePrefix(f);var g=document.createElement("style");g.setAttribute("type","text/css"),g.setAttribute("id","theme_css"),g.setAttribute("tcsflag",t),g.setAttribute("sysThemeMode",n||""),s&&g.setAttribute("tmodifyflag",1),g.innerHTML="",g.appendChild(document.createTextNode(f)),_.appendChild(g),window.jszGVars.themeUpdatedCount+=1,l=!0,_app_sub_ov_sendMsgToApp([{theme:"1"}]),_app_sub_ov_ThemeInstalled(1==t,!0)}}catch(t){}}else _app_sub_ov_sendMsgToApp([{theme:"2"}])}else r&&(BJA_removeNode(r),r=null,window.jszGVars.themeUpdatedCount-=1,_app_sub_ov_sendMsgToApp([{theme:"3"}])),l=!0,_app_sub_ov_ThemeInstalled(1==t,!1);return window.jszGVars.themedoing=!1,l}function _bja_private_setLazyLoadingImages(){try{if(window.jszGVars.imageMode>0){let e=BJA_GetURL();var t=document.querySelectorAll("img");t.forEach(t=>{null==BJA_ele_getStringAttribute(t,varAttr_addlazy)&&(null!=BJA_getImageUrlAndConfigLazy(t,window.jszGVars.imgAttrs,e,window.jszGVars.imgUrlFilters,!0)&&0)})}}catch(t){}}function _app_jsz_autoImages(t=!1,e=null){var n=new Object,r=0;n.url=BJA_GetURL();var a=[];if(null!=e)!0,e.forEach(t=>{try{for(var e=0;e<window.jszGVars.addImageContentSels.length;e++){var r=BJA_xpathQuerySelector(t,window.jszGVars.addImageContentSels[e],!0);if(null!=r&&r.length>0)for(var i=0;i<r.length;i++){var o;null!=(o=BJA_getImageUrlAndConfigLazy(r[i],window.jszGVars.imgAttrs,n.url,window.jszGVars.imgUrlFilters,!0))&&a.indexOf(o)<0&&a.push(o)}}}catch(t){}}),a.length>0&&(window.jszGVars.images=window.jszGVars.images.concat(a),r=window.jszGVars.images.length,window.jszGVars.imageCount=r,_app_sub_ov_sendMsgToApp([{imageCount:r}]));else if(t||0==window.jszGVars.images.length)try{var i=[],o=_app_sub_ov_imgContentSels();null!=o&&BJA_isArray(o)&&(i=i.concat(o)),null!=window.jszGVars.imgContentSels&&BJA_isArray(window.jszGVars.imgContentSels)&&(i=i.concat(window.jszGVars.imgContentSels)),i=BJA_ArrayDeduplication(i);for(var l=0;l<i.length;l++){var s=i[l];if(null!=(d=BJA_xpathQuerySelector(document,s,!0))&&BJA_isArray(d)&&d.length>0){for(var u=0;u<d.length;u++){var c=null;null!=(c=BJA_getImageUrlAndConfigLazy(d[u],window.jszGVars.imgAttrs,n.url,window.jszGVars.imgUrlFilters,!0))&&a.indexOf(c)<0&&a.push(c)}break}}try{var d=[],_=BJA_arrayFromNodeList(_app_sub_ov_imgNodes());null!=_&&_.length>0&&d.concat(_);try{if("function"==typeof _app_sub_def_imgNodesFunc){var h=BJA_arrayFromNodeList(_app_sub_def_imgNodesFunc());if(null!=h&&h.length>0){var f=d.length>0;d.concat(h),f&&(d=BJA_ArrayDeduplication(d))}}}catch(t){}if(d&&d.length>0)for(u=0;u<d.length;u++){c=null;null!=(c=BJA_getImageUrlAndConfigLazy(d[u],window.jszGVars.imgAttrs,n.url,window.jszGVars.imgUrlFilters,!0))&&a.indexOf(c)<0&&a.push(c)}}catch(t){}window.jszGVars.images=a,r=a.length,window.jszGVars.imageCount!=r&&(window.jszGVars.imageCount=r,_app_sub_ov_sendMsgToApp([{imageCount:r}]))}catch(t){}return n.images=window.jszGVars.images,n.count=r>0?r:n.images.length,n}function _bja_private_ImageLazyloadShow(){if(window.jszGVars.imageMode<2)return;var t=document.querySelectorAll("img[addlazy='1']");let e=document.documentElement.clientHeight||document.body.clientHeight,n=document.documentElement.scrollTop||document.body.scrollTop;for(let o=window.jszGVars.lazyImageShowIndex;o<t.length;o++){var r=t[o];if(!(BJA_GetElementToTop(r)<n+e))break;var a=BJA_ele_getStringAttribute(r,"zj-src");BJA_ele_getStringAttribute(r,"src")!=a&&(r.src=a);for(let t=0;t<window.jszGVars.lazyImgAttrFilters.length;t++){var i=window.jszGVars.lazyImgAttrFilters[t];BJA_ele_hasAttribute(r,i)&&BJA_ele_setStringAttribute(r,i,a)}window.jszGVars.lazyImageShowIndex++}}
var _jszDiscuzPcdark = "QG1lZGlhIChwcmVmZXJzLWNvbG9yLXNjaGVtZTogZGFyaykgewpib2R5IHtiYWNrZ3JvdW5kOmJsYWNrIWltcG9ydGFudDsgYmFja2dyb3VuZC1jb2xvcjogYmxhY2shaW1wb3J0YW50O2NvbG9yOiB3aGl0ZSFpbXBvcnRhbnQ7IH0KLndwIHsgYmFja2dyb3VuZDpibGFjayFpbXBvcnRhbnQ7IGJhY2tncm91bmQtY29sb3I6IGJsYWNrIWltcG9ydGFudDsgY29sb3I6IHdoaXRlIWltcG9ydGFudDt9CiN0b3B0YiB7IGJhY2tncm91bmQtY29sb3I6IGJsYWNrIWltcG9ydGFudDsgY29sb3I6IHdoaXRlIWltcG9ydGFudDt9CiNoZCB7YmFja2dyb3VuZC1jb2xvcjogYmxhY2shaW1wb3J0YW50OyBjb2xvcjogd2hpdGUhaW1wb3J0YW50OyBib3JkZXItYm90dG9tOiMzMzMhaW1wb3J0YW50OyB9CiNzY2JhciB7IGJhY2tncm91bmQtY29sb3I6ICMzNTMyMzIhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiAjMzUzMjMyIWltcG9ydGFudDsgYm9yZGVyLXRvcDoxcHggc29saWQgYmxhY2shaW1wb3J0YW50OyBib3JkZXItYm90dG9tOjFweCBzb2xpZCAjMzUzMjMyIWltcG9ydGFudDsgfQojbnYge2JhY2tncm91bmQ6YmxhY2shaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6IHJnYig3NCwgNTEsIDUxKSFpbXBvcnRhbnQ7IH0KI3NjYmFyX2J0biB7YmFja2dyb3VuZDojMjExOTE5IWltcG9ydGFudDsgYmFja2dyb3VuZC1jb2xvcjogIzIxMTkxOSFpbXBvcnRhbnQ7IH0KI3NjYmFyX3R5cGUge2JvcmRlcjogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiAjMjExOTE5IWltcG9ydGFudDt9Ci5wbmMge2JhY2tncm91bmQ6YmxhY2shaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6IHJnYig3NCwgNTEsIDUxKSFpbXBvcnRhbnQ7Y29sb3I6IGdyYXkhaW1wb3J0YW50OyB9CiNwZ3NidG4geyBiYWNrZ3JvdW5kOmJsYWNrIWltcG9ydGFudDtiYWNrZ3JvdW5kLWNvbG9yOiByZ2IoNzQsIDUxLCA1MSkhaW1wb3J0YW50O2NvbG9yOiBncmF5IWltcG9ydGFudDsgfQojcW1lbnUge2JhY2tncm91bmQ6YmxhY2shaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6IGJsYWNrIWltcG9ydGFudDtjb2xvcjogZ3JheTt9CmEge2NvbG9yOiAjYzZiM2IzIWltcG9ydGFudDt9CmlucHV0IHtjb2xvcjojZWJkZGRkIWltcG9ydGFudDsgY2FyZXQtY29sb3I6IHJlZCFpbXBvcnRhbnQ7IGJhY2tncm91bmQ6IzIzMjAyOSFpbXBvcnRhbnQ7IH0KLnhnMSB7Y29sb3I6I2ViZGRkZCFpbXBvcnRhbnQ7IGNhcmV0LWNvbG9yOiByZWQhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiMyMzIwMjkhaW1wb3J0YW50O30KLnB4IHsgY29sb3I6I2ViZGRkZCFpbXBvcnRhbnQ7IGNhcmV0LWNvbG9yOiByZWQhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiMyMzIwMjkhaW1wb3J0YW50OyB9Ci5wbHMgeyBiYWNrZ3JvdW5kOmJsYWNrIWltcG9ydGFudDtiYWNrZ3JvdW5kLWNvbG9yOiBibGFjayFpbXBvcnRhbnQ7Ym9yZGVyLXJpZ2h0OjFweCBzb2xpZCAjMzMzIWltcG9ydGFudDt9Ci5waSB7IGJvcmRlci1ib3R0b206MXB4IGRhc2hlZCAjMzMzIWltcG9ydGFudDt9Ci5ibSB7Ym9yZGVyOjFweCBzb2xpZCAjMzMzIWltcG9ydGFudDtiYWNrZ3JvdW5kOiMzNTMyMzIhaW1wb3J0YW50O30KLnBnIGEsLnBnIHN0cm9uZywgLnBnYiBhLCAucGcgbGFiZWwgeyBib3JkZXItY29sb3I6Z3JheSFpbXBvcnRhbnQ7IGJhY2tncm91bmQtY29sb3I6YmxhY2shaW1wb3J0YW50O30KLmFkIC5wbGMge2JhY2tncm91bmQ6IzE1MTQxNCFpbXBvcnRhbnQ7fQoucGwgLnF1b3RlIHsgYmFja2dyb3VuZDojMGIwNjA2IWltcG9ydGFudDsgfQoudGVkdCAucHR7YmFja2dyb3VuZDojMzYzMzMzIWltcG9ydGFudDsgfQoudGVkdCAuYXJlYSB7IGJhY2tncm91bmQ6IzM2MzMzMyFpbXBvcnRhbnQ7fQouZWR0IC5wdCB7IGJhY2tncm91bmQ6IzM2MzMzMyBub25lIWltcG9ydGFudDt9Ci5lZHQge2JvcmRlci1jb2xvcjojOTk5ICNDQ0MgI0NDQyAjOTk5IWltcG9ydGFudDt9Ci5lZHQgLmJhciB7Ym9yZGVyLWJvdHRvbToxcHggc29saWQgcmVkIWltcG9ydGFudDtiYWNrZ3JvdW5kOiMzNjMzMzMhaW1wb3J0YW50OyB9Ci5lZHQgLmNzdCB7IGJhY2tncm91bmQ6IzM2MzMzMyFpbXBvcnRhbnQ7Ym9yZGVyLWJvdHRvbToxcHggc29saWQgI0E5MDAwMCFpbXBvcnRhbnQ7fQoudGVkdCAuYmFyIHtib3JkZXItYm90dG9tOjFweCBzb2xpZCAjMzMzIWltcG9ydGFudDtiYWNrZ3JvdW5kOiMzNjMzMzMhaW1wb3J0YW50OyB9Ci5wbyB7Ym9yZGVyLXRvcDoxcHggZGFzaGVkIHdoaXRlIWltcG9ydGFudDt9CiNzY2Jhcl90eHQge2JvcmRlcjoxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQouYmJkYSB7IGJvcmRlci1ib3R0b206MXB4IGRhc2hlZCAjNzA2YzZjIWltcG9ydGFudDt9Ci5idGRhIHsgYm9yZGVyLXRvcDoxcHggZGFzaGVkICM3MDZjNmMhaW1wb3J0YW50O30KLmJicyB7IGJvcmRlci1ib3R0b206MXB4IHNvbGlkICM3MDZjNmMhaW1wb3J0YW50O30KLmJ0cyB7Ym9yZGVyLXRvcDoxcHggZGFzaGVkICNBOTAwMDAhaW1wb3J0YW50O30KLnBfcG9wLC5wX3BvZiwuc2xsdCB7Ym9yZGVyLWNvbG9yOiM3MDZjNmMhaW1wb3J0YW50O2JhY2tncm91bmQ6IzA5MDkwOSFpbXBvcnRhbnQ7fQoucF9wb3AgYSB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMyMjIhaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6ICMwMDAhaW1wb3J0YW50O30KLnBfcG9wIGE6aG92ZXIsLnBfcG9wIGE6Zm9jdXMgIHtiYWNrZ3JvdW5kLWNvbG9yOiAjNjY2IWltcG9ydGFudDt9Ci5qdW1wX2JkbCBsaSB7Ym9yZGVyOjFweCBzb2xpZCAjNzA2YzZjIWltcG9ydGFudDsgYmFja2dyb3VuZDojMzYzMzMzIWltcG9ydGFudDt9Ci5qdW1wX2JkbCAuYSBhLC5qdW1wX2JkbCAuYSBhOmhvdmVyIHsgYmFja2dyb3VuZC1jb2xvcjojNjY1ZDVkIWltcG9ydGFudDsgfQouem9vbWlubmVyIHsgYmFja2dyb3VuZDogIzM2MzMzMyFpbXBvcnRhbnQ7IHRleHQtYWxpZ246IGxlZnQ7fQoucG4geyBiYWNrZ3JvdW5kOiAjMzYzMzMzIWltcG9ydGFudDsgYm94LXNoYWRvdzogMCAxcHggMCAjMzMzIWltcG9ydGFudDt9CmJ1dHRvbiB7YmFja2dyb3VuZDogIzM2MzMzMyFpbXBvcnRhbnQ7IH0KYm9keSwgaW5wdXQsIGJ1dHRvbiwgc2VsZWN0LCB0ZXh0YXJlYSB7IGNvbG9yOiAjZTllOWU5IWltcG9ydGFudDsgYm9yZGVyOjFweCBzb2xpZCAjMzMzIWltcG9ydGFudDtiYWNrZ3JvdW5kLWNvbG9yOiAjMTMxMzEzIWltcG9ydGFudDsgfQojdG9wdGIge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzMzIWltcG9ydGFudDt9CiNwX2J0biBhIHtiYWNrZ3JvdW5kOiAjMTUxNzE5IWltcG9ydGFudDt9Ci50aXAge2JvcmRlcjogMXB4IHNvbGlkICNhOGE4OTkhaW1wb3J0YW50O2JhY2tncm91bmQ6ICMyNjI2MjMhaW1wb3J0YW50O30KLnBnYnRuIGEge2JvcmRlcjogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50OyBib3gtc2hhZG93OiAwIDFweCAwICMzMzM7fQouYm1faCB7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50O2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzMzIWltcG9ydGFudDtiYWNrZ3JvdW5kOiAjMzMzIWltcG9ydGFudDt9Ci50dHAgLmEgYSB7Ym9yZGVyLWNvbG9yOiAjYTkwMDAwIWltcG9ydGFudDtiYWNrZ3JvdW5kOiAjMjExOTE5IWltcG9ydGFudDtjb2xvcjogI2E5MDAwMCFpbXBvcnRhbnQ7fQoudHRwIGEsIC50dHAgc3Ryb25nIHtib3JkZXI6IDFweCBzb2xpZCAjNWQ1NDU0IWltcG9ydGFudDtiYWNrZ3JvdW5kOiAjMDYwNjA2IWltcG9ydGFudDt9Ci50bCAudGgge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjNjY2MTYxIWltcG9ydGFudDtiYWNrZ3JvdW5kOiAjMzUzMjMyIWltcG9ydGFudDt9Ci50bCB0cjpob3ZlciB0aCwgLnRsIHRyOmhvdmVyIHRkIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMzUzMjMyIWltcG9ydGFudDt9Ci50bCAudHMgdGgsIC50bCAudHMgdGQgeyBib3JkZXItYm90dG9tLWNvbG9yOiAjNjY2MTYxIWltcG9ydGFudDtiYWNrZ3JvdW5kOiAjNjY2MTYxIWltcG9ydGFudDt9Ci5zbHRtIHtib3JkZXI6IDFweCBzb2xpZCAjMzMzIWltcG9ydGFudDtiYWNrZ3JvdW5kLWNvbG9yOiAjMTMxMzEzIWltcG9ydGFudDtib3gtc2hhZG93OiAycHggNHB4IDRweCByZ2JhKDAsMCwwLDAuMikhaW1wb3J0YW50O30KLmZ0aWQgYSB7dGV4dC1kZWNvcmF0aW9uOiBub25lIWltcG9ydGFudDtjb2xvcjogIzQ0NCFpbXBvcnRhbnQ7Ym9yZGVyOiAxcHggc29saWQ7Ym9yZGVyLWNvbG9yOiAjODQ4NDg0ICMzMzMgIzMzMyAjMzMzIWltcG9ydGFudDsKICAgIGJhY2tncm91bmQ6ICMxMzEzMTMgdXJsKCJkYXRhOmltYWdlL3N2Zyt4bWwsJTNjc3ZnIHhtbG5zPSdodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2Zycgd2lkdGg9JzE3JyBoZWlnaHQ9JzEzJyUzZSUzY3BhdGggZmlsbD0nJTIzOTk5JyBkPSdNMTAgNSBoLTcgbDMuNSA0eicvJTNlJTNjL3N2ZyUzZSIpIG5vLXJlcGVhdCAxMDAlIDRweCFpbXBvcnRhbnQ7fQoucmZtIHtib3JkZXItYm90dG9tOiAxcHggZG90dGVkICMzMzMhaW1wb3J0YW50O30KLmNoaXBfaW5kZXhfenVpeGluIC50bXBhZCB7YmFja2dyb3VuZDogIzM1MzIzMiFpbXBvcnRhbnQ7fQouY2hpcGhlbGxfaW5kZXhfbmV3cyAuYWNvbiB7YmFja2dyb3VuZDogIzM1MzIzMiFpbXBvcnRhbnQ7fQouY2hpcF9pbmRleF9waW5nY2UgLnRtcGFkIHtiYWNrZ3JvdW5kOiAjMzUzMjMyIWltcG9ydGFudDt9Ci5jaGlwX2luZGV4X3p1aXhpbiBsaSAuYXZpbWFpbiAuYXNvcnQge2JhY2tncm91bmQ6ICMyMTE5MTkhaW1wb3J0YW50O30KLmxvb2ttb3JlIGEge2JvcmRlcjogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50O2JhY2tncm91bmQ6ICMyMTE5MTkhaW1wb3J0YW50O30KLmNoaXBfaW5kZXhfcGluZ2NlIGxpIC5hdmltYWluMiAuYXNvcnQge2JhY2tncm91bmQ6ICMyMTE5MTkhaW1wb3J0YW50O30KICAgIGRpdi5yZm0gc2VsZWN0IHtib3JkZXItY29sb3I6ICMyMzIwMjkhaW1wb3J0YW50O2JhY2tncm91bmQ6ICNkYTNlM2UhaW1wb3J0YW50O30KLnZ3IC5kIHtjb2xvcjogI2U5MGUwZSFpbXBvcnRhbnQ7fQoud2F0ZXJmYWxsIGxpIHtib3JkZXItdG9wOiAxcHggc29saWQgIzY2NjE2MSFpbXBvcnRhbnQ7fQoud2F0ZXJmYWxsIC5jLCAud2F0ZXJmYWxsIGgzIHtib3JkZXI6IHNvbGlkICM2NjYxNjEhaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6ICMzNTMyMzIhaW1wb3J0YW50O30KLndhdGVyZmFsbCAuYXV0aCB7Ym9yZGVyLWNvbG9yOiB0cmFuc3BhcmVudCAjNjY2MTYxICM2NjYxNjEhaW1wb3J0YW50O2JhY2tncm91bmQ6ICMzNTMyMzIhaW1wb3J0YW50O30KZGl2I3RocmVhZGxpc3QudGwgdGQsIC50bCB0aCB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICM2NjYxNjEhaW1wb3J0YW50O30KI3VoZCB7Ym9yZGVyOiAxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7YmFja2dyb3VuZDogIzM1MzIzMiFpbXBvcnRhbnQ7fQouZnJhbWUsIC5mcmFtZS10YWIge2JhY2tncm91bmQ6ICMzNTMyMzIhaW1wb3J0YW50OyBib3JkZXI6IDFweCBzb2xpZCAjMzUzMjMyIWltcG9ydGFudDt9Ci52dyAucGgge2NvbG9yOiAjZjFmN2Y3IWltcG9ydGFudDt9Ci5wZyBsYWJlbCBzcGFuIHtjb2xvcjogI2M2YjNiMyFpbXBvcnRhbnQ7fQoucHN0aCB7YmFja2dyb3VuZDogIzIxMTkxOSFpbXBvcnRhbnQ7fQojc2Nyb2xsdG9wIHtiYWNrZ3JvdW5kOiAjMjUyNTI1IWltcG9ydGFudDsgYm9yZGVyOiAxcHggIzMzMyBzb2xpZCFpbXBvcnRhbnQ7fQojc2Nyb2xsdG9wIGEge2NvbG9yOiAjQkJCOyBib3JkZXItdG9wOiAxcHggIzMzMyBzb2xpZCFpbXBvcnRhbnQ7fQoucGkgc3Ryb25nIGEge2JvcmRlcjogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50O30KLnJhdGwgLnh3MSAueGkxIHtiYWNrZ3JvdW5kOiAjMzMzIWltcG9ydGFudDt9Ci5tX2Mge2JhY2tncm91bmQ6ICMyNTI1MjUhaW1wb3J0YW50O30KYnV0dG9uI2Zhc3Rwb3N0c3VibWl0IHsgYmFja2dyb3VuZDogI0E5MDAwMCFpbXBvcnRhbnQ7IGNvbG9yOiAjZWNjIWltcG9ydGFudDsgYm94LXNoYWRvdzogMCAxcHggMCAjMDBlOTBlMGUhaW1wb3J0YW50O30KLnN0dGwge21hcmdpbjogMTBweCAwO3BhZGRpbmc6IDVweDtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzJlMjkyOSFpbXBvcnRhbnQ7YmFja2dyb3VuZDogIzJlMjkyOSFpbXBvcnRhbnQ7IH0KLm5mbCAuZl9jIHtib3JkZXI6IDNweCBzb2xpZCAjMjUyNTI1IWltcG9ydGFudDtiYWNrZ3JvdW5kOiAjMjUyNTI1IWltcG9ydGFudDt9CmJ1dHRvbiNhZGRzdWJtaXRfYnRuIHsgYmFja2dyb3VuZDogI0E5MDAwMCFpbXBvcnRhbnQ7IGNvbG9yOiAjZWNjIWltcG9ydGFudDsgYm94LXNoYWRvdzogMCAxcHggMCAjMDBlOTBlMGUhaW1wb3J0YW50O30KLm1fYyAubyB7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50O2JhY2tncm91bmQ6ICMyNTI1MjUhaW1wb3J0YW50O30KLnB4LCAucHQsIC5wcywgc2VsZWN0IHtib3JkZXI6IDFweCBzb2xpZDtib3JkZXItY29sb3I6ICMzMzMgIzMzMyAjMzMzICMzMzMhaW1wb3J0YW50O2JhY2tncm91bmQ6ICMyNTI1MjUhaW1wb3J0YW50O30KLnBtIC5jIHtiYWNrZ3JvdW5kOiAjMjUyNTI1IWltcG9ydGFudDt9Ci5wbV90YWMge2JhY2tncm91bmQ6ICM1NDFkMWQhaW1wb3J0YW50O30KLnBtIC5mbGIge2JhY2tncm91bmQ6ICMzMzMhaW1wb3J0YW50O30KLnRiIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzBkMGMwYyFpbXBvcnRhbnQ7fQojdWhkIC50YiBhIHtib3JkZXItdG9wLWNvbG9yOiAjMzMzIWltcG9ydGFudDtib3JkZXItYm90dG9tLWNvbG9yOiAjMzMzIWltcG9ydGFudDt9Ci50YiBhe2JvcmRlcjogMHB4IHNvbGlkICMzMzMhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiAjMGQwYzBjIWltcG9ydGFudDsgfQoudGIgLmEgYSwgLnRiIC5jdXJyZW50IGEge2JvcmRlci1ib3R0b20tY29sb3I6ICMzMzMhaW1wb3J0YW50O2JhY2tncm91bmQ6ICMyYTI1MjUhaW1wb3J0YW50O30KLmF2dCBpbWcge2JhY2tncm91bmQ6ICMzMzMhaW1wb3J0YW50O2JvcmRlci1jb2xvcjogIzA1MDUwNSAjMDYwNTA1ICMwNjA1MDUgIzA1MDUwNSFpbXBvcnRhbnQ7fQoucGxzIC5hdmF0YXIgaW1nIHtiYWNrZ3JvdW5kOiAjMzMzIWltcG9ydGFudDtib3JkZXItY29sb3I6ICMwNTA1MDUgIzA2MDUwNSAjMDYwNTA1ICMwNTA1MDUhaW1wb3J0YW50O30KLnRibiBsaS5hIHtiYWNrZ3JvdW5kOiAjMTQxMzEzIWltcG9ydGFudDt9IAoudGJuIGxpIHtib3JkZXItYm90dG9tOiAxcHggZGFzaGVkICMzMzMhaW1wb3J0YW50O30KLmN0Ml9hLCAuY3QzX2Ege2JvcmRlcjogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50O30KI2F2YXRhcmRlc2lnbmVyIHtib3JkZXI6IDFweCBzb2xpZCAjNDc0NjQ2IWltcG9ydGFudDt9Ci5kdCB0aCB7YmFja2dyb3VuZDogIzBlMGQwZCFpbXBvcnRhbnQ7fQouZHQgdGQsIC5kdCB0aCB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICM2NjYxNjEhaW1wb3J0YW50O30KLmV4Zm0ge2JvcmRlcjogMXB4IGRhc2hlZCAjYTkwMDAwIWltcG9ydGFudDtiYWNrZ3JvdW5kOiAjMmEyNTI1IWltcG9ydGFudDt9Ci5KenNqaWFsZV9Jc21zX0hlYWRlciB7YmFja2dyb3VuZDogIzFmMWIxYjt9Ci5qenNqaWFsZV9pc21zX3NlY3VyaXR5X21haW5Db2x1bW4ge2JhY2tncm91bmQ6ICM0NTQwNDAhaW1wb3J0YW50O2JvcmRlcjogMXB4IHNvbGlkICM0NTQwNDAhaW1wb3J0YW50O30KLmp6c2ppYWxlX2lzbXNfc2VjdXJpdHlfRkFRIHtiYWNrZ3JvdW5kOiAjNDU0MDQwIWltcG9ydGFudDsgIGJvcmRlcjogMXB4IHNvbGlkICM0NTQwNDAhaW1wb3J0YW50O30KLml2dS1jb2xsYXBzZS1zaW1wbGUge2JhY2tncm91bmQtY29sb3I6ICMwNjA2MDYhaW1wb3J0YW50O30KLkpDYXJkIHtiYWNrZ3JvdW5kOiAjNDU0MDQwIWltcG9ydGFudDt9Ci5qenNqaWFsZV9pc21zX3NlY3VyaXR5X21haW5Db250ZW50X3NldHRpbmcge2JvcmRlci10b3A6IDFweCBzb2xpZCAjNjY2MTYxIWltcG9ydGFudDt9Ci5JU01TRm9ybS1hY2NvdW50IHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzY2NjE2MSFpbXBvcnRhbnQ7fQouanpzamlhbGVfaXNtc19tYWluX2NvbnRlbnQgLklucHV0LXdyYXBwZXIge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjNjY2MTYxIWltcG9ydGFudDt9Ci5qenNqaWFsZV9pc21zX3NlY3VyaXR5X21haW5Db250ZW50IHtib3JkZXItbGVmdDogMXB4IHNvbGlkICM2NjYxNjEhaW1wb3J0YW50O30KLml2dS10YWJsZSB7Y29sb3I6ICM1MTVhNmUhaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6ICMxZjFiMWIhaW1wb3J0YW50O30KLml2dS10YWJsZSB0aCB7YmFja2dyb3VuZC1jb2xvcjogIzFmMWIxYiFpbXBvcnRhbnQ7fQouaXZ1LXRhYmxlIHRkIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMmEyNTI1IWltcG9ydGFudDt9Ci5pdnUtdGFibGUgdGQsIC5pdnUtdGFibGUgdGgge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMWYxYjFiIWltcG9ydGFudDt9Ci5pdnUtdGFibGU6YmVmb3JlIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMWYxYjFiIWltcG9ydGFudDt9Ci5pdnUtdGFibGU6YWZ0ZXIge2JhY2tncm91bmQtY29sb3I6ICMxZjFiMWIhaW1wb3J0YW50O30KLml2dS10YWJsZS13cmFwcGVyIHtib3JkZXI6IDFweCBzb2xpZCAjMWYxYjFiIWltcG9ydGFudDt9Ci5pdnUtcGFnZS1kaXNhYmxlZDpob3ZlciB7Ym9yZGVyLWNvbG9yOiAjMWQyYjQ3IWltcG9ydGFudDt9Ci5pdnUtcGFnZS1uZXh0LCAuaXZ1LXBhZ2UtcHJldiB7YmFja2dyb3VuZC1jb2xvcjogIzFkMWIxYiFpbXBvcnRhbnQ7fQouaXZ1LXBhZ2UtaXRlbS1qdW1wLW5leHQsIC5pdnUtcGFnZS1pdGVtLWp1bXAtcHJldiwgLml2dS1wYWdlLW5leHQsIC5pdnUtcGFnZS1wcmV2IHtib3JkZXI6IDFweCBzb2xpZCAjMWQxYjFiIWltcG9ydGFudDt9Ci5pdnUtcGFnZS1pdGVtLWFjdGl2ZSB7Ym9yZGVyLWNvbG9yOiAjMWQxYjFiIWltcG9ydGFudDt9Ci5pdnUtcGFnZS1pdGVtIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMWQxYjFiIWltcG9ydGFudDtib3JkZXI6IDFweCBzb2xpZCAjMWQxYjFiIWltcG9ydGFudDt9Ci5wbWwgLm5ld3BtIHtiYWNrZ3JvdW5kOiAjMzUzMjMyIWltcG9ydGFudDt9Ci5hbHQsIC5hbHQgdGgsIC5hbHQgdGQge2JhY2tncm91bmQtY29sb3I6ICMxZjFiMWIhaW1wb3J0YW50O30KLnRkYXRzIHRoLCAudGRhdHMgdGQge2JvcmRlci1jb2xvcjogIzQ1NDA0MCFpbXBvcnRhbnQ7fQoudGZ4IC5hbHQsIC50ZnggLmFsdCB0aCwgLnRmeCAuYWx0IHRkIHtiYWNrZ3JvdW5kOiAjMjIxZDE1IWltcG9ydGFudDt9Ci50ZnggdGgsIC50ZnggdGQge2JhY2tncm91bmQ6ICM1NzRjM2MhaW1wb3J0YW50O30KLnRkYXRzIC5oIHRoIHtib3JkZXItdG9wOiAxcHggc29saWQgIzIyMWQxNSFpbXBvcnRhbnQ7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMyMjFkMTUhaW1wb3J0YW50O2JhY2tncm91bmQ6IGxpbmVhci1ncmFkaWVudCgwZGVnLCMyMjFkMTUsIzIyMWQxNSkhaW1wb3J0YW50O30KLmFsdCwgLmFsdCB0aCwgLmFsdCB0ZCB7YmFja2dyb3VuZC1jb2xvcjogIzJhMjUyNSFpbXBvcnRhbnQ7fQoudGRhdCB0aCwgLnRkYXQgdGQge2JvcmRlcjogMXB4IHNvbGlkICM1NzQ5NDkhaW1wb3J0YW50O30KLmR0IHtib3JkZXItdG9wOiAxcHggc29saWQgIzY2NjE2MSFpbXBvcnRhbnQ7fQouZWR0IC5iYmFyIHtib3JkZXItdG9wOiAxcHggc29saWQgIzY2NjE2MSFpbXBvcnRhbnQ7YmFja2dyb3VuZDogIzY2NjE2MSFpbXBvcnRhbnQ7fQouZWR0IC5hcmVhIHtiYWNrZ3JvdW5kOiAjMzUzMjMyIWltcG9ydGFudDt9CiNwb3N0X2V4dHJhX3RiIGxhYmVsLmEge2JvcmRlci1ib3R0b20tY29sb3I6ICM0NTQwNDAhaW1wb3J0YW50O2JhY2tncm91bmQ6ICM0NTQwNDAgbm9uZSFpbXBvcnRhbnQ7fQojcG9zdF9leHRyYV90YiBsYWJlbCB7Ym9yZGVyOiAxcHggc29saWQgIzQ1NDA0MCFpbXBvcnRhbnQ7fQoudGwgI2ZvcnVtbmV3c2hvdyB7YmFja2dyb3VuZDogI0E5MDAwMCFpbXBvcnRhbnQ7fQoudGwgI2ZvcnVtbmV3c2hvdyBhIHtib3JkZXItdG9wOiAxcHggc29saWQgIzIyMWQxNSFpbXBvcnRhbnQ7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMyMjFkMTUhaW1wb3J0YW50O30KLm5ld3RocmVhZCB0ciB0ZCB7YmFja2dyb3VuZDogIzFmMWIxYiFpbXBvcnRhbnQ7fQojYXV0b3BibiB7Ym9yZGVyOiAxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQovKiBwY2JldGEgKi8KLmZsIC5ibV9jIHtiYWNrZ3JvdW5kOiAjMjIxZDE1IWltcG9ydGFudDt9CiN0b3B0YiB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMyMjFkMTUhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiAjMjIxZDE1IWltcG9ydGFudDt9CiNudiBsaSwgI2hvbWUge2JhY2tncm91bmQ6ICM1NzQ5NDkhaW1wb3J0YW50O30KI2N0IHtiYWNrZ3JvdW5kOiAjMjIxZDE1IDAgMHB4IWltcG9ydGFudDt9CiNtb29kZm0gdGV4dGFyZWE6Zm9jdXMge2JhY2tncm91bmQtY29sb3I6ICMxMjEyMTIhaW1wb3J0YW50O30KI21vb2RmbSB0ZXh0YXJlYSB7YmFja2dyb3VuZC1jb2xvcjogIzEyMTIxMiFpbXBvcnRhbnQ7fQoudGwgdGgsIC50bCB0ZCB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICM2NjYxNjEhaW1wb3J0YW50O30KLmFwcGwge2JvcmRlcjogMXB4IHNvbGlkICMyMzIzMjMhaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6ICMyMzIzMjMhaW1wb3J0YW50O30KLm1sYSAuYyB7YmFja2dyb3VuZDogIzMzMyFpbXBvcnRhbnQ7Ym94LXNoYWRvdzogMXB4IDFweCAycHggIzMzMyFpbXBvcnRhbnQ7fQouYm1faCAubyBpbWcsIC5ibV9oIC5vIGVtIHtjb2xvcjogI2U0MGUwZSFpbXBvcnRhbnQ7fQojZV9zaW1wbGUsICNlX2Z1bGxzd2l0Y2hlciB7Ym9yZGVyOiAxcHggc29saWQgIzIzMjMyMyFpbXBvcnRhbnQ7IGJhY2tncm91bmQ6ICM2NjYxNjEhaW1wb3J0YW50O30KLmVkdCAuYmFyIGEge2JvcmRlcjogMXB4IHNvbGlkICMwMDAwMDAhaW1wb3J0YW50O30KLmVkdCAuYjFyLCAuZWR0IC5iMnIge2JvcmRlci1yaWdodDogMXB4IHNvbGlkICMwMDAwMDAhaW1wb3J0YW50O2JvcmRlci1sZWZ0OiAxcHggc29saWQgIzAwMDAwMCFpbXBvcnRhbnQ7fQouZWR0IC5idG4ge2JvcmRlci1yaWdodDogMXB4IHNvbGlkICMwMDAwMDAhaW1wb3J0YW50O30KLmNoYXJ0IGVtIHtjb2xvcjogIzY2NjE2MSFpbXBvcnRhbnQ7fQojZnRiZyB7YmFja2dyb3VuZDogIzEzMTMxMyFpbXBvcnRhbnQ7fQovKiBuYjUgKi8KLm5nZV9hY3RpdmUge2JhY2tncm91bmQ6ICM1MDUwNTAhaW1wb3J0YW50O2JvcmRlci1yaWdodDogMXB4IHNvbGlkICM2MDYwNjAhaW1wb3J0YW50O2NvbG9yOiAjZmZmIWltcG9ydGFudDt9Ci5uZ2VfaW5hY3RpdmUge2JhY2tncm91bmQ6ICM2MDYwNjAhaW1wb3J0YW50O2JvcmRlci1yaWdodDogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50O2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjNjA2MDYwIWltcG9ydGFudDt9CmRpdiNjYXRlZ29yeV9zdHVkeV9uZ2UgZGl2IHRhYmxlIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQoubmdlX2JvcmRlcl9yaWdodCB7Ym9yZGVyLXJpZ2h0OiAxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQouaXQ2MThzZWxlY3Qge2JvcmRlcjogMXB4IHNvbGlkICMyMzIzMjMhaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6ICMyMzIzMjMhaW1wb3J0YW50O2NvbG9yOiAjNTU1IWltcG9ydGFudDt9Ci5sb2dpbnRhYmxlIHRyIHRkLnRkcmVnYm9keSB0YWJsZSB0ciB0ZC50ZGxlZnR0aXRsZSB7Y29sb3I6ICNjNmIzYjMhaW1wb3J0YW50O30KLmxvZ2ludGFibGUgdHIgdGQudGRyZWdib2R5IHRhYmxlIHRyIHRkIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQoubG9naW50YWJsZSB0ciB0ZCB7Ym9yZGVyOiAxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQoubG9naW50YWJsZSB0ciB0ZC50ZHJlZ3RpdGxlIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMzMzIWltcG9ydGFudDs7fQojbG9naW50aXRsZSB7IGNvbG9yOiAjYzZiM2IzIWltcG9ydGFudDt9Ci5zZWFyY2hsaV9yZWdsb2dpbiB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50O30KLnNlYXJjaGxpX3JlZ2xvZ2luIGxpIHtib3JkZXItYm90dG9tOiAycHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQojcF9idG4gaSB7YmFja2dyb3VuZDogIzE1MTcxOSFpbXBvcnRhbnQ7fQoua2VrZV9yZXBseSAuaGQge2JhY2tncm91bmQ6IHVybChzb3VyY2UvcGx1Z2luL2tla2VfcmVwbHkvdGVtcGxhdGUvaW1nL2ljby5wbmcpIG5vLXJlcGVhdCAxM3B4ICMxMjEyMTIhaW1wb3J0YW50O30KI3NjYmFyX2J0biBzdHJvbmcge2xpbmUtaGVpZ2h0OiAyMXB4IWltcG9ydGFudDt9Ci54aTIsIC54aTIgYSwgLnhpMyBhIHtjb2xvcjogI2ZmZiFpbXBvcnRhbnQ7fQouc2NiYXJfYnRuX3RkIHtiYWNrZ3JvdW5kOiBuby1yZXBlYXQgOHB4IC0xNDJweCAjMzMzIWltcG9ydGFudDt9Ci5zY2Jhcl90eXBlX3RkIHtiYWNrZ3JvdW5kOiBuby1yZXBlYXQgMCAtMTkzcHggIzMzMyFpbXBvcnRhbnQ7fQouc2NiYXJfdHh0X3RkLCAuc2NiYXJfdHlwZV90ZCB7YmFja2dyb3VuZDogcmVwZWF0LXggMCAtOTNweCAjMzMzIWltcG9ydGFudDt9Ci5zY2Jhcl9pY29uX3RkIHtiYWNrZ3JvdW5kOiBuby1yZXBlYXQgMCAtNTBweCAjMzMzIWltcG9ydGFudDt9CiNkYW9oYW5nYm94IHtiYWNrZ3JvdW5kLWNvbG9yOiAjMTExIWltcG9ydGFudDtib3JkZXItY29sb3I6ICMzMzMhaW1wb3J0YW50O30KLnRtX2Mge2JhY2tncm91bmQ6ICM1NTUhaW1wb3J0YW50O30KI2NhdGVnb3J5X2dyaWQgaDQge2JhY2tncm91bmQ6ICMyMjIhaW1wb3J0YW50O30KLmNhdGVnb3J5X2wxLCAuY2F0ZWdvcnlfbDIsIC5jYXRlZ29yeV9sMywgLmNhdGVnb3J5X2w0IHtiYWNrZ3JvdW5kOiAjMzMzIWltcG9ydGFudDt9Ci5zbGlkZWJveF9ncmlkIHtib3JkZXI6IDFweCAgc29saWQgIzExMSFpbXBvcnRhbnQ7fQojY2F0ZWdvcnlfZ3JpZCB0ZCB7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMxMTEhaW1wb3J0YW50O2JvcmRlci1sZWZ0OiAxcHggc29saWQgIzExMSFpbXBvcnRhbnQ7fQojY2F0ZWdvcnlfZ3JpZCB7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMzMzMhaW1wb3J0YW50O30KLnRlZHQge2JvcmRlci1jb2xvcjogIzY2NiAjNjY2ICM2NjYgIzY2NiFpbXBvcnRhbnQ7fQoudncgLnMge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjNjY2IWltcG9ydGFudDt9Ci52dyAuaCB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICM2NjYhaW1wb3J0YW50O30KLnZ3IC5vIHtib3JkZXItdG9wOiAxcHggc29saWQgIzY2NiFpbXBvcnRhbnQ7fQoKCn0=";
var _jszDiscuzMbdark = "QG1lZGlhIChwcmVmZXJzLWNvbG9yLXNjaGVtZTogZGFyaykgewpib2R5IHtiYWNrZ3JvdW5kOmJsYWNrICFpbXBvcnRhbnQ7YmFja2dyb3VuZC1jb2xvcjogYmxhY2sgIWltcG9ydGFudDtjb2xvcjogd2hpdGUgIWltcG9ydGFudDt9Ci5haW51b192dGl0bGUgLnRpdCBoMSB7Y29sb3I6ICM4YjhiOGIgIWltcG9ydGFudDt9Ci5haW51b192dGl0bGV7IGJhY2tncm91bmQ6ICMyNTI1MjUgIWltcG9ydGFudDsgYm9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMyNDI0MjQgIWltcG9ydGFudDt9Ci5wbGMgLnBpYXV0aG9yIHsgYmFja2dyb3VuZDogIzIwMjAyMCAhaW1wb3J0YW50O30KLmNoaXBfaGVhZGVye2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMjQyNDI0ICFpbXBvcnRhbnQ7IGJhY2tncm91bmQ6ICMxNDEzMTcgIWltcG9ydGFudDt9Ci50b3BfbWVudV9wb3AgLnBvcF9tZW51bmF2IC5uYXZfbGVmdCBsaXsgY29sb3I6ICNmZmYgIWltcG9ydGFudDsgfSAKLnRvcF9tZW51X3BvcCAucG9wX21lbnVuYXYgLm5hdl9sZWZ0IGxpIHNwYW57IGNvbG9yOiAjMDAwICFpbXBvcnRhbnQ7IH0gCi50b3BfbWVudV9wb3B7YmFja2dyb3VuZDogIzM2MzIzMiAhaW1wb3J0YW50O30KLnBvcF9ib2FyZF9uYXZ7IGJvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMjQyNDI0ICFpbXBvcnRhbnQ7fQoudG9wX21lbnVfcG9wIC5wb3BfbWVudW5hdiAubmF2X2xlZnQgdWx7IGJvcmRlci1yaWdodDogMXB4IHNvbGlkICMyNDI0MjQgIWltcG9ydGFudDt9Ci50b3BfbWVudV9wb3AgLnBvcF9tZW51bmF2IC5uYXZfcmlnaHQgbGkgYXtjb2xvcjogI2ZmZiAhaW1wb3J0YW50O30KYTpsaW5rLCBhOmhvdmVyIHtjb2xvcjogI2Y2ZTZlNiAhaW1wb3J0YW50O30KYTp2aXNpdGVkIHtjb2xvcjogIzM5MzgzOCAhaW1wb3J0YW50O30KLmFpbnVvX3Z0aXRsZSAubmV3c3Qge2NvbG9yOiAjY2ZjZmNmICFpbXBvcnRhbnQ7fQoudmlld2hpcyBhIHtjb2xvcjogI2IwYjBiMCAhaW1wb3J0YW50O30KLmF2cmF0ZSBkZCB7Ym9yZGVyOiAxcHggc29saWQgIzI1MjEyMSAhaW1wb3J0YW50O2JhY2tncm91bmQ6ICMxNDE0MTQgIWltcG9ydGFudDtib3JkZXItbGVmdDogMXB4IHNvbGlkICNhOTAwMDAgIWltcG9ydGFudDt9Ci5hdnJhdGUgZGQgdGgsIC5hdnJhdGUgZGQgdGQge2JvcmRlci1ib3R0b206IDFweCBkYXNoZWQgIzU0NTI0YSAhaW1wb3J0YW50O30KLmNsIHtiYWNrZ3JvdW5kOiMyNDI0MjQgIWltcG9ydGFudDsgYm9yZGVyLXRvcDoxcHggc29saWQgIzI0MjQyNDt9IAoucmVwbHlfYm90IHtiYWNrZ3JvdW5kOiAjMjQyNDI0ICFpbXBvcnRhbnQ7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMyNDI0MjQgIWltcG9ydGFudDt9Ci5wbGNub3RmaXJzdCB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICM1NDUyNGE7YmFja2dyb3VuZDogIzI0MjQyNCAhaW1wb3J0YW50O30KLnBsY25vdGZpcnN0IC5waSAubWVzc2FnZSAucXVvdGUge2JhY2tncm91bmQ6ICMxODE4MTggIWltcG9ydGFudDtib3JkZXItbGVmdDogM3B4IHNvbGlkICNhOTAwMDAgIWltcG9ydGFudDt9Ci5jaGlwX2FydGljbGVfcmVwbHlsaXN0IC5xdW90ZSB7YmFja2dyb3VuZDogIzE4MTgxOCAhaW1wb3J0YW50O2JvcmRlci1sZWZ0OiAzcHggc29saWQgI2E5MDAwMCAhaW1wb3J0YW50O30KLmFpbnVvX2Zwb3N0Ym90dG9tIHtiYWNrZ3JvdW5kOiAjMTcxNzE3ICFpbXBvcnRhbnQ7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMxODE4MTggIWltcG9ydGFudDt9Ci5haW51b19mcG9zdGJvdHRvbSB1bCBsaSB7YmFja2dyb3VuZDogIzE3MTcxNyAhaW1wb3J0YW50O30KLmFpbnVvX2Zwb3N0Ym90dG9tIHVsIC5mYXN0Y29uIGEge2JhY2tncm91bmQ6ICMxNzE3MTcgIWltcG9ydGFudDt9Ci50aXAge2JhY2tncm91bmQ6ICMyYjIyMjIgIWltcG9ydGFudDtib3JkZXI6IDFweCBzb2xpZCAjNTI0MzQzICFpbXBvcnRhbnQ7fQoudGlwIGRkIHtiYWNrZ3JvdW5kOiAjMmIyMjIyICFpbXBvcnRhbnQ7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMxNDExMTEgIWltcG9ydGFudDt9CmRpdi50aHJlYWRsaXN0IGRkIGE6aG92ZXIge2NvbG9yOiAjZjZlNmU2ICFpbXBvcnRhbnQ7fQpkaXYudGhyZWFkbGlzdCBkZCBhOnZpc2l0ZWQgIHtjb2xvcjogIzM5MzgzOCAhaW1wb3J0YW50O30KLmNoaXBfYXJ0aWNsZV92aWV3IC5jb24zIGEge2JhY2tncm91bmQ6ICM1OTEzMTMgIWltcG9ydGFudDt9Ci5maXhfcGFnZSB7YmFja2dyb3VuZDogIzE3MTcxNyAhaW1wb3J0YW50O2JvcmRlci10b3A6IDFweCBzb2xpZCAjMzMzMzMzICFpbXBvcnRhbnQ7fQoucGFnZSBhIHtib3JkZXI6IDFweCBzb2xpZCAjMDgwODA4O2JhY2tncm91bmQ6ICMzMjMyMzIgIWltcG9ydGFudDt9Ci5wYWdlIGEuZ3JleSB7YmFja2dyb3VuZDogIzMyMzIzMiAhaW1wb3J0YW50O30KLnBhZ2UgYSNzZWxlY3RfYXtiYWNrZ3JvdW5kOiAjMzIzMjMyICFpbXBvcnRhbnQ7fQouY2hpcF9hcnRpY2xlX3RpdGxlIHtib3JkZXItdG9wOiAxcHggc29saWQgIzE0MTExMSAhaW1wb3J0YW50O30KLnBvc3RfbmV3X2FydGljbGUge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAgIzI0MjQyNCAhaW1wb3J0YW50O30KLmNoaXBfYXJ0aWNsZV9yZXBseWxpc3QgbGkge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMTQxNDE0ICFpbXBvcnRhbnQ7fQouY2hpcF9hcnRpY2xlX3JlcGx5bGlzdCBsaSAuYXZhciAuYW1lbnUgYSB7YmFja2dyb3VuZDogIzE0MTQxNCAhaW1wb3J0YW50O30KLmJtX2gge2JhY2tncm91bmQ6ICM0OTI0MjQgIWltcG9ydGFudDtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzQ5MjQyNCAhaW1wb3J0YW50O30KLnN1Yl9mb3J1bSB7YmFja2dyb3VuZDogIzI0MjQyNCAhaW1wb3J0YW50O2JvcmRlcjogMXB4IHNvbGlkICMyNDI0MjQgIWltcG9ydGFudDt9Ci5zdWJfZm9ydW0gbGkge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7fQoudGhyZWFkbGlzdCBsaSB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMzMjMyMzIgIWltcG9ydGFudDt9Ci50aHJlYWRsaXN0IGxpIGEge2JvcmRlci10b3A6IDFweCBzb2xpZCAjMjQyNDI0ICAhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiMyNDI0MjQgIWltcG9ydGFudDt9Ci50aHJlYWRsaXN0IGxpIGEgLmNse2JvcmRlci10b3A6IDFweCBzb2xpZCAjMjQyNDI0ICAhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiMyNDI0MjQgIWltcG9ydGFudDt9CmRpdi5ncmV5X2xpbmUuY2wge2JhY2tncm91bmQ6IzMyMzIzMiAhaW1wb3J0YW50OyBib3JkZXItYm90dG9tOjFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7OyBib3JkZXItdG9wOjFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7O30gCi5jaGlwX3R5cGUge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMjQyNDI0ICFpbXBvcnRhbnQ7fQouYXZpZXdfbW9yZXBmIHRkIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzMyMzIzMiAhaW1wb3J0YW50O30KLmxvZ2luYm94IC5sb2dpbl9mcm9tIHtiYWNrZ3JvdW5kOiAjMjQyNDI0ICFpbXBvcnRhbnQ7fQoubG9naW5fZnJvbSBsaSB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMzMjMyMzIgIWltcG9ydGFudDt9Ci50Y2FwdGNoYS10cmFuc2Zvcm0ge2JhY2tncm91bmQ6ICM0OTI0MjQgIWltcG9ydGFudDt9Ci5jaGlwX2FydGljbGVfbmV3IGxpIC5hYjIge2NvbG9yOiAjZTdlN2U3ICFpbXBvcnRhbnQ7fQoubG9naW5fZnJvbSBpbnB1dCB7Y29sb3I6ICNlN2U3ZTcgIWltcG9ydGFudDtiYWNrZ3JvdW5kLWNvbG9yOiAjMDAwICFpbXBvcnRhbnQ7fQpkaXYuYWludW9fdXNlcnRiIHVsIGxpLmEgYTp2aXNpdGVkICB7Y29sb3I6ICNmNmU2ZTYgIWltcG9ydGFudDt9Ci5haW51b191c2VybmF2IC5zd2lwZXItc2xpZGUgYSB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICM2MTVhNWEgICFpbXBvcnRhbnQ7Y29sb3I6ICM2NjYgICFpbXBvcnRhbnQ7fQouY2hpcF9pbmRleF9uZXcgbGkgLmFiMiB7Y29sb3I6ICNmNmU2ZTYgICFpbXBvcnRhbnQ7fQoubG9hZG1vcmUgc3BhbiB7YmFja2dyb3VuZDogIzI0MjQyNCAgIWltcG9ydGFudDtjb2xvcjogI2Y2ZTZlNiAgIWltcG9ydGFudDt9CiNhZmFzdHJlcGx5IC5hZl90ZXh0IHRleHRhcmVhIHtiYWNrZ3JvdW5kOiAjMTQxMTExICFpbXBvcnRhbnQ7fQojYWZhc3RyZXBseSAjYWludW9fZmFjZW1lbnUge2JvcmRlci10b3A6IDFweCBzb2xpZCAjMTQxMTExICFpbXBvcnRhbnQ7fQouYWludW9fc21pbGV3aXBlciB7YmFja2dyb3VuZDogIzE0MTExMSAhaW1wb3J0YW50O2JvcmRlcjogMXB4IHNvbGlkICMxNDExMTEgIWltcG9ydGFudDt9Ci5wb3N0X2ltZ2xpc3QgbGkucGx1cyBhIHtiYWNrZ3JvdW5kOiAjMTQxMTExICFpbXBvcnRhbnQ7IGJvcmRlcjogMXB4IHNvbGlkICMxNDExMTEgIWltcG9ydGFudDt9Ci5haW51b19zbWlsZXRhYiBsaSBhLmEge2JhY2tncm91bmQ6ICMxNDExMTEgIWltcG9ydGFudDtib3JkZXItcmlnaHQ6IDFweCBzb2xpZCAjMTQxMTExICFpbXBvcnRhbnQ7Ym9yZGVyLWxlZnQ6IDFweCBzb2xpZCAjMTQxMTExICFpbXBvcnRhbnQ7fQojYWZhc3RyZXBseSB7YmFja2dyb3VuZDogIzE0MTExMSAhaW1wb3J0YW50OyB9Ci5haW51b19waWNsaXN0IGxpIHsgYmFja2dyb3VuZDogIzI0MjQyNCAhaW1wb3J0YW50O30KLmFpbnVvX3BpY2xpc3QgbGkgLmFzdWIgLmF0aXRsZSB7Y29sb3I6ICM0YTQ1NDUgIWltcG9ydGFudDsgfQoucGFnZSBhLmdvbnh0IHtjb2xvcjogI2Y2ZTZlNiAhaW1wb3J0YW50OyB9CiN0Y2FwdGNoYV9pZnJhbWVfZHl7YmFja2dyb3VuZDogIzI0MjQyNCAhaW1wb3J0YW50O30KI3RjYXB0Y2hhX3RyYW5zZm9ybV9keSB7Ym9yZGVyOiAxcHggc29saWQgMjQyNDI0ICFpbXBvcnRhbnQ7fQoubmF2X2xlZnQgbGkgc3BhbiB7YmFja2dyb3VuZDogIzYxNWE1YSAhaW1wb3J0YW50O30KLmFpbnVvX25vd3BtIC5wbWZtIHtib3JkZXItdG9wOiAxcHggc29saWQgIzYxNWE1YSAhaW1wb3J0YW50O30KLmFpbnVvX25vd3BtIC5wbWZtIC50ZWR0X2wgdGV4dGFyZWEge2JhY2tncm91bmQ6ICM2MTVhNWEgIWltcG9ydGFudDt9Ci5haW51b191c2VydGIgLnRiIGxpIGEge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMTQxMTExICFpbXBvcnRhbnQ7fQouYWludW9fZmF2b3JpdGUgbGkge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7fQouYWludW9fcG1ib3ggLnBtdWwgLm5ld3BtIHtiYWNrZ3JvdW5kOiAjMTQxMTExICFpbXBvcnRhbnQ7fQouYWludW9fcG1ib3ggLnBtdWwgbGkge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7fQouYWludW9keHggLmRhc2hlZHRpcCB7YmFja2dyb3VuZDogIzE0MTExMSAhaW1wb3J0YW50O2JvcmRlcjogMXB4IGRhc2hlZCAjNGY0ZDQ2ICFpbXBvcnRhbnQ7fQouYWludW9fcmVtaW5kIC50YiBsaS5hIGEge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjYzE0NDQ0ICAhaW1wb3J0YW50OyBjb2xvcjojYjBiMGIwICAhaW1wb3J0YW50OyAgYmFja2dyb3VuZDogIzMyMzIzMiAhaW1wb3J0YW50O30KLmFpbnVvX3JlbWluZCAudGIgbGkgYSB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMxNDExMTEgIWltcG9ydGFudDtjb2xvcjojYjBiMGIwICAhaW1wb3J0YW50OyBiYWNrZ3JvdW5kOiAjNGY0ZDQ2ICFpbXBvcnRhbnQ7fQouYWludW9fcmVtaW5kIC54bGQgLm50c2ltZyB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMxNDExMTEgIWltcG9ydGFudDt9Ci5haW51b19yZW1pbmQgLnRiIGxpIHtib3JkZXItbGVmdDogMXB4IHNvbGlkICMwYTA5MDkgIWltcG9ydGFudDt9Ci5haW51b191c2VyaW5mbyAuc2VjdGlvbjEgbGkgYSB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMzMjMyMzIgIWltcG9ydGFudDt9CmxpPmRpdi5ncmV5X2xpbmUuY2wge2JhY2tncm91bmQ6ICMyNDI0MjQgIWltcG9ydGFudDtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzI0MjQyNCAhaW1wb3J0YW50O2JvcmRlci10b3A6IDFweCBzb2xpZCAjMjQyNDI0ICFpbXBvcnRhbnQ7fQpib2R5PmRpdi5ncmV5X2xpbmUuY2wge2JhY2tncm91bmQ6ICMyNDI0MjQgIWltcG9ydGFudDtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzE0MTExMSAhaW1wb3J0YW50O2JvcmRlci10b3A6IDFweCBzb2xpZCAjMjQyNDI0ICFpbXBvcnRhbnQ7fQouY2hpcF9hcnRpY2xlX25ldyBsaSAuYWIzIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzA4MDcwNyFpbXBvcnRhbnQ7fQojYWludW9sb2FkbW9yZT5kaXYuY2x7Ym9yZGVyLXRvcDogMHB4IHNvbGlkICM1MjQzNDMhaW1wb3J0YW50O30KLmNoaXBfaW5kZXhfbmV3IGxpIC5hYjMge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyIWltcG9ydGFudDt9Ci5jaGlwX3N3aXBlciB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMzMjMyMzIhaW1wb3J0YW50O30KLml2dS1kcmF3ZXItY29udGVudCB7YmFja2dyb3VuZC1jb2xvcjogIzI0MjQyNCAhaW1wb3J0YW50O30KLml2dS1kcmF3ZXItaGVhZGVyIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzRmNTI1NCAhaW1wb3J0YW50O30KLml2dS1kcmF3ZXItaGVhZGVyIHAsIC5pdnUtZHJhd2VyLWhlYWRlci1pbm5lciB7Y29sb3I6ICNhYmI0YzggIWltcG9ydGFudDt9Ci5KenNqaWFsZV9Jc21zX0hlYWRlciB7YmFja2dyb3VuZDogIzJiMjkyOSAhaW1wb3J0YW50O30KLmp6c2ppYWxlX2lzbXNfc2VjdXJpdHlfbWFpbkNvbHVtbiB7YmFja2dyb3VuZDogIzI0MjQyNCAhaW1wb3J0YW50O2JvcmRlcjogMXB4IHNvbGlkICMyNDI0MjQgIWltcG9ydGFudDstd2Via2l0LWJveC1zaGFkb3c6IDAgMCA0cHggIzI0MjQyNCAhaW1wb3J0YW50O2JveC1zaGFkb3c6IDAgMCA0cHggIzI0MjQyNCAhaW1wb3J0YW50O30KLmp6c2ppYWxlX2lzbXNfc2VjdXJpdHlfbWFpbkNvbnRlbnQge2JvcmRlci1sZWZ0OiAxcHggc29saWQgIzI0MjQyNCAhaW1wb3J0YW50O30KLmp6c2ppYWxlX2lzbXNfc2VjdXJpdHlfbWFpbl90aXRsZSB7Y29sb3I6ICNlNGRjZGMgIWltcG9ydGFudDt9Ci5qenNqaWFsZV9pc21zX3NlY3VyaXR5X21haW5Db250ZW50X3NldHRpbmcge2JvcmRlci10b3A6IDFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7fQouSkNhcmQge2JhY2tncm91bmQ6ICMzMjMyMzIgIWltcG9ydGFudDt9Ci5JU01TRm9ybS1hY2NvdW50IHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzE0MTExMSAhaW1wb3J0YW50O30KLklTTVNGb3JtLWFjY291bnRTZXBlcmF0b3Ige2JhY2tncm91bmQ6ICMzMjMyMzIgIWltcG9ydGFudDt9Ci5JbnB1dC13cmFwcGVyIHtiYWNrZ3JvdW5kOiAjMmIyYjJiICFpbXBvcnRhbnQ7fQouanpzamlhbGVfaXNtc19zZWN1cml0eV9GQVEge2JhY2tncm91bmQ6ICMzMjMyMzI7Ym9yZGVyOiAxcHggc29saWQgIzMyMzIzMiAhaW1wb3J0YW50O30KLml2dS1jb2xsYXBzZS1zaW1wbGUge2JhY2tncm91bmQtY29sb3I6ICMzMjMyMzIgIWltcG9ydGFudDt9Ci5pdnUtdGFibGUtd3JhcHBlciB7Ym9yZGVyOiAxcHggc29saWQgIzE0MTExMSAhaW1wb3J0YW50O30KLml2dS10YWJsZSB7Y29sb3I6ICM5MTk0OWMgIWltcG9ydGFudDtiYWNrZ3JvdW5kLWNvbG9yOiAjMTMxMTExICFpbXBvcnRhbnQ7fQouaXZ1LXRhYmxlIHRoIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMTMxMTExICFpbXBvcnRhbnQ7fQouaXZ1LXRhYmxlOmFmdGVyIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMTQxMTExICFpbXBvcnRhbnQ7fQouaXZ1LXRhYmxlOmJlZm9yZSB7YmFja2dyb3VuZC1jb2xvcjogIzE0MTExMSAhaW1wb3J0YW50O30KLml2dS10YWJsZSB0ZCwgLml2dS10YWJsZSB0aCB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMxNDExMTEgIWltcG9ydGFudDt9Ci5pdnUtcGFnZS1uZXh0LCAuaXZ1LXBhZ2UtcHJldiB7YmFja2dyb3VuZC1jb2xvcjogIzI0MjQyNCAhaW1wb3J0YW50O30KLml2dS1wYWdlLWl0ZW0tanVtcC1uZXh0LCAuaXZ1LXBhZ2UtaXRlbS1qdW1wLXByZXYsIC5pdnUtcGFnZS1uZXh0LCAuaXZ1LXBhZ2UtcHJldiB7Y29sb3I6ICM2NjYgIWltcG9ydGFudDtib3JkZXI6IDFweCBzb2xpZCAjMjQyNDI0ICFpbXBvcnRhbnQ7fQouaXZ1LXBhZ2UtZGlzYWJsZWQgYSB7Y29sb3I6ICM4ODgxODEgIWltcG9ydGFudDt9Ci5pdnUtcGFnZS1pdGVtIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMjQyNDI0ICFpbXBvcnRhbnQ7Ym9yZGVyOiAxcHggc29saWQgIzI0MjQyNCAhaW1wb3J0YW50O30KLmRpYWxvZ2JveCAuYnV0dG9uIHtiYWNrZ3JvdW5kOiAjMTQxMTExICFpbXBvcnRhbnQ7fQoudmlld190aXQgIHtiYWNrZ3JvdW5kOiBibGFjayAhaW1wb3J0YW50O30KLnBjbHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzMyMzIzMiAhaW1wb3J0YW50O30KLmRpc2N1el94IHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzI0MjQyNCAhaW1wb3J0YW50OyB9Ci50eHRsaXN0IC5tdGl0IHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzMyMzIzMiFpbXBvcnRhbnQ7fQoudHh0bGlzdCAubXRpdCAueXR4dCB7YmFja2dyb3VuZC1jb2xvcjogIzEzMTExMSAhaW1wb3J0YW50OyBib3JkZXI6IDFweCBzb2xpZCAjMTMxMTExICFpbXBvcnRhbnQ7IH0KLnRocmVhZGxpc3RfZm9vdCBsaSB7YmFja2dyb3VuZC1jb2xvcjogIzEyMTIxMiAhaW1wb3J0YW50O30KLnBvc3RfYm94IGxpIC5wb3N0X2ltZ2J0biwgLnBvc3RfYm94IGxpIC5wb3N0X2F0dGJ0biB7YmFja2dyb3VuZC1jb2xvcjogI2E5MDAwMCAhaW1wb3J0YW50O2JvcmRlcjogMXB4IHNvbGlkICNjMTQ0NDQgIWltcG9ydGFudDt9Ci5wb3N0X2JveCBsaS5tdGV4dCB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMxMjEyMTIgIWltcG9ydGFudDt9Ci5idG5fcG5fZ3JleSB7YmFja2dyb3VuZC1jb2xvcjogI2E5MDAwMCAhaW1wb3J0YW50OyBjb2xvcjogI2U0ZGNkYyAhaW1wb3J0YW50O30KLmRobmF2c19ib3gge2JhY2tncm91bmQtY29sb3I6ICMyNDI0MjQgIWltcG9ydGFudDtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzI0MjQyNCAhaW1wb3J0YW50O30KLnRpcCBkdC5tcHQge2JhY2tncm91bmQtY29sb3I6ICM0NjNkM2QgIWltcG9ydGFudDt9Ci50aXAgZHQubXB0IC5wdCB7Y29sb3I6ICNlNGRjZGMgIWltcG9ydGFudDt9Ci5qdW1wX2Mge2JhY2tncm91bmQtY29sb3I6ICMxMjEyMTIgIWltcG9ydGFudDtib3JkZXItdG9wOiAxcHggc29saWQgIzMyMzIzMiAhaW1wb3J0YW50O2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7fQouZm9vdCB7YmFja2dyb3VuZC1jb2xvcjogIzEyMTIxMiFpbXBvcnRhbnQ7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMyNDI0MjQhaW1wb3J0YW50O30KLmFubi1ib3gge2JhY2tncm91bmQtY29sb3I6ICMxMjEyMTIgIWltcG9ydGFudDtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzEyMTIxMiAhaW1wb3J0YW50O30KLmhlYWRlciAubXlzcyBhIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMTIxMjEyICFpbXBvcnRhbnQ7fQouaGVhZGVyID4gZGl2Lm5hdiB7YmFja2dyb3VuZDogIzEyMTIxMiAhaW1wb3J0YW50O30KLmZvcnVtbGlzdCAuc3ViZm9ydW1zaG93IHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzMyMzIzMiFpbXBvcnRhbnQ7fQouZm9ydW1saXN0IC5tbGlzdDMgIHtiYWNrZ3JvdW5kLWNvbG9yOiAjMTIxMjEyICFpbXBvcnRhbnQ7fQouZm9ydW1saXN0IC5tbGlzdDMgbGkge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7Ym9yZGVyLXJpZ2h0OiAxcHggc29saWQgIzMyMzIzMiFpbXBvcnRhbnQ7fQouZm9ydW1saXN0IC5tbGlzdDQgbGkge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7Ym9yZGVyLXJpZ2h0OiAxcHggc29saWQgIzMyMzIzMiFpbXBvcnRhbnQ7fQouZm9ydW1saXN0IC5zdWItZm9ydW0ge2JhY2tncm91bmQtY29sb3I6ICMyNDI0MjQgIWltcG9ydGFudDt9Ci5zZWFyY2ggLm10eHQge2JvcmRlcjogMXB4IHNvbGlkICMzMjMyMzIgIWltcG9ydGFudDtiYWNrZ3JvdW5kLWNvbG9yOiAjMzIzMjMyICFpbXBvcnRhbnQ7Y29sb3I6ICNlNGRjZGMhaW1wb3J0YW50O30KLnNlYXJjaCB7YmFja2dyb3VuZC1jb2xvcjogIzEyMTIxMiAhaW1wb3J0YW50O2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMTIxMjEyICFpbXBvcnRhbnQ7fQouZm9ydW1saXN0IC5zdWJmb3J1bXNob3cgaSB7Y29sb3I6ICNhOTAwMDAgIWltcG9ydGFudDt9Ci5kaG5hdl9ib3gge2JhY2tncm91bmQtY29sb3I6ICMxMjEyMTIhaW1wb3J0YW50O2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMTIxMjEyIWltcG9ydGFudDt9Ci5mb3J1bWRpc3BsYXktdG9wIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzEyMTIxMiAhaW1wb3J0YW50O30KLnRocmVhZGxpc3QgbGkubGlzdF90b3Age2JhY2tncm91bmQtY29sb3I6ICMyNDI0MjQgICFpbXBvcnRhbnQ7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMyNDI0MjQgICFpbXBvcnRhbnQ7fQoudGhyZWFkbGlzdCBsaS5saXN0IHtiYWNrZ3JvdW5kLWNvbG9yOiAjMjQyNDI0IWltcG9ydGFudDtib3JkZXItdG9wOiAxcHggc29saWQgIzI0MjQyNCFpbXBvcnRhbnQ7fQoucGxjIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzMyMzIzMiFpbXBvcnRhbnQ7fQoucXVvdGUsIC5zaG93aGlkZSwgLmxvY2tlZCB7YmFja2dyb3VuZC1jb2xvcjogIzMyMzIzMiFpbXBvcnRhbnQ7fQoubXlpbmZvX2xpc3RfaWNvIGxpIGEge2JhY2tncm91bmQtY29sb3I6ICMzMjMyMzIhaW1wb3J0YW50O30KLnVzZXJfYm94IHtib3JkZXI6IDFweCBzb2xpZCAjMjQyNDI0IWltcG9ydGFudDt9Ci5teWluZm9fbGlzdF9pY28ge2JvcmRlcjogMXB4IHNvbGlkICMyNDI0MjQhaW1wb3J0YW50O30KLm15aW5mb19saXN0IHtib3JkZXI6IDFweCBzb2xpZCAjMjQyNDI0IWltcG9ydGFudDt9Ci5teWluZm9fbGlzdCBsaSB7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMzMjMyMzIgIWltcG9ydGFudDt9Ci5kaG52IHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzMyMzIzMiFpbXBvcnRhbnQ7fQouZmluZGJveCB1bCBsaSB7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMzMjMyMzIhaW1wb3J0YW50O30KLmZpbmRib3gge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyIWltcG9ydGFudDt9Ci5wbGMgLnBzdGgge2JhY2tncm91bmQ6ICMxMjEyMTIhaW1wb3J0YW50O30KLnBvc3RfYm94IGxpLm1saSB7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMzMjMyMzIhaW1wb3J0YW50O30KLmZvcnVtbGlzdCAubWxpc3QzIHVsLCAuZm9ydW1saXN0IC5tbGlzdDQgdWx7b3ZlcmZsb3c6IGF1dG87c2Nyb2xsYmFyLXdpZHRoOiBub25lICFpbXBvcnRhbnQ7LW1zLW92ZXJmbG93LXN0eWxlOiBub25lICFpbXBvcnRhbnQ7fQouZm9ydW1saXN0IC5tbGlzdDMgdWwsIC5mb3J1bWxpc3QgLm1saXN0NCB1bDo6LXdlYmtpdC1zY3JvbGxiYXJ7ZGlzcGxheTogbm9uZSAhaW1wb3J0YW50O30KLmZvb3RfcmVwbHkgYS5teCB7Ym9yZGVyLWxlZnQ6IDFweCBzb2xpZCAjMzIzMjMyICFpbXBvcnRhbnQ7fQoudGhyZWFkbGlzdCBsaS5saXN0X3RvcCBhIHtjb2xvcjogI2U0ZGNkYyAhaW1wb3J0YW50O30KLnBvc3RfZnJvbSBsaSB7IGJvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMTIxMjEyICFpbXBvcnRhbnQ7IGJvcmRlci10b3A6IDFweCBzb2xpZCAjMTIxMjEyO30KLnBvc3Rfc2VsZWN0IHNlbGVjdCB7YmFja2dyb3VuZC1jb2xvcjogIzI0MjQyNCAhaW1wb3J0YW50OyBjb2xvcjogI2U0ZGNkYyAhaW1wb3J0YW50O2JvcmRlci1jb2xvcjogIzQyNDI0MiAhaW1wb3J0YW50O30KLnBvc3Rfc2VsZWN0IHNlbGVjdCBvcHRpb24geyBiYWNrZ3JvdW5kLWNvbG9yOiAjMTIxMjEyICFpbXBvcnRhbnQ7IGNvbG9yOiAjZTRkY2RjICFpbXBvcnRhbnQ7fQppbnB1dCNuZWVkc3ViamVjdCB7Y29sb3I6ICNlNGRjZGMgIWltcG9ydGFudDsgYmFja2dyb3VuZC1jb2xvcjogIzMyMzIzMiAhaW1wb3J0YW50O30KLnBvc3RfZnJvbSB7IGJhY2tncm91bmQ6ICMyNDI0MjQgIWltcG9ydGFudDt9Ci5hY29uIHRleHRhcmVhIHtjb2xvcjogI2U0ZGNkYyAhaW1wb3J0YW50OyAgYm9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMxMjEyMTIgIWltcG9ydGFudDsgYmFja2dyb3VuZC1jb2xvcjogIzEyMTIxMiAhaW1wb3J0YW50O30KLnBvc3RfbXNnX2Zyb20gdGV4dGFyZWEsIC5wb3N0X2Zyb20gdGV4dGFyZWEge2NvbG9yOiB3aGl0ZSAhaW1wb3J0YW50O30KLmZvcnVtbGlzdCAubWxpc3QxIGxpIHtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzEyMTIxMiFpbXBvcnRhbnQ7fQoudGhyZWFkbGlzdF9ib3ggaDQge2JhY2tncm91bmQtY29sb3I6ICMyNDI0MjQhaW1wb3J0YW50O2JvcmRlci10b3A6IDFweCBzb2xpZCAjMjQyNDI0IWltcG9ydGFudDtib3JkZXItYm90dG9tOiAxcHggc29saWQgIzI0MjQyNCFpbXBvcnRhbnQ7fQoKLypiYnMucGNiZXRhLmNvbS1tYiovCi5zZWFyY2gtaG90IHtib3JkZXItdG9wOiAxcHggc29saWQgIzIyMiFpbXBvcnRhbnQ7Ym9yZGVyLWJvdHRvbTogMXB4IHNvbGlkICMyMjIhaW1wb3J0YW50O2JhY2tncm91bmQtY29sb3I6ICMwMDAhaW1wb3J0YW50O30KLnNlYXJjaC1ob3QgbGkgYSB7Ym9yZGVyLXRvcDogMXB4IHNvbGlkICMyMjIhaW1wb3J0YW50O30KLnRocmVhZGxpc3RfYm94IGgyIHtiYWNrZ3JvdW5kLWNvbG9yOiAjNjAzYTNhIWltcG9ydGFudDtib3JkZXItdG9wOiAjNjAzYTNhIWltcG9ydGFudDt9Ci5wYmwgbGkge2JvcmRlci1sZWZ0OiAxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQoKLyppLnBjYmV0YS5jb20tbWIqLwoubWVkYWxsaXN0IC50Ym11IHtiYWNrZ3JvdW5kOiAjMTIxMjEyIWltcG9ydGFudDtib3JkZXI6IDFweCBkYXNoZWQgIzEyMTIxMiFpbXBvcnRhbnQ7fQoubWdjbCAubWdjbF9ib3gge2JhY2tncm91bmQ6ICMxMjEyMTIhaW1wb3J0YW50O30KLmltZ2xpc3QgbGkge2JvcmRlci1ib3R0b206IDFweCBzb2xpZCAjMzIzMjMyIWltcG9ydGFudDt9Ci5ob21lX2ZlZWRfdGltZSBzcGFuIHtjb2xvcjogIzY5MTExMSFpbXBvcnRhbnQ7YmFja2dyb3VuZDogIzBhMGEwYSFpbXBvcnRhbnQ7fQouaG9tZV9mZWVkX3RpbWU6YWZ0ZXIge2JhY2tncm91bmQ6ICMwYTBhMGEhaW1wb3J0YW50O30KZGl2LnBvc3RfZnJvbSA+IHVsID4gbGkuYXJlYSB7Ym9yZGVyOiAxcHggc29saWQgIzMzMyFpbXBvcnRhbnQ7fQouYXBvc3RfaW1nbGlzdCBsaS5wbHVzIHtib3JkZXI6IDJweCBkYXNoZWQgIzY2NiAhaW1wb3J0YW50O30KLnRlZHQgdGV4dGFyZWEjc2VuZG1lc3NhZ2Uge2JhY2tncm91bmQ6ICMxNDExMTEgIWltcG9ydGFudDt9Ci51bl9zZWxlY3RvciBpbnB1dHtiYWNrZ3JvdW5kOiAjMTQxMTExICFpbXBvcnRhbnQ7fQouYWludW9fZmF4aWFveGkgLmRhc2hlZHRpcCB7YmFja2dyb3VuZDogIzU1NSFpbXBvcnRhbnQ7Ym9yZGVyOiAxcHggZGFzaGVkICM3NzchaW1wb3J0YW50O30KCgoKfQ==";
var _lazyDefaultImg = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABMAAAAVCAYAAACkCdXRAAAAAXNSR0IArs4c6QAAAIRlWElmTU0AKgAAAAgABQESAAMAAAABAAEAAAEaAAUAAAABAAAASgEbAAUAAAABAAAAUgEoAAMAAAABAAIAAIdpAAQAAAABAAAAWgAAAAAAAABIAAAAAQAAAEgAAAABAAOgAQADAAAAAQABAACgAgAEAAAAAQAAABOgAwAEAAAAAQAAABUAAAAAXBXIBQAAAAlwSFlzAAALEwAACxMBAJqcGAAAAVlpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IlhNUCBDb3JlIDYuMC4wIj4KICAgPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iPgogICAgICAgICA8dGlmZjpPcmllbnRhdGlvbj4xPC90aWZmOk9yaWVudGF0aW9uPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgPC9yZGY6UkRGPgo8L3g6eG1wbWV0YT4KGV7hBwAAABtJREFUOBFjYBgFoyEwGgKjITAaAqMhQIUQAAAGUQAB4RoFgAAAAABJRU5ErkJggg==";
var _suppertDzDomain=['chiphell.com','pcbeta.com'];
var _suppertDzSites=[];
var _jszSitesIsMobile = -1;
var _jszSitePcExtensionDark ='';
var _jszSiteMbExtensionDark ='';
var _jszIsDzSites = -1;
var _jszSiteExtensionJs ='';

function _bja_isDiscuzSite(){
    if(_jszIsDzSites==1){
        return true;
    }
    var cd =null;
    var uid =null;
    try{
        cd= cookiedomain;
        REPORTURL;
        SITEURL;
        uid=discuz_uid;
    }catch(e){}
    return uid !=null;
}
function _bja_discuzSITEURL(){
    var r ='';
    try{
        r=SITEURL;
    }catch(e){}
    return r;
}
function _bja_discuzTidFromUrl(u){
    var r =null;
    const fidRegex = ['thread-([0-9]+)-\\d+','tid=(\\d+)','mod=view&aid=(\\d+)','mod=view&aid=(\\d+)','article-(\\d+)'];
    if(u && BJA_isString(u))
    {
        r= BJA_stringByMatchList(u,fidRegex,1);
    }
    return r;
}
function _bja_discuzIsThread(u){
    var r =alse;
    const fidRegex = ['thread-([0-9]+)-\\d+','viewthread&tid=(\\d+)'];
    if(u && BJA_isString(u))
    {
        r= BJA_isMatchListByString(u,fidRegex)==1;
    }
    return r;
}
function _bja_discuzFidFromUrl(u){
    var r =null;
    const fidRegex = ['forum-([a-z|A-Z|0-9]+)-\\d+','catid=(\\d+)','cateid=(\\d+)','fid=(\\d+)'];
    if(u && BJA_isString(u))
    {
        r= BJA_stringByMatchList(u,fidRegex,1);
    }
    return r;
}
function _bja_discuzIsForum(u){
    var r =alse;
    const fidRegex = ['forum-([a-z|A-Z|0-9]+)-\\d+','mod=list&catid=(\\d+)','forumdisplay&fid=(\\d+)'];
    if(u && BJA_isString(u)){
        r= BJA_isMatchListByString(u,fidRegex)==1;
    }
    return r;
}
function _bja_discuzAreaIdFromUrl(u){
    var r =null;
    const fidRegex = ['gid=(\\d+)'];
    if(u && BJA_isString(u)){
        r= BJA_stringByMatchList(u,fidRegex,1 );
    }
    return r;
}
function _bja_discuzIsArea(u){
    var r =_bja_discuzAreaIdFromUrl(u);
    return r!=null ;
}

function _bja_discuzPageFromUrl(u){
    var r =null;
    const fidRegex = ['forum-[a-z|A-Z|0-9]+-(\\d+)','thread-\\d+-(\\d+)-','page=(\\d+)'];
    if(u && BJA_isString(u))
    {
        r= BJA_stringByMatchList(u,fidRegex,1 );
    }
    return r;
}

function isSite(url=null){
    var r=false;
    if(_bja_isDiscuzSite()){
        r= true;
    }
    else{
        var uri = url!=null? new URL(url) : BJA_URI();
        if(uri!=null){
            var uh =uri.host;
            for (var i =0; i< _suppertDzDomain.length; i++){
                if(uh.indexOf(_suppertDzDomain[i])>=0 ){
                    r = true;
                    break;
                }
            }
            if(!r){
                 var uh =uri.href;
                 for (var i =0; i< _suppertDzSites.length; i++){
                    if(uh.startsWith(_suppertDzSites[i])>=0 ){
                        r = true;
                        break;
                    }
                }
            }
        }else{
            r= true;
        }
    }
    return r;
}

function isSiteThread(){
    var u =BJA_GetURL ();
    return isSite(u) && (
            (u.indexOf('&aid=')>=0) || 
            (u.indexOf('article-')>=0 )||
             (u.indexOf('viewthread&tid=')>=0) || 
             (u.indexOf('thread-')>=0 )) ;
}

function isSiteHome(url,base=false){
    var u =url?url: BJA_GetURL ();
    var uiv =BJA_URI(u);
    var host =uiv.host;
    var path =uiv.pathname;
    var pathurl=uiv.origin + uiv.pathname;
    var dsu = _bja_discuzSITEURL();
    if(dsu!='' && pathurl.startsWith(dsu)){
        path=pathurl.slice(dsu.length);
        if(!path.startsWith('/')){
            path = '/'+path;
        }
    }
    var rgx = path + "\\?mobile=\\d$";
    return (path=='' ||path=='/' || path =='/index.php') || (
        base==false && 
        (BJA_isMatchByString(uri.href,rgx)));
}

function isSiteForum(portal=true){
    var u =BJA_GetURL ();
    return  isSite(u) && (
            (portal && (u.indexOf('portal.php?')>=0)) || 
            (u.indexOf('forum-')>=0 )||
             (u.indexOf('mod=list')>=0) || 
             isSiteHome(u,true)||
             (u.indexOf('mod=forumdisplay')>=0 ));
}

function isSiteMobile(){
    var u =BJA_GetURL ();
    return  isSite(u) && (
            (u.indexOf('mobile=2')>=0 )||
             (u.indexOf('mobile=3')>=0));
}

function _auto_reset_notDiscuzImageSel(){
    if(!isSite()){
        try{
            window.jszGVars.addImageContentSels = ["img"];
            window.jszGVars.imgContentSels=  ["img"];
        }catch(e){}
    }
}

function _app_sub_ov_initVariable(){
    window.jszGVars.imgAttrs = ['file','zsrc','zj-src','data-src','src','zoom'];
    window.jszGVars.lazyImgAttrFilters = ['data-src','file','zoomfile','src'];
    window.jszGVars.imgUrlFilters = ['static/image/','images/logo.png','data/avatar/','X:smiley/([a-z|A-Z|0-9_])+/\\d+'];
   
    // 3 "div.message img[id*=aimg_][src]:not([src*=smiley]):not([zsrc])|div.message img[zsrc]:not([src*=smiley])|div.message img[zsrc]:not([zsrc*=smiley])|div[id*='pid'] img[id]", 
    window.jszGVars.imgContentSels=  [
        "#article_content a img",
        "article.chip_article_view a img", 
        "div.display img:not([src*='smiley']):not([src*='avatar'])",
        "table[id*='pid'] img[id*='aimg_']||#postlist div[id*='post_'] div.t_fsz img[id]",
    ];
    window.jszGVars.addImageContentSels = [
        "div.c>a>img",
        "a>div.ab1>img",
        "li>a.tm01>img",
        "[id*='postmessage_']>ignore_js_op>img",
    ];

    var sels = {
        'uname': ['#avatar_pop div.ava_user a','#hd #um .vwmy a'],
        'prompt':['#avatar_pop > div.apop_con > div.ava_menu > ul > li:nth-child(6) > a > span'],
        'observe':{
            'content':['#postlist', '#waterfall','#threadulid','#ainuoloadmore','div.chip_index_new>ul','div.viewthread'],
            'list':["div.chip_index_new > ul","article.chip_article_new > ul","table#threadlisttableid","ul#waterfall","div.threadlist>ul"]
        },
        'blacklist':{
            'filter':[
                    {	
                        'absolute':"X://div[@id='postlist']/div[contains(@id,'post_')]",
                        'relative':"X:.//td[@class='plc']//div[contains(@class,'po')]/div[contains(@class,'pob')]/p",
                        'node':"X:.//div[@class='pi']/div[@class='authi']/a"
                    },
                    {	
                        'absolute':"X://div[contains(@class,'postlist')]/div[contains(@id,'pid')]",
                        'relative':"X:.//span[@class='viewhis']",
                        'node':"X:.//ul[@class='authi']/li/a[@class='ausize'][contains(@href,'uid')]||.//div[@class='aleft']/a[contains(@href,'uid')]"
                    },
                    {	
                        'absolute':"X://div[@class='viewthread']/div[contains(@class,'plc')]",
                        'relative':"X:.//ul[contains(@class,'authi')]/li[contains(@class,'mtit')]|.//div[contains(@class,'threadlist_foot')]/ul",
                        'node':"X:.//ul[@class='authi']/li/span[@class='z']/a[contains(@href,'uid')]"
                    },
                ],
            'content':{
                'absolute':["div[class='plc'][id*='pid']|.ainuo_vtitle .aleft a[href*='mod=space']",".plcnotfirst|.ausize","div#comment ul.cl li |div.at1 h3 a[href*='mod=space']","[id^='thread']|a[c='1']","div#postlist [id^='post_']|a.xw1","div.viewthread div[id^='pid']|ul.authi li.mtit .z a","div#comment dl.cl |.mbm a[href*='space-uid']" ],
                'relative':[".ainuo_vtitle .aleft a[href*='mod=space']", ".ausize","div.at1 h3 a[href*='mod=space']","a[c='1']","a.xw1","ul.authi li.mtit .z a" ]
            },
            'list':{
                'absolute':[
                    "div.chip_index_new > ul > li | .ab3 a[href*='mod=space']",
                    "tbody[id*='thread_']| tr:nth-child(1) > td:nth-child(3) > cite:nth-child(1) > a:nth-child(1)", 
                    "article.chip_article_new > ul > li | .ab3 a[href*='mod=space']",
                    "article.chip_index_new > ul > li | .ab3 a[href*='mod=space']",
                    "ul#waterfall li | .auth a[href*='space-uid']|1|1",
                    "div.threadlist>ul>li | a>div.ainfo>span.by"
                ],
                'relative':["tr:nth-child(1) > td:nth-child(3) > cite:nth-child(1) > a:nth-child(1)", "a[href*='mod=space']",".auth a[href*='space-uid']|1|1","a>div.ainfo>span.by" ]
            }
            
        },
        'favorite':["a[id='a_favorite']","a.favbtn","a[id='k_favorite']" ],
        'searchbar':['#scbar > div:nth-child(2) > form'],
    };
    window.jszGVars.kv.set('sels',sels);
    _jsz_get_client_InitVars(0);
}
function _jsz_get_client_InitVars(v){
    try{
        var u = BJA_GetURL();
        if(!u){
            u='';
        }
        var h = BJA_URI_host();
        if(!h){
            h='';
        }
        var ua = '';
        try{ ua=navigator.userAgent;}catch(e){}
        _app_sub_ov_sendMsgToAppAndResult([{'domInitVars': [u,h,ua,v]}],function(result){
            if (result) {
                try{
                    if( result.discuz==1 || result.discuz==0){
                        _jszIsDzSites =result.discuz;
                        if(_jszIsDzSites ==1){
                            var h = BJA_URI_origin();
                            if(h && h.length>5){
                                if(_suppertDzSites.indexOf(h)<0){
                                    _suppertDzSites.push(h);
                                }
                            }
                        }
                    }
                    if(_jszIsDzSites==1 && result.host!=null && (result.host.length>0) &&  (_suppertDzDomain.indexOf(result.host)<0)){
                        _suppertDzDomain.push(result.host);
                    }
                    if(_jszIsDzSites==1 && result.url!=null && (result.url.length>0) &&  (_suppertDzSites.indexOf(result.url)<0)){
                        _suppertDzSites.push(result.url);
                    }
                    if( result.mb==1 || result.mb==0){
                        _jszSitesIsMobile =result.mb;
                    }
                    if( result.css !=null ){
                        if(_jszSitesIsMobile==0){
                            _jszSitePcExtensionDark =result.css;
                        }else if(_jszSitesIsMobile==1){
                            _jszSiteMbExtensionDark =result.css;
                        }
                    }
                    if( result.js !=null ){
                        _jszSiteExtensionJs = result.js;
                    } 
                }catch (e){}
            }
        });
    }catch (e){
      
    }
}

function _jszGVarsKV_Sels(firstKey=null,secondKey=null,threeKey=null,fourKey=null){
    var r=null;
    var p = ['sels'];
    if(firstKey!=null){
        p.push(firstKey);
    }
    if(secondKey!=null){
        p.push(secondKey);
    }
    if(threeKey!=null){
        p.push(threeKey);
    }
     if(fourKey!=null){
        p.push(fourKey);
    }
    try{r= _jszGVarsKV(window.jszGVars.kv,p);}catch (e){}
    return r!=null?r:[];
}
function _jszGVarsKV_Sels_uname(){
    var r= _jszGVarsKV_Sels('uname');
    return r!=null?r:[];
}
function _jszGVarsKV_Sels_prompt(){
     var r= _jszGVarsKV_Sels('prompt');
    return r!=null?r:[];
}
function _jszGVarsKV_Sels_observe(contentOrList=true){
     var r= _jszGVarsKV_Sels('observe',contentOrList?'content':'list');
    return r!=null?r:[];
}
function _jszGVarsKV_Sels_blacklist(contentOrList=true,absOrRel=true){
    var r= _jszGVarsKV_Sels('blacklist',contentOrList?'content':'list',absOrRel?'absolute':'relative');
    return r!=null?r:[];
}
function _jszGVarsKV_Sels_blacklistFilter(){
     var r= _jszGVarsKV_Sels('blacklist','filter');
     if(r!=null && !BJA_isArray(r)){
        r=[];
     }
    return r;
}
function _jszGVarsKV_Sels_favorite(){
    var r= _jszGVarsKV_Sels('favorite');
    return r!=null?r:[];
}
function _jszGVarsKV_Sels_searchbar(){
    var r= _jszGVarsKV_Sels('searchbar');
    return r!=null?r:[];
}
function _jszGVarsKVMapPrompt(){
    return _jszGVarsKVMapForKey('prompt_count',-1);
}
function _jszGVarsKVMapPromptUp(val){
    var f =false;
    var r = _jszGVarsKVMapPrompt();
    try{
        if(val>=0 && val != r){
           f=_jszGVarsKVMapSet('prompt_count',val);
        }
    }catch(e){}
    return f;
}
function _app_sub_ov_ThemeEncodeCss(mobile){
    if(!isSite()){
        if(_app_sub_ov_ThemeExtensionEncodeCss(mobile).length>0){
            return "@media (prefers-color-scheme: dark) {}";    
        }
        return null;
    }
    return mobile ?_jszDiscuzMbdark:_jszDiscuzPcdark;
}
function _app_sub_ov_ThemeExtensionEncodeCss(mobile){
    return mobile ?_jszSiteMbExtensionDark:_jszSitePcExtensionDark;
}
function _app_sub_ov_SiteExtensionJS(){
    return _jszSiteExtensionJs;
}
function _app_sub_ov_ThemeInstalled(isMobile,isDark){
    //执行需要修改iframe body颜色的代码
    try{
        var n =document.getElementById('e_iframe');
        if(n!=null){
            var b;
            var c;
            if(isDark){
                b='#121212';
                c='#e9e9e9';
            }else{
                b='#ffffff';
                c='#121212';
            }
            n.contentDocument.body.style.backgroundColor = b;
            n.contentDocument.body.style.color = c;
        }
    } catch(e){}
}
function _app_sub_ov_lazyImageUrl(){
    return _lazyDefaultImg;
}
function _app_sub_ov_currentSiteType(){
    var rc = 0;
    if(window.jszGVars.uatype==1){
        rc = 1;
    }else if(window.jszGVars.uatype==2){
        rc = 2;
    }else{
        var url =BJA_GetURL ();
        if(url == null || url.startsWith('about:blank',0) || !url.startsWith('http',0)){
            rc = 2;
        }
        else if(isSite(url) ){
            rc = 0;
        }
        else if((url.indexOf('mobile=2')>-1) || document.querySelector('header.chip_header')!=null) {
            rc=1;
        }
        else{
            rc =2;
        }
    }
    return rc;
}

//function _app_sub_def_imgNodesFunc(){}
function _app_sub_ov_imgNodes(){
    var r = [];
    try{
        if(window.jszGVars.isImageDocument==null){
            window.jszGVars.isImageDocument=BJA_documentIsImage();
        }
        if(window.jszGVars.isImageURI==null){
            window.jszGVars.isImageURI=BJA_isImagePage();
        }
    }catch(e){}
    if(!isSite() || window.jszGVars.isImageDocument==true || window.jszGVars.isImageURI==true){
        try{
            var nodes = document.images;
            if(nodes!=null && nodes.length>0){
                r = Array.from(nodes);
            }
        }catch(e){}
    }
    return r;
}

function _imageAutoImageGalleryHandle(img){
    if(img){
        if(window.jszGVars.autoImageGallery){
            var attr= BJA_ele_getStringAttribute(img, varAttr_onclick);
            if(attr !=null){
                if(BJA_ele_setStringAttribute(img, varAttr_bkonclick, attr)==1){
                  BJA_ele_removeAttribute(img,varAttr_onclick);
                }
            }
        }else {
            var attr= BJA_ele_getStringAttribute(img, varAttr_bkonclick);
            if(attr !=null){
                if(BJA_ele_setStringAttribute(img, varAttr_onclick, attr)==1){
                    BJA_ele_removeAttribute(img,varAttr_bkonclick);
                }
            }
        }
    }
}

function _app_sub_ov_image_handler(img,imgUrl){
    _imageAutoImageGalleryHandle(img);
}

function  _app_sub_def_imageModeChanged(val){
     BJA_run_throttle(_app_setLazyLoadingImages, 400);
}

function _app_sub_def_AutoImageGalleryChanged(){
    if(!isSiteThread(url)){
        return;
    }
    var xp = "//img[@"+ window.jszGVars.autoImageGallery?varAttr_onclick:varAttr_bkonclick  + "]";
    var imgNodes =  BJA_nodesDocumentForXPath(xp);
    if(imgNodes!=null){
        imgNodes.forEach(node => {
            _imageAutoImageGalleryHandle(node);
        });
    }
}

function  _app_sub_def_imageModeChanged(val){
    BJA_run_throttle(_app_setLazyLoadingImages, 400);
}

function _app_sub_def_AutoImageGalleryChanged(val){
    if(!isSiteThread(url)){
        return;
    }
    var xp = "//img[contains(@"+ window.jszGVars.autoImageGallery?varAttr_onclick:varAttr_bkonclick  + ",'zoom')]";
    var imgNodes =  BJA_nodesDocumentForXPath(xp);
    if(imgNodes!=null){
        imgNodes.forEach(node => {
            _imageAutoImageGalleryHandle(node);
        });
    }
}
function _app_sub_def_blacklistModeChanged(val){

}

function  webinterfaceThemeMode(appThemeMode,sysThemeDarkMode,uatype,imageMode,param){
    return _app_updateThemeMode(appThemeMode,sysThemeDarkMode,uatype,imageMode,param);
}

function webinterfaceAutoTheme(){
    _app_autoTheme();
}

function _blacklistNodeHandle(node,hide, displayOrVisiable){
    var r =0;
    if(hide){
        if(BJA_isVisible(node)){                               
            var s= displayOrVisiable?node.style.display : node.style.visibility;
            if(s==null||s==''){
                s = '-';
            }
            var f =false;
            if(displayOrVisiable){
                f=BJA_hideElement(node);
            }else{
                f=BJA_NoVisiableElement(node);
            }
            if(f){
                var atv = displayOrVisiable?'0':'1';
                atv= atv+'|'+s;
                BJA_ele_setStringAttribute(node,varAttr_zjsfilter, atv);
                r=1;
            }else{
                r=2;
            }
        }else{
            r=1;
        }
    }else{
        var flg= BJA_ele_getStringAttribute(node,varAttr_zjsfilter);
        if(flg !=null){
            var flgList= flg.split('|');
            if(flgList.length>1){
                var dv=BJA_parseInt(flgList[0]);
                var s = flgList[1];
                if(dv==0){
                    BJA_setDisplayElement(node,(s=='-')?null:s);
                }else if(dv==1){
                    BJA_setVisibilityElement(node,(s=='-')?null:s);
                }
            }
            BJA_ele_removeAttribute(node,varAttr_zjsfilter);
            r=3;
        }
    }
    return r;
}

function _blacklistFoundNodeHandle(blacklist,node,sel,aquerycount,displayOrVisiable){
    var fd =false;
    var alist=[];
    if(aquerycount==1){
        var an = BJA_querySelector(node,sel);
        if(an!=null){
            alist.push(an);
        }
    }else{
        alist = BJA_querySelectorAll(node,sel);
    }
    if(alist){
        for(var j =0; j< alist.length; j++){
            var anode= alist[j];
            var user=null;
            try{user= anode.textContent.trim();}catch(e){}
            if(user!=null &&  blacklist.indexOf(user)>-1){
                fd = true;
                break;
            }
        }
    }
    return _blacklistNodeHandle(node,fd,displayOrVisiable);
}

function filterBlacklistContent(addedNodes=null){
    var _blacklistModeBefore = _jszGVarsKVMapForKey(varMap_blacklistModeLast);
    try {
        var isList = isSiteForum();
        var isContent = isSiteThread();
        var shouldCheck =(window.jszGVars.blacklistMode==1 && (isList||isContent))||
         (isList&&  window.jszGVars.blacklistMode==2)|| 
         (isContent&&  window.jszGVars.blacklistMode==3);
        var cancelBefore =window.jszGVars.blacklistMode==0;
        if(cancelBefore==false && _blacklistModeBefore!=null && _blacklistModeBefore!= window.jszGVars.blacklistMode) {
            if(_blacklistModeBefore==2 && isList){
                cancelBefore=true;
            }else  if(_blacklistModeBefore==3 && isContent){
                cancelBefore=true;
            }
        }
        if(window.jszGVars.blacklistMode==0 || cancelBefore){
            if(addedNodes!=null){
                addedNodes.forEach(node => {
                    var rs = BJA_querySelectorAll(node,"*["+varAttr_zjsfilter+"]");
                    if(rs!=null){
                        rs.forEach(fnode => {
                            _blacklistNodeHandle(fnode,false,null);
                        });
                    }
                });
            }else{
                var rs = BJA_querySelectorAll(document,"*["+varAttr_zjsfilter+"]");
                if(rs!=null){
                    rs.forEach(fnode => {
                        _blacklistNodeHandle(fnode,false,null);

                    });
                }
            }
            _jszGVarsKVMapSet(varMap_blacklistModeLast, window.jszGVars.blacklistMode);
            return;
        }
        var blacklist = window.jszGVars.blacklist;
        var filterCount = 0;
        var filtedCount = 0;
        var filterFailedCount = 0;
        var delFilterCount = 0;
    
        if(addedNodes!=null){
            if (shouldCheck && ( blacklist.length>0)){
                var addedNodeHandleBlacklistSels= _jszGVarsKV_Sels_blacklist(isContent,false);
                addedNodes.forEach(node => {
                    try{
                        for(var i =0; i< addedNodeHandleBlacklistSels.length; i++){
                            var tsel= addedNodeHandleBlacklistSels[i].trim();
                            var sel =tsel;
                            var aquerycount =1;
                            var displayOrVisiable=true;
                            if(sel.indexOf('|') >0){
                                var vvs =sel.split('|');
                                sel = vvs[0];
                                vvs = BJA_parseInt(vvs[1]);
                                if(vvs.length>2){
                                   var dv= BJA_parseInt(vvs[2]);
                                   if(dv==1){
                                     displayOrVisiable =false;
                                   }
                                }
                            }
                            var rc= _blacklistFoundNodeHandle(blacklist,node,sel,aquerycount,displayOrVisiable);
                            if(rc==1){
                                filterCount++;
                            }else if(rc==2){
                                filterFailedCount++;
                            }else if(rc==3){
                                delFilterCount++;
                            }
                        }
                    }catch(e){
                        
                    }
                });
            }
            return;
        }

        if(shouldCheck){
            var cssList= _jszGVarsKV_Sels_blacklist(isContent,true);
            for(var vsi =0; vsi< cssList.length; vsi++){
                var qsaList = cssList[vsi].split('|');
                var firstCss =qsaList[0].trim();
                var secondCss = qsaList[1].trim();
                var aquerycount =1;
                var displayOrVisiable=true;
                if(qsaList.length>2){
                    aquerycount=parseInt(qsaList[2].trim());
                }
                if(qsaList.length>3 && parseInt(qsaList[3].trim())==1){
                    displayOrVisiable=false;
                }
                var list = BJA_querySelectorAll(document,firstCss);
                if(list!=null){
                    for(var i=0; i<list.length;i++){
                        var node = list[i];
                        var rc = _blacklistFoundNodeHandle(blacklist,node,secondCss,aquerycount,displayOrVisiable);
                        if(rc==1){
                            filterCount++;
                        }else if(rc==2){
                            filterFailedCount++;
                        }else if(rc==3){
                            delFilterCount++;
                        }
                    }
                }
            }
        }  
        window.jszGVars.handleBlacklistCount+=1;
       
    }catch(e){
        
    }
    _jszGVarsKVMapSet(varMap_blacklistModeLast, window.jszGVars.blacklistMode);
}

function webinterfaceSetBlacklist(jsonParams){
    var rc = 0;
    try{
        _bja_private_safeInitVars();
        if (jsonParams) {
            var jsObj = BJA_getJSON(jsonParams);
            if (jsObj) {
                var list = jsObj['list'];
                if (list&& BJA_isArray(list) ) {
                    window.jszGVars.blacklist = list;
                    rc = list.length;
                
                }
            }
        }
        if(rc!=0){
            __jszBlacklistHandle();
        }
    }catch(e){
        
    }
    return rc; 
}

function webinterfaceBlacklistMode(value){
    var rc = BJA_parseInt(value);
    if(rc != null){
        if(_app_private_updateBlacklistMode(rc)==1){
            __jszBlacklistHandle();
        }
    }
}

function webinterfaceUpdateBlacklist(jsonParams){
    var rc = 0;
    if (jsonParams  ) {
        var jsObj = BJA_getJSON(jsonParams);
        if (jsObj) {
            var name = jsObj['name'];
            var isadd= jsObj['op'];
            if (BJA_isString(name)) {
                var index = window.jszGVars.blacklist.indexOf(name);
                if(isadd==1){
                    if (index <0) {
                        window.jszGVars.blacklist.push(name);
                        rc++;
                    } 
                } else {
                    var index = window.jszGVars.blacklist.indexOf(name);
                    if (index > -1) {
                        window.jszGVars.blacklist.splice(index, 1);
                        rc -=1;
                    }
                }
            }
        }
    }
    if(rc!=0)
    {
        __jszBlacklistHandle();
    }
    return rc; 
}

function _jszGetSiteLoginUserInfo(){
    var ret = new Object;
    var userUrl =null;
    var username =null;
    //pc
    var pcSels = [
        "div[id='hd'] div[id='um'] div.avt a[href*='space-uid-']", 
    ];
    var mbSels = [
        "section#avatar_pop div.ava_user a[href*='uid=']",
        "body > div.wp > div.pd2 > a:nth-child(1)"
    ];
    var atextfilters=[];
    var aclassfilters =[];
    var sels;
    var url =BJA_GetURL ();
    ret.src = url?url:'';
    var iconurl = null;
    var uid ='';
    try{uid=window.discuz_uid;}catch(e){}
    if((url!=null && (url.indexOf('mobile=2')>-1))){
       sels = mbSels.concat(pcSels);
    }else{
       sels = pcSels.concat(mbSels);
    }
    for (var i =0; i< sels.length; i++){
        var anodes = document.querySelectorAll(sels[i]);
        if(anodes){
            var len = anodes.length;
            for(var j = len -1; j>=0; j--){
                var anode =  anodes[j];
                var clsVall= BJA_ele_getStringAttribute(anode,"class");
                var clstext= anode.text;
                if(clstext!=null){
                    clstext= clstext.trim();
                }
                if(  ((clstext ==null ) || (clstext!=null) &&( atextfilters.indexOf(clstext)<0) ) 
                    && 
                    ((clsVall==null) ||  ((clsVall!=null) && (aclassfilters.indexOf(clsVall)<0)))){
                    var slink= BJA_ele_getStringAttribute(anode,"href");
                    if(slink!=null){
                        userUrl= BJA_getEntireUrl(slink,url);
                        if(userUrl!=null){
                            username = clstext;
                            var img = anode.querySelector("img.user_avatar");
                            if(img){
                                var imgSrc=BJA_ele_getStringAttribute(img,"src");
                                if(imgSrc!=null){
                                   iconurl= (url!=null)? BJA_getEntireUrl(imgSrc,url):imgSrc;
                                   if(iconurl.toLowerCase().indexOf('http')!=0){
                                    iconurl =null;
                                   }
                                } 
                            }
                            break;
                        }else{
                            userUrl=null;
                        }
                    }
                }   
            }
            if(userUrl!=null){
                break;
            }
        }
    } 
    ret.url = userUrl?userUrl:'';
    ret.name = username?username:'';
    ret.icon = iconurl?iconurl:'';
    ret.uid =uid?uid:'';
    return ret; 
}

function webinterfaceGetLoginUserInfo(){
    return BJA_objToJSONString(_jszGetSiteLoginUserInfo()); 
}

function webinterfaceWebForumInfo()
{
    var backInfo = new Object;
    var url =BJA_GetURL ();
    backInfo.fid= '';
    backInfo.url ='';
    backInfo.src =url?url:'';
    backInfo.page ='';
    backInfo.gid ='';
    backInfo.tid ='';
    if(isSite(url)){
        var page = _bja_discuzPageFromUrl(url);
        if(page!=null){
            backInfo.page=page;
        }
        var fidStr= _bja_discuzFidFromUrl(url);
        if(fidStr!=null){
            backInfo.fid = fidStr;
        }
        var gidStr= _bja_discuzAreaIdFromUrl(url);
        if(gidStr!=null){
            backInfo.gid = gidStr;
        }
        var tidStr= _bja_discuzTidFromUrl(url);
        if(tidStr!=null){
            backInfo.tid = tidStr;
        }
        try{
            //pc site
            var list =BJA_xpathQuerySelector(document,"div#pt div.z a[href]||section.pop_board_nav a:not([href*='mod=post']):not([href*='javascript:'])");
            if(list!=null && list.length>0){
                var a= null;
                if(list.length<4){
                    a=list.pop();
                }else if(list.length>=4){
                    a=list[list.length-2];
                }
                var link = BJA_ele_getStringAttribute(a,'href');
                var name= BJA_ele_getText(a);
                if(link && link.length>0 && name && name.length>0){
                    var u =  BJA_getEntireUrl(link,backInfo.src);
                    if(u && u.length>0){
                        backInfo.url=u;
                        backInfo.name=u;
                    }
                }
            }
            if(backInfo.url==''){
                list =BJA_querySelectorAll(document,"div>h2>a[href*=fid]|body > div.wp > div[class='box'] > a");
                if(list!=null && list.length>0){
                    //https://bbs.pcbeta.com/forum.php?mod=forumdisplay&fid=574&page=1
                    //https://bbs.huorong.cn/forum.php?mod=viewthread&tid=142013&mobile=1
                    var a= list.pop();
                    while(a){
                        var link = BJA_ele_getStringAttribute(a,'href');
                        var name= BJA_ele_getText(a);
                        if(link && link.length>0 && name && name.length>0){
                            var u =  BJA_getEntireUrl(link,backInfo.src);
                            if(u && (u.length>0) && u!=backInfo.src){
                                backInfo.url=u;
                                backInfo.name=name;
                                if(backInfo.fid=='' ){
                                    var fid= _bja_discuzFidFromUrl(u);
                                    if(fid&& fid.length>0){
                                        backInfo.fid = fid;
                                    }
                                }
                                break;
                            }
                        }
                        a= list.pop();
                    }
                }
            }
            if(backInfo.url=='')
            {   
                //https://www.chiphell.com/portal.php?mod=view&aid=34951&mobile=2
                //list =document.querySelectorAll("section.pop_board_nav a ");
               // if (list.length ==0) {
               list =document.querySelectorAll("div.pop_board_nav a ");
               // }
                var total = list.length;
                var last =total-1;
                var i = last;
                while(i>=0) {
                    var anode = list[i];
                    var title= anode.textContent.trim();
                    var fid =null;
                    var gid =null;
                    var link=null;
                    //forum-319-1.html
                    if ((title.length > 0) && (title != '回复') ) {
                        link = BJA_ele_getStringAttribute(anode,'href');
                        if (link =='index.php?mobile=2' ||
                            link =='forum.php?mobile=2' ||
                            link =='index.php?mobile=3' ||
                            link =='forum.php?mobile=3' ||
                            link.indexOf("mod=forumdisplay&fid=")>-1 ||
                            (  (link.indexOf('forum.php') > -1)  && (i!=last && (total!=1) )  ) ||
                            ( (link.indexOf('portal.php') > -1)  && (i!=last) && (total!=1)  )
                        )
                        {
                            var forumUrl =  BJA_getEntireUrl(link,backInfo.src);
                            if( (forumUrl!= backInfo.src) && (forumUrl.toLowerCase().indexOf('http')==0)  ){
                                backInfo.name =title;
                                backInfo.url =forumUrl;
                                if(backInfo.fid==''){
                                    fidStr=   _bja_discuzFidFromUrl(forumUrl);
                                    if(fidStr!=null){
                                        backInfo.fid = fidStr;
                                    }
                                }
                                break;
                            }
                        }
                    }
                    i--;
                }
            }
        }catch(e){

        }
    }
    
    return BJA_objToJSONString(backInfo);
}

function webinterfaceWebImagesInfo(){
    _auto_reset_notDiscuzImageSel();
    return BJA_objToJSONString(_app_jsz_autoImages(false));
}

function webinterfaceWebImageCount(){
    _auto_reset_notDiscuzImageSel();
    var count = _app_jsz_autoImages(false).count;
    return ''+count;
}

function webinterfaceWebImageMode(imgMode){
    var rc = BJA_parseInt(imgMode);
    if(rc != null){
        _app_private_updateImageMode(rc);
    }
}

function webinterfaceAutoImageGallery(value){
    var rc = BJA_parseInt(value);
    if(rc != null){
        _app_private_updateAutoImageGallery(rc!=0?true:false);
    }
}

function _jszAddFilterButton(e,username){
   if(username!=null && username.length>0){
        var  un= encodeURIComponent(username);
        var buttonHTML= "<a href=" +  '"'+ 'zorro_add_filter://'+un+'" '+ ` class="xw1" style="color: #CC0000!important; white-space: pre"> 过滤 </a>`;
        e.innerHTML += buttonHTML;
    }
}

function _jszAddFilterButtonMobile3(e,username){
   if(username!=null && username.length>0){
        var  un= encodeURIComponent(username);
        var buttonHTML= "<li><a href=" +  '"'+ 'zorro_add_filter://'+un+'" '+ ` class="xw1" style="color: #CC0000!important; white-space: pre"> 过滤 </a></li>`;
        e.innerHTML += buttonHTML;
    }
}

function _jszIsAddedFilterButton(e){
    var alist= BJA_nodesForXPath(e, ".//a[contains(@href,'zorro_add_filter://')]");
    return alist!=null && alist.length>0;
}

function _jszAddUserBlackButtonToPost(post,selObj){
    var r =false;
    try{
        if(selObj!=null){
            var plugEle =  BJA_xpathQuerySelector(post,selObj.relative,false);
            if(plugEle!=null){
                if(_jszIsAddedFilterButton(plugEle)){
                    r =true;
                }else{
                    var auth =  BJA_xpathQuerySelector(post,selObj.node,false);
                     if(auth!=null){
                        _jszAddFilterButton(plugEle,auth.textContent);
                        r=true;
                    }
                }
            }
        }
    }catch (e){
        wbsdk_console("_jszAddUserBlackButtonToPost error:"+e); 
    }
    return r;
}

function _jszAddUserBlackButtonToPostList(posts,selObj=null,force=false){
    var r=false;
    var sucess=0;
    if(force || isSiteThread() || isSiteForum()){
        var nodes =BJA_arrayFromNodeList(posts);
        var vsels=null;
        if(nodes && BJA_isArray(nodes) && nodes.length>0){
             for(var i=0; i< nodes.length;i++){ 
                 var node =nodes[i];
                 if(selObj!=null){
                    var rc= _jszAddUserBlackButtonToPost(node,selObj);
                    if(rc){
                        sucess++;
                    }
                 }else{
                    vsels= vsels==null? _jszGVarsKV_Sels_blacklistFilter():vsels;
                    if(vsels!=null && vsels.length>0){
                        for(var j=0; j< vsels.length;j++){ 
                            var sel = vsels[j];
                            var flag= _jszAddUserBlackButtonToPost(node,sel);
                            if(flag){
                                break;
                            }
                        };
                    }
                 }
            }
        }
    }
    r = sucess>0;
    return r;
}

function _jszAddUserBlackButtonToAllPost(){
    if(isSiteThread() || isSiteForum()){
        try{
            var vsels= _jszGVarsKV_Sels_blacklistFilter();
            if(vsels && vsels.length>0){
                for(var i=0; i< vsels.length;i++){
                    var selObj =vsels[i];
                    var topSel = selObj.absolute;
                    var lou = BJA_xpathQuerySelector(document,topSel,true);
                    if(lou!=null && lou.length>0){
                        if(_jszAddUserBlackButtonToPostList(lou,selObj,true)){
                            break;
                        }
                    }
                }
            }
            
        }catch (e){
            wbsdk_console("_jszAddUserBlackButtonToAllPost error:"+e); 
        }
    }
}

function _jszFuncClickTapFavor(csList){
    var r =0;
    if(isSite()){
        try{
            for(var i = 0; i<csList.length; i++){
                var cs = csList[i];
                var node = document.querySelector(cs);
                if(node){
                    if(BJA_ele_getStringAttribute(node,'addclick')==null){
                        var flag = BJA_ele_getIntAttribute(node,'favid');
                        if(flag == null){
                            flag = 0;
                        }
                        node.addEventListener('click',function(event){
                            flag = flag==0?1:0;
                            _app_sub_ov_sendMsgToApp([{'tapFavor': ''+flag }]);
                        });
                        BJA_ele_setStringAttribute(node,'addclick','1');
                        r +=1;
                    }else{
                        r +=1;
                     
                    }
                }else{
               
                }
            }
        }catch (e){
          
        }
    }
    return r;
}

var _vsprompt_msg_timer = -1;
function _jszFuncUserPromptMessage(){
    if(_vsprompt_msg_timer >0 || !isSite()) {
        return;
    }
    function _timerhandle(){
        if(!isSite()) {
            return;
        }
        try{
            var discuz_name = null;
            var discuz_uid=null;
            var count =0;
            try{
                discuz_uid=window.discuz_uid;
                if(BJA_isString(discuz_uid)){
                    discuz_uid=discuz_uid.trim();
                    if(discuz_uid.length<=0 || discuz_uid=='0'){
                        discuz_uid =null;
                    }
                }
                if(discuz_uid!=null){
                    var rgs = _jszGVarsKV_Sels_uname();
                    //['#avatar_pop div.ava_user a','#hd #um .vwmy a'];
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
            } catch(e){
                return;
            }
            if(discuz_uid!=null) {
                var rlist =_jszGVarsKV_Sels_prompt();
                // ['#avatar_pop > div.apop_con > div.ava_menu > ul > li:nth-child(6) > a > span'];
                for(var i = 0; i<rlist.length; i++){
                    var node =document.querySelector(rlist[i]);
                    if(node){
                        var msg = node.textContent.trim();
                        if(msg!=null && (msg.indexOf('有新提醒')>=0) ){
                            count = 1;
                        }else{
                            count=0;
                        }
                        break;
                    }
                }
            }
            if(discuz_name==null){
                discuz_name='';
            }
            if(discuz_uid==null){
                discuz_uid='';
            }
            if(_jszGVarsKVMapPromptUp(count)){
                _app_sub_ov_sendMsgToApp([{'promptmsg':{'name':discuz_name, 'uid':discuz_uid,'count':count ,'stamp': new Date().getTime()}}]);
            }
        }catch(e){
        }
    }
    _vsprompt_msg_timer = setInterval(_timerhandle, 3000);
}

var __jszMC = BJA_run_debounce(function (){
        if(isSite()){
            var sels =  _jszGVarsKV_Sels_observe(isSiteForum()?false:true);
            var n =null;
            if(sels!=null){
                for(var i=0; i<sels.length;i++){
                    n = document.querySelector(sels[i]);
                    if(n!=null){
                        break;
                    }
                }
            }
            if(n){
                BJA_AddMutation(n,0,function(m){
                    filterBlacklistContent(m.addedNodes);
                    _app_jsz_autoImages(true,m.addedNodes);
                    _jszAddUserBlackButtonToPostList(m.addedNodes);
                },0,null);
            }else{
               
            }
        }
    },1000,false);
    
var __jszACF = BJA_run_debounce(function (){
        if(isSite()){
            _jszFuncClickTapFavor(_jszGVarsKV_Sels_favorite());
            _jszAddUserBlackButtonToAllPost(); 
            _jszFuncUserPromptMessage();
        }
    },1000,false);
    
var __jszPCSearch = BJA_run_debounce(function (){
        if(isSite()){
            BJA_for(_jszGVarsKV_Sels_searchbar(),function(t,i,e){
                if(e!=null){
                    BJA_addPCSearchBar(document.querySelector(e));
                }
            });
        }
    },1000,false);

var __jszSiteInfo = BJA_run_debounce(function (){
        if(isSite()){
            var r = 0;
            var curl = BJA_GetURL();
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
            var cookiedm = '';
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
                cookiedm =cookiedomain;
                cd=cookiedomain;
                if(cookiedomain.startsWith('.')){
                    cd = cookiedomain.slice(1);
                }
                cp=cookiepre;
                uid=discuz_uid;
                tcharset=charset;
                isdiz ='1';
                if(stt==''){
                   stt= BJA_stringByMatch(document.title, "-([^-\s]+论坛)",1);
                }
            }catch(e){}
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
            }catch(e){
                tcharset=BJA_getPageCharset();
                r =-1;}
            _app_sub_ov_sendMsgToApp([{'siteinfo': r }]);
        }
    },1000,false);

function _app_sub_def_initFunc(){
    try{
        _app_sub_ov_sendMsgToAppAndResult([{'theme': '0'}],function(result){
            if (result) {
                window.jszGVars.appThemeMode = result.themeModel;
                window.jszGVars.uatype = result.uatype;
                window.jszGVars.sysThemeDarkMode =result.sysThemeDarkMode;
                window.jszGVars.themeInit =true;
                if(BJA_isArray(result.param) && result.param.length > 1 ){
                    var iv =  BJA_parseInt(result.param[0]);
                    _app_private_updateAutoImageGallery(iv!=0?true:false);
                    iv =  BJA_parseInt(result.param[1]);
                    _app_private_updateBlacklistMode(iv);
                }
                _app_private_updateImageMode(result.imageMode);
                webinterfaceAutoTheme();
            }
        });
    }catch (e){
      
    }
}

function _app_sub_def_headOrBodyReadyFunc(){
    _app_sub_ov_sendMsgToApp([{'domReady': '1'}]);
}



var __jszBlacklistHandle = BJA_run_debounce(filterBlacklistContent,1000,false);
var __jszAddThemeListenerFlag = false;
function _app_sub_def_domReadyFunc(type){
    webinterfaceAutoTheme();
    if(!__jszAddThemeListenerFlag){
         __jszAddThemeListenerFlag=BJA_addThemeChangListener(function (){
            webinterfaceAutoTheme(); 
        });
    }
    __jszMC(); 
    __jszACF();
    __jszBlacklistHandle();
    __jszPCSearch();
    __jszSiteInfo();
}
_bja_safeInitSDK();

