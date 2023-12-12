# Swift Deep Dive - Character 🤿

```swift
@frozen
public struct Character: Sendable {
  @usableFromInline
  internal var _str: String

  @inlinable @inline(__always)
  internal init(unchecked str: String) {
    self._str = str
    _invariantCheck()
  }
}
```

## 🙋‍♂️ 코드 분석.
이 코드는 **`Character`** 구조체를 정의하고 있습니다.
이 구조체는 문자를 나타내는 데 사용되며, Swift의 문자열 처리 시스템의 일부입니다.

## 🍗 코드 뜯어 먹기 냠냠!

1️⃣ **`@frozen`**
이 속성은 Swift 5에서 도입되었습니다.
**`@frozen`** 이 구조체에 적용되면, 컴파일러는 이 구조체의 레이아웃이 변경되지 않을 것으로 간주합니다.
이는 주로 바이너리 호환성을 위해 사용됩니다.
이 구조체가 앞으로 변경되지 않을 것임을 나타냅니다.

2️⃣ **`public struct Character: Sendable`**
이 선언은 **`Character`** 라는 이름의 공개(public) 구조체를 정의합니다.
**`Sendable`** 프로토콜을 준수함으로써, 이 구조체의 인스턴스는 동시성(concurrency)관련 기능에서 안전하게 전송될 수 있음을 나타냅니다.

3️⃣ **`@usableFromInline intrenal var _str: String`**
이 코드 라인은 내부 변수 **`_str`** 를 선언합니다.
이 변수는 **`String`** 타입이며, **`@usableFromInline`** 속성을 사용해 인라인 함수 내에서 사용할 수 있습니다.
**`internal`** 접근 수준은 같은 모듈 내에서만 접근 가능함을 의미합니다.

4️⃣ **`@inlinable @inline(__always)`**
이 두 속성은 함수나 메소드에 적용되며, 컴파일러에게 해당 함수를 가능한 항상 인라인(inline)처리하라고 지시합니다.
**`@inlinable`** 은 모듈 바깥에서도 인라인될 . 수있음을 의미하며, **`@inline(__always)`** 은 컴파일러에게 항상 인라인 처리하라고 강제합니다.

5️⃣ **`internal init(unchecked str: String)`**
이 구조체의 내부 생성자입니다.
**`unchecked`** 라는 이름의 매개변수를 받으며, 이는 컴파일러가 제공하는 보통의 안전 검사를 수행하지 않음을 나타냅니다.
이 생성자는 주어진 **`String`** 값을 **`_str`** 변수에 할당합니다.

6️⃣ **`self._str = str; _invariantCheck()`**
이 생성자는 입력된 **`String`** 을 내부 변수 **`_str`** 에 할당한 다음, **`invariantCheck()`** 함수를 호출합니다.
이 함수는 **`Character`** 구조체 불변식(invariants)이 유지되는지 확인하는 데 사용될 것으로 보입니다.
