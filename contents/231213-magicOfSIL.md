# The magic of SIL 🤿

Swift의 개발과 함께, 소스 언어의 모든 타임 의미론을 유지하는 중간 언어를 생성하는 아이디어는 새로운 것이었습니다.
다른 LLVM 컴파일러들이 특정 진단을 표시하고 고급 최적화를 수행하기 위해 매우 복잡한 경로를 거쳐야 하는 반면,
SILGen은 이를 직접적이고 테스트 가능한 방식으로 생성할 수 있습니다.

## Overflow detection

SIL의 능력을 실제로 확인해보세요. 다음과 같은 플레이그라운드 오류를 고려해보세요:

<img src = "https://github.com/devKobe24/images/blob/main/SWDD-231213.png?raw=true"><br>

SILGen 단계 덕분에 컴파일러는 소스 코드를 정적으로 분석(컴파일 시간에 검사)하여, 127까지밖에 올라가지 않는 Int8에 130이라는 숫자가 들어갈 수 없다는 것을 확인합니다.

## Definite initialization

Swift는 기본적으로 초기화되지 않은 메모리에 접근하기 어렵게 만드는 안전한 언어입니다.
SILGen은 '명확한 초기화'라고 불리는 검사 과정을 통해 이러한 보장을 제공합니다.
다음 예를 고려해 보세요.

```swift
import Foundation

final class Printer {
    var value: Int
    init(value: Int) { self.value = value }
    func print() { Swift.print(value) }
}

func printTest() {
    var printer: Printer
    if .random() {
        printer = Printer(value: 1)
    }
    else {
        printer = Printer(value: 2)
    }
    printer.print()
}

printTest()
```

이 코드는 컴파일되고 잘 실행됩니다.
하지만 else 절을 주석 처리하면, 컴파일러는 SIL 덕분에 올바르게 오류를 표시합니다(변수 'printer'가 초기화되기 전에 사용됨.)
이 오류는 **`SIL`** 이 **`Printer`** 에 대한 메소드 호출의 의미론을 이해하기 때문에 가능합니다.

## Allocation and devirtualization

SILGen은 할당과 메소드 호출의 최적화를 돕습니다.
아래의 코드를 봐봅시다.

```swift
import Foundation

class Magic {
    func number() -> Int { return 0 }
}

final class SpecialMagic: Magic {
    override func number() -> Int { return 42 }
}

public var number: Int = -1

func magicTest() {
    let specialMagic = SpecialMagic()
    let magic: Magic = specialMagic
    number = magic.number()
}
```

이 코드는 숫자를 설정하기 위한 가장 인위적인 예시일 것입니다.
magicTest 함수에서 SpecialMagic 타입을 생성한 다음, 
기본 클래스 참조에 할당하고 전역 숫자를 설정하기 위해 number()를 호출합니다.
개념적으로, 이것은 클래스의 가상 테이블을 사용하여 올바른 함수를 찾아내고, 그 함수는 42라는 값을 반환합니다.

## Raw SIL

터미널 창에서 `magic.swift`가 있는 소스 디렉토리로 변경하고 다음 명령을 실행합니다.

```shell
swift -O -emit-silgen magic.swift > magic.rawsil
```

이렇게 하면 Swift 컴파일러가 최적화되어 실행되고 Raw(원시) SIL이 생성되어 `magic.rawsil` 파일로 출력됩니다.

당황하디 말고 심호흡을 하고 텍스트 편집기에서 `magic.rawsil`을 엽니다.

아래쪽으로 스크롤을 내리면 `magicTest()` 함수에 대한 이 정의를 찾을 수 있습니다.

