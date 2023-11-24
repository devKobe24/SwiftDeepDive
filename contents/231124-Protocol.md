# Swift에서의 프로토콜(Protocol) 🤿

**Swift에서 프로토콜(Protocol) 은 일련의 메서드, 속성 그리고 다른 요구사항들을 정의하는 청사진이나 계약과 같은 역할을 합니다.**

프로토콜 자체는 이러한 요구사항들의 구현을 제공하지 않지만, 프로토콜을 **채택(adopt)** 하고 **준수(conform)** 하는 타입은 이러한 **요구사항들을 구현**해야 합니다.

## 1️⃣ Swift 프로토콜의 특징과 목적.

### 1. 요구사항 정의.

**프로토콜은 타입이 특정 기능을 수행하기 위해 필요한 메서드, 속성 그리고 다른 요구사항들을 정의합니다.**
이 요구사항들은 구체적인 행동이나 값을 정의하지 않고, 형식만 제시합니다.

#### ✅ 1.1 예시코드와 설명

Swift에서 프로토콜을 사용하여 요구사항을 정의하는 간단한 예시를 만들어 보겠습니다.

이 예시에서는 **'Vehicular'** 라는 프로토콜을 정의하고, 이 프로토콜은 모든 차량이 가져야 할 기본적인 속성과 메서드를 요구합니다.

```swift
protocol Vehicular {
    var numberOfWheels: Int { get }
    var color: String { get set }
    
    func startEngine()
    func startEngine()
}

class Car: Vehicular {
    let numberOfWheels: Int
    var color: String
    
    init(numberOfWheels: Int, color: String) {
        self.numberOfWheels = numberOfWheels
        self.color = color
    }
    
    func startEngine() {
        print("부릉 부릉~")
    }
    
    func stopEngine() {
        print("뿌에에엥~")
    }
}

class Bicycle: Vehicular {
    var numberOfWheels: Int
    var color: String
    
    init(color: String) {
        self.numberOfWheels = 2
        self.color = color
    }
    
    func startEngine() {
        print("저는,,엔진이 없어요,,")
    }
    
    func stopEngine() {
        print("엔진이 저는 없어요우,,")
    }
}

let myCar = Car(numberOfWheels: 4, color: "Black")
myCar.startEngine() // 출력: "부릉 부릉~"

let myBike = Bicycle(color: "Yellow")
myBike.startEngine() // 출력: "저는,,엔진이 없어요,,"
```

이 예시에서 **'Vehicular'** 프로토콜은 차량이 가져야 할 기본적인 요구사항을 정의합니다.

이 요구사항에는 **'numberOfWheels'** 와 **'color'** 라는 속성과 **'startEngine'** 및 **'stopEngine'** 이라는 메서드가 포함됩니다.

그런 다음 **'Car'** 와 **'Bicycle'** 두 클래스가 이 프로토콜을 채택하고 각 요구사항을 구현합니다.

이 예시에서 볼 수 있듯이, 프로토콜은 구체적인 구현을 제시하지 않고, 대신 타입이 준수해야 할 형식을 정의합니다.

프로토콜을 채택하는 각 클래스나 구조체는 이 요구사항을 자신의 방식대로 구현합니다.

## 🙌 프로토콜에서의 읽기 전용 { get }

Swift에서 **`'{ get }'`** 이라는 표시는 프로토콜에서 해당 속성이 **읽기 전용**임을 나타냅니다.
이는 프로토콜을 구현하는 타입이 **최소한** 이 속성을 읽을 수 있어야 함을 의미합니다.
그러나 **`'{ get }'`** 으로 표시된 속성이라도, 그것을 구현하는 클래스나 구조체에서 해당 속성을 **읽기/쓰기 가능하게 만들 수 있습니다.**

예제 코드에서 **'Vehicular'** 프로토콜은 **'numberOfWheels'** 속성이 최소한 읽기가 가능해야 함을 명시합니다.
그러나 **'Bicycle'** 클래스에서 이 속성을 정의할 때, 이를 읽기와 쓰기 **모두 가능한 속성**으로 구현했습니다.
따라서 **'Bicycle'** 인스턴스의 **'numberOfWheels'** 속성을 변경할 수 있는 것입니다.

