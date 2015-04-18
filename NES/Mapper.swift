import Foundation

public protocol Mapper {
    func read(address: Address) -> UInt8

    mutating func write(address: Address, _ value: UInt8)
}

public typealias Mapper000 = Mapper002

public struct Mapper002: Mapper {
    private var cartridge: Cartridge

    private var PRGBanks: (Int, Int)

    private let numberOfBanks: Int

    public init(cartridge: Cartridge) {
        self.cartridge = cartridge

        numberOfBanks = cartridge.PRGROM.count / 0x4000
        PRGBanks = (0, numberOfBanks - 1)
    }

    public func read(address: Address) -> UInt8 {
        switch Int(address) {
        case 0x0000..<0x2000:
            return cartridge.CHRROM[Int(address)]
        case 0x2000..<0x6000:
            fatalError("Unhandled mapper address \(address)")
        case 0x6000..<0x8000:
            let SRAMAddress = Int(address - 0x6000)
            return cartridge.SRAM[SRAMAddress]
        case 0x8000..<0xC000:
            let PRGAddress = PRGBanks.0 * 0x4000 + Int(address - 0x8000)
            return cartridge.PRGROM[PRGAddress]
        case 0xC000..<0x10000:
            let PRGAddress = (PRGBanks.1 * Int(0x4000)) + (Int(address) - Int(0xC000))
            return cartridge.PRGROM[PRGAddress]
        default:
            fatalError("Unhandled mapper address \(address)")
        }
    }

    public mutating func write(address: Address, _ value: UInt8) {
        switch Int(address) {
        case 0x0000..<0x2000:
            cartridge.CHRROM[Int(address)] = value
        case 0x2000..<0x6000:
            fatalError("Unhandled mapper address \(address)")
        case 0x6000..<0x8000:
            let SRAMAddress = Int(address - 0x6000)
            cartridge.SRAM[SRAMAddress] = value
        case 0x8000..<0x10000:
            PRGBanks.0 = Int(value) % numberOfBanks
        default:
            fatalError("Unhandled mapper address \(address)")
        }
    }
}