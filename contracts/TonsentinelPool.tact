import "@stdlib/deploy";

message PlacePrediction {
    queryId: Int as uint64;
    outcomeYes: Bool;
    amount: Int as coins;
}

message ResolveMarket {
    queryId: Int as uint64;
    winningOutcome: Bool;
}

message ClaimReward {
    queryId: Int as uint64;
}

contract TonsentinelPool with Deployable {
    owner: Address;
    marketId: Int as uint32;
    resolved: Bool;
    winningOutcome: Bool;
    totalYes: Int as coins;
    totalNo: Int as coins;

    init(owner: Address, marketId: Int as uint32) {
        self.owner = owner;
        self.marketId = marketId;
        self.resolved = false;
        self.winningOutcome = false;
        self.totalYes = 0;
        self.totalNo = 0;
    }

    receive(msg: PlacePrediction) {
        require(!self.resolved, "Market already resolved");
        let ctx: Context = context();
        require(ctx.value >= msg.amount, "Insufficient TON sent");

        if (msg.outcomeYes) {
            self.totalYes = self.totalYes + msg.amount;
        } else {
            self.totalNo = self.totalNo + msg.amount;
        }
    }

    receive(msg: ResolveMarket) {
        let ctx: Context = context();
        require(ctx.sender == self.owner, "Only contract owner can resolve");
        require(!self.resolved, "Market is already resolved");
        self.resolved = true;
        self.winningOutcome = msg.winningOutcome;
    }

    get fun getMarketInfo(): (Int, Bool, Bool, Int, Int) {
        return (self.marketId, self.resolved, self.winningOutcome, self.totalYes, self.totalNo);
    }
}