간단히 말해서, 프로토콜에서 **`'{ get }'`** 은 해당 속성이 읽기 전용이어야 한다는 최소 요구사항을 나타내지만, 실제 구현에서는 이를 더 확장하여 **읽기/쓰기가 가능**하게 만들 수 있습니다.

## 그렇다면 numberOfWheels을 읽기 속성만 가능하게 하려면🤔?

**'numberOfWheels'** 속성을 오직 읽기만 가능하게 하려면, 프로토콜에서 정의한 것처럼 **`'{ get }'`** 을 사용하고, 이 속성을 구형하는 클래스나 구조체에서도 이 속성을 **오직** 읽기만 가능하도록 구현해야 합니다.

즉, **`'set'`** 메서드를 제공하지 않아야 합니다.

예를 들어 **'Bicycle'** 클래스에서 **'numberOfWheels'** 를 읽기 전용으로 만들기 위해서는, 클래스 내에서 이 속성을 변경할 수 없도록 구현해야 합니다.

```swift
class Bicycle {
    let numberOfWheels: Int // 'let' 키워드를 사용하여 상수로 선언
    var color: String
    
    init(color: String) {
        self.numberOfWheels = 2
        self.color = color
    }
    
    func startEngine() {
        print("저는,,엔진이 없어요,,")
    }
    
    func stopEngine() {
        print("엔진이 저는 없어요우,,")
    }
}
```

이 코드에서 **'numberOfWheels'** 는 **'let'** 키워드를 사용하여 상수로 선언되었습니다.

이는 **'numberOfWheels'** 속성이 초기화 이후에 변경될 수 없음을 의미하며, 따라서 이 속성은 읽기 전용이 됩니다.

이렇게 구현하면 **'numberOfWheels'** 속성은 **'Bicycle'** 인스턴스가 생성된 후에는 변경할 수 없게 되어, 오직 읽기만 가능한 속성이 됩니다.

### 2. 타입의 계약.

**프로토콜은 특정 기능이나 행동을 수행할 수 있다는 타입의 약속이나 계약과 같습니다.**
프로토콜을 채택한 타입은 프로토콜에 정의된 모든 요구사항을 충족시켜야 합니다.

#### ✅ 2.1 예시코드와 설명

이 예시 코드에서는 간단한 **'Printable'** 프로토콜을 정의하고, 이 프로토콜을 채택하는 여러 타입이 프로토콜의 요구사항을 충족시키는 방법을 보여줍니다.

```swift
protocol Printable {
    func printDescription()
}

class Document: Printable {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func printDescription() {
        print("Document: \(title)")
    }
}

class Photo: Printable {
    var filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    
    func printDescription() {
        print("Photo: \(filename)")
    }
}

let items: [Printable] = [
    Document(title: "My Report"),
    Photo(filename: "sunset.jpg")
]

for item in items {
    item.printDescription()
}
```

이 코드에서 **'Printable'** 프로토콜은 **'printDescription'** 이라는 하나의 메서드를 요구합니다.

**'Document'** 클래스와 **'Photo'** 클래스는 **'Printable'** 프로토콜을 채택하고, 이 메서드를 구현하여 프로토콜의 요구사항을 충족시킵니다.

이를 통해 어떤 객체든 **'Printable'** 프로토콜을 준수하면 **'printDescription'** 메서드를 가지고 있음이 보장됩니다.

이 예시는 프로토콜을 통해 타입에 특정 행동을 수행할 수 있다는 계약을 정의하고, 이를 구현하는 방법을 보여줍니다.

이를 통해 코드의 유연성과 재사용성을 높일 수 있습니다.

### 3. 다형성.

**프로토콜은 다형성을 지원합니다.**
다양한 타입이 동일한 프로토콜을 준수할 수 있으며, 프로토콜 타입을 사용하여 이들을 추상적으로 다룰 수 있습니다.

#### ✅ 3.1 예시코드와 설명

이 예시 코드에서는 **'Movable'** 이라는 프로토콜을 정의하고, 이 프로토콜을 여러 타입이 채택하여 다형성을 구현하는 방법을 보여줍니다.

