## 版本，改动内容
## v-1.0.21
修复设置跟随主题时，系统主题变化没有更新主题。

## v-1.0.20
修复有些系统会一直弹通知窗口问题
修改android compileSdk = 37

## v-1.0.19
升级最新flutter sdk(3.47.7)， 依赖库最新
修复macos27 窗口标题栏背景色透明

## v-1.0.18
地址栏输入法，因为安全键盘，无法切换输入法
修复地址栏编辑问题
修复后退逻辑的一个bug
修复文件名后缀名为null的情况（导出pdf，title包含'.'导致文件名pdf没有设置成功）
修改图片保存文件夹为Chiphell
修改windows平台图片保存从‘文档图片’转到用户图片目录中

## v-1.0.17
调整看图按钮风格和位置
修复主次窗口黑名单模式性能问题
修复帖子页面看图提示消失问题
支持多discuz站点的切换，探测，用户指定。
支持多discuz，目录站点如：https://cliff.imwork.net:19999/xfbbs/
支持discuz页面css扩展
支持非discuz站点单独设置css
支持论坛附件二进制文件下载,
支持图片查看，支持文件下载
优化和解决移动列表过滤
增加用户定义css样式/js代码加载（自带extension目录）
  //macos /Users/cjxy/Library/Containers/com.zorro.chiphell/Data/Documents/chiphell/web
  //android /data/user/0/com.zorro.chiphell/app_flutter/web
  //windows C:\Users\用户\Documents\chiphell\web

优化bbs.pcbeta.com 论坛
桌面平台增加了打开图片下载目录
增加了图片压缩功能。为了方便发帖，回帖时候图片大小适应
增加了图片压缩大小上限设置

gif 保存

///帖子加上背景图片，暗黑模式无法改变
#pid59058327 {
background-image: url("static/image/postbg/bg3.png");
}

问题：
1. 回帖发帖内嵌iframe，设置css颜色 --fix

```js
document.getElementById('e_iframe').contentDocument.body.style.backgroundColor = 'red';
document.getElementById('e_iframe').contentDocument.body.style.color = 'white';
```

2. 支持discuz站点css style （STYLEID = '22'）列表：
  22:https://www.chiphell.com/thread-2803850-1-1.html，ok
  6： https://www.ixian.cn/forum-88-1.html
      https://bbs.pcbeta.com/
  5:  https://cliff.imwork.net:19999/xfbbs/

3. discuz 有些页面没有discuz变量，当时属于同一个站点


## v-1.0.16
1. 修复移动版，帖子内容楼主没有过滤
2. 修复移动版本发帖有些组件没适配暗模式
3. 增加了设置过滤模式功能，可以选择开启，关闭，只过滤列表，只过滤帖子内容
4. 移动版对帖子列表用户长按的识别
5. 调整书签页面UI
6. 增加了过滤明单csv文件的导入导出

增加黑明单对保持尺寸又隐藏元素的style.visibility的情况处理，如："ul#waterfall li |.auth a[href*='space-uid']|1|1"，第三个参数1表示对visibility属性的处理

## v-1.0.15.1
1. 修改了手势返回，后退一个页面功能，不能后退将进入程序退出判断。可设置是否启用这个功能。默认启用
2. 修正了 android 14-16 不能拦截手势退出应用，设置1.5秒内两次返回手势，将退出应用。
3. 增加了，主页面服务器繁忙时候，提示信息。

## v-1.0.15
- 修正了启动由于流程异常，导致更新功能失常。
- 修正了内部浏览窗口关闭 web资源没有被关闭，导致的后台继续播放

---通知功能
  1.有 - 新提醒 - title会一闪一闪的。（我的帖子 有人回帖了）
    pc版本：
      document.querySelector('#myprompt').textContent => 提醒(1)
      点击 跳到 https://www.chiphell.com/home.php?mod=space&do=notice"
    mobile =3:
      user name:
      document.querySelector('#avatar_pop div.ava_user a p').textContent
      user space
      document.querySelector('#avatar_pop div.ava_user a[href]').
      user id
      window.discuz_uid;

      我的提醒
      document.querySelector('#avatar_pop > div.apop_con > div.ava_menu > ul > li:nth-child(6) > a')
      有新提醒
      document.querySelector('#avatar_pop > div.apop_con > div.ava_menu > ul > li:nth-child(6) > a > span')

    
  2.板块列表-在板块主题下：红色行提醒
     pc版本： document.querySelector('#forumnewshow').textContent => 有新回复的主题，点击查看
      <a href="javascript:void(0);" onclick="ajaxget('forum.php?mod=ajax&amp;action=forumchecknew&amp;fid=312&amp;time=1776781805&amp;uncheck=1&amp;inajax=yes', 'forumnew');">有新回复的主题，点击查看</a>



## [0.11.0](https://github.com/)
- 修正移动端长按图片，弹窗不显示图片问题
- 修正设置页面字体大小不适配系统缩放，一些文字颜色在不同主题下不变化问题
- 增加了页面截图功能，页面生成完整pdf文件（windows/macos/ios支持）
- 增加帖子页面点击图片跳到看图模式，可以在设置页面开关
- 增加ios/android 页面通知（测试），可以在设置页面开关
- 增加黑名单可以从剪贴板导入导出（逗号分隔）
- 增加了打印页面（Linux不支持）
- 增加下面导航条，长按刷新按钮向前页的功能
- 增加了页面内搜索(windows 不支持)
- 优化桌面系统窗口位置改变的存储方式。
- 优化android 登陆保持时间
- 优化长按链接弹窗页面，以及共享功能
- 移动端图片下载后自动保存
- 优化新建页面
- 优化输入键盘和主题匹配
- 优化网址地址栏输入
- 搜索页面改成百度
- 修改了windows/runner/Runner.rc 文件：VALUE "CompanyName", "com.zorro.chiphell" "\0"
- 图片批量下载,下载帖子图片，保存
- 帖子页面除外，长按图片，弹出看图节面
- 开启自动看图模式，则禁用网站自带看图功能（pc网站实现,mobile2/mobile3 通过结束图片显示后 发送一个消息给webview退出图片缩放模式）
- 在多标签浏览管理，清除所有标签，提示确认
- 在帖子列表中用户头像中加入加入黑名单列表按钮