```rawsil
// magicTest()
sil hidden [ossa] @$s5magic0A4TestyyF : $@convention(thin) () -> () {
bb0:
  %0 = global_addr @$s5magic6numberSivp : $*Int   // user: %12
  %1 = metatype $@thick SpecialMagic.Type         // user: %3
  // function_ref SpecialMagic.__allocating_init()
  %2 = function_ref @$s5magic12SpecialMagicCACycfC : $@convention(method) (@thick SpecialMagic.Type) -> @owned SpecialMagic // user: %3
  %3 = apply %2(%1) : $@convention(method) (@thick SpecialMagic.Type) -> @owned SpecialMagic // users: %18, %4
  %4 = begin_borrow [lexical] %3 : $SpecialMagic  // users: %17, %6, %5
  debug_value %4 : $SpecialMagic, let, name "specialMagic" // id: %5
  %6 = copy_value %4 : $SpecialMagic              // user: %7
  %7 = upcast %6 : $SpecialMagic to $Magic        // users: %16, %8
  %8 = begin_borrow [lexical] %7 : $Magic         // users: %15, %11, %10, %9
  debug_value %8 : $Magic, let, name "magic"      // id: %9
  %10 = class_method %8 : $Magic, #Magic.number : (Magic) -> () -> Int, $@convention(method) (@guaranteed Magic) -> Int // user: %11
  %11 = apply %10(%8) : $@convention(method) (@guaranteed Magic) -> Int // user: %13
  %12 = begin_access [modify] [dynamic] %0 : $*Int // users: %14, %13
  assign %11 to %12 : $*Int                       // id: %13
  end_access %12 : $*Int                          // id: %14
  end_borrow %8 : $Magic                          // id: %15
  destroy_value %7 : $Magic                       // id: %16
  end_borrow %4 : $SpecialMagic                   // id: %17
  destroy_value %3 : $SpecialMagic                // id: %18
  %19 = tuple ()                                  // user: %20
  return %19 : $()                                // id: %20
} // end sil function '$s5magic0A4TestyyF'
```

위 코드는 `magicTest()` 함수의 세 줄에 대한 **`SIL`** 정의입니다.

레이블 bb0은 기본 블록 0을 의미하며, 계산의 단위입니다.(**`if/else`** 문이 있었다면, 각 가능한 경로에 대해 **`bb1과 bb2`** 라는 두 개의 기본 블록이 생성됩니다.)

**`%1, %2`** 등의 값들은 가상 레지스터입니다.

SIL은 단일 정적 할당 형식이므로 레지스터는 무제한이며 재사용되지 않습니다.

여기 논의에 중요하지 않은 더 많은 작은 세부 사항들이 있습니다.

이것을 읽으면서, 객체의 할당, 할당, 호출 및 해제가 어떻게 이루어지는지 대략적으로 알 수 있어야 합니다.

이것은 Swift 언어의 전체 의미론을 표현합니다.

## Canonical SIL

Canonical(정규) SIL은 최적화를 포함하며, -Onone으로 최적화를 끌 때 최소한의 최적화 패스 세트를 포함합니다.

아래 명령어를 실행해보세요.

```shell
swift -O -emit-sil magic.swift > magic.sil
```

이 명령은 정규 SIL이 포함된 **magic.sil** 파일을 생성합니다.

파일 끝으로 스크롤하여 **`magicTest()`** 를 찾습니다.

```sil
// magicTest()
sil hidden @$s5magic0A4TestyyF : $@convention(thin) () -> () {
[global: write,deinit_barrier]
bb0:
  %0 = global_addr @$s5magic6numberSivp : $*Int   // user: %3
  %1 = integer_literal $Builtin.Int64, 42         // user: %2
  %2 = struct $Int (%1 : $Builtin.Int64)          // user: %4
  %3 = begin_access [modify] [dynamic] [no_nested_conflict] %0 : $*Int // users: %4, %5
  store %2 to %3 : $*Int                          // id: %4
  end_access %3 : $*Int                           // id: %5
  %6 = tuple ()                                   // user: %7
  return %6 : $()                                 // id: %7
} // end sil function '$s5magic0A4TestyyF'

```

위 코드는 원시 SIL보다 훨씬 간결하지만 동일한 것을 나타냅니다.
주요 작업은 정수 리터럴 42를 전역 주소 위치 `store %2 to %3: $*Int` 에 저장하는 것입니다.

클래스는 초기화되거나 해제되지 않으며, 가상 메소드도 호출되지 않습니다.
구조체는 스택을 사용하고 클래스는 힙을 사용한다는 것을 들을 때, 이것이 일반화라는 것을 명심하세요.

**"Swift에서 모든 것은 힙에 초기화되어 시작되며, SIL 분석을 통해 할당을 스택으로 이동시키거나 전혀 없애버릴 수 있습니다."**

"가상 함수 호출도 최적화 과정을 통해 비가상화될 수 있으며, 직접 호출되거나 심지어 인라인될 수 있습니다."