```swift
protocol Movable {
    func move()
}

class Car: Movable {
    func move() {
        print("자동차가 움직입니다.")
    }
}

class Animal: Movable {
    func move() {
        print("동물이 움직입니다.") 
    }
}

let movables: [Movable] = [Car(), Animal()]

for movable in movables {
    movable.move()
}
```

이 코드에서 **'Movable'** 프로토콜은 **'move'** 라는 메서드를 요구합니다.

**'Car'** 클래스와 **'Animal'** 클래스는 **'Movable'** 프로토콜을 채택하고, **'move'** 메서드를 각자의 방식으로 구현합니다.

이러한 구조를 통해 **'Car'** 와 **'Animal'** 은 **'Movable'** 타입의 배열에 저장될 수 있고, 각 객체는 고유한 **'move'** 메서드 구현을 가집니다.

이는 프로토콜을 사용한 다형성의 예시이며, 이를 통해 타입에 관계없이 공통 인터페이스를 통해 객체들을 처리할 수 있습니다.

### 4. 유연성과 재사용성.

**프로토콜은 코드의 재사용성과 유연성을 높입니다.**
다양한 타입에서 공통의 인터페이스로 프로토콜을 사용할 수 있으며, 이를 통해 중복을 줄이고 유지보수를 용이하게 할 수 있습니다.

#### ✅ 4.1 예시코드와 설명

이 예시 코드에서는 **'Serializable'** 프로토콜을 정의하고, 다양한 타입에서 이 프로토콜을 채택하여 공통 인터페이스를 제공하는 방법을 보여줍니다.

```swift
protocol Serializable {
    func serialize() -> String
}

class User: Serializable {
    var name: String
    var age: Int
    
    init(name: String, age: Int) {
        self.name = name 
        self.age = age
    }
    
    func serialize() -> String {
        return "User(name: \(name), age: \(age))"
    }
}

class Product: Serializable {
    var title: String
    var price: Double
    
    init(title: String, price: Double) {
        self.title = title
        self.price = price
    }
    
    func serialize() -> String {
        return "Product(title: \(title), price: \(price))"
    }
}

let itens: [Serializable] = [
    User(name: "Alice", age: 30),
    Product(title: "Laptop", price: 1299.99)
]

for item in items {
    print(item.serialize())
}
```

이 코드에서 **'Serializable'** 프로토콜은 **'serialize'** 라는 메서드를 정의합니다.

이 메서드는 객채를 문자열로 직렬화하는 기능을 수행합니다.

**'User'** 클래스와 **'Product'** 클래스는 **'Serializable'** 프로토콜을 채택하고, 각자의 방식으로 **'serialize'** 메서드를 구현합니다.

이렇게 함으로써 다양한 타입(**'User'**, **'Product'**)에 대해 공통된 인터페이스(**'serialze'**)를 제공합니다.

이는 코드의 재사용성을 높이고, 다양한 타입을 동일한 방식으로 처리할 수 있게 하여 유연성을 증가시킵니다.

### 5. 확장성

**프로토콜 확장을 사용하여 프로토콜에 기본 구현을 제공할 수 있습니다.**
이를 통해 채택하는 모든 타입에 대해 공통의 구현을 제공할 수 있으며, 필요에 따라 특정 타입에서 이를 오버라이드할 수 있습니다.

#### ✅ 5.1 예시코드와 설명

이 예시 코드에서는 **'Greeting'** 프로토콜을 정의하고, 프로토콜 확장을 통해 기본 구현을 제공합니다.
다양한 타입이 이 프로토콜을 채택할 수 있으며, 필요에 따라 기본 구현을 오버라이드할 수 있습니다.

```swift
protocol Greeting {
    var name: String { get }
    func greet()
}

extension Greeting {
    func greet() {
        print("Hello, \(name)!")
    }
}

class Person: Greeting {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

class Robot: Greeting {
    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    func greet() {
        print("Greetings, \(name)!")
    }
}

let alice = Person(name: "Alice")
alice.greet() // 출력: Hello, Alice!

let carbot = Robot(name: "Carbot")
carbot.greet() // 출력: Greetings, Carbot!
```

