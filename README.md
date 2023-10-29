## Rugpull contract foundry project

## Usage

### Build

```shell
$ forge build
```

### Test

Test entire weth test cases
```shell
$ forge test --mc TradingCenterTest
$ forge test --mc FiatTokenV3Test
```
Or test specific case via
```shell
$ forge test --mc TradingCenterTest --mt testRugPull
$ forge test --mc FiatTokenV3Test --mt test_V3_Mint
```