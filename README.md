GQFlowController
================

A multiple content layer container view controller.

GQFlowController实现了一个多层的容器视图控制器，其目标是实现类似于[网易新闻客户端](https://itunes.apple.com/cn/app/wang-yi-xin-wen/id425349261?mt=8)iPhone的UI结构（主要是3.0之后的版本）。

特性：
* 支持从4个不同方向滑入或滑出视图控制器界面
* 多层视图控制器结构
* 滑动手势
* 完整的ARC支持
* 支持iPad和iPhone



GQViewControllerAdditions Category
-------------------------
通过Category的特性来扩展UIViewController的方法，这些方法可以让你在UIViewController中访问GQFlowController的实例和其它功能的设置。


GQViewController Protocol
---------------------------------
该协议定义了长按滑动手势的相关方法，可以在UIViewController的子类中实现该协议，来控制不同的长按滑动行为。

在GQFlowController的设计中，提供对顶层内容视图控制器的长按手势支持，当顶层UIViewController实现该协议，则会激活GQFlowController中长按滑动手势功能。


从UINavigationController移植到GQFlowController
---------------------------------------------

由于GQFlowController实现了与UINavigationController类似的方法来管理视图控制器，所以移植起来会非常方便。对应关系如下表：

<table>
  <tr>
    <th>GQFlowController</th>
    <th>UINavigationController</th>
  </tr>
  <tr>
    <th colspan="2">Creating Navigation Controllers</th>
  </tr>
  <tr>
    <td>initWithRootViewController:</td>
    <td>initWithRootViewController:</td>
  </tr>
  <tr>
    <th colspan="2">Accessing Items on the Navigation Stack</th>
  </tr>
  <tr>
    <td>topViewController</td>
    <td>topViewController</td>
  </tr>
  <tr>
    <td>viewControllers</td>
    <td>viewControllers</td>
  </tr>
   <tr>
    <td>setViewControllers:animated</td>
    <td>setViewControllers:animated</td>
  </tr>
  <tr>
    <th colspan="2">Pushing and Popping Stack Items</th>
  </tr>
  <tr>
    <td>flowInViewController:animated:</td>
    <td>pushViewController:animated:</td>
  </tr>
  <tr>
    <td>flowOutViewControllerAnimated:</td>
    <td>popViewControllerAnimated:</td>
  </tr>
  <tr>
    <td>flowOutToRootViewControllerAnimated:</td>
    <td>popToRootViewControllerAnimated:</td>
  </tr>
  <tr>
    <td>flowOutToViewController:animated:</td>
    <td>popToViewController:animated:</td>
  </tr>
  <tr>
    <td>setViewControllers:animated:</td>
    <td>setViewControllers:animated:</td>
  </tr>
</table>

Demo说明
-------

Demo1展示了如果实现类Path的实现。

Demo2展示了类UINavigationController的各个方法。

Demo3展示了iPad的使用例子。


Requirements
------------
GQFlowController requires Xcode 4.5 and iOS 6.0 or later SDK (LLVM Compiler 4.0)。

[Objective-C Feature Availability Index](http://developer.apple.com/library/ios/#releasenotes/ObjectiveC/ObjCAvailabilityIndex/)


联系方式
---

[Q.GuoQiang](https://github.com/gonefish)

License
-------

GQFlowController is available under the New BSD license. See the LICENSE file for more info.
