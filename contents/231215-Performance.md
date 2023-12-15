# Performance 🤿

최적화 컴파일러로 프로그램을 작성하는 것의 멋진 점 중 하나는 코드를 명확하고 유지보수하기 쉽게 만드는 추상화 비용이 종종 없거나 거의 없다는 것입니다.

여기에서 어떻게 했는지 확인하려면, 아래의 코드를 `ifelse.swift`라는 텍스트 파일에 넣어세요.

```swift
@inlinable
func ifelse<V>(_ condition: Bool,
               _ valueTrue: @autoclosure () throws -> V,
               _ valueFalse: @autoclosure () throws -> V) rethrows -> V {
  condition ? try valueTrue() : try valueFalse()
}

func ifelseTest1() -> Int {
  if .random() {
      return 100
  } else {
      return 200
  }
}

func ifelseTest2() -> Int {
  Bool.random() ? 300 : 400
}

func ifelseTest3() -> Int {
  ifelse(.random(), 500, 600)
}
```

위 코드를 가져와서 아래 명령을 사용하여 컴파일러를 직접 실행해봅시다.

```shell
swiftc -O -emit-assmbly ifelse.swift > ifelse.asm
```

깊게 숨을 들이마시고 어셈블리 파일을 열어보세요.
이 어셈블리 파일들은 호출 규칙과 진입점 주변에 많인 보일러플레이트 코드를 포함하고 있다는 것을 기억하세요.
그것이 당신이 살펴보는 것을 막지 않도록 하세요.
필요 없는 부분을 제외하고, 아래 코드를 봐봅시다.

```asm
_$s6ifelse0A5Test1SiyF:
    :
    callq   _swift_stdlib_random
    testl   $131072, -8(%rbp)
    movl    $100, %ecx
    movl    $200, %eax
    cmoveq  %rcx, %rax
    :

_$s6ifelse0A5Test2SiyF:
    :
    callq   _swift_stdlib_random
    testl   $131072, -8(%rbp)
    movl    $300, %ecx
    movl    $400, %eax
    cmoveq  %rcx, %rax
    :

_$s6ifelse0A5Test3SiyF:    
    :    
    callq   _swift_stdlib_random
    testl   $131072, -8(%rbp)
    movl    $500, %ecx
    movl    $600, %eax
    cmoveq  %rcx, %rax
    :
```

이것들은 세 개의 테스트 함수에 대한 어셈블리 명령어들입니다.
이것이 당신에게 이해할 수 없는 기호처럼 보일 수도 있습니다.
중요한 것은 `ifelseTest1()`, `ifelseTest2()`, `ifelseTest3()` 에 대한 같은 기호들이라는 것입니다.
다시 말해서, 코드를 작성하는 세 가지 방식에 대해 추상화의 비용이 전혀 없다는 것입니다.
당신에게 가장 아름답게 보이는 것을 선택하세요.

이제 위의 어셈블리를 해석해보면, `callq` 명령어는 무작위 숫자를 얻기 위해 함수를 호출합니다.
다음으로, `testl` 명령어는 무작위 숫자 반환값을 가져옵니다.(64비트 기본 포인터 - 8에 의해 가리키는 주소에 위치함.)
이는 `131072` 즉, `0x20000` 또는 17번째 비트와 비교됩니다.
`Bool.random`에 대한 Swift 소스를 살펴보면 다음과 같습니다.

```swift
@inlinable
public static func random<T: RandomNumberGenerator>(
    using generator: inout T
) -> Bool {
    return (generator.next() >> 17) & 1 == 0
}
```

이것은 `131072`의 미스터리를 설명해 줍니다.
17번째 비트를 이동시키고, 마스킹하고, 한 명령어로 모두 테스트합니다.
다음으로 함수의 두 가지 가능한 결과 값이 `movl` 명령어를 사용하여 `cx` 와 `ax` 레지스터로 이동됩니다.
접두사 `"e"`는 레지스터의 확장된 `32비트` 버전을 나타냅니다.
나머지 비트들을 모든 64비트를 채우기 위해 제로-확장됩니다.
마지막으로, "조건부 이동(만약 같다면)" 또는 `cmoveq` 명령어는 이전 테스트 명령어의 결과를 사용하여 `cx` 레지스터를 `ax` 레지스터로 이동합니다.
`rcx`와 `rax`에 붙은 접두사 `r`은 레지스터의 전체 `64비트`를 사용한다는 것을 나타냅니다.

> 📝 Note
> 
> 맹글링된 심볼 `_$s6ifelse0A5Test1SiyF` 는 `ifelse.ifelseTest1() -> Int`의 고유 심볼 이름입니다.
> (앞의 `"ifelse."`는 모듈 이름이거나 이 경우 파일 이름입니다.)
> 
> 링커는 프로그램의 모든 외부 심볼에 대해 짧고, 보장된 고유 이름이 필요합니다.
> 
> 맹글링에 대한 사양은 여기에서 찾을 수 있습니다: https://github.com/apple/swift/blob/main/docs/ABI/Mangling.rst
> 
> 또한 `/Library/Developer/CommandLineTools/usr/bin/` 에 있는 커맨드 라인 도구 `swift-demangle`을 실행할 수도 있습니다.
> 
> 예를 들어, `swift-demangle _$s6ifelseAAyxSb_xyKXKxyKXKtKlF`는 심볼 `ifelse.ifelse<A>(Swift.Bool, @autoclosure () throws -> A, @autoclosure () throws -> A) throws -> A`에 해당합니다.

이것으로 `ifelse`에 대한 논의와 구현이 완료됩니다.
스위프트 코어 팀 멤버인 존 맥콜이 제시한 질문을 던저보는 것이 좋습니다.
**"이것은 스스로의 가치를 지불하는 추상화인가요?"** 이 경우에는 아마도 그렇지 않습니다.
삼항 연산자가 이미 존재하는데, 이것은 본질적으로 동일한 기능을 수행합니다.
**그럼에도 불구하고, 이 예제를 통해 라이브러리의 일부로 언어와 같은 기능을 구축할 때 스위프트가 제공하는 기능을 상기시켜줄 수 있기를 바랍니다.**
