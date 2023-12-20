# 🤿 Array.

```swift
@frozen
@_eagerMove
public struct Array<Element>: _DestructorSafeContainer {
  #if _runtime(_ObjC)
  @usableFromInline
  internal typealias _Buffer = _ArrayBuffer<Element>
  #else
  @usableFromInline
  internal typealias _Buffer = _ContiguousArrayBuffer<Element>
  #endif

  @usableFromInline
  internal var _buffer: _Buffer

  /// Initialization from an existing buffer does not have "array.init"
  /// semantics because the caller may retain an alias to buffer.
  @inlinable
  internal init(_buffer: _Buffer) {
    self._buffer = _buffer
  }
}
```

Array와 함께하는 특별한 밤 우리 모두 다 출석 췍!! 뚠뚠뚠뚠~ Array 뜯어 볼 때 못노는 사람도 게으른 사람~ (feat. DynamicDuo) 🤣<br>

자, Array를 한 번 먼저 분해하고 그 다음 분석을 차근 차근 해 볼까요옹?<br>

## 🤿 분해 타임~ 따단!!

여기서는 `@`가 붙은 속성, 키워드, 특성 등..만 뽑아서 분해해볼게요 ㅎㅎ<br>

복습겸 해서 다시 다 정리해보겠습니다.<br>

```swift
@frozen
@_eagerMove
@usableFromInline
@inlinable
```

**먼저** `@frozen`은 자주 본 친구에요 먼저 이 친구부터 알아봅시다 구면이니까요 ㅎㅎ<br>

**1. `@frozen`**<br>
이 속성은 Swift 프로그래밍 언어에서 메모리 레이아웃이나 멤버의 추가, 제거 등이 미래의 Swift 버전에서도 병경되지 않음을 나타낸다고 합니다.<br>

이는 **`Array`** 와 같은 기본 타입이 ABI(응용 프로그램 바이너리 인터페이스)안정성을 유지해야 하는 중요한 경우에 사용됩니다.<br>

**`@frozen`** 속성의 주된 목적과 특징이 있다고 하는데요 같이 알아볼까요??<br>

1️⃣ **ABI 안정성 보장.**<br>
**`@frozen`** 으로 표시된 **`Array`** 구조체는 이후 버전의 Swift에서도 동일한 메모리 레이아웃과 ABI를 유지해요.<br>
이는 Swift 표준 라이브러리와 같은 시스템 레벨의 구성 요소에 매우 중요합니다.<br>

2️⃣ **컴파일러 최적화 기능**<br>
컴파일러는 **`@frozen`** 속성을 가진 타입이 변경되지 않는다는 것을 알고 있을거에요.<br>
때문에 이를 바탕으로 더 효율적인 바이너리 코드를 생성할 수 있겠죠?!<br>

3️⃣ **호환성 유지**<br>
이 속성을 사용함으로써, 미래의 Swift 버전에서도 현재 작성된 코드가 기대하는 대로 동작하도록 보장합니다.<br>
이는 특히 큰 시스템이나 많은 의존성을 가진 프로젝트에서 중요할거에요.<br>
때문에 호환성 유지에 많은 도움이 될 것 입니다.<br>

🙋‍♂️ **`@frozen`** 속성은 주로 Swift의 표준 라이브러리나 중요한 시스템 라이브러리에서 사용됩니다.<br>
그래서 일반적인 애플리케이션 개발에서는 직접 사용할 일이 거의 없다고 해요.<br>
**"그러나 이 속성의 존재와 의미를 이해하는 것은 Swift의 내부 동작 방식과 성능 최적화에 대한 깊은 이해를 돕게 되니 알아두는게 좋습니다!!"**

**두 번째**로 `@_eagerMove`!! '앗.. 야생의 `@_eagerMove`가 나타났다...' 이럴 땐 바로 도감에 저장하고 포켓볼로 잡아야겠죠?! 헤헿

**2. `@_eagerMove`**<br>

값에 적용될 때, 이 특성은 그 값의 수명이 어휘적(lexical)이 아니라는 것을 나타냅니다. 즉, 값의 해제가 deinit 장벽에 관계없이 조기에 이루어질 수 있습니다.<br>

타입에 적용될 때, 이 특성은 그 타입의 모든 정적 인스턴스가 위와 같이 `@_eagerMove`임을 나타냅니다. 단, `@_noEagerMove`로 오버라이드되지 않는 한입니다.<br>

모든 필드가 `@_eagerMove`이거나 사소한(trivial) 경우, 그 집합체는 `@_eagerMove`로 추론됩니다.<br>

일반 API(특성 `@_eagerMove`가 주석 처리되지 않은 매개변수)로 전달되는 `@_eagerMove` 타입의 값은, 그 일반 함수의 맥락에서 정적으로 `@_eagerMove` 타입의 인스턴스가 아닙니다. 그 결과, 그 함수 내에서는 어휘적 수명을 가지게 됩니다.<br>

**세 번째**는 `@usableFromInLine`입니다!! 반갑다 친구야!! 우리 다시 한 번 알아가보자꾸나 ㅎㅎ<br>

**3. `@usableFromInLine`**<br>

이 특성(attribute)은 Swift에서 사용되며, 주로 프레임워크 또는 라이브러리를 작성할 때 중요하다고 해요.<br>

이 특성은 특정 함수, 메소드, 프로퍼티, 생성자 등이 해당 모듈 내부에서는 **`public`** 과 유사하게 동작하지만, 모듈 외부에서는 **`internal`** 처럼 보이도록 한답니다.<br>

**즉, 해당 모듈을 사용하는 코드에서는 직접 접근할 수 없지만, 모듈 내부의 다른 `public` 또는 `open` API를 통해 간접적으로 사용될 수 있습니다.**<br>

