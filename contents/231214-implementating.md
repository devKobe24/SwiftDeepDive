# Implementaing a language feature 🤿

Swift는 가능한 많은 기능의 구현을 컴파일러에서 라이브러리로 옮기도록 합니다.
예를 들어, Optional이 단지 일반적인 열거형임을 알고 걔실 수도 있습니다.
사실, 대부분의 기본 타입들은 컴파일러에 내장되어 있지 않고 표준 라이브러리의 일부입니다.
이에는 Bool, Int, Double, String, Array, Set, Dictionary, Range 등 많은 것들이 포함됩니다.
2020년 10월 Lex Fridman 인터뷰에 Lattner는 이러한 표현적인 라이브러리 디자인을 프로그래밍 언어의 가장 아픔다운 특징으로 여긴다고 말했습니다.

스위프트의 더 복잡한 기능들에 대해 배우거나 기본적인 기능들에 대한 더 나은 이해를 얻는 좋은 방법은 직접 이를 수행하는 것입니다.
언어와 같은 기능을 구축하는 것입니다.
이제 그렇게 할 것입니다.

## Building ifelse

이 실험에서는 통계 프로래밍 언어인 R에서 사용하는 ifelse() 문을 구현합니다.
함수는 아래와 같습니다.

```swift
ifelse(condition, valueTrue, valueFalse)
```

이것은 Swift의 삼항 연산자인 `condition ? valueTrue : valueFalse`가 수행하는 것과 동일한 기능을 합니다.
일부는 미적인 이유로 이 연산자를 좋아하지 않습니다.

아래 코드를 봐봅시다.

```swift
func ifelse(condition: Bool,
            valueTrue: Int,
            valueFalse: Int) -> Int {
    if condition {
        return valueTrue
    } else {
        return valueFalse
    }
}

let value = ifelse(condition: Bool.random(),
                   valueTrue: 100,
                   valueFalse: 0)
```

이 해결책에 무엇이 문제일까요?
아마도 아무것도 아닐 수 있습니다.
만약 이것이 문제를 해결하고 오직 `Int`와만 작업한다면, 여기서 멈추는 것도 좋은 선택일 수 있습니다.
하지만 모든 사람을 위한 일반적인 목적의 언어 기능을 만들려고 한다면, 몇 가지 개선을 할 수 있습니다.
먼저 인터페이스를 조금 다듬어봅시다.

```swift
func ifelse(_ condition: Bool,
            _ valueTrue: Int,
            _ valueFalse: Int) -> Int {
    condition ? valueTrue : valueFalse
}

let value = ifelse(.random(), 100, 0)
```

자주 사용될 언어 구조에 대해서는, 인자 레이블을 제거하는 것이 타당합니다.
와일드 카드 레이블인 `_`를 사용하면 이를 제거할 수 있습니다.
간결함을 위해, 덜 장황한 삼항 연산자를 사용하여 기능을 구현하세요.
(camel-case 이름인 `ifElse`를 사용하지 않는 이유가 궁금할 수 있습니다. `typealias`와 `associatedtype`과 같이 단순한 연결어가 키워드로 사용된 선례가 있으므로, 원래 R 언어의 명명법을 유지하세요.)

다음은 명백한 문제는 이것이 오직 `Int` 타입에만 작동한다는 것 입니다.
원하는 중요한 타입들에 대한 많은 오버로드로 이를 대체할 수 있습니다.
아래 코드를 봐봅시다.

```swift
func ifelse(_ condition: Bool,
            _ valueTrue: Int,
            _ valueFalse: Int) -> Int {
    condition ? valueTrue : valueFalse
}

func ifelse(_ condition: Bool,
            _ valueTrue: String,
            _ valueFalse: String) -> String {
    condition ? valueTrue : valueFalse
}

func ifelse(_ condition: Bool,
            _ valueTrue: Double,
            _ valueFalse: Double) -> Double {
    condition ? valueTrue : valueFalse
}

func ifelse(_ condition: Bool,
            _ valueTrue: [Int],
            _ valueFalse: [Int]) -> [Int] {
    condition ? valueTrue : valueFalse
}
```

이것이 확장성이 떨어진다는 것은 쉽게 알 수 있습니다.
완성했다고 생각되는 순간, 사용자들은 또 다른 타입의 지원을 원합니다.
그리고 각 오버로드는 구현을 반복하게 되는데, 이는 그다지 좋지 않습니다.

대안으로, Swift의 어떤 타입이든 대체할 수 있는 타입 소거된 타입인 Any를 사용할 수 있습니다.
아래 코드를 봐봅시다.

```swift
func ifelse(_ condition: Bool,
            _ valueTrue: Any,
            _ valueFalse: Any) -> Any {
    condition ? valueTrue : valueFalse
}

let value = ifelse(.random(), 100, 0) as! Int
```

이 코드는 모든 타임에 대해 작동하지만, 원하는 원래 타입으로 다시 캐스팅해야 하는 중요한 주의사항이 있습니다.
Any 타입을 사용하는 것은 이와 같이 타입을 혼합하는 상황에서 보호해주지 않습니다.
아래 코드를 봐봅시다.

```swift
let value = ifelse(.random(), "100", 0) as! Int
```

이 구문은 테스트에서는 작동할 수 있지만, 무작위 숫자가 참(true)으로 나올 경우 실제 운영 환경에서는 충돌할 수 있습니다.
Any는 매우 다재다능하지만 사용하기에 오류가 발생하기 쉽습니다.

더 나은 해결책은, 예상했듯이, 제네릭을 사용하는 것입니다.
아래 코드를 봐봅시다.

```swift
func ifelse<V>(_ condition: Bool,
               _ valueTrue: V,
               _ valueFalse: V) -> V {
    condition ? valueTrue : valueFalse
}

// let value = ifelse(.random(), "100", 0) // 더 이상 컴파일 되지 않습니다.
let value = ifelse(.random(), 100, 0)
```

이 디자인은 타입 정보를 유지하면서도 인자들이 반환 타입과 동일한 타입이 되도록 제한합니다.
제네릭 Swift 언어의 필수적인 부분입니다.

> 📝 Note.
> 
> Swift 표준 라이브러리는 위의 예시처럼 코드 중복을 제거하기 위해 광범위하게 제네릭을 사용합니다.
> 
> 제네릭 시스템이 아직 충분히 강력하지 않은 경우, 
> 
> 라이브러리는 파이썬 스크립트인 gyb(또는 generate-your-boilerplate)를 사용하여 여러 타입의 코드를 생성합니다.
