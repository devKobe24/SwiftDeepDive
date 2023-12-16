# Types & Mutation: Functions and methods 🤿

지금까지의 사용자 정의 타입들은 저장된 속성 형태의 데이터만 가지고 있었습니다.<br>
하지만 연산을 추가하면 상황이 흥미로워집니다.<br>
우선,`Point` 타입에 몇 가지 메소드를 추가해보겠습니다.<br>

아래 코드를 봐봅시다.<br>

```swift
// 첫 번째 초안버전
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

여기서 점의 `x`와 `y` 좌표를 교환하는 두 가지의 간단한 메소드가 있습니다.<br>
메소드의 이름은 Swift API 디자인 가이드라인(https://swift.org/documentation/api-design-guidelines/)에 설명된 대로 '유창한' 사용법에 따라 변형하는 메소드와 비변형 메소드 쌍을 따릅니다.
<br>
`flipped()` 함수는 `self`를 사용하고, `filp` 함수는 `self`를 사용하고 수정합니다.<br>
이 땨문에 `filp`을 `mutating`으로 선언해야 합니다.<br>
두 함수 모두 교환 로직을 포함하고 있으며, 이는 반복적입니다.<br>

위 코드를 깔끔해게 바꿔보겠습니다.<br>
아래 코드를 봐봅시다.<br>

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

불필요한 `self` 참조들이 사라졌고, 교환 로직은 `flipped`에만 있습니다.<br>
이 경우에는 구현이 간단하기 때문에 중복이 큰 문제가 되지 않았습니다.<br>
하지만 더 복잡한 비변형 함수와 변형 함수 쌍을 가질 때, 이 패턴의 가치를 더욱 느끼게 될 것입니다.<br>

## Mutating and self

타입 메소드에서 Swift 컴파일러는 보이지 않는 매개변수로 `self:Self`를 전달합니다.<br>
그래서 함수 본문에서 `self`를 사용할 수 있습니다.<br>
변형 메소드에서는 Swift가 보이지 않는 `self: inout Self`를 전달합니다.<br>
`inout`의 의미를 기억한다면, 함수 진입 시에 복사가 이루어지고 나갈 때도 복사가 이루어진다는 것을 알 수 있습니다.<br>
이 타이밍은 속성 관찰자인 `willSet`과 `didSet`이 호출되는 것과 일치합니다.<br>
또한, `inout`은 실질적으로 함수에서 입력값과 추가 반환값을 만듭니다.<br>

> 📝 Note.
> 
> 클래스(즉, 참조 타입)의 메소드는 `inout`을 사용하지 않습니다.<br>
> `self: inout Self`가 무엇을 하는지 생각해보면, 그것이 타당하다는 것을 알 수 있습니다.<br>
> 참조 타입에 대한 `inout`은 인스턴스 전체가 다은 인스턴스에 재할당되는 것을 방지할 뿐입니다.<br>

## Static methods and properties

아래의 코드를 봐봅시다.<br>

```swift
extension Point {
	static var zero: Point {
		Point(x: 0, y: 0)
	}
	
	static func random(inRadius radius: Double) -> Point {
		guard radius >= 0 else {
			return .zero
		}
		
		let x = Double.random(in:  -radius ... radius)
		let maxY = (radius * radius - x * x).squareRoot()
		let y = Double.random(in: -maxY ... maxY)
		return Point(x: x, y: y)
	}
}
```

이 코드는 원점에 있는 점인 `zero`라는 정적 속성을 만듭니다.<br>
정적 메소드 `random`은 지정된 반경에 의해 제한된 무작위 점을 생성합니다.<br>
먼저 `x` 값을 고정하고, 원 안에 머무르도록 피타고라스 정리를 사용하여 허용되는 `y`값의 최대 범위를 결정합니다.<br>

### Going deterministic

Swift의 기본 `Double.random(in:)`은 암호학적으로 안전한 `SystemRandomNumberGenerator()`를 사용합니다.<br>
이 선택은 잠재적 공격자가 무작위 숫자를 추측하는 것을 방지하기 때문에 훌륭한 기본값입니다.<br>

때로는 무작위 값이 결정적이고 반복 가능해야 할 필요가 있습니다.<br>
이 중요성은 특히 지속적인 통합 테스트에 해당합니다.<br>
이러한 유형의 테스트는 새롭고 시도되지 않은 입력 값이 아니라 코드 변경(잘못된 병합이나 리팩토링)에 대한 반응으로 실패해야 합니다.<br>
다행히 Swift 표준 라이브러리는 사용자 정의 생성기를 지원합니다.<br>
오버로드된 메소드 `Double.random(in:using:)`에서 `using` 매개변수는 선택한 의사 무작위 수 생성기를 취합니다.

표준 라이브러리에는 이러한 seedable 의사-무작위 소스가 포함되어 있지 않지만, 직접 만드는 것은 쉽습니다.<br>
웹상에 "좋은" 무작위 생성기에 대한 많은 연구가 있습니다.<br>
여기 위키 백과에 괜찮은 것이 있습니다.<br>
`Permuted Congruential Generator`(https://en.wikipedia.org/wiki/Permuted_congruential_generator)는 나열된 C 코드에서 Swift로 번역될 수 있습니다.<br>

아래 코드를 봐봅시다.<br>

```swift
struct PermutedCongruential: RandomNumberGenerator {
  private var state: UInt64
  private let multiplier: UInt64 = 6364136223846793005
  private let increment: UInt64 = 1442695040888963407

