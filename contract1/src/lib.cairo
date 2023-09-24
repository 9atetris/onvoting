// @dev Core Library Imports for the Traits outside the Starknet Contract
use starknet::ContractAddress;

#[starknet::interface]
trait VoteTrait<T> {
    fn get_vote_status(self: @T) -> (u8, u8, u8, u8);
    fn voter_can_vote(self: @T, user_address: ContractAddress) -> bool;
    //voterをのちに登録できるようにする
    //voter登録->can_vote?
    fn is_voter_registered(self: @T, address: ContractAddress) -> bool;
    fn vote(ref self: T, vote: u8);
}

#[starknet::contract]
mod Votingcode {
    use starknet::ContractAddress;
    use starknet::get_caller_address;

    const YES: u8 = 1_u8;
    const NO: u8 = 0_u8;

    #[storage]
    struct Storage {
        yes_votes: u8,
        no_votes: u8,
        can_vote: LegacyMap::<ContractAddress, bool>,
        registered_voter: LegacyMap::<ContractAddress, bool>,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        voter_1: ContractAddress,
        voter_2: ContractAddress,
        voter_3: ContractAddress
    ) {
        //can pass to _refister_voters?
        self._register_voters(voter_1, voter_2, voter_3);

        self.yes_votes.write(0_u8);
        self.no_votes.write(0_u8);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        VoteCast: VoteCast,
        UnauthorizedAttempt: UnauthorizedAttempt,
    }

    #[derive(Drop, starknet::Event)]
    struct VoteCast {
        voter: ContractAddress,
        vote: u8,
    }

    #[derive(Drop, starknet::Event)]
    struct UnauthorizedAttempt {
        unauthorised_address: ContractAddress,
    }

    #[external(v0)]
    impl VoteImpl of super::VoteTrait<ContractState> {
        fn get_vote_status(self: @ContractState) -> (u8, u8, u8, u8) {
            let (n_yes, n_no) = self._get_voting_result();
            //fill out percentage
            let (yes_percentage, no_percentage) = self._get_voting_result();
            return (n_yes, n_no, yes_percentage, no_percentage);
        }
        fn voter_can_vote(self: @ContractState, user_address: ContractAddress) -> bool {
            self.can_vote.read(user_address)
        }
        fn is_voter_registered(self: @ContractState, address: ContractAddress) -> bool {
            self.registered_voter.read(address)
        }
        fn vote(ref self: ContractState, vote: u8) {
            assert(vote == NO || vote == YES, 'VOTE_0_OR_1');
            let caller: ContractAddress = get_caller_address();
            self._assert_allowed(caller);
            self.can_vote.write(caller, false);

            if (vote == NO) {
                self.no_votes.write(self.no_votes.read() + 1_u8);
            }
            if (vote == YES) {
                self.yes_votes.write(self.yes_votes.read() + 1_u8);
            }

            self.emit(VoteCast { voter: caller, vote: vote, });
        }
    }

    #[generate_trait]
    impl InternalFunctions of InternalFunctionsTrait {
        //これを外部から呼び出せるようにする
        fn _register_voters(
            ref self: ContractState,
            voter_1: ContractAddress,
            voter_2: ContractAddress,
            voter_3: ContractAddress
        ) {
            self.registered_voter.write(voter_1, true);
            self.can_vote.write(voter_1, true);

            self.registered_voter.write(voter_2, true);
            self.can_vote.write(voter_2, true);

            self.registered_voter.write(voter_3, true);
            self.can_vote.write(voter_3, true);
        }
    }
    #[generate_trait]
    impl AssertsImpl of AssertsTrait {
        fn _assert_allowed(ref self: ContractState, address: ContractAddress) {
            let is_voter: bool = self.registered_voter.read((address));
            let can_vote: bool = self.can_vote.read((address));

            if (can_vote == false) {
                self.emit(UnauthorizedAttempt { unauthorised_address: address, });
            }

            assert(is_voter == true, 'USER_NOT_REGISTERED');
            assert(can_vote == true, 'USER_ALREADY_VOTED');
        }
    }
    #[generate_trait]
    impl VoteResultFunctionsImpl of VoteResultFunctionsTrait {
        fn _get_voting_result(self: @ContractState) -> (u8, u8) {
            let n_yes: u8 = self.yes_votes.read();
            let n_no: u8 = self.no_votes.read();

            return (n_yes, n_no);
        }
    }

    fn _get_voting_result_in_percentage(self: @ContractState) -> (u8, u8) {
        let n_yes: u8 = self.yes_votes.read();
        let n_no: u8 = self.no_votes.read();

        let total_votes: u8 = n_yes + n_no;

        let yes_percentage: u8 = (n_yes * 100_u8) / (total_votes);
        let no_percentage: u8 = (n_no * 100_u8) / (total_votes);

        return (yes_percentage, no_percentage);
    }
}
