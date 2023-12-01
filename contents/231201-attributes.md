# Attributes 🤿

Swift에서 **"Attributes(속성)"** 은 특정 선언이나 타입에 대한 추가 정보를 제공하는 방법입니다.

**"Attributes(속성)"** 은 컴파일러에게 특정 선언이나 타입이 어떻게 처리되어야 하는지에 대한 지시를 제공합니다.

예를 들어, 성능 최적화, 접근 제어, 인터페이스 호환성 및 다른 여러 측면에서 중요한 역할을 합니다.

## 1️⃣ Attributes의 범주.

### 1. 선언 속성(Declaration Attributes)

이들은 함수, 변수, 클래스 등과 같은 특정 선언에 적용됩니다.

예를 들어, **`@IBOutlet`** 또는 **`@IBAction`** 은 iOS 개발에서 UI 요소와 코드 사이의 연결을 나타내는 데 사용됩니다.

**`@discardableResult`** 는 함수가 반환 값을 가지지만, 이를 사용하지 않아도 경고를 생성하지 않도록 지시합니다.

### 2. 타입 속성(Type Attributes)

이러한 속성은 특정 타입에 적용됩니다.

예를 들어 **`@escaping`** 속성은 클로저가 함수의 실행 범위를 벗어나 사용될 수 있음을 나타냅니다.

# 💯 Attributes 마무리.

속성은 **`@`** 기호를 사용하여 선언 바로 앞에 추가하여 적용합니다.
일부 속성은 인수를 받아들여 선언이나 타입에 대해 더 구체적인 정보를 제공할 수 있습니다.

Swift의 속성은 코드의 가독성을 향상시키고, 컴파일러에게 명확한 지시를 제공하여 오류를 줄이고, 코드의 성능과 안전성을 향상시키는 데 중요한 역할을 합니다.

### 참고자료 📚

- [docs.swift.org - Attributes](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/attributes/)
