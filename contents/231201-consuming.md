# `__consuming` Intro 🤿

이번에 제가 **Swift standard library(스위프트 표준 라이브러리)** 가 제공하는 주요 데이터구조 중 하나인 **"배열(Array)"** 를 학습하면서 **`Sequence`** 를 탐험하다가 **`__consuming`** 이라는 키워드를 만나버렸습니다 😆

(멀고도 험난하게 만난 새로운 친구는 못참지...🤔)

그래서 저는 이 친구가 어떤 친구인지 알아보기로 했답니다 헤헿

<img src = "https://github.com/devKobe24/images/blob/main/SWDD-consuming.png?raw=true"></br>

## 1️⃣ `__consuming` 🤔?

이 키워드는 함수가 **`self`** 에 대해 소비적(**"consuming"**)이라는 것을 나타냅니다.

즉, 이 함수는 **`self`**(위 스크린샷에서는 "시퀀스" 자체)를 **"소비"** 하며, 이후 **"self"** 는 더이상 유효하지 않을 수 있습니다.

**이는 주로 값 타입에 사용되며, 함수 호출 이후에 해당 인스턴스의 상태가 변경될수 있음을 의미합니다.** 🙌

**`"__consuming"`** 은 특히 시퀀스가 한 번만 반복될 수 있을 때 중요합니다.
(예를 들어, 반복자(**"iterator"**)가 시퀀스를 **"소비"** 하는 경우).

### ✅ 의문점 1️⃣ `__consuming` 키워드에 대해 설명할 때 `self` 가 왜 나오는거지?

**`__consuming`** 키워드에 대해 설명할 때 **`self`** 에 대한 언급이 나오는 이유는 **Swift 프로그래밍 언어의 문맥상에서 이해할 수 있습니다.** (기본기가 탄탄해야하는 이유!! 🙋‍♂️)

Swift에서 메소드 내부에서 **`'self'`** 는 해당 메소드가 호출되는 인스턴스를 나타냅니다.

즉, 메소드가 어떤 객체의 상태를 변경하거나 객체의 데이터에 접근할 때, 이 객체는 메소드 내에서 **`self`** 로 참조됩니다.

위 스크린샷을 보면 **`__consuming func makeIterator() -> Iterator`** 코드 조각에서, **`makeIterator`** 는 **`Sequence`** 프로토콜의 메소드로, 시퀀스의 반복자(**'iterator'**)를 생성하는 역할을 합니다.

여기서 **`__consuming`** 키워드는 이 메소드가 시퀀스 인스턴스(**`self`**)를 소비한다는 것을 의미합니다.

이는 메소드가 **`self`(즉, 시퀀스 인스턴스)** 에 대해 작업을 수행하고, 이 과정에서 시퀀스의 상태를 변경하거나 시퀀스의 요소를 소모할 수 있음을 나타냅니다.

**`self`** 가 코드에 **명시적으로 나타나지 않는 이유는 Swift의 문법 규칙에 따른 것입니다.**
Swift에서는 인스턴스의 프로퍼티나 메소드에 접근할 때, 현재 인스턴스를 가리키는 **`self`** 키워드를 **생략할 수 있습니다.**
예를 들어, **`self.x`** 는 단순히 **`x`** 로 쓸 수 있으며, 이는 현재 인스턴스의 **`x`** 프로퍼티를 의미합니다.

💯 따라서 **`__consuming`** 키워드의 설명에서 **`self`** 가 언급되는 것은 메소드가 호출되는 시퀀스 인스턴스 자체에 영향을 줄 수 있다는 의미에서 **`self`** 를 참조하는 것입니다.

## 2️⃣ 예시 코드로 `__consuming` 이해하기!

```swift
import Foundation

struct CountDown: Sequence {
    var start: Int

    func makeIterator() -> CountDownIterator {
        return CountDownIterator(self)
    }

    struct CountDownIterator: IteratorProtocol {
        var countDown: CountDown

        init(_ countDown: CountDown) {
            self.countDown = countDown
        }

        mutating func next() -> Int? {
            if countDown.start > 0 {
                let current = countDown.start
                countDown.start -= 1
                return current
            } else {
                return nil
            }
        }
    }
}

// 사용 예시
let countDown = CountDown(start: 3)
for number in countDown {
    print(number)
}
```

이 코드에서 **`CountDown`** 구조체는 **`start`** 값에서 시작하여 0까지 카운트다운하는 시퀀스를 나타냅니다.
**`CountDownIterator`** 는 **`IteratorProtocol`** 을 준수하며, **`next`** 메소드를 통해 다음 숫자를 제공합니다.

✅ **`__consuming`** 은 이 코드에서 직접적으로 나타나지 않지만, **`makeIterator`** 함수의 구현 방식은 **`__consuming`** 의 개념과 유사합니다.
**`CountDownIterator`** 는 **`CountDown`** 시퀀스의 상태를 **'소비'** 하면서 이터레이션을 진행합니다.

> 🙋‍♂️ Swift의 최신 버전에서는 **`__consuming`** 키워드가 내부적으로 사용되며, 개발자가 명시적으로 사용하는 경우는 드뭅니다.

---

### 참고자료 📚

- [Swift에서의 Instance](https://github.com/devKobe24/SwiftDeepDive/blob/main/contents/231126-Instance.md
- [developer.apple.com - Sequence](https://developer.apple.com/documentation/swift/sequence)
- [developer.apple.com - Iterator](https://developer.apple.com/documentation/swift/sequence/iterator)
