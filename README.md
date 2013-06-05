GQFlowController
================

目标是实现类似于[网易新闻客户端3.0](https://itunes.apple.com/cn/app/wang-yi-xin-wen/id425349261?mt=8)的UI结构。

提供通过架构，支持iPad和iPhone。

比从UINavigationController提供哪些功能
怎么支持手势

从UINavigationController移植到GQFlowController
---------------------------------------------

从UINavigationController移植到GQFlowController非常方便。

<table>
  <tr>
    <th>GQFlowController</th>
    <th>UINavigationController</th>
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