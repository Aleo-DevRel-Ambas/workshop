program auction.aleo;

record Bid:
    owner as address.private;
    bidder as address.private;
    amount as u64.private;
    is_winner as boolean.private;
    auction_id as field.private;

struct Auction:
    runner as address;
    title as field;
    complete as boolean;


mapping auctions:
	key as field.public;
	value as Auction.public;


function init_auction:
    input r0 as field.private;
    hash.bhp256 r0 into r1 as field;
    async init_auction self.caller r0 r1 into r2;
    output r1 as field.private;
    output r2 as auction.aleo/init_auction.future;

finalize init_auction:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as field.public;
    cast r0 r1 false into r3 as Auction;
    get.or_use auctions[r2] r3 into r4;
    is.eq r4 r3 into r5;
    branch.eq r5 false to end_then_0_0;
    set r3 into auctions[r2];
    branch.eq true true to end_otherwise_0_1;
    position end_then_0_0;
    position end_otherwise_0_1;



function place_bid:
    input r0 as address.private;
    input r1 as u64.private;
    input r2 as field.private;
    input r3 as address.private;
    assert.eq self.caller r0;
    cast r3 r0 r1 false r2 into r4 as Bid.record;
    output r4 as Bid.record;


function resolve:
    input r0 as Bid.record;
    input r1 as Bid.record;
    assert.eq self.caller aleo1fxs9s0w97lmkwlcmgn0z3nuxufdee5yck9wqrs0umevp7qs0sg9q5xxxzh;
    gte r0.amount r1.amount into r2;
    is.eq r0.auction_id r1.auction_id into r3;
    and r2 r3 into r4;
    ternary r4 r0.owner r1.owner into r5;
    ternary r4 r0.bidder r1.bidder into r6;
    ternary r4 r0.amount r1.amount into r7;
    ternary r4 r0.is_winner r1.is_winner into r8;
    ternary r4 r0.auction_id r1.auction_id into r9;
    cast r5 r6 r7 r8 r9 into r10 as Bid.record;
    output r10 as Bid.record;



function finish:
    input r0 as Bid.record;
    input r1 as field.private;
    input r2 as address.private;
    assert.eq self.caller r2;
    cast r0.bidder r0.bidder r0.amount true r1 into r3 as Bid.record;
    async finish r1 into r4;
    output r3 as Bid.record;
    output r4 as auction.aleo/finish.future;

finalize finish:
    input r0 as field.public;
    get auctions[r0] into r1;
    cast r1.runner r1.title true into r2 as Auction;
    set r2 into auctions[r0];