  private func rotr32(x: UInt32, r: UInt32) -> UInt32 {
    (x &>> r) | x &<< ((~r &+ 1) & 31)
  }

  private mutating func next32() -> UInt32 {
    var x = state
    let count = UInt32(x &>> 59)
    state = x &* multiplier &+ increment
    x ^= x &>> 18
    return rotr32(x: UInt32(truncatingIfNeeded: x &>> 27),
                            r: count)
  }

  mutating func next() -> UInt64 {
    UInt64(next32()) << 32 | UInt64(next32())
  }

  init(seed: UInt64) {
    state = seed &+ increment
    _ = next()
  }
}

```

> 🤔 seedable?
> 
> 이 단어는 무작위 수 생성과 관련된 용어로 사용됩니다.<br>
> seebable 의사-무작위 수 생성기는 특정 시작 값(씨앗, seed)을 사용하여 숫자의 시퀀스를 생성합니다.<br>
> 이 씨앗 값은 생성기가 동일한 숫자 시퀀스를 반복적으로 생성하도록 하는 데 사용됩니다.<br>
> 즉, 동일한 씨앗 값으로 생성기를 초기화하면, 매번 동일한 무작위 수 시퀀스를 생성할 수 있습니다.<br>
> 이러한 특성은 테스트나 시뮬레이션에서 일관된 견과를 필요로 할 때 유용합니다.<br>


이 코드에서는 중요하지 않은 몇 가지 수학적 세부사항이 포함되어 있습니다(그러나 `"Numberics & Ranges"`라는 제목의 장에서 C 스타일의 안전하지 않은 이진 산술 연산인 `&>>`, `&*`, `&+`에 대해 더 자세히 알아볼 것입니다.)<br>

주목해야할 중요한 점은 내부 세부사항과 상태를 `private`으로 표시하는 방법입니다.<br>
이 타입의 사용자로서 알아야 할 것은 그것이 64비트 정수로 시드되어 있고, 결정적인 의사-무작위 64비트 정수 스트림을 생성한다는 것뿐입니다.<br>
이러한 숨김은 캡슐화의 실천 예입니다.<br>
이는 복잡성을 다루고 타입을 사용하고 이해하기 쉽게 만듭니다.<br>

이 의사-무작위 소스를 사용하기 위해, `Point.random`의 오버로드를 생성하세요.

다음 코드를 봐봅시다.

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

이것은 시스템 무작위 수 생성기를 사용하는 이전 버전과 매우 유사합니다.<br>
정적 메소드로서, `randon(in:using:)`는 `Point`의 인스턴스와 관련이 없습니다.<br>
하지만 `randomSource`가 `inout` 매개변수이기 때문에 변경 가능한 상태가 함수를 통해 흐를 수 있다는 점에 주목하세요.<br>
매개변수를 통해 부수 효과를 처리하는 이 방법은, 예를 들어, 의사-무작위 상태를 추적하기 위해 전역 변수를 사용하는 것보다 훨씬 더 나은 디자인 입니다.<br>
이는 부수 효과를 사용자에게 명시적으로 드러내어 제어할 수 있도록 합니다.<br>

아래 코드를 봐봅시다.<br>

이 코드를 사용하여 결정론적 난수를 테스트하세요<br>

```swift
var pcg = PermutedCongruential(seed: 1234)
for _ in 1...10 {
	print(Point.random(inRadius: 1, using: &pcg))
}

