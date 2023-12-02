# Type & Mutarion 🤿

## Functions and methods

**이제까지 사용자 정의 타입은 저장된 프로퍼티의 형태로 데이터를 가지고 있었습니다.
그러나 연산을 추가하면 흥미로운 일이 발생합니다.**

`Point` 타입에 몇 가지 메소드를 추가해보겠습니다.

```swift
// 1차 초안 버전
extension Point {
    func flipped() -> Self {
        Point(x: self.y, y: self.x)
    }
    
    mutating func flip() {
        let temp = self
        self.x = temp.y
        self.y = temp.x
    }
}
```

여기에서는 포인트의 `x`좌표와 `y`좌표를 교환하는 두 가지의 간단한 메소드가 있습니다.
[Swift API 디자인 가이드라인](https://swift.org/documentation/api-design-guidelines/)에 의해 설명된 "fluent" 사용법의 변형(mutating) 및 비변형(non-mutating) 쌍을 따릅니다.

`flipped()` 함수는 `self`를 사용하고, `flip` 함수는 `self`를 사용하고 수정합니다.
이 때문에 변형(mutation)으로 선언해야 합니다.

두 함수 모두 교환 로직을 포함하고 있어 중복됩니다.

아래의 버전으로 코드를 교체해보겠습니다.

```swift
extension Point {
    func flipped() -> Self {
        Point(x: y, y: x)
    }
    
    mutating func flip() {
        self = flipped()
    }
}
```

불필요한 `self` 참조가 사라졌고, 교환 로직은 `flipped` 안에만 있습니다.
이 경우 구현은 간단하므로 중복은 큰 문제가 아니었습니다.
그러나 좀 더 복잡한 `비변형(non-mutating)` 및 `변형(mutating)` 함수 쌍을 가질 때, 이 패턴의 가치를 알게 될 것입니다.

## Mutating and self

타입 메소드에서 Swift 컴파일러는 보이지 않는 매개변수는 `self: Self`를 전달합니다.
그래서 함수 본문에서 `self`를 사용할 수 있습니다.
`변형(mutating)` 메소드에서는 Swift가 보이지 않는 `self: inout Self`를 전달합니다.
`inout`의 의미를 기억하면, 함수로 들어갈 때 복사가 일어나고 나갈 때 다시 복사가 이루어진다는 것을 알 수 있습니다.
이 타이밍은 프로퍼티 옵저버 `willSet`과 `didSet`이 호출되는 시점과 일치합니다.
또한, `inout`은 실질적으로 입력과 함수에서 나가는 추가적인 반환 값이 됩니다.

> 📝 Note
> 
> 클래스(즉, 참조 타입)의 메소드는 `inout`을 사용하지 않습니다.
> `self: inout Self`가 무엇을 의미하는지 생각해보면, 그것이 말이 되는 것을 알 수 있습니다.
> 참조 타입에서 `inout`은 전체 인스턴스가 다른 인스턴스로 재할당되는 것을 방지할 뿐입니다.

## Static method and properties

이 코드는 **`Point`** 타입에 정적 프로퍼티와 메소드를 추가하는 방법을 보여줍니다.

```swift
extension Point {
    static var zero: Point {
        Point(x: 0, y: 0)
    }
    
    static func random(inRadius radius: Double) -> Point {
        guard radius >= 0 else {
            return .zero
        }
        
        let x = Double.random(in: -radius ... radius)
        let maxY = (radius * radius - x * x).squareRoot()
        let y = Double.random(in: -maxY ... maxY)
        return Point(x: x, y: y)
    }
}
```

이 코드는 원점에 위치한 **`zero`** 라는 `정적 프로퍼티(Static properties)`를 생성합니다.

**`random`** 이라는 `정적 메소드(Static methos)`는 지정된 반지름에 의해 제한되는 무작위 점을 생성합니다.

먼저 x값이 결정되며, 피타고라스 정리를 사용하여 원 안에 위치하도록 허용되는 y 값의 최대 범위를 결정합니다.

### Going deterministic(결정론적 방식으로 전환하다.)

Swift의 기본 **`Double.random(in:)`** 은 암호화에 적합한 **`SystemRandomNumberGenerator()`** 를 사용합니다.

이 선택은 공격자가 무작위 숫자를 추측하는 것을 방지하기 때문에 훌륭한 기본 설정입니다.

때로는 무작위 값이 결정론적이고 반복 가능하길 원할 수 있습니다.

이 중요성은 특히 지속적 통합 테스트에서 진실합니다.

이러한 유형의 테스트는 새롭고 시도되지 않은 입력 값 때문이 아니라 코드 변경(잘못된 병합이나 리팩토링)에 대응하여 실패해야 합니다.

다행히 Swift 표준 라이브러리는 여러분의 선택에 따른 의사 난수 생성기를 사용할 수 있는 오버로드 메소드 **`Double.random(in:using:)`** 를 지원합니다.

표준 라이브러리에는 이러한 시드 가능한 의사 난수 소스가 포함되어 있지 않지만, 직접 만들기는 쉽습니다.

웹에서 "좋은"난수 생성기에 대한 많은 연구가 있습니다.
여기 위키피디아에서 괜찮은 하나가 있습니다.

Permuted Congruential Generator(섞인 합동 생성기)는 나열된 C 코드에서 Swift로 번역할 수 있습니다.

이 코드를 봐봅시다.

```swift
struct PermutedCongruential: RandomNumberGenerator {
    private var state: UInt64
    private let multiplier: UInt64 = 6364136223846793005
    private let increment: UInt64 = 1442695040888963407
    
    private func rotr32(x: UInt32, r: UInt32) -> UInt32 {
        (x &>> r) | x &<< ((~r &+ 1)) & 31)
    }

    private mutating func next32() -> UInt32 {
        var x = state
        let count = UInt32(x &>> 59)
        state x &* multiplier &+ increment
        x ^= x &>> 18
        return rotr32(x: UInt32(truncatingIfNeeded: x &>> 27),
                                r: count)
    }

    mutating func next() -> UInt64 {
        UInt64(next32() << 32 | UInt64(next32()))
    }

    init(seed: UInt64) {
        state = seed &+ increment
        _ = next()
    }
}
```

이 코드는 이 글에서 중요하지 않은 몇 가지 수학적 세부사항을 포함하고 있습니다.

중요한 것은 내부 세부사항과 상태를 `private`으로 표시할 수 있다는 점입니다.

이 타입의 사용자로서 알아야 할 것은 64비트 정수로 시드되고 결정론적인 의사 난수 64비트 정수 스트림을 생성한다는 것입니다.

이 숨김은 캡슐화의 실천입니다.

복잡성을 다루고 타입을 사용하고 추론하기 쉽게 만듭니다.

이 의사 난수 소스를 사용하려면 **`Point.random`** 의 오버로드를 생성해야합니다.

아래의 코드를 봐봅시다.

```swift
extension Point {
    static func random(inRadius radius: Double,
                      using randomSource:
                        inout PermutedCongruential) -> Point {
        guard radius >= 0 else {
            return .zero
        }
        
        let x = Double.random(in: -radius...radius,
                              using: &randomSource)
        let maxY = (radius * radius - x * x).squareRoot()
        let y = Double.random(in: -maxY...maxY,
                              using: &randomSource)
        return Point(x: x, y: y)
    }
}
```

이것은 시스템 난수 생성기를 사용하는 이전 버전과 매우 유사합니다.
정적 메소드 **`random(in:using:)`** 도 **`Point`** 의 인스턴스를 건드리지 않습니다.
하지만 **`randomSource`** 가 `inout` 매개변수이기 때문에 가변 상태가 함수를 통해 흐를 수 있음을 주목하세요.
이젓은 매개변수를 통해 부작용을 처리하는 방식이며, 예를 들어 의사 난수 상태를 추적하기 위해 전역 변수를 사용하는 것보다 훨씬 더 나은 디자인입니다.
이것은 사용자에게 부작용을 명시적으로 드러내어 제어할 수 있게합니다.

아래의 코드로 결정론적 난수를 테스트해봅시다.

```swift
var pcg = PermutedCongruential(seed: 1234)
for _ in 1...10 {
    print(Point.random(inRadius: 1, using: &pcg))
}
```

이것들은 무작위 숫자처럼 보이지만 재현 가능합니다.

시작 시드가 1234일 때, 열 번째 난수 점은 항상 **`Point(x: 0.43091531644250813, y: 0.3236366519677818)`** 입니다.

### ✅ 궁금증! 🤔 "결정론적 방식으로 전환하다"는 무슨뜻일까?

**"Going deterministic"** 라는 표현은 **"결정론적으로 변화하다"** 또는 **"결정론적 방식으로 전환하다"** 라는 의미를 가집니다.

여기서 **'결정론적(deterministic)'** 이라는 단어는 주어진 시작 조건에서 동일한 결과가 반복적으로 발생하는 것을 의미합니다.

컴퓨터 과학과 프로그래밍에서, 이 용어는 특히 난수 생성과 관련하여 사용됩니다.
일반적인 난수 생성기는 매번 다른 결과를 생성합니다.

하지만, 결정론적 난수 생성기는 같은 '시드(seed)'값으로 시작할 때마다 동일한 일련의 난수를 생성합니다.
이러한 특성은 테스트와 시뮬레이션에서 유용하며, 특정 입력에 대해 일관된 결과가 필요할 때 중요합니다.

따라서 **"Going deterministic"** 은 무작위성에서 벗어나 예측 가능하고 재현 가능한 결과를 생성하는 방식으로 전환하는 것을 의미합니다.
