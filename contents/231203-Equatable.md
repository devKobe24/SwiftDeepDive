# Equatable 🤿

**"값의 동일성을 비교할 수 있는 유형입니다."**

```swift
protocol Equatable
```

## 1️⃣ Equatable의 내부 코드.

```swift
public protocol Equatable {

  static func == (lhs: Self, rhs: Self) -> Bool
}

extension Equatable {

  @_transparent
  public static func != (lhs: Self, rhs: Self) -> Bool {
    return !(lhs == rhs)
  }
}

@_silgen_name("_swift_stdlib_Equatable_isEqual_indirect")
internal func Equatable_isEqual_indirect<T: Equatable>(
  _ lhs: UnsafePointer<T>,
  _ rhs: UnsafePointer<T>
) -> Bool {
  return lhs.pointee == rhs.pointee
}

#if !$Embedded
@inlinable
public func === (lhs: AnyObject?, rhs: AnyObject?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return ObjectIdentifier(l) == ObjectIdentifier(r)
  case (nil, nil):
    return true
  default:
    return false
  }
}
#else
@inlinable
public func ===<T: AnyObject, U: AnyObject>(lhs: T?, rhs: U?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return Builtin.bridgeToRawPointer(l) == Builtin.bridgeToRawPointer(r)
  case (nil, nil):
    return true
  default:
    return false
  }
}
#endif

#if !$Embedded
@inlinable
public func !== (lhs: AnyObject?, rhs: AnyObject?) -> Bool {
  return !(lhs === rhs)
}
#else
@inlinable
public func !==<T: AnyObject, U: AnyObject>(lhs: T, rhs: U) -> Bool {
  return !(lhs === rhs)
}
#endif
```

## 2️⃣ 내부 코드 뜯어 먹기 냠냠 😋

### ✅ 1. 'Equatable' 프로토콜.

```swift
public protocol Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool
}
```

**`Equatable`** 은 값이 동등한지 비교하는 기능을 제공하는 프로토콜입니다.

**`==`** 연산자는 동일 타입의 두 인스턴스(**`lhs`** 와 **`rhs`**)를 받아 두 값이 동등한지 비교하여 **`Bool`** 값을 반환합니다.

> 🤔 잠깐만요!! `lhs`와 `rhs`는 매개변수 아닌가요?! 그런데 왜 `두 인스턴스`라고 설명하시죠?!
> 
> 🙋‍♂️ **`두 인스턴스`** 라고 명시된 이유는 **`==`** 연산자가 비교를 위해 두 개의 개별 객체 또는 값(인스턴스)를 필요로 하기 때문입니다.
> 
> **`Equatable`** 프로토콜의 **`==`** 연산자 정의에 따르면, 이 연산자는 같은 타입의 두 객체를 비교하기 위해 두 매개변수를 받습니다.
> 
> 여기에서 **`lhs(left-hand side)`** 와 **`rhs(right-hand side)`** 는 이 비교 연산에서 각각 왼쪽과 오른쪽에 오는 두 개의 인스턴스를 나타냅니다.
> 
> 예를 들어, 두 개의 문자열 인스턴스를 비교할 때 **`==`** 연산자는 다음과 같이 사용됩니다.
> 
> ```swift
> let string1 = "Hello"
> let string2 = "Kobe"
> let areEqual = string1 == string2 // 이 경우에 'string1'이 lhs, 'string2'가 'rhs'입니다.
> ```
> 
> 여기서 **`string1`** 과 **`string2`** 는 **`String`** 타입의 두 개별 인스턴스로, **`==`** 연산자에 의해 비교됩니다.
> 
> 이처럼 **`==`** 연산자는 비교를 위해 두 인스턴스를 필요로 하며, 이 두 인스턴스는 연산자의 매개변수로 전달됩니다.
> 
> 따라서 설명에서 **`두 인스턴스`** 라고 명시된 것은 **`==`** 연산자가 동작하기 위해 필요한 두 개의 비교 대상을 강조하기 위함입니다.

### ✅ 2. 'Equatable' 확장.

```swift
extension Equatable {
    @_transparent
    public static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
}
```

**`Equatable`** 프로토콜을 확장하여 **`!=`** 연산자를 구현합니다.

**`!=`** 연산자는 **`==`** 연산자의 결과를 부정하여, 두 값이 다른지를 판단합니다.

**`@_transparent`** 속성은 컴파일러 최적화를 위해 사용되며, 함수의 구현이 호출지점에 인라인될 수 있음을 나타냅니다.