// 출력
// Point(x: -0.9023933549046517, y: 0.2211787650929622)
// Point(x: 0.4641017758215471, y: -0.008619730806256554)
// Point(x: 0.36933813580626684, y: 0.4895702940792429)
// Point(x: -0.7832637507415443, y: 0.2222762838363581)
// Point(x: -0.39861654363735255, y: 0.6772764813744074)
// Point(x: -0.034191807657613316, y: 0.5795322691237969)
// Point(x: 0.8482691889621115, y: -0.2844778060034989)
// Point(x: 0.339224206487307, y: -0.9114167027275113)
// Point(x: 0.993542039565745, y: 0.06968554494353471)
// Point(x: 0.43091531644250813, y: 0.3236366519677818)
```

이는 난수처럼 보이지만 제현 가능합니다<br>

10번째 무작위 포인트는 시작 시드가 1234인 경우 항상 `Point(x: 0.43091531644250813, y: 0.3236366519677818)`입니다.<br>

## Enumerations

Swift 열거형은 유한한 상태 집합을 모델링할 수 있게 해주는 강력한 타입 중 하나입니다.<br>

아래 코드를 봐봅시다.<br>

```swift
enum Quadrant: CaseIterable, Hashable {
	case i, ii, iii, iv
	
	init?(_ point: Point) {
		guard !point.x.isZero && !point.y.isZero else {
			return nil
		}
		
		switch (point.x.sign, point.y.sign) {
		case (.plus, .plus):
			self = .i
		case (.minus, .plus):
			self = .ii
		case (.minus, .minus):
			self = .iii
		case (.plus, .minus):
			self = .iv
		}
	}
}
```

이 코드는 이차원 평면에서 사분면을 추상화합니다.<br>
`CaseIterable` 준수는 `allCases`라는 배열에 접근할 수 있게 해줍니다.<br>
`Hashable`은 `Set`의 원소나 `Dictionary`의 키로 사용할 수 있음을 의미합니다.<br>
`x` 축이나 `y` 축 위의 점들이 사분면에 정의되어 있지 않기 때문에 초기화자를 실패 가능하게 만들 수 있습니다.<br>
선택적 초기화자는 이 가능성을 자연스럽게 문서화할 수 있게 해줍니다.<br>

다음 코드를 봐봅시다.<br>

```swift
Quadrant(Point(x: 10, y: -3)) // .iv로 평가합니다.
Quadrant(.zero) // nil로 평가합니다.
```

## Types as documentation

타입은 문서화 역할을 할 수 있습니다.<br>
예를 들어, `Int`를 반환하는 함수가 있다면, 그 함수가 3.14159 나 "Giraffe"을 반환할 걱정을 할 필요가 없습니다.<br>
그런 일은 일어날 수 없습니다.<br>
어떤 의미에서, 컴파일러는 모든 그런 미친 가능성들을 배제합니다.<br>

`Foundation`에는 길이, 온도, 각도와 같은 일반적인 물리 단위를 다루기 위한 확장 가능한 타입 집합이 있습니다.<br>
각도를 생각해 보세요, 이는 다양한 단위로 표현될 수 있습니다.<br>

아래의 코드를 봐봅시다.<br>

```swift
let a = Measurement(value: .pi/2,
                    unit: UnitAngle.radians)

let b = Measurement(value: 90,
                    unit: UnitAngle.degrees)

a + b // 180 도(degree)
```

변수 `a`는 라디안으로 표현된 직각이고, `b`는 도(degree)로 표현된 직각입니다.<br>
이들을 함께 더하면 180도임을 볼 수 있습니다.<br>
`'+'` 연산자는 값을 더하기 전에 기본 단위로 변환합니다.<br>

물론 Swift에서는 표준 수학 함수의 오버로드를 정의할 수 있습니다.<br>
타입-안전한 버전의 `cos()`와 `sin()`을 만들 수 있습니다.<br>

```swift
func cos(_ angle: Measurement<UnitAngle>) -> Double {
	cos(angle.converted(to: .radians).value)
}

func sin(_ angle: Measurement<UnitAngle>) -> Double {
	sin(angle.converted(to: .radians).value)
}

cos(a) // 0
cos(b) // 0
sin(a) // 1
sin(b) // 1
```

이 함수는 각도를 명시적으로 라디안으로 변환한 후 표준 초월 함수인 `cos()`와 `sin()`에 전달합니다.<br>
이 새로운 API를 사용함으로써, 컴파일러는 당신이 각도 타입을 전달하는지 아니면 무의미한 것을 전달하는지 확인할 수 있습니다.<br>

> 📝 Note.<br>
> 
> 여러 인기 있는 프레임워크들이 각도 타입을 처리합니다.<br>
> `Foundation`의 `Measurement` 타입 외에도, `SwiftUI`는 `도(degree)`나 `라디안(Radian)`으로 명시적으로 초기화하는 `Angle`을 정의합니다.<br>
> 모든 다른 부동 소수점 타입을 추상화하는 일반적인 버전이 공식 Swift numerics package에 제안되었습니다.<br>

## Improving type ergonomics

Swift의 훌륭한 점 중 하나는 소스 코드를 갖고 있지 않은 기존 타입의 기능과 상호 운용성을 확장할 수 있다는 것입니다.<br>
예를 들어, 여러분의 프로그램이 극좌표를 다루길 원한다고 가정해 봅시다.<br>
여러분은 각도를 많이 사용할 것입니다.<br>

아래 코드를 봐봅시다.<br>

```swift
typealias Angle = Measurement<UnitAngle>

