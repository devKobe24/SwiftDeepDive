# 🤿 Protocols: Getting started with protocols.

프로토콜의 중요성을 이해하기 위해서는 정적 타입 언어가 어떻게 작동하는지 먼저 이해해야 합니다.<br>

다음과 같은 코드를 보십시오:<br>

```swift
counter.increment(by: 10)
```

여기서 `counter`는 `Counter`라는 클래스의 객체이며, `increment(by:)`라는 인스턴스 메소드를 호출하고 있습니다.<br>

이 인스턴스 메소드는 클래스에 존재할 수도 있고, 아니면 작성하는 것을 잊었을 수도 있습니다.<br>

Objective-C와 같은 보다 동적인 언어에서는 컴파일러가 코드를 기꺼이 실행시키지만 아무 일도 일어나지 않을 것입니다.<br>

JavaScript와 같은 일부 동적 언어는 코드를 실행하지만 `increment`가 존재하지 않는다는 오류를 표시할 것입니다.<br>

정적 타입 언어인 Swift는 `increment(by:)`가 해당 클래스에 존재하는지 먼저 확인하고, 존재하지 않는다면 코드를 실행조차 하지 않을 것입니다.<br>

때로는 컴파일러가 불평하는 것처럼 보이지만, 실제로는 바보 같은 실수를 저지르는 것을 막아주고 있습니다.<br>

컴파일러가 이 메소드가 존재하는지 알고 있는 이유는 `counter`의 타입이 `Counter`이며, 이를 통해 `Counter` 클래스에 일치하는 증가 메소드가 있는지 확인할 수 있기 때문입니다.<br>

그러나 컴파일러나 당신이 정확히 어떤 타입을 사용하고 싶은지 확실하지 않은 경우도 있습니다.<br>

자신의 `Counter` 뿐만 아니라 `DoubleCounter`, `UserCounter` 등 다양한 종류의 카운터를 증가시킬 수 있는 단일 함수를 정의하고 싶다면 어떻게 해야 할까요?<br>

다음 메소드를 고려해 보십시오:<br>

```swift
func incrementCounters(counters: [?]) {
    for counter in counters {
        counter.increment(by: 1)
    }
}
```

`counter`의 타입은 무엇이어야 할까요?<br>

이를 단순히 `'[Counter]'`로 제한하는 것은 의미가 없습니다.<br>

왜냐하면 다른 타입들도 작동하기를 원하기 때문입니다.<br>

`'[Any]'` 를 사용해 보려고 할 수도 있지만, Swift는 `'Any'` 인스턴스가 `'increment(by:)'` 메소드를 가질지 알 수 없어 오류가 발생할 것입니다.<br>

필요한 것은 "나는 `'increment(by:)'` 메소드를 가진 어떤 타입이든 원한다"고 컴파일러에게 알려주는 방법입니다.<br>

바로 여기서 프로토콜이 중요한 역할을 합니다.<br>

다음과 같은 프로토콜을 정의할 수 있습니다:<br>

```swift
protocol Incrementable {
    func increment(by: Int)
}
```

메소드 요구사항을 가진 프로토콜을 정의함으로써, 프로토콜을 타입으로 사용하여 "이 메소드는 `Incrementable`을 구현하는 모든 것을 받는다"고 할 수 있습니다.<br>

```swift
func incrementCounters(counters: [Incrementable]) {
    for counter in counters {
        counter.increment(by: 1)
    }
}
```

프로토콜의 구체적인 구현을 작성할 때, Swift는 `increment(by:)` 메소드를 선언했는지 확인합니다.<br>

이를 알고 있으면, Swift 컴파일러는 함수가 `Incrementable`의 모든 인스턴스에 대해 작동한다는 것을 보장할 수 있습니다.<br>