> 🤔 **인라인(inline)** 너무 생소해요 알려주세요!
> 
> 🙋‍♂️ **인라인(inline)** 이란 함수 호출에 대한 처리 방식에서 사용되는 프로그래밍 용어로, **특정 함수의 본문 코드가 호출 지점에 직접 삽입되는 것을 의미합니다.**
> 
> 이는 컴파일 시간에 수행되며, 프로그램의 실행 효율성을 향상시키기 위해 사용됩니다.
> 
> 일반적인 함수 호출 과정을 예로 들어 인라인이 어떤 점이 일반적인 함수 호출과 다른지 알려드릴게요.
> 
> 먼저, 함수가 호출될 때 프로그램 실행 흐름은 함수의 본문 코드가 위치한 메모리 주소로 이동합니다.
> 
> 이후, 함수의 코드가 실행되고 실행 흐름은 원래 위치로 돌아와 다음 명령을 계속 실행합니다.
> 
> **함수가 인라인되는 경우, 이러한 "호출-반환" 과정이 없습니다.**
> 
> 대신, 함수의 본문 코드가 호출 지점에 **직접 삽입**됩니다.
> 
> 이로 인해 프로그램의 실행 속도가 향상될 수 있으며, 특히 작은 함수에서 이점이 큽니다.
> 
> 그렇다면 장점과 단점을 알아볼까요?
> 
> **장점**은 다음과 같습니다.
> 
> 함수의 호출에 따른 오버헤드가 줄어들어 프로그램의 실행 속도가 향상되는 **"성능 향상".**
> 
> 함수 호출 및 반환에 따른 스택 조작이 필요 없어 메모리 사용량이 감소할 수 있음에 따른 **오버헤드 감소**.
> 
> **단점**은 다음과 같습니다.
> 
> 함수가 여러 번 호출될 경우, 해당 함수의 코드가 각 호출 지점에 복사되어 전체 코드 크기가 증가 할 수 있음에 따른 **"코드 크기 증가".**
> 
> 인라인 처리는 컴파일 시간에 이루어지기 때문에, 컴파일 시간이 늘어날 수 있음에 따른 **"컴파일 시간 증가".**

### ✅ 3. 'Equatable_isEqual_indirect' 함수.

```swift
@_silgen_name("swift_stdlibt_Equtable_isEqual_indirect")
internal func Equatable_isEqual_indirect<T: Equatable>(
    _ lhs: UnsafePointer<T>,
    _ rhs: UnsafePointer<T>
) -> Bool {
    lhs.pointee == rhs.pointee
}
```

이 함수는 **`Equatable`** 타입의 두 값을 비교하는 내부(internal) 함수입니다.

**`@_silgen_name`** 속성은 Swift 컴파일러에게 이 함수가 다른 이름으로 심볼화될 것임을 알리는 것 입니다.

**`UnsafePointer<T>`** 를 사용하여, 메모리의 특정 주소에서 값을 읽습니다.
**`lhs.pointee`** 와 **`rhs.pointee`** 는 해당 주소의 값을 의미합니다.

### ✅ 4. '===' 연산자.

```swift
public func === (lhs: AnyObject?, rhs: AnyObject?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return ObjectIdentifier(l) == ObjectIdentifier(r)
    case (nil, nil):
        return true
    default:
        return false
  }
}
```

이 연산자는 두 객체 참조가 동일한 객체를 가리키는지 비교합니다.

**`ObjectIdentifier`** 를 사용하여 두 객체의 고유 식별자를 비교합니다.

### ✅ 5. '!==' 연산자.

```swift
public func !== (lhs: AnyObject?, rhs: AnyObject?) -> Bool {
    return !(lhs === rhs)
}
```

이 연산자는 **`===`** 연산자의 결과를 부정하여, 두 객체 참조가 다른 객체를 가리키는지 판단합니다.

### ✅ 6. 조건부 컴파일 지시문 `#if !$Embedded`

**`#if !$Embedded`** 및 **`#else`** 블록은 조건부 컴파일을 위한 지시문입니다.

**`$Embedded`** 가 **`false`** 일 때 (즉, 임베디드 환경이 아닐 때), 첫 번째 블록의 코드가 컴파일 됩니다.

임베디드 환경일 경우 두 번째 블록의 코드가 컴파일됩니다.

## 💯📝 Equatable 내부 코드 뜯어 먹기 마무리.

이 코드는 Swift 언어의 핵심 기능 중 하나인 값의 동등성 비교를 위한 구현을 보여주며, **`Equatable`** 프로토콜을 통해 타입 안전성과 일관된 동등성 비교 방식을 제공합니다.

---

### 참고자료 📚

- [Apple Developer Documentation - Equatable](https://developer.apple.com/documentation/swift/equatable)
- [Apple - Swift repository / Equatable.swift](https://github.com/apple/swift/blob/main/stdlib/public/core/Equatable.swift)