이 코드에서 **'Greeting'** 프로토콜은 **'name'** 속성과 **'greet'** 메서드를 요구합니다.

프로토콜 확장을 통해 **'greet'** 메서드의 기본 구현을 제공합니다.

**'Person'** 클래스는 **'Greeting'** 프로토콜을 채택하지만 **'greet'** 메서드를 오버라이드하지 않으므로, 기본 구현이 사용됩니다.

반면, **'Robot'** 클래스는 **'greet'** 메서드를 오버라이드하여 다른 인사말을 출력합니다.

프로토콜 확장을 사용하면, 프로토콜을 채택하는 모든 타입에 대해 공통의 구현을 제공할 수 있으며, 각 타입은 필요에 따라 이를 커스터마이즈할 수 있습니다.

이러한 방식은 코드의 중복을 줄이고 확장성을 높이는 데 유용합니다.

### 6. 위임 패턴 지원.

**프로토콜은 위임 패턴을 구현하는 데 자주 사용됩니다.**
한 객체가 특정 작업을 다른 객체에게 위임 할 때, 프로토콜은 이 작업을 수행하는 데 필요한 메서드를 정의합니다.

#### ✅ 6.1 예시코드와 설명

여기서는 Swift에서 프로토콜을 사용한 위임 패턴(Delegation Pattern)의 예시를 만들어보겠습니다.

이 패턴은 한 객체가 일부 책임을 다른 객체에게 위임하는 구조입니다.

예시에서는 **'TaskDelegate'** 프로토콜을 정의하고, 한 객체가 작업 완료 시 이를 다른 객체에게 알리는 상황을 구현합니다.

```swift
// TaskDelegate 프로토콜 정의
protocol TaskDelegate {
    func taskDidFinish()
}

// Worker 클래스는 작업을 수행하고 완료 시 delegate에게 알림
class Worker {
    var delegate: TaskDelegate?
    
    func doWork() {
        print("Worker: 작업중입니다...")
        // 작업 완료
        print("Worker: 작업이 완료되었습니다, 델리게이트에 알림을 전송합니다.")
        delegate?.taskDidFinish()
    }
}

// Manager 클래스가 TaskDelegate 프로토콜을 채택
class Manager: TaskDelegate {
    func taskDidFinish() {
        print("Manager: Worker가 작업을 완료했습니다.")
    }
}

// Worker와 Manager 인스턴스 생성.
let manager = Manager()
let worker = Worker()

// worker의 delegate로 manager를 지정
worker.delegate = manager

// worker에게 일을 시작하라고 함
worker.doWork()
```

이 코드에서 **'Worker'** 클래스는 어떤 작업을 수행합니다.

작업이 완료되면, **'Worker'** 는 **'delegate'**(이 경우 **'Manager'**)에게 작업 완료를 알립니다.

**'Manager'** 클래스는 **'TaskDelegate'** 프로토콜을 채택하고 **'taskDidFinish'** 메서드를 구현하여, **'Worker'** 로부터의 작업 완료 알림을 처리합니다.

이러한 위임 패턴은 객체 간의 결합도를 낮추고, 코드의 재사용성과 유연성을 높이는 데 유용합니다.

Swift에서 위임 패턴은 특히 사용자 인터페이스 구성 요소간의 상호작용을 관리하는 데 자주 사용됩니다.

# 💯 Swift에서의 프로토콜 마무리.

Swift에서 프로토콜은 클래스, 구조체, 열거형 등 다양한 타입에서 채택할 수 있습니다.
이는 프로토콜 지향 프로그래밍의 핵심 개념 중 하나이며, Swift 프로그래밍에서 매우 중요한 역할을 합니다.
프로토콜을 통해 소프트웨어 설계의 유연성을 높이고, 코드의 재사용성과 유지보수를 개선할 수 있습니다.

---

### 참고 자료 📚

- [다형성, Swift에서의 다형성.](https://github.com/devKobe24/TIL/blob/main/TIL/231119(3)_TIL.md)
- [Swift에서의 추상화](https://github.com/devKobe24/TIL/blob/main/TIL/231124(2)_TIL.md)