extension Angle {
	init(radians: Double) {
		self = Angle(value: radians, unit: .radians)
	}
	init(degree: Double) {
		self = Angle(value: degree, unit: .degrees)
	}
	var radians: Double {
		converted(to: .radians).value
	}
	var degree: Double {
		converted(to: .degrees).value
	}
}
```

`typealias` 는 각도에 대해 더 짧고 설명적인 표현을 제공합니다.<br>
이제 `sin`과 `cos` 구현을 다음과 같이 개선할 수 있습니다.

```swift
func cos(_ angle: Angle) -> Double {
	cos(angle.radians)
}

func sin(_ angle: Angle) -> Double {
	sin(angle.radians)
}
```

이들이 훨씬 더 깔끔해 보입니다.<br>
이제, 극좌표 타입을 정의할 수 있습니다.<br>

```swift
struct Polar: Equatable {
	var angle: Angle
	var distance: Double
}
```

`xy` 좌표와 극좌표 간에 쉽게 전환하길 원하기 때문에, 해당하는 타입 변환 초기화자를 추가할 수 있습니다.<br>

```swift
// 극좌표를 xy 좌표로 변환
extension Point {
	init(_ polar: Polar) {
		self.init(x: polar.distance * cos(polar.angle),
                  y: polar.distance * sin(polar.angle))
	}
}

// xy 좌표를 극좌표로 변환
extension Polar {
	init(_ point: Point) {
		self.init(angle: Angle(radians: atan2(point.x, point.y)),
                  distance: hypot(point.x, point.y))
	}
}
```

여러분의 추상화가 서로 위에 구축되어 더욱 강력한 작업 환경을 만드는 것을 알 수 있습니다.<br>
여러분의 타입들이 복잡성을 계층별로 숨기게 해줍니다.<br>

이제, 다음과 같이 `xy`좌표에서 극좌표로, 그 반대로 쉽게 전환할 수 있습니다.<br>

```swift
let coord = Point(x: 4, y: 3)
Polar(coord).angle.degree // 36.87
Polar(coord).distance // 5
```

강한 타입은 극좌쵸와 `xy` 좌표를 실수로 혼동하는 것을 방지하지만, 의도한 경우레는 여전히 두 좌표간에 쉽게 전환할 수 있습니다.<br>

## Associated values
스위프트의 열거형은 특정 케이스와 정보를 연결할 수 있어 매우 강력합니다.<br>
예를 들어, 다음과 같이 고정된 모양 집합을 만들 수 있습니다.<br>

아래 코드를 봐봅시다.<br>

```swift
enum Shap {
	case point(Point)
	case segment(start: Point, end: Point)
	case circle(center: Point, radius: Double)
	case rectangle(Rectangle)
}
```
보시다시피, 타입을 조합하는 것이 간단합니다.<br>
앱에서 유효한 상태를 간결하게 모델링할 수 있으며, 표현할 수 없는 상태가 컴파일 되지 않도록 방지할 수도 있습니다.<br>

## Using RawRepresentable
도구 상자에 또 다른 필수 도구가 있습니다.<br>
아마도 모르고 열거형에 대해 `RawRepresentable`을 사용한 적이 있을 것입니다.<br>

아래 코드를 봐봅시다.<br>

```swift
enum Coin {
	case penny, nickel, diem, quarter
}
```

열거형을 정수, 문자 또는 문자열로 백업하면 컴파일러 마법 덕분에 `RawRepresentable`이 됩니다.<br>

다음 코드를 봐봅시다.<br>

```swift
enum Coin: Int {
	case penny = 1, nickel = 5, diem = 10, quarter = 25
}
```

`RawRepresentable` 이라는 것은 원시 값을 생성하고 가져올 수 있다는 것을 의미합니다.<br>
또한, 타입이 `Equatable`, `Hashable` 및 `Codable`이 무료로 제공된다는 것을 의미합니다.<br>

아래 코드를 봐봅시다.<br>

```swift
let lucky = Coin(rawValue: 1)
lucky?.rawValue // Optional(1)을 반환함
let notSoMuch = Coin(rawValue: 2)
```

`RawRepresentable`을 직접 사용하여 간단한 검증된 타입을 만들 수 있습니다.<br>

아래의 코드를 봐봅시다.<br>

```swift
struct Email: RawRepresentable {
	var rawValue: String
	
