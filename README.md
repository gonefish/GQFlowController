GQFlowController
================

A multiple content layer container view controller. 

[![Travis-ci](https://travis-ci.org/gonefish/GQFlowController.png)](https://travis-ci.org/gonefish/GQFlowController)

GQFlowController是一个多层次视图的容器控制器，其目标是实现灵活的UI结构。

特性：
* 支持自定义的滑入或滑出视图控制器方位
* 多层次内容视图容器结构
* 滑动手势
* 完整的ARC支持
* 支持iPad和iPhone
* 与iOS 7 UINavigationController相同的过渡动画效果
* 支持iOS 5及更新的版本


GQFlowControllerAdditions Category
-------------------------
通过Category的特性来扩展UIViewController的方法，这些方法可以让你在UIViewController中访问GQFlowController的实例和其它方法。


GQViewController Protocol
---------------------------------
GQViewController继承于UIGestureRecognizerDelegate，该协议定义了控制滑动手势效果的各种方法，可以在UIViewController的子类中实现该协议，来激活UIPanGestureRecognizer。在GQFlowController的设计中，仅对顶层UIViewController提供滑动手势的支持。


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
GQFlowController requires Xcode 5 and iOS 7.0 or later SDK.


联系方式
---

[Q.GuoQiang](https://github.com/gonefish)

License
-------

GQFlowController is available under the New BSD license. See the LICENSE file for more info.
