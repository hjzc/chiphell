## 文件说明

### 基础js代码
    开发版：theme.js
    Release版：theme_release.js
### web_notification.js 支持web 通知的js文件,在不支持通知的webview 加载这个文件 自动支持通知。

### Site js代码
    开发版：wbsdk.js
    Release版：wbsdk_release.js

### Site js 加密文件
    wbsdk 为wbsdk.js的加密文件，参看aes_util.dart
    wbsdk0 为备份文件

## 工具
js 代码压缩：https://www.mayicms.com/js/
css base64 https://www.sojson.com/base64.html

## 皮肤
1. media 模式：适合纯网页，无需 JS 控制，但依赖系统支持（iOS ≥13 / Android ≥10 + WebView ≥84）

```js
window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches==true
window.matchMedia && window.matchMedia('(prefers-color-scheme: light)').matches==true
```
否则应该是系统不支持，这个时候应该去掉 @media (prefers-color-scheme: dark) {},否则暗黑模式失败
android 10以下 css 加上 prefers-color-scheme 可能不执行
```js
if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
  // 暗色模式
  document.body.classList.add('dark-mode');
} else {
  // 亮色模式
  document.body.classList.remove('dark-mode');
}
```

## querySelectorAll的语法
  文档(https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Selectors/Attribute_selectors)
  所有 div 元素下的第一个子元素是 p 的元素。
  ```js
  let elements = document.querySelectorAll('div > p:first-child');
  ```
  ID选择器: #id
  ```js
  '#myId'
  ```
  类选择器: .class
  ```js
  '.myClass'
  ```
  标签选择器: tag
  ```js
  'div'
  ```
  属性选择器: [attribute=value] 
  ```js
   'input[type="text"]'
  ```
  后代选择器: ancestor descendant 
  ```js
   '#container .item'
  ```

  伪类选择器: 返回所有满足 nth-child(odd) 规则的 li 元素（即奇数位置的元素）
  ```js
  :pseudo-class =》  document.querySelectorAll('li:nth-child(odd)');
  ```
  
  不包括：img属性zsrc不包括smiley的节点：  
  ```js
  img[zsrc]:not([zsrc*=smiley])
  // 不要 .hidden 的
  const filtered = document.querySelectorAll('.item:not(.hidden)');
  // 文本包含关键词的
  const filtered = document.querySelectorAll('.item:has-text("关键词")'); 
  ```
选择器类型
类型	示例	说明
标签	'div'	所有 div
类	'.className'	所有带该类的元素
ID	'#myId'	唯一 ID 元素
属性	'[type="text"]'	属性选择器
后代	'div p'	div 内的所有 p
子元素	'ul > li'	ul 的直接子 li
伪类	'li:first-child'	第一个 li
组合	'div.active, span.highlight'	多个选择器（逗号分隔）

    兄弟节点：div.divsearchli兄弟节点table
    div.divsearchli~table



## 图片url过滤 window.jszGVars.imgUrlFilters 定义

