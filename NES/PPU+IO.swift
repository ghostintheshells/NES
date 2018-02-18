import Foundation

internal enum MirroringMode: Int {
    case horizontal = 0
    case vertical = 1
    case firstScreen = 2
    case secondScreen = 3
}

extension PPU: IO {
    @discardableResult
    func read(_ address: Address) -> UInt8 {
        let wrappedAddress = address % 0x4000

        switch wrappedAddress {
        case 0x0000 ..< 0x2000:
            return mapper.read(wrappedAddress)
        case 0x2000 ..< 0x3F00:
            let mirrored = mirrorVRAM(wrappedAddress)

            return vram[mirrored]
        case 0x3F00 ..< 0x4000:
            let mirrored = mirrorPalette(wrappedAddress)

            return palette[mirrored]
        default:
            fatalError("Attempt to read illegal PPU memory address \(format(address)).")
        }
    }

    func write(_ address: Address, _ value: UInt8) {
        let wrappedAddress = address % 0x4000

        switch wrappedAddress {
        case 0x0000 ..< 0x2000:
            mapper.write(wrappedAddress, value)
        case 0x2000 ..< 0x3F00:
            let mirrored = mirrorVRAM(wrappedAddress)

            vram[mirrored] = value
        case 0x3F00 ..< 0x4000:
            let mirrored = mirrorPalette(wrappedAddress)

            palette[mirrored] = value
        default:
            fatalError("Attempt to wirte illegal PPU memory address \(format(address)).")
        }
    }

    private static let mirroringLookupTable: [[UInt16]] = [
        [0, 0, 1, 1],
        [0, 1, 0, 1],
        [0, 0, 0, 0],
        [1, 1, 1, 1]
    ]

    internal func mirrorVRAM(_ address: Address, mirroringMode: MirroringMode = .horizontal) -> Address {
        let wrappedAddress = (address - 0x2000) % 0x1000
        let table = wrappedAddress / 0x0400
        let offset = wrappedAddress % 0x0400

        return PPU.mirroringLookupTable[mirroringMode.rawValue][table] * 0x0400 + offset
    }

    internal func mirrorPalette(_ address: Address) -> Address {
        return address % 32
    }
}
