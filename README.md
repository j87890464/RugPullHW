## Rugpull contract foundry project

## Usage

### Build

```shell
$ forge build
```
### Setting
Set RPC_MAINNET environment variable in .env file. It must be done before test FiatTokenV3Test.

### Test

Test entire test cases
```shell
$ forge test --mc TradingCenterTest
$ forge test --mc FiatTokenV3Test
```
Or test specific case via
```shell
$ forge test --mc TradingCenterTest --mt testRugPull
$ forge test --mc FiatTokenV3Test --mt test_V3_Mint
```