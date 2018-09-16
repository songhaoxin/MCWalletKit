public final class HDWallet {
    
    private let masterPrivateKey: HDPrivateKey
    private let network: Network
    
    public init(seed: Data, network: Network) {
        self.masterPrivateKey = HDPrivateKey(seed: seed, network: network)
        self.network = network
    }
    
    // MARK: - Public Methods
    
    public func generatePrivateKey(at index: UInt32) throws -> PrivateKey {
        return try privateKey(change: .external).derived(at: index).privateKey()
    }
    
    
    public func generatePrivateKey(coin:Coin) throws -> PrivateKey {    //Add by songmj
        return try privateKey(coin: coin).derived(at: 0).privateKey()
    }
    
    public func generatePrivateKey(coin:Coin,index:UInt32) throws -> PrivateKey { //Add by songmj
        return try privateKey(coin: coin).derived(at: index).privateKey()
    }
   
    
    public func generateAddress(at index: UInt32) throws -> String {
        return try generatePrivateKey(at: index).publicKey.generateAddress()
    }
    
    
    public func generateAddress(coin:Coin) throws -> String {   //Add by songmj
        return try generatePrivateKey(coin: coin).publicKey.generateAddress()
    }
    

    
    public func mainAddress() throws -> String {
        return self.masterPrivateKey.hdPublicKey().publicKey().generateAddress()
    }
    
    
    public func dumpPrivateKey(at index: UInt32) throws -> String {
        return try generatePrivateKey(at: index).raw.toHexString()
    }
    
    public func dumpPrivateKey(coin:Coin) throws -> String { //Add by songmj
        return try generatePrivateKey(coin: coin).raw.toHexString()
    }
    
    public func dumpMainPrivateKey() -> String { //Add by songmj
        return  self.masterPrivateKey.raw.toHexString()
    }
    
 
    // MARK: - Private Methods
    
    // Ethereum only uses external.
    private enum Change: UInt32 {
        case external = 0
        case `internal` = 1
    }
    
    // m/44'/coin_type'/0'/external
    private func privateKey(change: Change) throws -> HDPrivateKey {
        return try masterPrivateKey
            .derived(at: 44, hardens: true)
            .derived(at: network.coinType, hardens: true)
            .derived(at: 0, hardens: true)
            .derived(at: change.rawValue)
    }
    
 
    // m/44'/coin_type'  add by songmj
    private func privateKey(coin:Coin) throws -> HDPrivateKey {
        return try masterPrivateKey
            .derived(at: 44, hardens: true)
            .derived(at: coin.rawValue,hardens: true)
            .derived(at: 0,hardens: true)
            .derived(at: 0)
    }
}
