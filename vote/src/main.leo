// The 'vote.aleo' program.
program vote.aleo {
    // Proposal details
    struct ProposalInfo {
        title: field,
        content: field,
        proposer: address,
    }

    // Proposal record records proposal info publicly
    record Proposal {
        owner: address,
        id: field,
        info: ProposalInfo,
    }

    // Save proposal info in public storage.
    mapping proposals: field => ProposalInfo;

    // Privacy tickets to vote
    record Ticket {
        owner: address,
        pid: field,
    }

    // Count the total tickets issued for each proposal
    mapping tickets: field => u64;

    mapping agree_votes: field => u64;

    mapping disagree_votes: field => u64;

    // Propose a new proposal to vote on.
    async transition propose(public info: ProposalInfo) -> (Proposal, Future) {
        // Authenticate proposer.
        assert_eq(self.caller, info.proposer);

        // Generate a new proposal id.
        let id: field = BHP256::hash_to_field(info.title);

        let proposal: Proposal = Proposal {
            owner: self.caller,
            id,
            info,
        };

        // Return a new record for the proposal.
        // Finalize the proposal id.
        return (proposal, propose_public_execution(id));
    }

    // Create a new proposal in the "tickets" mapping.
    async function propose_public_execution(id: field) {
        Mapping::set(tickets, id, 0u64);
    }

    // Create a new ticket to vote with.
    async transition new_ticket(
        public pid: field,
        public voter: address,
    ) -> (Ticket, Future) {

        let ticket: Ticket = Ticket {
            owner: voter,
            pid,
        };
        // Finalize the proposal id for the ticket.
        return (ticket, new_ticket_pub_exec(pid));
    }

    async function new_ticket_pub_exec(pid: field) {
        let current: u64 = Mapping::get_or_use(tickets, pid, 0u64);
        Mapping::set(tickets, pid, current + 1u64);
    }

    // Vote privately
    async transition vote(ticket: Ticket, agree: bool) -> Future {
        // Finalize this vote.
        return vote_public_execution(ticket.pid, agree);
    }

    async function vote_public_execution(pid: field, agree: bool) {
        if agree {
            // Publicly increment the number of agree votes.
            let current: u64 = Mapping::get_or_use(agree_votes, pid, 0u64);
            Mapping::set(agree_votes, pid, current + 1u64);
        } else {
            // Publicly increment the number of disagree votes.
            let current: u64 = Mapping::get_or_use(disagree_votes, pid, 0u64);
            Mapping::set(disagree_votes, pid, current + 1u64);
        }
    }

}
