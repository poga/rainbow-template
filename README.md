# Rainbow Template

`rainbow-template` 是基於tumblr-like的語法建立的template engine。

## 基本概念

1. 沒有eval，不執行template中任何程式碼
2. parser不會因為錯誤的輸入而產生exception，只會產生非預期的輸出
3. block-based template，沒有條件判斷，一律利用condition block與collection block來處理邏輯。
4. 白名單模式，只處理已知的tag

## Usage

參考`spec/rainbow-template/engine_spec.rb`

## Terminology

* Parser：將plain text轉為S-expression
* Generator：將S-expression根據Context資訊轉為最後的輸出結果
* Engine：parser與generator的組合
* Context：一層或多層的Hash結構，代表整個template中可能使用到的變數值、condition block與collection block。

## Block

block概念來自於tumblr的template language，分為兩種block：**condition block**與**collection block**

若是template中有一段區塊只會在特定條件下顯示，則可利用以下語法：

`{block:TextPost}
   ...
 {/block:TextPost}
 `

在解析時，generator會檢查context hash中是否有`"block:TextPost"`這個key的存在，並對key對應的value作相應的處理

* `true`：會將該block顯示出來。
* `false`：跳過該block
* `nil`：跳過該block
* `Hash`：會將該block內的變數依照hash中的值產生出來
* `Array`：會根據array中hash的數量，將每個hash作為一個context，將block render出來。render出的block數量等於array中的元素數目

## Variable

Variable對應到context中特定key對應的值，若context中無對應的key，則不會被parse，視為plain text。

ex. `{Title}`

* 若context為 `{ "Title" => "foo" }`，則render結果為`foo`
* 若context為 `{}`，則render結果為`{Title}`
