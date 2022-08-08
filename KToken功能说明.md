# KToken
&emsp;&emsp;基于区块链的社区贡献激励方案

## KToken-v1说明
- Transfer功能被禁止，Token数量可以当作积分使用。
- contract address: 0x1b1FA9392aB82c562DCcb7D1C402E3e9FfB0eB6b

## KToken-v2说明
- 有允许交易的开关·isExchangeEnable·，默认关闭，需要Owner将其打开才能允许交易
用户积分由Owner分发，每分发给一个新的地址，他就成为了X-Lab Token的使用者。对于每个使用者：
- Balance存储其可以交易的Token
- Point存储分发给该用户的balance总数
- 在允许交易的情况下，用户需要先将自己一定量的balance通过Approve函数标记成可交易状态（或者委托给他人），再通过transferFrom函数进行交易

## 案例1
复旦大学可视分析与智能决策实验室[FDU-VIS](http://fduvis.net/)使用私有以太坊PoA区块链，与语雀链接起来，用来记录实验室内部人员的活跃程度。