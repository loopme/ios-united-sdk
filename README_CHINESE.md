# LoopMe-iOS-SDK #

[点击阅读SDK对接中文说明](README_CHINESE.md)

1. **[概览](#概览)**
2. **[特点](#特点)**
3. **[要求](#要求)**
4. **[SDK对接](#SDK对接)**
  * **[全屏插屏广告](#全屏插屏广告)**
  * **[横幅广告](#横幅广告)**
5. **[示例](#示例)**
6. **[更新](#更新)**

## 概览 ##

LoopMe是最大的移动视频DSP和广告网络，全球覆盖受众超过10亿。LoopMe的全屏视频和富媒体广告格式给受众带来互动性强的移动广告经验。

LoopMe的SDK以代码格式传播并且能够在你的应用里检索、展示广告。

如果您有任何问题，请联系support@loopmemedia.com.

## 特点 ##

* 全屏图片插屏广告
* 全屏富媒体插屏广告
* 预加载视频广告
* 横幅广告
* 原生视频广告
* 最小化窗口广告
* 应用内置奖励提醒（包括视频完整浏览）

## 要求 ##

在您使用`loopme-ios-sdk`前，您需要前往我们的**[系统后台](http://loopme.me/)** 注册并获取appKey。appKey是用来在我们的广告网络中识别您的应用的。（示例appKey：7643ba4d53）.

仅支持`XCode 7`及更高系统, `iOS 8.0`及更高系统。用`ARC`编译。

## 对接 ##

* 从储存库里下载`loopme-ios-sdk`
* 复制 `loopme-sdk` 文件夹到您的`XCode`项目
* 请确保在 `Xcode`项目中的`build phases`加入以下框架：
  * `MessageUI.framework`
  * `StoreKit.framework`
  * `AVFoundation.framework`
  * `CoreMedia.framework`
  * `AudioToolbox.framework`
  * `AdSupport.framework`
  * `CoreTelephony.framework`
  * `SystemConfiguration.framework`

## 全屏插屏广告 ##

`LoopMenterstitial`在您的应用中自然过渡点提供一个全屏的广告.

```objective-c
#import "LoopMeInterstitial.h"

/* ... */  

@property (nonatomic, strong) LoopMeInterstitial *interstitial;

/* ... */

/**
 * 初始化插屏广告
 * 使用你在LoopMe后台开通app时获得的appKey
 * 作为测试，你能使用LoopMeInterstitial.h中定义的测试appKey常数
 */
self.interstitial = [LoopMeInterstitial interstitialWithAppKey:YOUR_APPKEY
                                                      delegate:self];
/* ... */

/**
 * 开始载入广告内容
 * 建议提前触发以便准备好插屏广告
 * 并且能立即在您的应用里展现
 */
[self.interstitial loadAd];

/* ... */

/**
 * 展示插屏广告
 * 可以为用户发起的（比如：点击播放按钮）或开发者发起（如游戏回合结束后）
 */
[self.interstitial showFromViewController:self];

```
 * 建议实现 `LoopMeInterstitialDelegate`在载入/展示广告过程中接受通知，以便您触发随后的应用内置事件：
   * `-loopMeInterstitialDidLoadAd`: 当插屏广告载入广告内容时触发
   * `-loopMeInterstitial: didFailToLoadAdWithError:`: 当插屏广告载入广告内容失败时触发
   * `-loopMeInterstitialVideoDidReachEnd`: 当插屏视频广告完整播放时触发
   * `-loopMeInterstitialWillAppear`: 当插屏广告即将展示时触发
   * `-loopMeInterstitialDidAppear:`: 当插屏广告出现时触发
   * `-loopMeInterstitialWillDisappear`: 当插屏广告将在屏幕消失时触发
   * `-loopMeInterstitialDidDisappear`: 当插屏广告已经从屏幕消失时触发
   * `-loopMeInterstitialDidReceiveTap`: 当插屏广告被点击时触发


## 横幅广告 ##

`LoopMeBanner`在您的应用中自然过渡点提供一个可自定义尺寸的广告.

```objective-c
#import "LoopMeAdView.h"

/* ... */  

@property (nonatomic, strong) LoopMeAdView *adView;

/* ... */  

/**
* 初始化LoopMe AdView
* 使用你在LoopMe后台开通app时获得的appKey
* 作为测试，你能使用LoopMeAdView.h中定义的测试appKey常数
*/
CGRect adFrame = CGRectMake(0, 0, 300, 250);
self.adView = [LoopMeAdView adViewWithAppKey:YOUR_APPKEY frame:adFrame delegate:self];

/* ... */

/**
 * 开始载入广告内容
 * 建议提前触发以便准备好插屏广告
 * 并且能立即在您的应用里展现
 */
 [self.adView loadAd];

/* ... */

/**
* 把adView作为子视图添加到您的视图里，LoopMeAdView是继承于UIView类别.
* 建议当广告被加载时，把adView添加到您的视图里
*/
- (void)loopMeAdViewDidLoadAd:(LoopMeAdView *)adView {
    [yourView addSubview:adView];
}

/**
 * 有时候有必要继续/暂停广告活动
 * 尤其在视图或视图控制器的自然转换中
 * 您可以用这个方法来管理广告可视性
 */
 - (void)setAdVisible:(BOOL)visible;
   ```

**在可滑动内容中展示广告**
```objective-c
/**
* 注意: 如果adView会被添加到可滑动内容中,
* 您应该在初始化adView时传递scrollView (例如 tableView)的实例
* 来管理广告内容活动 (例如： 当广告可视性改变时暂停/继续视频)
*/
self.adView = [LoopMeAdView adViewWithAppKey:YOUR_APPKEY frame:adFrame scrollView:tableView delegate:self];

/*
* 开启最小化视频模式。
* 在`UIWindow`的右下角添加的代表原始视频广告的拷贝。
* 当原始视频广告的可视性改变时，最小化视频出现/消失在滑动界面。
*/
self.adView.minimizedModeEnabled = YES;

/**
 * 当用户下滑屏幕时你也应该通知adView
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.adView updateAdVisibilityInScrollView];
}
   ```

* 建议实现`LoopMeAdViewDelegate`以便在载入/展示广告过程中接受通知来触发随后的应用内事件：
   * `-loopMeAdViewDidLoadAd`: 当adView加载完广告内容时触发
   * `-loopMeAdView: didFailToLoadAdWithError:`: 当adView载入广告内容失败时触发
   * `-loopMeAdViewVideoDidReachEnd`: 当adView视频广告被完整观看时触发
   * `-loopMeInterstitialDidReceiveTap`: 当adView广告被点击时触发
   * `-loopMeInterstitialDidExpire`:  当adView加载的广告内容失效时触发

## 示例 ##

请查看我们的demo`loopme-ios-sdk` 对接后示例。

## 更新 ##
**v5.4.0**

详情请查阅 [changelog](CHANGELOG.md) 。

## 许可 ##

详见 [License](LICENSE.md)