**`@usableFromInLine`** 의 주된 목적은 **"성능 최적화"** 입니다.<br>

이를 통해 인라인화(inlining) 가능한 코드를 작성할 수 있으며, 이는 특히 컴파일 시간 최적화에 중요하답니다.<br>

인라인화는 함수 호출의 오버헤드를 줄이고, 더 효율적인 코드를 생성하는 데 도움이 되지요 ㅎㅎ<br>

예를 들어볼까요?! :) <br>

Swift의 표준 라이브러리는 다양한 내부 구현을 **`@usableFromInline`** 으로 표시하여, 표준 라이브러리 내부의 다른 **`public`** 함수들이 이러한 구현을 효율적으로 사용할 수 있게 합니다.<br>

그러나 이러한 내부 구현들은 표준 라이브러리를 사용하는 외부 코드에서는 직접 접근이 불가능해요.<br>

이러한 방식으로, 라이브러리 개발자들은 내부 구현을 숨기면서도 성능 최적화를 달성할 수 있습니다.<br>

이는 모듈의 API를 깔끔하게 유지하면서도 필요한 경우 내부적으로 세부적인 최적화를 할 수 있는 유연성을 제공합니다.<br>

**마지막** `@inlinable`은 `@inline`과 형제인가?? ㅇㅅㅇ;; 일단 알아볼까요?!<br>

**`@inlineable`** 은 Swift에서 함수, 메소드, 이니셜라이저, 또는 프로퍼티의 getter와 setter에 사용되는 attribute입니다.<br>

이 특성(attribute)은 해당 코드가 모듈 경계를 넘어 인라인될 수 있도록 허용합니다.<br>

**"즉, 해당 함수나 메소드의 본문이 다른 모듈에서 호출될 때, 컴파일러가 그 본문을 호출하는 코드에 직접 삽입할 수 있습니다."**<br>

**`inlineable`** 특성의 주요 목적은 성능 최적화입니다.<br>

인라인화를 통해 함수 호출 오버헤드를 줄이고, 컴파일러 최적화를 더 효과적으로 수행할 수 있답니다!!<br>

하지만 이 특성을 사용할 때는 주의해야 합니다.<br>

인라인화된 코드는 모듈의 공개 API의 일부가 되므로, 나중에 이 코드를 변경하면 이를 사용하는 다른 모듈들과의 호환성에 영향을 줄 수 있습니다.<br>

Swift의 표준 라이브러리나 다른 프레임워크에서는 **`@inlineable`** 을 사용하여 핵심적인 성능이 중요한 함수나 메소드를 최적화합니다.<br>

이를 통해 이러한 함수나 메소드가 다른 모듈에서 호출될 때 성능 이점을 얻을 수 있습니다.<br>

예를 들어보겠습니다 :)<br>

위 코드에서, **`init(_buffer:)`** 이니셜라이저에 **`inlinable`** 특성이 적용되어 있으면, 이 이니셜라이저는 다른 모듈에서 이 Array 구조체를 사용할 때 인라인될 수 있습니다.<br>

이는 성능을 향상시키지만, 만약 이니셜라이저의 구현이 변경되면, 이 구조체를 사용하는 모든 코드에 영향을 미칠 수 있습니다.<br>

따라서 **`@inlinable`** 을 사용할 때는 API의 안정성과 호환성을 신중하게 고려해야 합니다아~<br>

## 🤿 코드 분석 타임~

```swift
@frozen
@_eagerMove
public struct Array<Element>: _DestructorSafeContainer {
  #if _runtime(_ObjC)
  @usableFromInline
  internal typealias _Buffer = _ArrayBuffer<Element>
  #else
  @usableFromInline
  internal typealias _Buffer = _ContiguousArrayBuffer<Element>
  #endif

  @usableFromInline
  internal var _buffer: _Buffer

  /// Initialization from an existing buffer does not have "array.init"
  /// semantics because the caller may retain an alias to buffer.
  @inlinable
  internal init(_buffer: _Buffer) {
    self._buffer = _buffer
  }
}
```

```swift
public struct Array<Element>
```

위 코드는 제네릭 **`Array`** 구조체를 정의합니다.<br>

**`Element`** 는 이 배열이 저장할 . 수있는 요소의 타입이랍니다 :)<br>

```swift
_DestructorSafeContainer
```

위 코드 조각은 **`Array`** 가 이 프로토콜을 준수함을 나타냅니다.<br>

이는 내부적으로 구현된 Swift의 프로토콜로, 배열이 소멸자(destructor)와 관련된 특정 안전성을 가짐을 보장합니다.<br>

```swift
internal var _buffer: _Buffer
```

이는 **`Array`** 가 내부적으로 사용하는 버퍼를 저장하는 속성입니다.<br>

```swift
@inlinable internal init(_buffer: _Buffer)
```

이는 인라인 가능한 내부 생성자입니다.<br>

이 생성자는 외부에서 직접 접근할 수 없지만, 모듈 내부에서 **`public`** API를 통해 간접적으로 사용될 수 있습니다.<br>

이 생성자는 **`_Buffer`** 인스턴스를 받아 **`Array`** 인스턴스를 초기화합니다.<br>

🙋‍♂️ 코드의 이러한 부분들은 모두 **`Array`** 의 성능과 안정성을 최적화하는데 중요한 역할을 합니다.<br>

이는 Swift의 배열이 어떻게 내부적으로 구현되어 있는지를 보여주는 좋은 예시입니다.<br>

---

## 참고 문서 📚

- [swift/docs/ReferenceGuide/UnderscoredAttributes.md](https://github.com/apple/swift/blob/f6dba90cf2b3b646de748b0fc4fbfbd1f65cb0a3/docs/ReferenceGuides/UnderscoredAttributes.md#_eagermove)