	init?(rawValue: String) {
		guard rawValue.contains("@") else {
			return nil
		}
		self.rawValue = rawValue
	}
}
```

이 간단한 타입은 일종의 문서화를 제공합니다.<br>
이를 사용하는 함수의 시그니처를 고려해 보세요<br>

아래의 코드를 봐봅시다<br>

```swift
func send(message: String, to recipient: Email) throws {
	// some implementation
}
```

이 함수는 매개변수 레이블이 메시지와 수신자가 어디로 가는지 분명하게 만들어 사용하기 쉽고,<br>
컴파일러가 확인할 수 있는 특정 타입으로 인해 잘못 사용하기 어렵습니다.<br>
`Email`의 타입은 잘 형성된 이메일 주소만 전달할 수 있음을 의미합니다.<br>
(이 예에서 검사는 주소에 `'@'`가 있는지 확인하지만, 원하는 만큼 엄격하게 만들 수 있습니다.)<br>

`isVaild`와 같은 속성을 가지는 것보다, 유효한 인스턴스를 생성할 수 없을 때 `nil`을 반환하거나 더 구체적인 오류를 발생시키는 실패 가능한 생성자를 만드는 것이 더 좋습니다.<br>
이 명시적인 실패 모드는 코드를 설정하여 컴파일러가 오류를 확인하도록 강제합니다.<br>
보상은 다음과 같습니다.<br>
타입을 사용하는 함수를 작성할 때, 유효하지 않을 수 있는 반쯤 만들어진 인스턴스에 대해 걱정할 필요가 없습니다.<br>
이 패턴은 데이터 유효성 검사와 요류 처리를 소프트웨어 스택의 상위 계층으로 밀어내고, 하위 계층이 추가 확인 없이 효율적으로 작동할 수 있도록 합니다.<br>

### 🍗 문장 뜯어 먹기 냠냠!!!

>이것은 시스템 무작위 수 생성기를 사용하는 이전 버전과 매우 유사합니다.<br>
정적 메소드로서, `randon(in:using:)`는 `Point`의 인스턴스와 관련이 없습니다.<br>
하지만 `randomSource`가 `inout` 매개변수이기 때문에 변경 가능한 상태가 함수를 통해 흐를 수 있다는 점에 주목하세요.<br>
매개변수를 통해 부수 효과를 처리하는 이 방법은, 예를 들어, 의사-무작위 상태를 추적하기 위해 전역 변수를 사용하는 것보다 훨씬 더 나은 디자인 입니다.<br>
이는 부수 효과를 사용자에게 명시적으로 드러내어 제어할 수 있도록 합니다.<br>

위 문장은 Swift 프로그래밍 언어에서 특정한 함수 디자인에 대해 설명하고 있습니다.<br>
구체적으로, **`'Point'`** 타입의 **`'random(in:using:)'`** 이라는 정적 메소드에 대한 설명입니다.<br>
이 메소드는 **`'Point'`** 객체의 인스턴스 상태와 관련이 없는데, 이는 **`'Point'`** 타입의 인스턴스를 수정하지 않고 동작한다는 의미입니다.<br>

중요한 부분은 **`'randomSource'`** 매개변수가 **`'inout'`** 유형으로 되어 있다는 것입니다.<br>
**`'inout'`** 매개변수는 함수 내에서 변경될 수 있으며, 함수 실행이 끝난 후에도 이 변경 사항이 호출자에게 반영됩니다.<br>
여기서, **`'randomSource'`** 는 의사-무작위 수 생성기의 상태를 나타내는 변수로, 이 매개변수를 통해 함수는 변경 가능한 상태를 "흐르게"할 수 있습니다.<br>

이러한 설계 방식은 전역 변수를 사용하여 의사-무작위 상태를 추적하는 것보다 우수합니다.<br>
전역 변수는 프로그램의 다른 부분에 부수 효과를 발생시킬 수 있지만, **`'inout'`** 매개변수를 사용하면 이리한 부수 효과가 명시적으로 드러나 사용자가 제어할 수 있게 됩니다.<br>
이는 함수가 어떻게 내부 상태를 처리하고 외부에 노출하는지에 대한 좋은 예시입니다.<br>
