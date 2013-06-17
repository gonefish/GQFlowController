GQFlowController
================

GQFlowController实现了一个多层的容器视图控制器，支持从4个不同方向滑入或滑出视图界面。

目标是实现类似于[网易新闻客户端3.0](https://itunes.apple.com/cn/app/wang-yi-xin-wen/id425349261?mt=8)的UI结构。

提供通过架构，支持iPad和iPhone。


启用长按移动视图手势
--------------
在GQFlowController的设计中，提供对topViewController的长按手势支持，只需实现GQViewControllerDelegate中的方法，就可以控制界面的滑动效果。


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

计划
-----
iPad的支持
...


联系方式
---

[Q.GuoQiang](https://github.com/gonefish)

