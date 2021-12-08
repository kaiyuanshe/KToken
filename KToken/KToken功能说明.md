# KToken
&emsp;&emsp;基于区块链的社区贡献激励方案

## X-Lab Token说明
* 发行量：**1000000**
* 小数位：**1位**

* 有允许交易的开关·isExchangeEnable·，默认关闭，需要Owner将其打开才能允许交易

用户积分由Owner分发，每分发给一个新的地址，他就成为了X-Lab Token的使用者。对于每个使用者：
* Balance存储其可以交易的Token
* Point存储分发给该用户的balance总数
* 在允许交易的情况下，用户需要先将自己一定量的balance通过Approve函数标记成可交易状态（或者委托给他人），再通过transferFrom函数进行交易
