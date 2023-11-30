# associatedtype 🤿

Swift에서 **`associatedtype`** 은 프로토콜 내에서 사용되는 타입 플레이스홀더(placeholder)입니다.
이를 통해 프로토콜을 정의할 때 구체적인 타입을 지정하지 않고, 프로토콜을 채택하는 타입이 이를 명시할 수 있도록 합니다.

**`associatedtype`** 은 제네릭과 유사하게 동작하지만, 프로토콜과 연관된 타입을 정의하는 데 사용됩니다.

# associatedtype의 주요 사용 사례

## 1️⃣ 타입 추상화.

**`associatedtype`** 을 사용하면, 프로토콜을 정의할 때 구체적인 타입을 결정하지 않고도 타입에 대한 요구사항을 표현할 수 있습니다.

이렇게 함으로써, 프로토콜을 채택하는 각 타입이 자신만의 구체적인 타입을 사용할 수 있습니다.

## 2️⃣ 제네릭 프로토콜.

**`associatedtype`** 을 사용하면, 제네릭과 유사한 방식으로 프로토콜을 더 유연하게 만들 수 있습니다.

이를 통해 프로토콜을 채택하는 타입은 자신의 특정한 요구사항에 맞는 타입을 지정할 수 있습니다.

## 3️⃣ associatedtype의 사용 예시.

예를 들어, Swift의 `IteratorProtocol`은 `associatedtype`을 사용합니다.

```swift
protocol IteratorProtocol {
    associatedtype Element
    mutating func next() -> Element?
}
```

이 프로토콜은 **`Element`** 라는 **`associatedtype`** 을 가지며, 이는 반복자가 생성할 요소의 타입을 나타냅니다.

프로토콜을 채택하는 타입은 이 **`Element`** 타입을 구체적인 타입으로 지정해야 합니다.

```swift
struct IntIterator: IteratorProtocol {
    typealias Element = Int
    mutating func next() -> Int? {
        // 구현 부분
    }
}
```

여기서 **`IntIterator`** 는 **`IteratorProtocol`** 을 구현하고, **`Element`** 를 **`Int`** 로 지정합니다.

이렇게 **`associatedtype`** 은 프로토콜을 좀 더 범용적으로 사용할 수 있게 해주는 강력한 기능입니다.
