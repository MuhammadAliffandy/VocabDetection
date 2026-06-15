import Foundation

class Module {
    public init() {}
}

@propertyWrapper
struct ModuleInfo<T> {
    var wrappedValue: T
    init(key: String) { fatalError() }
}

@MainActor
class SubModule: Module {
    @ModuleInfo(key: "A") var a: Int
    init(args: Int) {
        self._a = ModuleInfo(key: "A")
        super.init()
    }
}