```js
  window.jszGVars.imgUrlFilters = ['static/image/','/smiley/diy/','images/smiley/','images/logo.png','data/avatar/'];
```

  url包括 'static/image/' 则过滤
  url匹配表达式： 'X:\\d+' ,则过滤
  测试代码：

  ```js
  var vr ='https://bbs.pcbeta.com/static/image/smiley/yumeitu/21.gif';
  BJA_isMatchByString(vr,"smiley/([a-z|A-Z|0-9_])+/\\d+.gif")
  ```

  需要过滤的非内容图片
  ![smiley](https://bbs.pcbeta.com/static/image/common/uploadbutton_small.png)
  ![smiley](https://bbs.pcbeta.com/static/image/smiley/yumeitu/21.gif)
  ![广告](https://bbs.pcbeta.com//data/attachment/common/cf/185727usa0zva41711scs4.gif)
  ![smiley](static/image/common/none.gif)

## 图片节点寻找XQS选择器 BJA_xpathQuerySelector(e,xqs)
1. 支持 query selector 选择器, 支持或运算符 ||
    一次选择："#article_content a img", 
    or 选择："a||img",  只执行1次，找到a就不执行img了
    使用｜分隔符，则两者都执行，结果相加
2. 支持 xpath: 'X:' 作为区别selector。支持或运算符 ||
    找到./a则不计算/img:  "X:./a||/img",
    找到./a 与 /img 结果相加  : "X:./a|/img",
3. 优先顺序，先使用||分隔，然后selector使用|。xpath则直接执行（支持|运算符）
4. js 函数 BJA_query(),function BJA_querySelectorAll(node, sel);

## 正则表达式， 支持数组，支持一个字符串通过||组合多个表达式
1. BJA_stringByMatchList(string, regexs, capture); 支持多个表达式，获得结果成功后，后面的表达式将忽略
2. function BJA_isMatchListByString(string, regexs);支持多个表达式，表达式匹配后，后面的表达式将忽略
3. function BJA_stringByMatchOrString(string, regexStr, capture); regexs：通过 || 连接多个表达式。
4. function BJA_isMatchByOrString(string, regexStr);
5. 如 BJA_isMatchByString('d-1', "\\d+|\\w+");
6. 如 BJA_isMatchByString('d-1', "\\d+||\\w+");

```js
window.jszGVars.imgContentSels=  [
        //chiphell 文章，测评 内容
        "#article_content a img",       

        //chiphell 移动版本 文章，测评 内容   
        "article.chip_article_view a img",  

        "div[id*='pid'] img[id]",       

        // pc版本 帖子内容,找到前面，就忽略后面
        "table[id*='pid'] img[id*='aimg_']||#postlist div[id*='post_'] div.t_fsz img[id]",  

        //pcbeta.com 移动版本帖子内容图片
        "div.message img[zsrc]:not([zsrc*=smiley])"
    ];
```
监听节点下面的孩子节点增加删除，执行
```js
window.jszGVars.addImageContentSels = [
        "div.c>a>img",
        "a>div.ab1>img",
        "li>a.tm01>img",
        "[id*='postmessage_']>ignore_js_op>img",
    ];
```

## 自定义变量 window.jszGVars.kv.set('sels',sels);

```js
var sels = {
        'uname': ['#avatar_pop div.ava_user a','#hd #um .vwmy a'],
        'prompt':['#avatar_pop > div.apop_con > div.ava_menu > ul > li:nth-child(6) > a > span'],
        'observe':{
            'content':['#postlist', '#waterfall','#threadulid','#ainuoloadmore','div.chip_index_new>ul','div.viewthread'],
            'list':["div.chip_index_new > ul","article.chip_article_new > ul","table#threadlisttableid","ul#waterfall"]
        },
        'blacklist':{
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
                    "ul#waterfall li | .auth a[href*='space-uid']|1|1"
                ],
                'relative':["tr:nth-child(1) > td:nth-child(3) > cite:nth-child(1) > a:nth-child(1)", "a[href*='mod=space']",".auth a[href*='space-uid']|1|1" ]
            }
        },
        'favorite':["a[id='a_favorite']","a.favbtn","a[id='k_favorite']" ],
        'searchbar':['#scbar > div:nth-child(2) > form'],
    };
```
### 黑名单
    黑名单，包括帖子列表的隐藏，和内容楼层的隐藏，获取定义变量的函数
```js
function _jszGVarsKV_Sels_blacklist(contentOrList=true,absOrRel=true){
     var r= _jszGVarsKV_Sels('blacklist',contentOrList?'content':'list',absOrRel?'absolute':'relative');
    return r!=null?r:[];
}
```
    选择器sel语句解析，暂不支持xpath
    blacklist->list->absolute，absolute表示对绝对的选择器节点 relative表示相对节点，比如用户下拉增加的节点，就使用relative定义的选择去来处理
```js
     "ul#waterfall li | .auth a[href*='space-uid']|1|1"
``` 
  使用字符|分隔成了4个部分，因为是absolute 有四个部分
  1. 使用选择器找到ul#waterfall li，多个节点，然后循环每个节点。
  2. 以之前找到的节点为基础，使用第二部分表示选择器 寻找节点， 判断第三部分是1，表示寻找第一个节点，其他为多个节点
  3. 第四部分值是对找到的节点使用隐藏方式（display Or Visiable），1表示使用BJA_NoVisiableElement(node)方式隐藏元素;其他使用BJA_hideElement(node);方式
     有些节点使用在隐藏后必须保持占位，非常ui会错乱，如下面![列子](https://www.chiphell.com/forum-319-1.html)

```html
<ul id="waterfall" class="ml waterfall cl" style="height: 7264px; width: 1178px;"><li style="width: 386px; position: absolute; left: 0px; top: 0px;">
  <li style="width: 386px; position: absolute; left: 396px; top: 477px;">
  <div class="c cl">
  <a href="thread-2793360-1-1.html" onclick="atarget(this)" title="胖胖黑木凤——九州风神CH260WOOD+铭瑄B850M PRO II+索泰RTX5060TI XGAMING装机分享" class="z">
  <img src="https://static.chiphell.com/forum/threadcover/95/6b/2793360.jpg" alt="胖胖黑木凤——九州风神CH260WOOD+铭瑄B850M PRO II+索泰RTX5060TI XGAMING装机分享" width="362">
  </a>
  </div>
  <h3 class="xw0">
  <a href="thread-2793360-1-1.html" onclick="atarget(this)" title="胖胖黑木凤——九州风神CH260WOOD+铭瑄B850M PRO II+索泰RTX5060TI XGAMING装机分享">胖胖黑木凤——九州风神CH260WOOD+铭瑄B850M PRO II+索泰RTX5060TI XGAMING装机分享</a>
  </h3>
  <div class="auth cl">
  <cite class="xg1 y">
  喜欢: 0 &nbsp; 回复: <a href="thread-2793360-1-1.html" title="12 回复">12</a>
  </cite>
  <a href="space-uid-171061.html">youzhusky</a></div>
  </li>
</ul>
```


## 用户定义css样式加载（自带extension目录，）
  //linux /home/zorro/Documents/chiphell/web/sites
  //ios 使用doc目录，系统文件App 能访问
  //macos /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Documents/chiphell/web/sites
  //android /data/user/0/com.zorro.chiphell/app_flutter/web/sites
  //windows C:\Users\Zorro\Documents\chiphell\web\sites

  https://cliff.imwork.net:19999/xfbbs/ -> cliff.imwork.net-19999_xfbbs
  https://www.chiphell.com/ -> www.chiphell.com

  如果是UA代理-增加后缀： 
    css: www.chiphell.com-mb.css
    js:  www.chiphell.com-mb.js